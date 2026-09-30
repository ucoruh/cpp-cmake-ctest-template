@echo off
@setlocal enableextensions enabledelayedexpansion
@cd /d "%~dp0"

rem 7-build-all-windows.bat - EVERYTHING on Windows:
rem   build + unit tests (6-build-and-test-windows.bat), then
rem   reports\windows\<kind>-<tool>\   every HTML report (tests, code coverage, documentation coverage, Doxygen)
rem   site\                             the MkDocs Material site with those reports inside
rem   release\                          one archive per output + ASSETS.md + SHA256SUMS.txt
rem Open the result with 9-open-site-windows.bat. Re-runnable.

call "%~dp0scripts\load-project-env-windows.bat"
if errorlevel 1 exit /b 1

echo Detect a Python 3 with coverxygen and mkdocs ^(a plain "python" is not always the right one^)
call "%~dp0scripts\detect-python-windows.bat"
if errorlevel 1 (
    echo ERROR: no usable Python 3 found. See the messages above.
    exit /b 1
)
call "%~dp0scripts\detect-genhtml-windows.bat"
set "HAVE_GENHTML=1"
if errorlevel 1 set "HAVE_GENHTML=0"

set "DO_PAUSE="
if not defined NO_PAUSE set "DO_PAUSE=1"
set "NO_PAUSE=1"
call "%~dp06-build-and-test-windows.bat"
if errorlevel 1 (
    echo ERROR: the build or the unit tests failed - not building reports.
    exit /b 1
)

set "R=reports\%PLATFORM%"
set "DATA=%R%\data"
set "HIST=reports\history\%PLATFORM%"

echo.
echo === Fresh report and release folders
if exist "%R%" rd /S /Q "%R%"
if exist release rd /S /Q release
if exist site rd /S /Q site
mkdir "%R%\logs" "%DATA%" "%R%\api-doxygen\lib" "%R%\api-doxygen\tests" release
if errorlevel 1 exit /b 1
if not exist "%HIST%" mkdir "%HIST%"
mkdir "%R%\doccoverage-lcov"

set "STRIP_FROM_PATH=%CD%"
set "PLANTUML_JAR_PATH="
if exist "%CD%\plantuml.jar" set "PLANTUML_JAR_PATH=%CD%\plantuml.jar"

echo.
echo === API documentation ^(Doxygen^): libraries and test sources
set "DOXY_TITLE=%PROJECT_NAME% (Windows) - library API"
set "DOXY_OUT=%R%\api-doxygen\lib"
set "DOXY_LOG=%R%\logs\doxygen-lib.log"
call doxygen config\Doxyfile-lib
if errorlevel 1 (
    echo ERROR: doxygen failed on config\Doxyfile-lib.
    exit /b 1
)
set "DOXY_TITLE=%PROJECT_NAME% (Windows) - unit tests"
set "DOXY_OUT=%R%\api-doxygen\tests"
set "DOXY_LOG=%R%\logs\doxygen-tests.log"
call doxygen config\Doxyfile-tests
if errorlevel 1 (
    echo ERROR: doxygen failed on config\Doxyfile-tests.
    exit /b 1
)

echo.
echo === Documentation coverage: coverxygen reads the Doxygen XML and writes lcov data
call %PY_CMD% -m coverxygen --xml-dir "%R%/api-doxygen/lib/xml" --src-dir ./ --format lcov --exclude ".*\.md$" --exclude ".*\[generated\]$" --output "%DATA%/doccoverage-lib.info"
if errorlevel 1 (
    echo ERROR: coverxygen failed for the libraries.
    exit /b 1
)
call %PY_CMD% -m coverxygen --xml-dir "%R%/api-doxygen/tests/xml" --src-dir ./ --format lcov --exclude ".*\.md$" --exclude ".*\[generated\]$" --output "%DATA%/doccoverage-tests.info"
if errorlevel 1 (
    echo ERROR: coverxygen failed for the unit tests.
    exit /b 1
)

echo === Documentation coverage, family 1: ReportGenerator ^(HTML + history + badges^)
set "DOCFILTERS=-*.md;-*.xml;-*[generated];-*build*"
call reportgenerator "-title:%PROJECT_NAME% library documentation coverage (Windows)" "-reports:%DATA%/doccoverage-lib.info" "-targetdir:%R%/doccoverage-reportgenerator/lib" "-reporttypes:Html" "-filefilters:%DOCFILTERS%" "-historydir:%HIST%/doccoverage-lib"
if errorlevel 1 exit /b 1
call reportgenerator "-title:%PROJECT_NAME% test documentation coverage (Windows)" "-reports:%DATA%/doccoverage-tests.info" "-targetdir:%R%/doccoverage-reportgenerator/tests" "-reporttypes:Html" "-filefilters:%DOCFILTERS%" "-historydir:%HIST%/doccoverage-tests"
if errorlevel 1 exit /b 1
call reportgenerator "-reports:%DATA%/doccoverage-lib.info" "-targetdir:assets/badges/windows/doccoverage" "-reporttypes:Badges" "-filefilters:%DOCFILTERS%"

