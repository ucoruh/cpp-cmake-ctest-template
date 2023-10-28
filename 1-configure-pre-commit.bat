@echo off
setlocal

REM Set the path to the .git/hooks directory
set HOOKS_DIR=.git/hooks

REM Check if .git/hooks directory exists
if not exist "%HOOKS_DIR%" (
    echo Error: .git/hooks directory not found.
    exit /b 1
)

REM Backup current pre-commit script if it exists
if exist "%HOOKS_DIR%\pre-commit" (
    echo Backing up current pre-commit script...
    rename "%HOOKS_DIR%\pre-commit" "pre-commit.backup"
)

REM Copy 1-pre-commit to .git/hooks directory and rename it to pre-commit
copy "1-pre-commit" "%HOOKS_DIR%\pre-commit"

echo Script has been copied successfully.

pause

