@echo off

:: Enable necessary extensions
@setlocal enableextensions

echo ::: UPDATE SUBMODULES BEGIN ::::

echo Get the current directory
set "currentDir=%CD%"

echo Change the current working directory to the script directory
@cd /d "%~dp0"

del desktop.ini /A:H /S >nul 2>&1

for /r %%i in (desktop.ini) do (
    git rm --cached --force "%%i" >nul 2>&1
)

git submodule sync --recursive
git submodule update --remote --merge
if errorlevel 1 (
    echo [0-update-submodules] ERROR: submodule update failed. See messages above.
    cd /d "%currentDir%"
    exit /b 1
)

echo ::: UPDATE SUBMODULES COMPLETED ::::
cd /d "%currentDir%"
pause
