@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem 8-run-app-windows.bat ["2+3*(4-1)"]
rem Runs the sample application from publish\windows-<arch>\release\bin (built by 6-build-and-test-windows.bat).
rem   no argument  -> interactive: type an expression when asked
rem   an argument  -> that expression is evaluated and the result printed (non-interactive)

call "%~dp0scripts\load-project-env-windows.bat"
if errorlevel 1 exit /b 1

call :findapp
if defined APP goto run
echo No built application found - building it first ^(6-build-and-test-windows.bat^)...
set "NO_PAUSE=1"
call "%~dp06-build-and-test-windows.bat"
if errorlevel 1 exit /b 1
call :findapp
if defined APP goto run
echo ERROR: no application executable in publish\%PLATFORM%-%ARCH%\release\bin
exit /b 1

:run
echo Running %APP%
if "%~1"=="" goto interactive
echo %~1| "%APP%"
exit /b %errorlevel%

:interactive
"%APP%"
exit /b %errorlevel%

:findapp
set "APP="
for %%F in ("publish\%PLATFORM%-%ARCH%\release\bin\*.exe") do call :check "%%~fF" "%%~nF"
exit /b 0

:check
echo %~2| findstr /I /C:"_tests" >nul
if errorlevel 1 if not defined APP set "APP=%~1"
exit /b 0
