$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$executable = Join-Path $repositoryRoot 'cli\dist\TriadDesktop.exe'

if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
    throw "Desktop executable not found: $executable"
}

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -Namespace TriadSmoke -Name NativeMethods -MemberDefinition @'
    [System.Runtime.InteropServices.DllImport("user32.dll", EntryPoint = "SendMessageW")]
    public static extern System.IntPtr SendMessage(
        System.IntPtr window, uint message, System.IntPtr wParam, System.IntPtr lParam);

    [System.Runtime.InteropServices.DllImport("user32.dll", EntryPoint = "SendMessageW", CharSet = System.Runtime.InteropServices.CharSet.Unicode)]
    public static extern System.IntPtr SendMessageText(
        System.IntPtr window, uint message, System.IntPtr wParam, System.Text.StringBuilder text);
'@

$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($executable)
if ($null -eq $icon) {
    throw 'Desktop executable does not contain an application icon'
}

$process = Start-Process -FilePath $executable -WorkingDirectory $repositoryRoot -PassThru
try {
    $window = $null
    $condition = [System.Windows.Automation.PropertyCondition]::new(
        [System.Windows.Automation.AutomationElement]::ProcessIdProperty,
        $process.Id
    )
    $deadline = [DateTime]::UtcNow.AddSeconds(15)

    while ($null -eq $window -and [DateTime]::UtcNow -lt $deadline) {
        $window = [System.Windows.Automation.AutomationElement]::RootElement.FindFirst(
            [System.Windows.Automation.TreeScope]::Children,
            $condition
        )
        if ($null -eq $window) {
            Start-Sleep -Milliseconds 200
        }
    }

    if ($null -eq $window) {
        throw 'Desktop application did not open a window'
    }
    $expectedTitle = 'Triad 2.0 ' + [char]0x2014 + ' CLI'
    if ($window.Current.Name -ne $expectedTitle) {
        throw "Unexpected window title: $($window.Current.Name)"
    }

    $statusButton = $window.FindFirst(
        [System.Windows.Automation.TreeScope]::Descendants,
        [System.Windows.Automation.PropertyCondition]::new(
            [System.Windows.Automation.AutomationElement]::NameProperty,
            'Stato'
        )
    )
    if ($null -eq $statusButton) {
        throw 'Status action is not available in the desktop window'
    }

    if (-not $statusButton.Current.IsEnabled) {
        throw 'Status action is not enabled'
    }
    $buttonHandle = [IntPtr]$statusButton.Current.NativeWindowHandle
    if ($buttonHandle -eq [IntPtr]::Zero) {
        throw 'Status action does not expose a native button handle'
    }
    [TriadSmoke.NativeMethods]::SendMessage($buttonHandle, 0x00F5, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null

    $output = $window.FindAll(
        [System.Windows.Automation.TreeScope]::Descendants,
        [System.Windows.Automation.Condition]::TrueCondition
    ) | Where-Object { $_.Current.ClassName -match 'RichEdit' } | Select-Object -First 1
    if ($null -eq $output) {
        throw 'Output console is missing from the desktop window'
    }
    $outputHandle = [IntPtr]$output.Current.NativeWindowHandle
    if ($outputHandle -eq [IntPtr]::Zero) {
        throw 'Output console does not expose a native text handle'
    }

    $outputDeadline = [DateTime]::UtcNow.AddSeconds(15)
    $text = ''
    while ($text -notmatch 'Triad 2\.0 CLI Status' -and [DateTime]::UtcNow -lt $outputDeadline) {
        $buffer = [System.Text.StringBuilder]::new(8192)
        [TriadSmoke.NativeMethods]::SendMessageText(
            $outputHandle,
            0x000D,
            [IntPtr]$buffer.Capacity,
            $buffer
        ) | Out-Null
        $text = $buffer.ToString()
        if ($text -notmatch 'Triad 2\.0 CLI Status') {
            Start-Sleep -Milliseconds 200
        }
    }
    if ($text -notmatch 'Triad 2\.0 CLI Status') {
        throw 'The status action did not return CLI output'
    }

    Write-Output 'PASS: app opens with the Triad logo and the Status action works.'
}
finally {
    if ($null -ne $window) {
        try {
            $window.GetCurrentPattern([System.Windows.Automation.WindowPattern]::Pattern).Close()
        }
        catch {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }
    }
    if (-not $process.HasExited) {
        $process.WaitForExit(5000) | Out-Null
    }
    if (-not $process.HasExited) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }
}
