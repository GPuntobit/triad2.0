$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$source = Join-Path $PSScriptRoot 'TriadDesktop.cs'
$icon = Join-Path $PSScriptRoot 'triad.ico'
$outputDirectory = Join-Path $repositoryRoot 'cli\dist'
$output = Join-Path $outputDirectory 'TriadDesktop.exe'
$compilerCandidates = @(
    (Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'),
    (Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe')
)
$compiler = $compilerCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1

if (-not $compiler) {
    throw 'The .NET Framework C# compiler (csc.exe) was not found.'
}
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Desktop source not found: $source"
}
if (-not (Test-Path -LiteralPath $icon -PathType Leaf)) {
    throw "Application icon not found: $icon"
}

New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
$compilerArguments = @(
    '/nologo',
    '/target:winexe',
    "/out:$output",
    "/win32icon:$icon",
    '/reference:System.dll',
    '/reference:System.Drawing.dll',
    '/reference:System.Windows.Forms.dll',
    '/reference:System.Core.dll',
    $source
)

& $compiler @compilerArguments
if ($LASTEXITCODE -ne 0) {
    throw "C# compilation failed with exit code $LASTEXITCODE."
}

Write-Output "Built Windows desktop app: $output"
