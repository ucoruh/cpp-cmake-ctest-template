@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem Get the current directory path
for %%A in ("%~dp0.") do (
    set "currentDir=%%~fA"
)

::echo Clean Project
::call 9-clean-project.bat

echo Create the "release" folder and its contents
mkdir publish_win
mkdir release_win
mkdir build_win

echo Create the "docs" folder and its contents
mkdir docs
cd docs
mkdir coverxygenlibwin
mkdir coverxygentestwin
mkdir coveragereportlibwin
mkdir coveragereporttestwin
mkdir doxygenlibwin
mkdir doxygentestwin
mkdir testresultswin
cd ..

echo Create the "site" folder and its contents
mkdir site

echo Folders are Recreated successfully.

echo Generate Documentation

set STRIP_FROM_PATH=%currentDir%

echo Generate HTML/LATEX/RTF/XML Documentation for Library (No Source Code Only Headers)
call doxygen DoxyfileLibWin

echo Generate HTML/LATEX/RTF/XML Documentation for Unit Tests (Test Sources and Test Data Sets)
call doxygen DoxyfileTestWin

echo Not: coverxygen uses doxygen xml output for coverage

echo Run Documentation Coverage Data Collector for Library (No Source Code Only Headers)
call python -m coverxygen --xml-dir ./docs/doxygenlibwin/xml --src-dir ./ --format lcov --output ./docs/coverxygenlibwin/lcov_doxygen_lib_win.info

echo Run Documentation Coverage Data Collector for Unit Tests (Test Sources and Test Data Sets)
call python -m coverxygen --xml-dir ./docs/doxygentestwin/xml --src-dir ./ --format lcov --output ./docs/coverxygentestwin/lcov_doxygen_test_win.info
rem call python -m coverxygen --xml-dir ./docs/doxygen/xml --src-dir ./ --format lcov --output ./docs/coverxygen/lcov.info --prefix %currentDir%\

rem echo Run lcov genhtml
rem call perl C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml --legend --title "Documentation Coverage Report" ./docs/coverxygen/lcov.info -o docs/coverxygen

echo Run Documentation Coverage Report Generator for Library 
call reportgenerator "-title:Calculator Library Documentation Coverage Report (Windows)" "-reports:**/lcov_doxygen_lib_win.info" "-targetdir:docs/coverxygenlibwin" "-reporttypes:Html" "-filefilters:-*.md;-*.xml;-*[generated];-*build*" "-historydir:report_doc_lib_hist_win"
call reportgenerator "-reports:**/lcov_doxygen_lib_win.info" "-targetdir:assets/doccoveragelibwin" "-reporttypes:Badges" "-filefilters:-*.md;-*.xml;-*[generated];-*build*"

echo Run Documentation Coverage Report Generator for Unit Tests 
call reportgenerator "-title:Calculator Library Test Documentation Coverage Report (Windows)" "-reports:**/lcov_doxygen_test_win.info" "-targetdir:docs/coverxygentestwin" "-reporttypes:Html" "-filefilters:-*.md;-*.xml;-*[generated];-*build*" "-historydir:report_doc_test_hist_win"
call reportgenerator "-reports:**/lcov_doxygen_test_win.info" "-targetdir:assets/doccoveragetestwin" "-reporttypes:Badges" "-filefilters:-*.md;-*.xml;-*[generated];-*build*"

echo Testing Application with Coverage
echo Configure CMAKE
call cmake -B build_win -DCMAKE_BUILD_TYPE=Debug -G "Visual Studio 17 2022" -DCMAKE_INSTALL_PREFIX:PATH=publish_win
echo Build CMAKE Debug/Release
call cmake --build build_win --config Debug -j4
call cmake --build build_win --config Release -j4
rem call cmake --install build_win --strip
start "Install Debug" cmake --install build_win --config Debug --strip
start "Install Release" cmake --install build_win --config Release --strip
echo Test CMAKE
cd build_win
:: Test are already run with OpenCppCoverage...
::call ctest -C Debug -j4 --output-on-failure --output-log test_results_windows.log
call ctest -C Debug -j4 --output-junit testResults_windows.xml --output-log test_results_windows.log
call junit2html testResults_windows.xml testResults_windows.html
call copy testResults_windows.html "..\docs\testresultswin\index.html"
cd ..

echo Generate Test Coverage Data for Utility
call OpenCppCoverage.exe --export_type=binary:utility_tests_unit_win.cov --sources src\utility\src --sources src\utility\header --sources src\tests\utility -- build_win\build\Debug\utility_tests.exe

