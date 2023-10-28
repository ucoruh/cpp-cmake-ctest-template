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
call reportgenerator "-title:Calculator Library Documentation Coverage Report" "-reports:**/lcov_doxygen_lib_win.info" "-targetdir:docs/coverxygenlibwin" "-reporttypes:Html" "-filefilters:-*.md;-*.xml;-*[generated];-*build*" "-historydir:report_doc_lib_hist_win"
call reportgenerator "-reports:**/lcov_doxygen_lib_win.info" "-targetdir:assets/doccoveragelibwin" "-reporttypes:Badges" "-filefilters:-*.md;-*.xml;-*[generated];-*build*"

echo Run Documentation Coverage Report Generator for Unit Tests 
call reportgenerator "-title:Calculator Library Test Documentation Coverage Report" "-reports:**/lcov_doxygen_test_win.info" "-targetdir:docs/coverxygentestwin" "-reporttypes:Html" "-filefilters:-*.md;-*.xml;-*[generated];-*build*" "-historydir:report_doc_test_hist_win"
call reportgenerator "-reports:**/lcov_doxygen_test_win.info" "-targetdir:assets/doccoveragetestwin" "-reporttypes:Badges" "-filefilters:-*.md;-*.xml;-*[generated];-*build*"

echo Copy the "assets" folder and its contents to "docs" recursively
call robocopy assets "docs\assets" /E

echo Copy the "README.md" file to "docs\index.md"
call copy README.md "docs\index.md"

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