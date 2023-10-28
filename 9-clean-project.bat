@echo off
setlocal enableextensions
cd /d "%~dp0"

rem Delete Generated Previously Files
del /Q /F "doxygen_lib_win.log"
del /Q /F "doxygen_lib_linux.log"

del /Q /F "doxygen_test_win.log"
del /Q /F "doxygen_test_linux.log"

del /Q /F "utility_tests_unit_win.cov"
del /Q /F "calculator_tests_unit_win.cov"


del /Q /F "utility_tests_unit_linux.cov"
del /Q /F "calculator_tests_unit_linux.cov"


del /Q /F "LastCoverageResults.log"
del /Q /F "simulation_tests_unit_win_cobertura.xml"

del /Q /F "CMakePresets.json"

echo Delete and Create Required Folders and Their Files.
rd /S /Q ".vs"
rd /S /Q ".vscode"
rd /S /Q "out"
rd /S /Q "release"
rd /S /Q "publish"
rd /S /Q "build"
rd /S /Q "release_win"
rd /S /Q "publish_win"
rd /S /Q "build_win"
rd /S /Q "release_linux"
rd /S /Q "publish_linux"
rd /S /Q "build_linux"

echo Delete the "docs" folder and its contents
rd /S /Q "docs\coverxygen"
rd /S /Q "docs\coveragereport"
rd /S /Q "docs\doxygen"
rd /S /Q "docs\coverxygenlibwin"
rd /S /Q "docs\coverxygentestwin"
rd /S /Q "docs\coveragereportlibwin"
rd /S /Q "docs\coveragereporttestwin"
rd /S /Q "docs\doxygenlibwin"
rd /S /Q "docs\doxygentestwin"
rd /S /Q "docs\coverxygenliblinux"
rd /S /Q "docs\coverxygentestlinux"
rd /S /Q "docs\coveragereportliblinux"
rd /S /Q "docs\coveragereporttestlinux"
rd /S /Q "docs\doxygenliblinux"
rd /S /Q "docs\doxygentestlinux"
rd /S /Q "docs\testresultswin"
rd /S /Q "docs\testresultslinux"

echo Delete the "site" folder and its contents
rd /S /Q "site"
