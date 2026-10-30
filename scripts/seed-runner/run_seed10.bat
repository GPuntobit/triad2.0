@echo off
cd /d "%~dp0"
seed\windows-x86_64\seed.exe conformance\cases\valori\program.td > output.txt 2> error.txt
echo Exit code: %errorlevel%
echo File output.txt size: %~z0
echo File error.txt size: %~z0
if %~z0 equ 0 (
  echo output.txt is empty
) else (
  echo output.txt has content
)