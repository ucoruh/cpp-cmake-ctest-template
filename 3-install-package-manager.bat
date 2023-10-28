@echo off
@setlocal enableextensions
@cd /d "%~dp0"

echo Checking if Chocolatey is installed...
if exist "%ProgramData%\Chocolatey\bin\choco.exe" (
    echo Chocolatey is already installed.
) else (
    echo Installing Chocolatey...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
)

echo Checking if Scoop is installed...
where scoop >nul 2>&1
if %errorlevel%==0 (
    echo Scoop is already installed.
) else (
    echo Scoop is not installed. Installing Scoop...
    powershell Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    powershell Set-ExecutionPolicy RemoteSigned -scope CurrentUser
)

pause