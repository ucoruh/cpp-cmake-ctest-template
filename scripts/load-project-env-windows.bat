@echo off
:: load-project-env-windows.bat
::
:: Reads project.env (PROJECT_NAME, VERSION, GITHUB_REPO) from the repository root
:: and derives the values every script needs. Called with
::   call "%~dp0scripts\load-project-env-windows.bat"
:: (no setlocal on purpose: the variables must stay visible to the caller).
::
:: Sets: PROJECT_NAME, VERSION, GITHUB_REPO, REPO_OWNER, REPO_NAME, SITE_URL,
::       REPO_URL, PLATFORM (windows), ARCH (x64 or arm64), ROOT_DIR.
:: Also exports SITE_NAME / SITE_URL / REPO_URL for mkdocs.yml (!ENV).

for %%A in ("%~dp0..") do set "ROOT_DIR=%%~fA"
if not exist "%ROOT_DIR%\project.env" (
    echo [load-project-env] ERROR: %ROOT_DIR%\project.env not found.
    exit /b 1
)
for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%ROOT_DIR%\project.env") do set "%%A=%%B"
if not defined PROJECT_NAME (
    echo [load-project-env] ERROR: PROJECT_NAME is not set in project.env.
    exit /b 1
)
if not defined VERSION (
    echo [load-project-env] ERROR: VERSION is not set in project.env.
    exit /b 1
)

set "PLATFORM=windows"
set "ARCH=x64"
if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=arm64"

set "REPO_OWNER="
set "REPO_NAME="
if defined GITHUB_REPO (
    for /f "tokens=1,2 delims=/" %%A in ("%GITHUB_REPO%") do (
        set "REPO_OWNER=%%A"
        set "REPO_NAME=%%B"
    )
)
if defined REPO_OWNER (
    set "SITE_URL=https://%REPO_OWNER%.github.io/%REPO_NAME%/"
    set "REPO_URL=https://github.com/%GITHUB_REPO%"
) else (
    set "SITE_URL=http://localhost:8000/"
    set "REPO_URL=https://github.com/"
)
set "SITE_NAME=%PROJECT_NAME%"
exit /b 0
