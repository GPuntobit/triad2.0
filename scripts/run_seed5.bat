@echo off
cd /d "%~dp0"
seed\windows-x86_64\seed.exe conformance\cases\valori\program.td
echo Exit code: %errorlevel%