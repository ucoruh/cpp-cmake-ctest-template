@echo off
@setlocal enableextensions
@cd /d "%~dp0"

echo clean project
call 9-clean-project.bat

echo Re-Configure CMAKE
mkdir build_win
call cmake -B build_win -DCMAKE_BUILD_TYPE=Debug -G "Visual Studio 17 2022" -DCMAKE_INSTALL_PREFIX:PATH=publish_win

echo ....................
echo Operation Completed!
pause