<#
.SYNOPSIS
  Create a GitHub release for Triad 2.0 and attach the default download assets.

.DESCRIPTION
  Creates an annotated tag, pushes it, creates a GitHub release (pre-release by default)
  using the English release notes file, and uploads the three default download assets:
    - seed/windows-x86_64/seed.exe
    - cli/dist/triad-cli.exe
    - cli/dist/TriadDesktop.exe

.PARAMETER Version
  Release tag, e.g. v0.8.0-beta.8 or v0.9.0.

.PARAMETER NotesFile
  Path to the English release notes markdown. Defaults to docs/releases/RELEASE_NOTES_<Version>.md

.PARAMETER Stable
  Mark the release as stable (not a pre-release).

.EXAMPLE
  .\scripts\release.ps1 -Version v0.9.0
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [string]$NotesFile,

    [switch]$Stable
)

$ErrorActionPreference = 'Stop'
Set-Location (Resolve-Path (Join-Path $PSScriptRoot '..'))

if (-not $NotesFile) {
    $NotesFile = "docs/releases/RELEASE_NOTES_$Version.md"
}

# Default download assets (always attached to every release)
$assets = @(
    'seed/windows-x86_64/seed.exe',
    'cli/dist/triad-cli.exe',
    'cli/dist/TriadDesktop.exe'
)

foreach ($a in $assets) {
    if (-not (Test-Path $a)) {
        throw "Missing asset: $a (build it first)"
    }
}
if (-not (Test-Path $NotesFile)) {
    throw "Missing release notes: $NotesFile"
}

Write-Host "Creating tag $Version ..."
git tag -a $Version -m "Triad 2.0 - $Version"
git push origin $Version

Write-Host "Creating GitHub release ..."
$prereleaseFlag = if ($Stable) { '' } else { '--prerelease' }
gh release create $Version --title "Triad 2.0 - $Version" --notes-file $NotesFile $prereleaseFlag

Write-Host "Uploading default assets ..."
gh release upload $Version $assets

Write-Host "Done: https://github.com/GPuntobit/triad2.0/releases/tag/$Version"
