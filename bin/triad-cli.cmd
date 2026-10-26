@echo off
rem triad-cli.cmd - launcher Windows della CLI di sviluppo (richiede Node.js >= 18).
rem Uso: triad-cli ^<comando^> [opzioni]   (es. triad-cli status)
rem Per usarlo da ovunque: aggiungere la cartella bin al PATH.
setlocal
set "TRIAD_HOME=%~dp0.."
where node >nul 2>nul
if errorlevel 1 (
    echo triad-cli: Node.js non trovato ^(serve Node.js ^>= 18^). >&2
    exit /b 1
)
if exist "%TRIAD_HOME%\cli\node_modules" goto :run
echo triad-cli: installo le dipendenze ^(npm install in cli\^)... >&2
pushd "%TRIAD_HOME%\cli"
call npm install --silent 1>&2
set "RC=%ERRORLEVEL%"
popd
if not "%RC%"=="0" (
    echo triad-cli: npm install fallito ^(codice %RC%^). >&2
    if exist "%TRIAD_HOME%\cli\node_modules" rmdir /s /q "%TRIAD_HOME%\cli\node_modules"
    exit /b %RC%
)
:run
node "%TRIAD_HOME%\cli\triad-cli.mjs" %*
exit /b %ERRORLEVEL%
