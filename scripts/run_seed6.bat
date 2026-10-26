@echo off
cd /d "%~dp0"
seed\windows-x86_64\seed.exe selfhost\eval.td
echo Exit code: %errorlevel%