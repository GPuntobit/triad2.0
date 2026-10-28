$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$executable = Join-Path $repositoryRoot 'cli\dist\TriadDesktop.exe'

if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
    throw "Desktop executable not found: $executable"
}

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($executable)
if ($null -eq $icon) {
    throw 'Desktop executable does not contain an application icon'
}

$process = Start-Process -FilePath $executable -PassThru
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
    if ($window.Current.Name -ne 'Triad 2.0 — CLI') {
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

    $statusButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke()
    $outputCondition = [System.Windows.Automation.PropertyCondition]::new(
        [System.Windows.Automation.AutomationElement]::NameProperty,
        'outputConsole'
    )
    $output = $window.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $outputCondition)
    if ($null -eq $output) {
        throw 'Output console is missing from the desktop window'
    }

    $textPattern = $output.GetCurrentPattern([System.Windows.Automation.TextPattern]::Pattern)
    $outputDeadline = [DateTime]::UtcNow.AddSeconds(15)
    $text = ''
    while ($text -notmatch 'Triad 2\.0 CLI Status' -and [DateTime]::UtcNow -lt $outputDeadline) {
        $text = $textPattern.DocumentRange.GetText(-1)
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
