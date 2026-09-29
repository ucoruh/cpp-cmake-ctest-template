@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem Get the current directory path
for %%A in ("%~dp0.") do (
    set "currentDir=%%~fA"
)

::echo Clean Project
::call "%~dp09-clean-project.bat"

echo Detect a Python 3 with the coverxygen module (a plain "python" is not always the right one)
call "%~dp0detect-python.bat"
if errorlevel 1 (
    echo ERROR: no usable Python 3 found. See messages above.
    exit /b 1
)

echo Detect the CMake generator (Visual Studio if installed, else Ninja)
call "%~dp0detect-generator.bat"
if errorlevel 1 (
    echo ERROR: could not detect a usable CMake generator. See messages above.
    exit /b 1
)

echo Detect genhtml (native lcov HTML report for documentation coverage; optional)
call "%~dp0detect-genhtml.bat"
set "HAVE_GENHTML=1"
if errorlevel 1 set "HAVE_GENHTML=0"

echo Create the "release" folder and its contents
mkdir publish_win
mkdir release_win
mkdir build_win

echo Create the "docs" folder and its contents
mkdir docs
cd docs
mkdir coverxygenlibwin
mkdir coverxygentestwin
mkdir coverxygennativelibwin
mkdir coverxygennativetestwin
mkdir coveragereportlibwin
mkdir coveragenativelibwin
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
if errorlevel 1 (
    echo ERROR: doxygen failed on DoxyfileLibWin.
    exit /b 1
)

echo Generate HTML/LATEX/RTF/XML Documentation for Unit Tests (Test Sources and Test Data Sets)
call doxygen DoxyfileTestWin
if errorlevel 1 (
    echo ERROR: doxygen failed on DoxyfileTestWin.
    exit /b 1
)

echo Not: coverxygen uses doxygen xml output for coverage

echo Run Documentation Coverage Data Collector for Library (No Source Code Only Headers)
call %PY_CMD% -m coverxygen --xml-dir ./docs/doxygenlibwin/xml --src-dir ./ --format lcov --output ./docs/coverxygenlibwin/lcov_doxygen_lib_win.info
if errorlevel 1 (
    echo ERROR: coverxygen failed for the library.
    exit /b 1
)

echo Run Documentation Coverage Data Collector for Unit Tests (Test Sources and Test Data Sets)
call %PY_CMD% -m coverxygen --xml-dir ./docs/doxygentestwin/xml --src-dir ./ --format lcov --output ./docs/coverxygentestwin/lcov_doxygen_test_win.info
if errorlevel 1 (
    echo ERROR: coverxygen failed for the unit tests.
    exit /b 1
)

echo Run Documentation Coverage Report Generator for Library (ReportGenerator, HTML + history)
call reportgenerator "-title:Calculator Library Documentation Coverage Report (Windows)" "-reports:**/lcov_doxygen_lib_win.info" "-targetdir:docs/coverxygenlibwin" "-reporttypes:Html" "-filefilters:-*.md;-*.xml;-*[generated];-*build*" "-historydir:report_doc_lib_hist_win"
call reportgenerator "-reports:**/lcov_doxygen_lib_win.info" "-targetdir:assets/doccoveragelibwin" "-reporttypes:Badges" "-filefilters:-*.md;-*.xml;-*[generated];-*build*"

echo Run Documentation Coverage Report Generator for Unit Tests (ReportGenerator, HTML + history)
call reportgenerator "-title:Calculator Library Test Documentation Coverage Report (Windows)" "-reports:**/lcov_doxygen_test_win.info" "-targetdir:docs/coverxygentestwin" "-reporttypes:Html" "-filefilters:-*.md;-*.xml;-*[generated];-*build*" "-historydir:report_doc_test_hist_win"
call reportgenerator "-reports:**/lcov_doxygen_test_win.info" "-targetdir:assets/doccoveragetestwin" "-reporttypes:Badges" "-filefilters:-*.md;-*.xml;-*[generated];-*build*"

if "%HAVE_GENHTML%"=="1" (
    echo Run native lcov genhtml Documentation Coverage Report for Library
    call %GENHTML_CMD% --legend --title "Calculator Library Documentation Coverage Report - native genhtml (Windows)" docs\coverxygenlibwin\lcov_doxygen_lib_win.info -o docs\coverxygennativelibwin
    echo Run native lcov genhtml Documentation Coverage Report for Unit Tests
    call %GENHTML_CMD% --legend --title "Calculator Library Test Documentation Coverage Report - native genhtml (Windows)" docs\coverxygentestwin\lcov_doxygen_test_win.info -o docs\coverxygennativetestwin
) else (
    echo Skipping native lcov genhtml documentation-coverage report ^(genhtml/perl not available^).
)

