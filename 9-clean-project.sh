#!/bin/bash
# chmod +x 9-clean-project.sh
# ./9-clean-project.sh
#
# Linux/WSL equivalent of 9-clean-project.bat: removes every generated
# output folder/file so the next build starts from a clean state. Safe to
# re-run (rm -rf on a missing path is a no-op, not an error).

currentDir=$(dirname "$(readlink -f "$0")")
cd "$currentDir" || exit 1

echo "Delete generated log/coverage data files"
rm -f doxygen_lib_win.log doxygen_lib_linux.log
rm -f doxygen_test_win.log doxygen_test_linux.log
rm -f utility_tests_unit_win.cov calculator_tests_unit_win.cov
rm -f utility_tests_unit_linux.cov calculator_tests_unit_linux.cov
rm -f LastCoverageResults.log simulation_tests_unit_win_cobertura.xml
rm -f coverage_linux.info *_cobertura.xml
rm -f CMakePresets.json

echo "Delete build/publish/release folders (Windows and Linux)"
rm -rf .vs .vscode out
rm -rf release publish build
rm -rf release_win publish_win build_win
rm -rf release_linux publish_linux build_linux

echo "Delete the 'docs' generated report/documentation folders"
rm -rf docs/coverxygen docs/coveragereport docs/doxygen
rm -rf docs/coverxygenlibwin docs/coverxygentestwin
rm -rf docs/coverxygennativelibwin docs/coverxygennativetestwin
rm -rf docs/coveragereportlibwin docs/coveragenativelibwin
rm -rf docs/doxygenlibwin docs/doxygentestwin
rm -rf docs/coverxygenliblinux docs/coverxygentestlinux
rm -rf docs/coverxygennativeliblinux docs/coverxygennativetestlinux
rm -rf docs/coveragereportliblinux docs/coveragenativeliblinux
rm -rf docs/doxygenliblinux docs/doxygentestlinux
rm -rf docs/testresultswin docs/testresultslinux
rm -rf docs/assets
rm -f docs/*.zip

echo "Delete the 'site' folder"
rm -rf site

echo "Clean complete."
