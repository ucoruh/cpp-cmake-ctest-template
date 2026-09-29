@echo off
:: detect-generator.bat
::
:: Picks a CMake generator for this machine instead of hard-coding one Visual
:: Studio version. Called with `call detect-generator.bat` from another
:: script (not run standalone), so it does NOT use setlocal: the variables it
:: sets (GENERATOR, EXTRA_CMAKE_ARGS) must be visible to the caller.
::
:: - If Visual Studio is installed (found via the official vswhere.exe
::   locator), use the matching "Visual Studio NN YYYY" generator.
:: - Otherwise, fall back to Ninja with an explicitly selected compiler
::   (gcc/g++, e.g. from MinGW), so builds still work on a machine that only
::   has Ninja + GCC and no Visual Studio.
::
:: Sets on success:
::   GENERATOR         e.g. "Visual Studio 17 2022" or "Ninja"
::   EXTRA_CMAKE_ARGS   extra -D... args to pass to `cmake -B ...` (may be empty)
:: Returns errorlevel 1 if no usable generator/compiler could be found.

set "GENERATOR="
set "EXTRA_CMAKE_ARGS="
set "VS_MAJOR="

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" set "VSWHERE=%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe"

if exist "%VSWHERE%" (
    for /f "usebackq tokens=1 delims=." %%A in (`"%VSWHERE%" -latest -products * -requires Microsoft.Component.MSBuild -property installationVersion 2^>nul`) do (
        set "VS_MAJOR=%%A"
    )
)

if "%VS_MAJOR%"=="17" set "GENERATOR=Visual Studio 17 2022"
if "%VS_MAJOR%"=="16" set "GENERATOR=Visual Studio 16 2019"
if "%VS_MAJOR%"=="15" set "GENERATOR=Visual Studio 15 2017"

if defined GENERATOR (
    echo [detect-generator] Found Visual Studio ^(version %VS_MAJOR%.x^) via vswhere; using generator: %GENERATOR%
    exit /b 0
)

echo [detect-generator] No Visual Studio installation found via vswhere; falling back to Ninja.

where ninja >nul 2>&1
if errorlevel 1 (
    echo [detect-generator] ERROR: Ninja is not installed either. Install Visual Studio
    echo [detect-generator]   ^(with the "Desktop development with C++" workload^) or run:
    echo [detect-generator]   choco install ninja cmake
    exit /b 1
)
set "GENERATOR=Ninja"

where gcc >nul 2>&1
if errorlevel 1 (
    echo [detect-generator] WARNING: gcc not found on PATH; letting CMake pick a default compiler.
) else (
    set "EXTRA_CMAKE_ARGS=-DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++"
    echo [detect-generator] Using generator Ninja with gcc/g++ ^(e.g. MinGW-w64^).
)

exit /b 0
