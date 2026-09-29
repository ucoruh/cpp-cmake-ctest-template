@echo off

:: Enable necessary extensions
@setlocal enableextensions

echo ::: INIT SUBMODULES BEGIN ::::

echo Get the current directory
set "currentDir=%CD%"

echo Change the current working directory to the script directory
@cd /d "%~dp0"

del desktop.ini /A:H /S >nul 2>&1

for /r %%i in (desktop.ini) do (
    git rm --cached --force "%%i" >nul 2>&1
)

echo Sync submodule URLs from .gitmodules
git submodule sync --recursive

echo Initialise and check out the pinned submodule commit(s)
git submodule update --init --recursive
if errorlevel 1 (
    echo.
    echo [0-init-submodules] The submodule update failed. This usually happens when the
    echo [0-init-submodules] repository itself was cloned shallowly (e.g. with
    echo [0-init-submodules] "git clone --depth 1"^), so the submodule's pinned commit is not
    echo [0-init-submodules] reachable from the shallow history yet. Fetching the submodule's
    echo [0-init-submodules] full history and retrying...
    if exist "src\tests\googletest\.git" (
        pushd src\tests\googletest
        git fetch --unshallow origin
        if errorlevel 1 (
            echo [0-init-submodules] Submodule was not shallow; fetching normally instead.
            git fetch origin
        )
        popd
    )
    git submodule update --init --recursive
    if errorlevel 1 (
        echo.
        echo [0-init-submodules] ERROR: still could not initialise the submodule^(s^). Check your
        echo [0-init-submodules] internet connection and that this clone's .git directory is not
        echo [0-init-submodules] shallow: `git rev-parse --is-shallow-repository`. If it is, run:
        echo [0-init-submodules]   git fetch --unshallow
        echo [0-init-submodules] and re-run this script.
        cd /d "%currentDir%"
        exit /b 1
    )
)

echo ::: INIT SUBMODULES COMPLETED ::::
cd /d "%currentDir%"
pause
