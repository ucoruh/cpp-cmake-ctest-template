@echo off
@setlocal enableextensions
@cd /d "%~dp0"

echo clean project
call "%~dp09-clean-project.bat"

echo Detect CMake generator (Visual Studio if installed, else Ninja)
call "%~dp0detect-generator.bat"
if errorlevel 1 (
    echo ERROR: could not detect a usable CMake generator. See messages above.
    exit /b 1
)

echo Re-Configure CMAKE
mkdir build_win
call cmake -B build_win -DCMAKE_BUILD_TYPE=Debug -G "%GENERATOR%" %EXTRA_CMAKE_ARGS% -DCMAKE_INSTALL_PREFIX:PATH=publish_win
if errorlevel 1 (
    echo ERROR: CMake configure failed.
    exit /b 1
)

echo ....................
echo Operation Completed!
pause