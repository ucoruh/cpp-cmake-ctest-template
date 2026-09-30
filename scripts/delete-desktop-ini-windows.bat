@echo off
@setlocal enableextensions
@cd /d "%~dp0.."

rem Google Drive drops a hidden desktop.ini into every folder. Git must never see them:
rem delete them and drop any that were staged. Usage: scripts\delete-desktop-ini-windows.bat [quiet]
if /I not "%~1"=="quiet" echo ::: DELETE GOOGLE DRIVE desktop.ini FILES ::::

del desktop.ini /A:H /S /Q >nul 2>&1
del desktop.ini /S /Q >nul 2>&1
for /f "delims=" %%i in ('git ls-files "*desktop.ini" 2^>nul') do git rm --cached --force -q "%%i" >nul 2>&1

if /I not "%~1"=="quiet" echo ::: DELETE OPERATION COMPLETED ::::
exit /b 0
