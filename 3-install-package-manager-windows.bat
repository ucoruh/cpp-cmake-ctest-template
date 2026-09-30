@echo off
setlocal enableextensions enabledelayedexpansion

cd /d "%~dp0"

:: Check if Chocolatey is installed
echo Checking if Chocolatey is installed...
if exist "%ProgramData%\Chocolatey\bin\choco.exe" (
    echo Chocolatey is already installed.
) else (
    echo Installing Chocolatey...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    if errorlevel 1 (
        echo Failed to install Chocolatey.
        goto :end
    )
    echo Chocolatey installed successfully.
)

:: Check if Scoop is installed
echo Checking if Scoop is installed...
where scoop >nul 2>&1
if !errorlevel! == 0 (
    echo Scoop is already installed.
) else (
    echo Scoop is not installed. Installing Scoop...
    powershell -Command "iex (Invoke-WebRequest -Uri get.scoop.sh).Content" -RunAsAdmin
    if errorlevel 1 (
        echo Failed to install Scoop.
        goto :end
    )
    powershell -Command "Set-ExecutionPolicy RemoteSigned -scope CurrentUser"
    echo Scoop installed successfully.
)

:end
pause
