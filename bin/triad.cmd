@echo off
rem =====================================================================
rem  triad.cmd — launcher Windows per il linguaggio Triad
rem
rem  Cerca un runtime Triad in questo ordine:
rem    1. bin\triad-native.exe  (eseguibile standalone)
rem    2. seed\windows-x86_64\seed.exe  (interprete Triad-Core in codice macchina)
rem
rem  Does not depend on Julia or other host languages: execution of
rem  codice .triad avviene tramite il seed in codice macchina.
rem
rem  Uso: triad [opzioni] [file.td [argomenti...]]
rem        triad --help          tutte le opzioni
rem
rem  Per usarlo da ovunque: aggiungere questa cartella al PATH.
rem =====================================================================

setlocal DisableDelayedExpansion

set "TRIAD_HOME=%~dp0.."

rem --- Mode --build (no longer supported) ----------------------------
if "%~1"=="--build" goto :build_dev

rem --- Ricerca del runtime ---------------------------------------------
set "RUNTIME="
set "SEED="

rem 1. Eseguibile standalone
if exist "%TRIAD_HOME%\bin\triad-native.exe" (
    set "RUNTIME=standalone"
    goto :run
)

rem 2. Seed in codice macchina
if exist "%TRIAD_HOME%\seed\windows-x86_64\seed.exe" (
    set "SEED=%TRIAD_HOME%\seed\windows-x86_64\seed.exe"
    set "RUNTIME=seed"
    goto :run
)

rem --- Nessun runtime trovato ------------------------------------------
echo triad: runtime non trovato. >&2
echo. >&2
echo Opzioni: >&2
echo   1. Decodifica il seed in codice macchina: >&2
echo      certutil -decodehex -f seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe >&2
echo   2. Usa il seed in codice macchina (nessuna dipendenza da Julia): >&2
echo. >&2
echo Triad non dipende da Julia per l'esecuzione del codice .triad. >&2
exit /b 1

rem --- Esecuzione ------------------------------------------------------
:run
if "%RUNTIME%"=="standalone" goto :run_standalone
if "%RUNTIME%"=="seed" goto :run_seed
exit /b 1

:run_standalone
"%TRIAD_HOME%\bin\triad-native.exe" %*
exit /b %errorlevel%

:run_seed
"%SEED%" %*
exit /b %errorlevel%

:build_dev
echo triad --build: non disponibile (nessuna dipendenza da Julia). >&2
echo Usa il seed in codice macchina (bin\triad / seed\^<piattaforma^>\seed). >&2
exit /b 2

