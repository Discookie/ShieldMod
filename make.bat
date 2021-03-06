@echo off
echo ================
echo Setting up workspace...
echo ================
if exist "output" del /F /S /Q output >nul 2>nul
mkdir output >nul 2>nul
xcopy /S /Q /I htp output >nul 2>nul
xcopy /S /Q /I tt output >nul 2>nul
xcopy /S /Q /I src output\src >nul 2>nul
xcopy /S /Q /I settings output\settings >nul 2>nul
copy LICENSE output\LICENSE >nul 2>nul
copy README.md "output\README" >nul 2>nul
copy "settings\display.js" "output\dynamic\diff.js" >nul 2>nul
echo.
echo ================
echo Compiling...
echo ================
luam.exe -n -s ./src/main.lua -o "./output/Hard ShieldVR.lua"
echo.
echo ================
echo Testing...
echo ================
lua "output/Hard ShieldVR.lua"
pause