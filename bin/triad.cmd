@echo off
rem =====================================================================
rem  triad.cmd — launcher Windows per il linguaggio Triad
rem
rem  Cerca un runtime Triad in questo ordine:
rem    1. bin\triad-native.exe  (eseguibile standalone)
rem    2. Variabile d'ambiente TRIAD_JULIA
rem    3. julia nel PATH
rem    4. Posizioni standard di Julia su Windows
rem
rem  Uso:  triad [opzioni] [file.td [argomenti...]]
rem        triad --help          tutte le opzioni
rem        triad --build         crea l'eseguibile standalone
rem
rem  Per usarlo da ovunque: aggiungere questa cartella al PATH.
rem =====================================================================

setlocal enabledelayedexpansion

set "TRIAD_HOME=%~dp0.."

rem --- Modalità --build ------------------------------------------------
if "%~1"=="--build" (
    set "JULIA=julia"
    if defined TRIAD_JULIA set "JULIA=!TRIAD_JULIA!"
    where /q "!JULIA!" >nul 2>&1
    if errorlevel 1 (
        echo triad --build: Julia non trovato. Imposta TRIAD_JULIA o aggiungi julia al PATH. >&2
        exit /b 2
    )
    echo ==^> Compilazione eseguibile standalone...
    "!JULIA!" --startup-file=no "%TRIAD_HOME%\bin\build_standalone.jl" %*
    exit /b %errorlevel%
)

rem --- Ricerca del runtime ---------------------------------------------
set "RUNTIME="

rem 1. Eseguibile standalone
if exist "%TRIAD_HOME%\bin\triad-native.exe" (
    set "RUNTIME=standalone"
    goto :run
)

rem 2. Variabile d'ambiente TRIAD_JULIA
if defined TRIAD_JULIA (
    if exist "!TRIAD_JULIA!" (
        set "JULIA=!TRIAD_JULIA!"
        set "RUNTIME=julia"
        goto :run
    )
)

rem 3. PATH
where /q julia >nul 2>&1
if not errorlevel 1 (
    set "JULIA=julia"
    set "RUNTIME=julia"
    goto :run
)

rem 4. Posizioni standard Windows
for %%d in (
    "%LOCALAPPDATA%\Programs\Julia-1.13.1\bin\julia.exe"
    "%LOCALAPPDATA%\Programs\Julia-1.12.0\bin\julia.exe"
    "%LOCALAPPDATA%\Programs\Julia-1.11.0\bin\julia.exe"
    "%LOCALAPPDATA%\Programs\Julia-1.10.0\bin\julia.exe"
    "%LOCALAPPDATA%\juliaup\bin\julia.exe"
    "%ProgramFiles%\Julia\bin\julia.exe"
    "C:\Julia\bin\julia.exe"
    "C:\Users\xbos\AppData\Local\Programs\Julia-1.13.1\bin\julia.exe"
) do (
    if exist %%d (
        set "JULIA=%%~d"
        set "RUNTIME=julia"
        goto :run
    )
)

rem --- Nessun runtime trovato ------------------------------------------
echo triad: runtime non trovato. >&2
echo. >&2
echo Opzioni: >&2
echo   1. Crea uno standalone:   triad --build >&2
echo   2. Installa Julia e aggiungilo al PATH >&2
echo   3. Imposta TRIAD_JULIA=C:\path\to\julia.exe >&2
echo. >&2
echo Scarica Julia da https://julialang.org/downloads/ >&2
exit /b 1

rem --- Esecuzione ------------------------------------------------------
:run
if "%RUNTIME%"=="standalone" (
    "%TRIAD_HOME%\bin\triad-native.exe" %*
    exit /b %errorlevel%
)
if "%RUNTIME%"=="julia" (
    "!JULIA!" --startup-file=no "%TRIAD_HOME%\triad.jl" %*
    exit /b %errorlevel%
)