echo === Documentation coverage, family 2: native lcov genhtml
if "%HAVE_GENHTML%"=="1" (
    rem genhtml on Windows creates sub folders one level at a time: create the tree first (tools\genhtml_prepare_dirs.py)
    call %PY_CMD% tools\genhtml_prepare_dirs.py "%DATA%\doccoverage-lib.info" "%R%\doccoverage-lcov\lib"
    call %GENHTML_CMD% --legend --title "%PROJECT_NAME% library documentation coverage - genhtml (Windows)" "%DATA%\doccoverage-lib.info" -o "%R%\doccoverage-lcov\lib"
    call %PY_CMD% tools\genhtml_prepare_dirs.py "%DATA%\doccoverage-tests.info" "%R%\doccoverage-lcov\tests"
    call %GENHTML_CMD% --legend --title "%PROJECT_NAME% test documentation coverage - genhtml (Windows)" "%DATA%\doccoverage-tests.info" -o "%R%\doccoverage-lcov\tests"
) else (
    echo WARNING: genhtml/perl not available - skipping the native lcov documentation-coverage report.
)

echo.
echo === Unit test results: CTest JUnit XML to HTML ^(junit2html^)
set "JUNIT2HTML_EXE=%PY_SCRIPTS%\junit2html.exe"
if not exist "%JUNIT2HTML_EXE%" set "JUNIT2HTML_EXE=junit2html"
mkdir "%R%\tests-junit2html"
call "%JUNIT2HTML_EXE%" "build\%PLATFORM%-debug\test-results.xml" "%R%\tests-junit2html\index.html"
if errorlevel 1 (
    echo ERROR: junit2html failed ^(py -3 -m pip install --user junit2html^).
    exit /b 1
)

echo.
echo === Code coverage with OpenCppCoverage ^(runs every Debug test executable *_tests.exe^)
rem Generic on purpose: any *_tests.exe you add is picked up, and everything under src\ except googletest is measured.
set "TESTBIN=build\%PLATFORM%-debug\bin\Debug"
set "COV_INPUTS="
for %%T in ("%TESTBIN%\*_tests.exe") do (
    call OpenCppCoverage.exe --quiet --export_type=binary:"%DATA%\%%~nT.cov" --sources "%CD%\src" --excluded_sources googletest -- "%%T"
    if errorlevel 1 exit /b 1
    set "COV_INPUTS=!COV_INPUTS! --input_coverage=%DATA%\%%~nT.cov"
)
echo Combine the runs: Cobertura XML ^(input for ReportGenerator^) AND OpenCppCoverage's own native HTML, side by side
call OpenCppCoverage.exe --quiet %COV_INPUTS% --export_type=cobertura:"%DATA%\cobertura.xml" --export_type=html:"%R%\coverage-opencppcoverage" --sources "%CD%\src" --excluded_sources googletest
if errorlevel 1 exit /b 1

echo === Code coverage, family 1: ReportGenerator ^(HTML + history + badges^)
set "SRCDIRS=src"
set "COVFILTERS=-*minkernel\*;-*gtest*;-*a\_work\*;-*gtest-*;-*gtest.cc;-*gtest.h;-*build*"
call reportgenerator "-title:%PROJECT_NAME% unit test code coverage (Windows)" "-reports:%DATA%/cobertura.xml" "-targetdir:%R%/coverage-reportgenerator" "-reporttypes:Html" "-sourcedirs:%SRCDIRS%" "-filefilters:%COVFILTERS%" "-historydir:%HIST%/coverage"
if errorlevel 1 exit /b 1
call reportgenerator "-reports:%DATA%/cobertura.xml" "-targetdir:assets/badges/windows/coverage" "-reporttypes:Badges" "-sourcedirs:%SRCDIRS%" "-filefilters:%COVFILTERS%"

echo.
echo === release\: one archive per output
call %PY_CMD% tools\release_assets.py pack --platform %PLATFORM% --arch %ARCH%
if errorlevel 1 exit /b 1

echo === The MkDocs site with every report inside
call %PY_CMD% tools\build_site.py
if errorlevel 1 (
    echo ERROR: the site build or its link check failed - see the messages above.
    exit /b 1
)

echo === release\: source.zip, site.zip, ASSETS.md, SHA256SUMS.txt
call %PY_CMD% tools\release_assets.py neutral
if errorlevel 1 exit /b 1

echo.
echo ....................
echo Operation completed. release\ now holds:
dir /B release
echo Open the site with 9-open-site-windows.bat
echo ....................
if defined DO_PAUSE pause
exit /b 0