echo Generate Test Coverage Data for Calculator
call OpenCppCoverage.exe --export_type=binary:calculator_tests_unit_win.cov --sources src\calculator\src --sources src\calculator\header --sources src\tests\calculator -- build_win\build\Debug\calculator_tests.exe

echo Generate Test Coverage Data for Calculator App and Combine Results
call OpenCppCoverage.exe --input_coverage=utility_tests_unit_win.cov --input_coverage=calculator_tests_unit_win.cov --export_type=cobertura:calculatorapp_unit_win_cobertura.xml --sources src\utility\src --sources src\utility\header --sources src\calculator\src --sources src\calculator\header --sources src\calculatorapp\src --sources src\calculatorapp\header --sources src\tests\utility --sources src\tests\calculator -- build_win\build\Debug\calculatorapp.exe

echo Generate Unit Test Coverage Report
call reportgenerator "-title:Calculator Library Unit Test Coverage Report (Windows)" "-targetdir:docs/coveragereportlibwin" "-reporttypes:Html" "-reports:**/calculatorapp_unit_win_cobertura.xml" "-sourcedirs:src/utility/src;src/utility/header;src/calculator/src;src/calculator/header;src/calculatorapp/src;src/calculatorapp/header;src/tests/utility;src/tests/calculator" "-filefilters:-*minkernel\*;-*gtest*;-*a\_work\*;-*gtest-*;-*gtest.cc;-*gtest.h;-*build*" "-historydir:report_test_hist_win"
call reportgenerator "-targetdir:assets/codecoveragelibwin" "-reporttypes:Badges" "-reports:**/calculatorapp_unit_win_cobertura.xml" "-sourcedirs:src/utility/src;src/utility/header;src/calculator/src;src/calculator/header;src/calculatorapp/src;src/calculatorapp/header;src/tests/utility;src/tests/calculator" "-filefilters:-*minkernel\*;-*gtest*;-*a\_work\*;-*gtest-*;-*gtest.cc;-*gtest.h;-*build*"

echo Copy the "assets" folder and its contents to "docs" recursively
call robocopy assets "docs\assets" /E

echo Copy the "README.md" file to "docs\index.md"
call copy README.md "docs\index.md"

echo Files and folders copied successfully.

:: echo Generate Webpage
:: call mkdocs build

rem echo Publish Linux Binaries
rem call dotnet publish -c Release -r linux-x64 --self-contained true -o publish/linux

rem echo Publish MacOS Binaries
rem call dotnet publish -c Release -r osx-x64 --self-contained true -o publish/macos

rem echo Publish Windows Binaries
rem call dotnet publish -c Release -r win-x64 --self-contained true -o publish/windows

rem echo Package Linux Binaries
rem call tar -czvf release/linux-binaries.tar.gz -C publish/linux .

rem echo Package MacOS Binaries
rem call tar -czvf release/macos-binaries.tar.gz -C publish/macos .

echo Package Publish Windows Binaries
tar -czvf release_win\windows-publish-binaries.tar.gz -C publish_win .

echo Package Publish Windows Binaries
call robocopy src\utility\header "build_win\build\Release" /E
call robocopy src\calculator\header "build_win\build\Release" /E
call robocopy src\calculatorapp\header "build_win\build\Release" /E
tar -czvf release_win\windows-release-binaries.tar.gz -C build_win\build\Release .

echo Package Publish Debug Windows Binaries
call robocopy src\utility\header "build_win\build\Debug" /E
call robocopy src\calculator\header "build_win\build\Debug" /E
call robocopy src\calculatorapp\header "build_win\build\Debug" /E
tar -czvf release_win\windows-debug-binaries.tar.gz -C build_win\build\Debug .

echo Package Publish Test Coverage Report
tar -czvf release_win\windows-test-coverage-report.tar.gz -C docs\coveragereportlibwin .

echo Package Publish Library Doc Coverage Report
tar -czvf release_win\windows-lib-doc-coverage-report.tar.gz -C docs\coverxygenlibwin .

echo Package Publish Unit Test Doc Coverage Report
tar -czvf release_win\windows-test-doc-coverage-report.tar.gz -C docs\coverxygentestwin .

echo Package Publish Library Documentation
tar -czvf release_win\windows-doxygen-lib-documentation.tar.gz -C docs\doxygenlibwin .

echo Package Publish Unit Test Documentation
tar -czvf release_win\windows-doxygen-test-documentation.tar.gz -C docs\doxygentestwin .

echo Package Publish Test Results Report
tar -czvf release_win\windows-test-results-report.tar.gz -C docs\testresultswin .

echo ....................
echo Operation Completed!
echo ....................
pause



