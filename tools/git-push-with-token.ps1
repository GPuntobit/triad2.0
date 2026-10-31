# tools/git-push-with-token.ps1
# Automatizza git add/commit/push usando un token GitHub presente in .git-credentials
# (o nella variabile d'ambiente GITHUB_TOKEN).
#
# Uso:
#   .\tools\git-push-with-token.ps1 -Message "feat: ..." [-Branch main]
#
# Prerequisiti:
#   - Copia .git-credentials.example in .git-credentials e inserisci il token.

param(
    [string]$Message = "chore: update",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

# Risolvi il token
$token = $null
if ($env:GITHUB_TOKEN) {
    $token = $env:GITHUB_TOKEN
} elseif (Test-Path ".git-credentials") {
    $line = Get-Content ".git-credentials" | Where-Object { $_ -match 'https://.+@github\.com' } | Select-Object -First 1
    if ($line) {
        $token = ($line -replace 'https://', '' -split '@')[0]
    }
}

if (-not $token -or $token -eq "<GITHUB_TOKEN>") {
    Write-Error "Token GitHub non trovato. Inseriscilo in .git-credentials o nella variabile GITHUB_TOKEN."
    exit 1
}

$remoteWithToken = "https://${token}@github.com/GPuntobit/triad2.0.git"
$remoteClean = "https://github.com/GPuntobit/triad2.0.git"

try {
    git remote set-url origin $remoteWithToken
    git add -A
    $status = git status --porcelain
    if ($status) {
        git commit -m $Message
    } else {
        Write-Host "Nessuna modifica da committare."
    }
    git push origin $Branch
} finally {
    git remote set-url origin $remoteClean
    Write-Host "Remote ripristinato a URL senza token."
}
