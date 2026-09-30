@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem 0-init-submodules-windows.bat [update]
rem   (no argument)  initialise / check out the submodule commit this repository pins (googletest)
rem   update         move the submodule(s) to the newest upstream commit (git submodule update --remote)

echo ::: INIT SUBMODULES BEGIN ::::

call "%~dp0scripts\delete-desktop-ini-windows.bat" quiet

echo Sync submodule URLs from .gitmodules
git submodule sync --recursive

if /I "%~1"=="update" (
    echo Update the submodule^(s^) to the newest upstream commit
    git submodule update --init --remote --merge
    if errorlevel 1 (
        echo [0-init-submodules] ERROR: submodule update failed. See messages above.
        exit /b 1
    )
    goto done
)

echo Initialise and check out the pinned submodule commit(s)
git submodule update --init --recursive
if errorlevel 1 (
    echo.
    echo [0-init-submodules] The submodule update failed. This usually happens when the
    echo [0-init-submodules] repository itself was cloned shallowly ^(git clone --depth 1^), so the
    echo [0-init-submodules] submodule's pinned commit is not reachable yet. Fetching the
    echo [0-init-submodules] submodule's full history and retrying...
    if exist "src\tests\googletest\.git" (
        pushd src\tests\googletest
        git fetch --unshallow origin
        if errorlevel 1 git fetch origin
        popd
    )
    git submodule update --init --recursive
    if errorlevel 1 (
        echo.
        echo [0-init-submodules] ERROR: still could not initialise the submodule^(s^). Check your
        echo [0-init-submodules] internet connection and that this clone is not shallow:
        echo [0-init-submodules]   git rev-parse --is-shallow-repository   ^(true = shallow^)
        echo [0-init-submodules]   git fetch --unshallow
        echo [0-init-submodules] then re-run this script.
        exit /b 1
    )
)

:done
echo ::: INIT SUBMODULES COMPLETED ::::
if not defined NO_PAUSE pause
exit /b 0
