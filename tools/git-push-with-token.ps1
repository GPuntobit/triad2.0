# tools/git-push-with-token.ps1
# Automatizza git add/commit/push autenticandosi con un token GitHub.
#
# Ordine di ricerca del token:
#   1. variabile d'ambiente GITHUB_TOKEN (consigliata: nessun token su disco)
#   2. %USERPROFILE%\.git-credentials (git credential store, FUORI dal repository)
#   3. .git-credentials nella root del repository (legacy: emette un avviso)
#
# Sicurezza (finding #6, docs/security/SECURITY-REVIEW.md):
#   - il token NON viene mai inserito nell'URL del remote: non finisce in
#     .git/config, negli errori di git o nei log. L'autenticazione passa da un
#     helper `credential.helper` usa-e-getta che vive solo per il push e legge
#     il token dall'ambiente di questo processo;
#   - `git add -A` esclude esplicitamente .git-credentials: un token reale non
#     puo' essere committato nemmeno se .gitignore regredisce.
#
# Uso:
#   .\tools\git-push-with-token.ps1 -Message "feat: ..." [-Branch main]
#
# Prerequisiti:
#   - GITHUB_TOKEN in ambiente, oppure un file credenziali (vedi
#     .git-credentials.example).

param(
    [string]$Message = "chore: update",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

# --- risoluzione del token --------------------------------------------------
# Estrae il token da una riga in formato git credential store:
#   https://<utente>:<token>@github.com   (consigliato)
#   https://<token>@github.com            (legacy)
# Ritorna $null per file mancanti, righe di commento e placeholder (<...>).
function Get-TokenFromStore([string]$path) {
    if (-not (Test-Path $path)) { return $null }
    $line = Get-Content $path | Where-Object { $_ -match '^https://[^@/]+@github\.com/?$' } | Select-Object -First 1
    if (-not $line) { return $null }
    $userinfo = ($line -replace '^https://', '' -split '@')[0]
    $parts = $userinfo -split ':', 2
    $candidate = if ($parts.Count -eq 2 -and $parts[1]) { $parts[1] } else { $parts[0] }
    # placeholder o riga malformata: nessun token utilizzabile
    if ($candidate -notmatch '^[A-Za-z0-9_]+$') { return $null }
    return $candidate
}

$storePath = Join-Path $env:USERPROFILE '.git-credentials'
$legacyPath = Join-Path $repoRoot '.git-credentials'

$token = $null
if ($env:GITHUB_TOKEN) {
    $token = $env:GITHUB_TOKEN
} else {
    $token = Get-TokenFromStore $storePath
    if (-not $token) {
        $token = Get-TokenFromStore $legacyPath
        if ($token) {
            Write-Warning "Token letto da .git-credentials nella root del repository (legacy). Spostalo in $storePath e lascia nel repository solo il placeholder."
        }
    }
}

if (-not $token) {
    Write-Error "Token GitHub non trovato. Imposta la variabile GITHUB_TOKEN oppure $storePath (vedi .git-credentials.example)."
    exit 1
}

# --- commit (con .git-credentials sempre escluso) ---------------------------
git add -A -- . ':(exclude).git-credentials'
$status = git status --porcelain
if ($status) {
    git commit -m $Message
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} else {
    Write-Host "Nessuna modifica da committare."
}

# --- push con credenziale usa-e-getta ---------------------------------------
# Il token vive solo nell'ambiente di questo processo: l'helper sh transitorio
# risponde username=x-access-token / password=<token> ai prompt di git e viene
# cancellato subito dopo. Il remote di origin resta quello senza credenziali.
$env:TRIAD_PUSH_TOKEN = $token
$env:GIT_TERMINAL_PROMPT = "0"
try {
    git -c "credential.helper=" `
        -c 'credential.helper=!f() { echo username=x-access-token; echo password=$TRIAD_PUSH_TOKEN; }; f' `
        push origin $Branch
    $pushExit = $LASTEXITCODE
} finally {
    Remove-Item Env:TRIAD_PUSH_TOKEN -ErrorAction SilentlyContinue
    Remove-Item Env:GIT_TERMINAL_PROMPT -ErrorAction SilentlyContinue
}
exit $pushExit
