#!/bin/bash
# 11-clean-linux.sh - removes every generated folder and file; the next build starts from zero.
# Re-runnable (rm -rf on a missing path is not an error).
cd "$(dirname "$(readlink -f "$0")")" || exit 1
echo "Removing generated folders..."
rm -rf build publish reports release site site-native docs/assets docs/raw docs/downloads .vs out
echo "Removing generated files in the repository root..."
rm -f ./*.cov ./*_cobertura.xml ./*.log LastCoverageResults.log coverage_*.info .gitignore.new
echo "Clean complete."
