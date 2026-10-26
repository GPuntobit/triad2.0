@echo off
:: Installazione estensione Triad per VS Code
set "EXT_SRC=c:\Users\xbos\Documents\progetti\triad2.0\editors\vscode"
set "EXT_DST=%APPDATA%\Code\User\extensions\triad"

echo ==========================================
echo Installazione estensione Triad per VS Code
echo ==========================================
echo.

if exist "%EXT_DST%" (
    rmdir /s /q "%EXT_DST%"
    echo Cartella vecchia rimossa.
) else (
    echo Nessuna cartella precedente trovata.
)

xcopy "%EXT_SRC%" "%EXT_DST%" /e /i /y
if %errorlevel% neq 0 (
    echo Errore nella copia della cartella.
    pause
    exit /b 1
)

echo Estensione copiata in: %EXT_DST%
echo.
echo Per attivare l'estensione:
echo 1. Riavvia VS Code (chiudi e riapri)
echo 2. Oppure premi Ctrl+Shift+P -> "Developer: Reload Window"
echo.
pause