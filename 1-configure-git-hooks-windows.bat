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

REM Copy pre-commit to .git/hooks directory and rename it to pre-commit
copy "pre-commit" "%HOOKS_DIR%\pre-commit"

REM Backup current pre-push script if it exists
if exist "%HOOKS_DIR%\pre-push" (
    echo Backing up current pre-push script...
    rename "%HOOKS_DIR%\pre-push" "pre-push.backup"
)

REM Copy pre-push to .git/hooks directory and rename it to pre-push
copy "pre-push" "%HOOKS_DIR%\pre-push"

echo Scripts has been copied successfully.

pause

