@echo off
cd /d "%~dp0"
seed\windows-x86_64\seed.exe selfhost\eval.td > output.txt 2> error.txt
echo Exit code: %errorlevel%
echo ---
echo output.txt size: %~z0
echo error.txt size: %~z0
if %~z0 equ 0 (
  echo output.txt is empty
) else (
  echo output.txt has content:
  type output.txt
)
if %~z1 equ 0 (
  echo error.txt is empty
) else (
  echo error.txt has content:
  type error.txt
)