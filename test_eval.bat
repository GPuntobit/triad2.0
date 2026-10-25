@echo off
cd /d "%~dp0"
seed\windows-x86_64\seed.exe selfhost\eval.td > output.txt 2> error.txt
echo Exit code: %errorlevel%
echo.
echo output.txt content:
type output.txt
echo.
echo error.txt content:
type error.txt