@echo off
cd /d "%~dp0"
echo # test semplice > test_simple.td
echo println("hello") >> test_simple.td
seed\windows-x86_64\seed.exe test_simple.td > output.txt 2> error.txt
echo Exit code: %errorlevel%
echo ---
type output.txt
echo ---
type error.txt
del test_simple.td output.txt error.txt