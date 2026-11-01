@echo off
REM Parametrized seed runner for Triad
REM Usage: run_seed.bat <program_file> [output_redirect]
REM Example: run_seed.bat selfhost\eval.td
REM          run_seed.bat conformance\cases\macro_eval\program.td > output.txt 2> error.txt

cd /d "%~dp0"
if "%~1"=="" (
  echo Usage: %~nx0 ^<program_file^> [output_redirect]
  echo Example: %~nx0 selfhost\eval.td
  echo          %~nx0 conformance\cases\macro_eval\program.td ^> output.txt 2^> error.txt
  exit /b 1
)

seed\windows-x86_64\seed.exe %*
echo Exit code: %errorlevel%
