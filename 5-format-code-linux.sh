#!/bin/bash
# 5-format-code-linux.sh - formats every .h/.cpp under src/ with AStyle (astyle-options.txt).
cd "$(dirname "$(readlink -f "$0")")" || exit 1
echo "Formatting code with AStyle (astyle-options.txt)..."
astyle --options="astyle-options.txt" --recursive "src/*.h" "src/*.cpp" --exclude=googletest
