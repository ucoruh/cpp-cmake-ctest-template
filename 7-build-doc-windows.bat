@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem Get the current directory path
for %%A in ("%~dp0.") do (
    set "currentDir=%%~fA"
)

echo Detect a Python 3 with the coverxygen module (a plain "python" is not always the right one)
call "%~dp0detect-python.bat"
if errorlevel 1 (
    echo ERROR: no usable Python 3 found. See messages above.
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
call reportgenerator "-title:Calculator Library Documentation Coverage Report" "-reports:**/lcov_doxygen_lib_win.info" "-targetdir:docs/coverxygenlibwin" "-reporttypes:Html" "-filefilters:-*.md;-*.xml;-*[generated];-*build*" "-historydir:report_doc_lib_hist_win"
call reportgenerator "-reports:**/lcov_doxygen_lib_win.info" "-targetdir:assets/doccoveragelibwin" "-reporttypes:Badges" "-filefilters:-*.md;-*.xml;-*[generated];-*build*"

echo Run Documentation Coverage Report Generator for Unit Tests (ReportGenerator, HTML + history)
call reportgenerator "-title:Calculator Library Test Documentation Coverage Report" "-reports:**/lcov_doxygen_test_win.info" "-targetdir:docs/coverxygentestwin" "-reporttypes:Html" "-filefilters:-*.md;-*.xml;-*[generated];-*build*" "-historydir:report_doc_test_hist_win"
call reportgenerator "-reports:**/lcov_doxygen_test_win.info" "-targetdir:assets/doccoveragetestwin" "-reporttypes:Badges" "-filefilters:-*.md;-*.xml;-*[generated];-*build*"

if "%HAVE_GENHTML%"=="1" (
    echo Run native lcov genhtml Documentation Coverage Report for Library
    call %GENHTML_CMD% --legend --title "Calculator Library Documentation Coverage Report - native genhtml (Windows)" docs\coverxygenlibwin\lcov_doxygen_lib_win.info -o docs\coverxygennativelibwin
    echo Run native lcov genhtml Documentation Coverage Report for Unit Tests
    call %GENHTML_CMD% --legend --title "Calculator Library Test Documentation Coverage Report - native genhtml (Windows)" docs\coverxygentestwin\lcov_doxygen_test_win.info -o docs\coverxygennativetestwin
) else (
    echo Skipping native lcov genhtml documentation-coverage report ^(genhtml/perl not available^).
)

echo Copy the "assets" folder and its contents to "docs" recursively
call robocopy assets "docs\assets" /E

echo Files and folders copied successfully.

echo Package Publish Library Doc Coverage Report
tar -czvf release_win\windows-lib-doc-coverage-report.tar.gz -C docs\coverxygenlibwin .

echo Package Publish Unit Test Doc Coverage Report
tar -czvf release_win\windows-test-doc-coverage-report.tar.gz -C docs\coverxygentestwin .

echo Package Publish Library Documentation
tar -czvf release_win\windows-doxygen-lib-documentation.tar.gz -C docs\doxygenlibwin .

echo Package Publish Unit Test Documentation
tar -czvf release_win\windows-doxygen-test-documentation.tar.gz -C docs\doxygentestwin .

echo ....................
echo Operation Completed!
pause