echo Testing Application with Coverage
echo Configure CMAKE
call cmake -B build_win -DCMAKE_BUILD_TYPE=Debug -G "%GENERATOR%" %EXTRA_CMAKE_ARGS% -DCMAKE_INSTALL_PREFIX:PATH=publish_win
if errorlevel 1 (
    echo ERROR: CMake configure failed.
    exit /b 1
)
echo Build CMAKE Debug/Release
call cmake --build build_win --config Debug -j4
if errorlevel 1 (
    echo ERROR: Debug build failed.
    exit /b 1
)
call cmake --build build_win --config Release -j4
if errorlevel 1 (
    echo ERROR: Release build failed.
    exit /b 1
)
rem call cmake --install build_win --strip
call cmake --install build_win --config Debug --strip
call cmake --install build_win --config Release --strip
echo Test CMAKE
cd build_win
:: Tests are already exercised again below via OpenCppCoverage; keep the CTest run
:: as the native JUnit-XML source of truth for the "Which report is which?" page.
call ctest -C Debug -j4 --output-junit testResults_windows.xml --output-log test_results_windows.log
set "TESTS_FAILED=%errorlevel%"
cd ..

echo Convert CTest JUnit XML results to a native HTML report (junit2html)
set "JUNIT2HTML_EXE=%PY_SCRIPTS%\junit2html.exe"
if not exist "%JUNIT2HTML_EXE%" set "JUNIT2HTML_EXE=junit2html"
call "%JUNIT2HTML_EXE%" build_win\testResults_windows.xml build_win\testResults_windows.html
if errorlevel 1 (
    echo WARNING: junit2html failed or is not installed ^(py -3 -m pip install --user junit2html^); skipping the native test-results HTML page.
) else (
    call copy build_win\testResults_windows.html "docs\testresultswin\index.html"
)

if not "%TESTS_FAILED%"=="0" (
    echo ERROR: one or more tests failed ^(see build_win\test_results_windows.log and docs\testresultswin\index.html^).
)

echo Generate Test Coverage Data for Utility
call OpenCppCoverage.exe --export_type=binary:utility_tests_unit_win.cov --sources src\utility\src --sources src\utility\header --sources src\tests\utility -- build_win\build\Debug\utility_tests.exe

echo Generate Test Coverage Data for Calculator
call OpenCppCoverage.exe --export_type=binary:calculator_tests_unit_win.cov --sources src\calculator\src --sources src\calculator\header --sources src\tests\calculator -- build_win\build\Debug\calculator_tests.exe

echo Generate Test Coverage Data for Calculator App and Combine Results (ReportGenerator cobertura input AND native OpenCppCoverage HTML, side by side)
call OpenCppCoverage.exe --input_coverage=utility_tests_unit_win.cov --input_coverage=calculator_tests_unit_win.cov --export_type=cobertura:calculatorapp_unit_win_cobertura.xml --export_type=html:docs\coveragenativelibwin --sources src\utility\src --sources src\utility\header --sources src\calculator\src --sources src\calculator\header --sources src\calculatorapp\src --sources src\calculatorapp\header --sources src\tests\utility --sources src\tests\calculator

echo Generate Unit Test Coverage Report (ReportGenerator, HTML + badges + history)
call reportgenerator "-title:Calculator Library Unit Test Coverage Report (Windows)" "-targetdir:docs/coveragereportlibwin" "-reporttypes:Html" "-reports:**/calculatorapp_unit_win_cobertura.xml" "-sourcedirs:src/utility/src;src/utility/header;src/calculator/src;src/calculator/header;src/calculatorapp/src;src/calculatorapp/header;src/tests/utility;src/tests/calculator" "-filefilters:-*minkernel\*;-*gtest*;-*a\_work\*;-*gtest-*;-*gtest.cc;-*gtest.h;-*build*" "-historydir:report_test_hist_win"
call reportgenerator "-targetdir:assets/codecoveragelibwin" "-reporttypes:Badges" "-reports:**/calculatorapp_unit_win_cobertura.xml" "-sourcedirs:src/utility/src;src/utility/header;src/calculator/src;src/calculator/header;src/calculatorapp/src;src/calculatorapp/header;src/tests/utility;src/tests/calculator" "-filefilters:-*minkernel\*;-*gtest*;-*a\_work\*;-*gtest-*;-*gtest.cc;-*gtest.h;-*build*"

echo Copy the "assets" folder and its contents to "docs" recursively
call robocopy assets "docs\assets" /E

echo Copy the "README.md" file to "docs\index.md"
call copy README.md "docs\index.md"

echo Files and folders copied successfully.

echo Generate Webpage (mkdocs site linking every report, see docs/reports.md "Which report is which?")
call %PY_CMD% -m mkdocs build
if errorlevel 1 (
    echo WARNING: mkdocs build failed; the site under site\ was not regenerated. Run
    echo   %PY_CMD% -m pip install --user mkdocs mkdocs-material
    echo and re-run this script if you need the site.
)

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
if not "%TESTS_FAILED%"=="0" (
    echo One or more tests FAILED - see docs\testresultswin\index.html
    pause
    exit /b 1
)
pause
