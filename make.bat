@echo off
echo ================
echo Compiling...
echo ================
luam.exe -n -s ./src/main.lua -o ./test.lua
echo.
echo ================
echo Running...
echo ================
lua test.lua
pause