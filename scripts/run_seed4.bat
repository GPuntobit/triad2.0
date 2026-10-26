@echo off
pushd "%~dp0seed\windows-x86_64"
seed.exe ..\selfhost\eval.td
echo Exit code: %errorlevel%
popd