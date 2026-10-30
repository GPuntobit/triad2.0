@echo off
cd /d "%~dp0"
seed\windows-x86_64\seed.exe conformance\cases\macro_eval\program.td
echo Exit code: %errorlevel%