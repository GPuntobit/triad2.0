@echo off
cd /d "%~dp0"
seed\windows-x86_64\seed.exe conformance\cases\macro_eval\program.td > output.txt 2> error.txt
echo Exit code: %errorlevel%
echo ---
type output.txt
echo ---
type error.txt