@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem Copies scripts\hooks\pre-commit and pre-push into .git\hooks (an existing hook is kept as *.backup).
set "HOOKS_DIR=.git\hooks"
if not exist "%HOOKS_DIR%" (
    echo ERROR: %HOOKS_DIR% not found - run this from the repository root of a git clone.
    exit /b 1
)
for %%H in (pre-commit pre-push) do (
    if exist "%HOOKS_DIR%\%%H" (
        echo Backing up the current %%H hook...
        copy /Y "%HOOKS_DIR%\%%H" "%HOOKS_DIR%\%%H.backup" >nul
    )
    copy /Y "scripts\hooks\%%H" "%HOOKS_DIR%\%%H" >nul
)
echo Git hooks installed: pre-commit (AStyle + checks) and pre-push.
if not defined NO_PAUSE pause
exit /b 0
