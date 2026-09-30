@echo off

:: Enable necessary extensions
@setlocal enableextensions

echo ::: DELETE GOOGLE DRIVE desktop.ini FILES ::::

echo Get the current directory
set "currentDir=%CD%"

echo Change the current working directory to the script directory
@cd /d "%~dp0"

del desktop.ini /A:H /S

for /r %%i in (desktop.ini) do (
    git rm --cached --force "%%i"
)

echo ::: DELETE OPERATION COMPLETED ::::
pause
