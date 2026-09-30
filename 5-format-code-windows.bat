@echo off
@setlocal enableextensions
@cd /d "%~dp0"

echo Formatting code with AStyle (astyle-options.txt)...
astyle --options="astyle-options.txt" --recursive "src/*.h" "src/*.cpp" --exclude=googletest
if errorlevel 1 exit /b 1
if not defined NO_PAUSE pause
exit /b 0
