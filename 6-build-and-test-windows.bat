@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem 6-build-and-test-windows.bat - the FAST loop: configure, build (Debug and Release) and run the unit tests.
rem   build\windows-debug\     build tree, Debug   (bin\Debug\*.exe, test-results.xml)
rem   build\windows-release\   build tree, Release
rem   publish\windows-<arch>\{debug,release}\   cmake --install output (bin\, lib\, include\)
rem Reports, API docs, the site and release\ come from 7-build-all-windows.bat.

call "%~dp0scripts\load-project-env-windows.bat"
if errorlevel 1 exit /b 1
call "%~dp0scripts\detect-generator-windows.bat"
if errorlevel 1 (
    echo ERROR: could not detect a usable CMake generator. See the messages above.
    exit /b 1
)

echo === %PROJECT_NAME% %VERSION% - build and test on %PLATFORM%-%ARCH%
if not exist "src\tests\googletest\CMakeLists.txt" (
    echo ERROR: the googletest submodule is missing. Run 0-init-submodules-windows.bat first.
    exit /b 1
)

rem Multi-config Visual Studio generators take the configuration at build time; Ninja needs it at configure time.
set "BUILD_TYPE_ARG=-DCMAKE_BUILD_TYPE="
if "%GENERATOR:~0,13%"=="Visual Studio" set "BUILD_TYPE_ARG=-DCMAKE_CONFIGURATION_TYPES="

if exist "publish\%PLATFORM%-%ARCH%" rd /S /Q "publish\%PLATFORM%-%ARCH%"

call :one debug Debug
if errorlevel 1 exit /b 1
call :one release Release
if errorlevel 1 exit /b 1

echo.
echo ....................
echo Build and tests OK  ^(build\%PLATFORM%-debug, build\%PLATFORM%-release, publish\%PLATFORM%-%ARCH%^)
echo ....................
if not defined NO_PAUSE pause
exit /b 0

:one
rem %1 = debug|release   %2 = Debug|Release
echo.
echo === Configure %2  ^(generator: %GENERATOR%^)
rem Visual Studio is multi-config (the configuration is chosen at build time); Ninja needs it at configure time.
set "BUILD_TYPE_ARG=-DCMAKE_BUILD_TYPE=%2"
if "%GENERATOR:~0,13%"=="Visual Studio" set "BUILD_TYPE_ARG="
call cmake -S . -B "build\%PLATFORM%-%1" -G "%GENERATOR%" %EXTRA_CMAKE_ARGS% %BUILD_TYPE_ARG%
if errorlevel 1 (
    echo ERROR: CMake configure failed for %2.
    exit /b 1
)
echo === Build %2
call cmake --build "build\%PLATFORM%-%1" --config %2 --parallel
if errorlevel 1 (
    echo ERROR: the %2 build failed.
    exit /b 1
)
echo === Unit tests %2 ^(CTest^)
pushd "build\%PLATFORM%-%1"
call ctest -C %2 --output-on-failure --output-junit test-results.xml --output-log test-results.log
if errorlevel 1 (
    popd
    echo ERROR: one or more %2 tests failed - see build\%PLATFORM%-%1\test-results.log
    exit /b 1
)
popd
echo === Install %2 to publish\%PLATFORM%-%ARCH%\%1
call cmake --install "build\%PLATFORM%-%1" --config %2 --prefix "publish\%PLATFORM%-%ARCH%\%1"
if errorlevel 1 (
    echo ERROR: cmake --install failed for %2.
    exit /b 1
)
exit /b 0
