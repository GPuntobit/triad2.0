@echo off
cd /d "%~dp0"
seed\windows-x86_64\seed.exe selfhost\eval.td > NUL 2> NUL
set EXITCODE=%ERRORLEVEL%
echo ExitCode: %EXITCODE%