#!/bin/bash
# chmod +x 7-build-app-linux.sh
# ./7-build-app-linux.sh
#
# Note for WSL users: run this from inside WSL, from a path under WSL's own
# filesystem (e.g. copy the repo to ~/work/cpp-cmake-ctest-template first).
# WSL cannot reliably reach a Windows Google Drive path such as
# /mnt/g/My Drive/... (the Drive virtual filesystem is not exposed to WSL),
# and building on a 9p/DrvFs-mounted Windows path is also much slower.

set -u

# Get the current directory path
currentDir=$(dirname "$(readlink -f "$0")")
cd "$currentDir" || exit 1

# `dotnet tool install --global` (reportgenerator) installs into ~/.dotnet/tools
# and `pip install --user` (junit2html, coverxygen, mkdocs) installs into
# ~/.local/bin; neither is guaranteed to be on PATH in a non-login shell. Put
# a per-user .NET SDK (installed by 4-install-wsl-environment.sh via the
# official dotnet-install.sh, see docs/guide/troubleshooting.en.md) ahead of
# any older distro-packaged `dotnet` (e.g. Ubuntu 20.04 only ships .NET 3.1,
# too old to run current reportgenerator releases - they need .NET 10).
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$HOME/.local/bin:$PATH"

echo "Check required tools are on PATH"
fail=0
for tool in doxygen cmake lcov genhtml reportgenerator; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "[7-build-app-linux] ERROR: '$tool' not found on PATH." >&2
        fail=1
    fi
done
if ! python3 -c "import coverxygen" >/dev/null 2>&1; then
    echo "[7-build-app-linux] ERROR: python3 does not have the 'coverxygen' module." >&2
    echo "[7-build-app-linux]   Fix: python3 -m pip install --user coverxygen" >&2
    fail=1
fi
if [ "$fail" -ne 0 ]; then
    echo "[7-build-app-linux] Run 4-install-wsl-environment.sh first, then re-run this script." >&2
    exit 1
fi
HAVE_GCOVR=0
if command -v gcovr >/dev/null 2>&1; then
    HAVE_GCOVR=1
fi

# Pick a GCC and, critically, a *matching* gcov: a distro can have several
# GCC versions installed side by side (e.g. Ubuntu 20.04 here has gcc-7,
# gcc-9 and gcc-13), and the default `gcc`/`gcov` are not guaranteed to be
# the same version as each other. Coverage data written by one GCC version's
# .gcno/.gcda format is not always readable by a differently-versioned gcov
# ("version 'A94*', prefer 'A75*'" / "GCOV did not produce any data") - this
# is exactly what happens if `gcc` is 9.x but `/usr/bin/gcov` is an
# update-alternatives symlink to gcov-7. Prefer the newest GCC found, and use
# the gcov with the same version suffix for lcov's --gcov-tool.
GCC_BIN="gcc"
GCOV_BIN="gcov"
for ver in 13 12 11 10 9; do
    if command -v "gcc-$ver" >/dev/null 2>&1 && command -v "gcov-$ver" >/dev/null 2>&1; then
        GCC_BIN="gcc-$ver"
        GCOV_BIN="gcov-$ver"
        break
    fi
done
GXX_BIN="${GCC_BIN/gcc/g++}"
if ! command -v "$GXX_BIN" >/dev/null 2>&1; then
    GXX_BIN="g++"
fi
echo "Using compiler $GCC_BIN/$GXX_BIN with matching gcov $GCOV_BIN"
echo "  ($GCC_BIN --version): $($GCC_BIN --version | head -1)"
echo "  ($GCOV_BIN --version): $($GCOV_BIN --version | head -1)"

# gcov (and ASan) runs can be flaky on WSL2: without a matching gcov this
# showed up as "no data produced" (see the GCC/gcov selection above), but a
# second, separate WSL2 issue was hit too - a `gcov` process spinning
# forever at ~14 GB virtual memory instead of finishing in milliseconds,
# hanging the whole build. This is a known WSL2 ASLR interaction; running
# the gcov-heavy commands under `setarch "$(uname -m)" -R` (disable ASLR for
# that command) avoids it. Use it when available; harmless elsewhere.
NOASLR=""
if command -v setarch >/dev/null 2>&1; then
    NOASLR="setarch $(uname -m) -R"
fi

echo "Deletion File Processed with Clean Project Script on Windows Part"

echo "Delete and Create the 'release' folder and its contents"
rm -rf "out"
rm -rf "release_linux"
rm -rf "publish_linux"
rm -rf "build_linux"
mkdir "publish_linux"
mkdir "release_linux"
mkdir "build_linux"

echo "Delete the 'docs' folder and its contents"
rm -rf "docs/coverxygenliblinux"
rm -rf "docs/coverxygentestlinux"
rm -rf "docs/coverxygennativeliblinux"
rm -rf "docs/coverxygennativetestlinux"
rm -rf "docs/coveragereportliblinux"
rm -rf "docs/coveragenativeliblinux"
rm -rf "docs/doxygenliblinux"
rm -rf "docs/doxygentestlinux"
rm -rf "docs/testresultslinux"
mkdir "docs"
mkdir "docs/coverxygenliblinux"
mkdir "docs/coverxygentestlinux"
mkdir "docs/coverxygennativeliblinux"
mkdir "docs/coverxygennativetestlinux"
mkdir "docs/coveragereportliblinux"
mkdir "docs/coveragenativeliblinux"
mkdir "docs/doxygenliblinux"
mkdir "docs/doxygentestlinux"
mkdir "docs/testresultslinux"

echo "Delete the 'site' folder and its contents"
#rm -rf "site"
mkdir -p "site"

echo "Folders are Recreated successfully."

echo "Generate HTML/LATEX/RTF/XML Documentation for Library (No Source Code Only Headers)"
STRIP_FROM_PATH="$currentDir"
export STRIP_FROM_PATH
doxygen DoxyfileLibLinux || { echo "ERROR: doxygen failed on DoxyfileLibLinux." >&2; exit 1; }

echo "Generate HTML/LATEX/RTF/XML Documentation for Unit Tests (Test Sources and Test Data Sets)"
doxygen DoxyfileTestLinux || { echo "ERROR: doxygen failed on DoxyfileTestLinux." >&2; exit 1; }

echo "Not: coverxygen uses doxygen xml output for coverage"

echo "Run Documentation Coverage Data Collector for Library (No Source Code Only Headers)"
python3 -m coverxygen --xml-dir ./docs/doxygenliblinux/xml --src-dir ./ --format lcov --output ./docs/coverxygenliblinux/lcov_doxygen_lib_linux.info || { echo "ERROR: coverxygen failed for the library." >&2; exit 1; }

echo "Run Documentation Coverage Data Collector for Unit Tests (Test Sources and Test Data Sets)"
python3 -m coverxygen --xml-dir ./docs/doxygentestlinux/xml --src-dir ./ --format lcov --output ./docs/coverxygentestlinux/lcov_doxygen_test_linux.info || { echo "ERROR: coverxygen failed for the unit tests." >&2; exit 1; }

echo "Run Documentation Coverage Report Generator for Library (ReportGenerator, HTML + history)"
reportgenerator "-title:Calculator Library Documentation Coverage Report (Linux)" "-reports:**/lcov_doxygen_lib_linux.info" "-targetdir:docs/coverxygenliblinux" "-reporttypes:Html" "-filefilters:-*.md;-*.xml;-*[generated];-*build*" "-historydir:report_doc_lib_hist_linux"
reportgenerator "-reports:**/lcov_doxygen_lib_linux.info" "-targetdir:assets/doccoverageliblinux" "-reporttypes:Badges" "-filefilters:-*.md;-*.xml;-*[generated];-*build*"

echo "Run Documentation Coverage Report Generator for Unit Tests (ReportGenerator, HTML + history)"
reportgenerator "-title:Calculator Library Test Documentation Coverage Report (Linux)" "-reports:**/lcov_doxygen_test_linux.info" "-targetdir:docs/coverxygentestlinux" "-reporttypes:Html" "-filefilters:-*.md;-*.xml;-*[generated];-*build*" "-historydir:report_doc_test_hist_linux"
reportgenerator "-reports:**/lcov_doxygen_test_linux.info" "-targetdir:assets/doccoveragetestlinux" "-reporttypes:Badges" "-filefilters:-*.md;-*.xml;-*[generated];-*build*"

echo "Run native lcov genhtml Documentation Coverage Report for Library"
genhtml --legend --title "Calculator Library Documentation Coverage Report - native genhtml (Linux)" docs/coverxygenliblinux/lcov_doxygen_lib_linux.info -o docs/coverxygennativeliblinux || echo "WARNING: native genhtml doc-coverage report (library) failed; continuing."

echo "Run native lcov genhtml Documentation Coverage Report for Unit Tests"
genhtml --legend --title "Calculator Library Test Documentation Coverage Report - native genhtml (Linux)" docs/coverxygentestlinux/lcov_doxygen_test_linux.info -o docs/coverxygennativetestlinux || echo "WARNING: native genhtml doc-coverage report (tests) failed; continuing."

echo "Testing Application with Coverage"
echo "Configure CMAKE"
cmake -B build_linux -DCMAKE_BUILD_TYPE=Debug -G "Ninja" -DCMAKE_INSTALL_PREFIX:PATH=publish_linux -DCMAKE_C_COMPILER="$GCC_BIN" -DCMAKE_CXX_COMPILER="$GXX_BIN" || { echo "ERROR: CMake configure failed." >&2; exit 1; }
echo "Build CMAKE Debug/Release"
cmake --build build_linux --config Debug -j4 || { echo "ERROR: Debug build failed." >&2; exit 1; }
cmake --build build_linux --config Release -j4 || { echo "ERROR: Release build failed." >&2; exit 1; }
cmake --install build_linux --strip
echo "Test CMAKE"
cd build_linux
# ctest -C Debug -j4 --output-on-failure --output-log test_results_linux.log
ctest -C Debug -j4 --output-junit testResults_linux.xml --output-log test_results_linux.log
testsFailed=$?
if command -v junit2html >/dev/null 2>&1; then
    junit2html testResults_linux.xml testResults_linux.html
    cp testResults_linux.html "../docs/testresultslinux/index.html"
else
    echo "WARNING: junit2html not found (pip install --user junit2html); skipping the native test-results HTML page."
fi
cd ..

if [ "$testsFailed" -ne 0 ]; then
    echo "ERROR: one or more tests failed (see build_linux/test_results_linux.log)." >&2
fi

echo "Running Test Executable"

./publish_linux/bin/utility_tests
./publish_linux/bin/calculator_tests

echo "Running the interactive calculatorapp sample non-interactively with a sample expression:"
echo "2+3*(4-1)" | ./publish_linux/bin/calculatorapp

echo "Generate Test Coverage Data"
# geninfo (lcov's Perl capture driver) is known, on some lcov releases (this
# was reproduced with lcov 1.14 on WSL2 Ubuntu 20.04), to deadlock reading
# gcov's output pipe for certain .gcno files - gcov itself finishes in well
# under a second when run directly, so this is a lcov/geninfo bug, not a gcov
# one (see docs/guide/troubleshooting.en.md). Bound it with `timeout` so a
# hit does not hang the whole build forever; skip the lcov-based reports and
# fall back to gcovr (a different, independent implementation) if it happens.
LCOV_TIMEOUT=180
LCOV_OK=1
if ! timeout "$LCOV_TIMEOUT" $NOASLR lcov --gcov-tool "$GCOV_BIN" --rc lcov_branch_coverage=1 --capture --initial --directory . --output-file coverage_linux.info; then
    echo "WARNING: lcov --capture --initial did not finish within ${LCOV_TIMEOUT}s (known lcov/geninfo"
    echo "  pipe-deadlock issue on some machines, see docs/guide/troubleshooting.en.md); skipping the"
    echo "  lcov-based coverage reports for this run. gcovr below is unaffected (independent tool)."
    LCOV_OK=0
fi
if [ "$LCOV_OK" -eq 1 ] && ! timeout "$LCOV_TIMEOUT" $NOASLR lcov --gcov-tool "$GCOV_BIN" --rc lcov_branch_coverage=1 --capture --directory . --output-file coverage_linux.info; then
    echo "WARNING: lcov --capture did not finish within ${LCOV_TIMEOUT}s; skipping the lcov-based coverage reports for this run."
    LCOV_OK=0
fi

if [ "$LCOV_OK" -eq 1 ]; then
    lcov --gcov-tool "$GCOV_BIN" --rc lcov_branch_coverage=1 --remove coverage_linux.info '/usr/*' --output-file coverage_linux.info
    lcov --gcov-tool "$GCOV_BIN" --rc lcov_branch_coverage=1 --remove coverage_linux.info 'tests/*' --output-file coverage_linux.info
    lcov --gcov-tool "$GCOV_BIN" --rc lcov_branch_coverage=1 --list coverage_linux.info

    echo "Run native lcov genhtml Test Coverage Report"
    genhtml --legend --branch-coverage --title "Calculator Library Unit Test Coverage Report - native genhtml (Linux)" coverage_linux.info -o docs/coveragenativeliblinux || echo "WARNING: native genhtml test-coverage report failed; continuing."

    echo "Generate Test Report (ReportGenerator, HTML + badges + history)"
    reportgenerator "-title:Calculator Library Unit Test Coverage Report (Linux)" "-reports:**/coverage_linux.info" "-targetdir:docs/coveragereportliblinux" "-reporttypes:Html" "-sourcedirs:src/utility/src;src/utility/header;src/calculator/src;src/calculator/header;src/calculatorapp/src;src/calculatorapp/header;src/tests/utility;src/tests/calculator" "-filefilters:-*minkernel\*;-*gtest*;-*a\_work\*;-*gtest-*;-*gtest.cc;-*gtest.h;-*build*" "-historydir:report_test_hist_linux"
    reportgenerator "-reports:**/coverage_linux.info" "-targetdir:assets/codecoverageliblinux" "-reporttypes:Badges" "-sourcedirs:src/utility/src;src/utility/header;src/calculator/src;src/calculator/header;src/calculatorapp/src;src/calculatorapp/header;src/tests/utility;src/tests/calculator" "-filefilters:-*minkernel\*;-*gtest*;-*a\_work\*;-*gtest-*;-*gtest.cc;-*gtest.h;-*build*"
else
    mkdir -p docs/coveragereportliblinux
fi

if [ "$HAVE_GCOVR" -eq 1 ]; then
    echo "Run gcovr Test Coverage Report (additional native tool, side by side with lcov/genhtml)"
    mkdir -p docs/coveragenativeliblinux/gcovr
    $NOASLR gcovr --root . --gcov-executable "$GCOV_BIN" --html-details docs/coveragenativeliblinux/gcovr/index.html --exclude 'src/tests/googletest/.*' || echo "WARNING: gcovr report failed; continuing."
fi

echo "Copy the 'assets' folder and its contents to 'docs' recursively"
cp -R assets "docs/assets"

echo "Copy the 'README.md' file to 'docs/index.md'"
cp README.md "docs/index.md"

echo "Files and folders copied successfully."

echo "Generate Webpage (mkdocs site linking every report, see docs/reports.md 'Which report is which?')"
if python3 -c "import mkdocs" >/dev/null 2>&1; then
    python3 -m mkdocs build || echo "WARNING: mkdocs build failed; the site under site/ was not (re)generated."
else
    echo "WARNING: mkdocs not installed (pip install --user mkdocs mkdocs-material); skipping the site build."
fi

echo "Package Publish Linux Binaries"
tar -czvf release_linux/linux-publish-binaries.tar.gz -C publish_linux .

echo "Package Publish Linux Binaries"
mkdir -p build_linux/build/Release
cp -R src/utility/header build_linux/build/Release
cp -R src/calculator/header build_linux/build/Release
tar -czvf release_linux/linux-release-binaries.tar.gz -C build_linux/build/Release .

echo "Package Publish Debug Linux Binaries"
mkdir -p build_linux/build/Debug
cp -R src/utility/header build_linux/build/Debug
cp -R src/calculator/header build_linux/build/Debug
tar -czvf release_linux/linux-debug-binaries.tar.gz -C build_linux/build/Debug .

echo "Package Publish Test Coverage Report"
tar -czvf release_linux/linux-test-coverage-report.tar.gz -C docs/coveragereportliblinux .

echo "Package Publish Library Doc Coverage Report"
tar -czvf release_linux/linux-lib-doc-coverage-report.tar.gz -C docs/coverxygenliblinux .

echo "Package Publish Unit Test Doc Coverage Report"
tar -czvf release_linux/linux-test-doc-coverage-report.tar.gz -C docs/coverxygentestlinux .

echo "Package Publish Library Documentation"
tar -czvf release_linux/linux-doxygen-lib-documentation.tar.gz -C docs/doxygenliblinux .

echo "Package Publish Unit Test Documentation"
tar -czvf release_linux/linux-doxygen-test-documentation.tar.gz -C docs/doxygentestlinux .

echo Package Publish Test Results Report
tar -czvf release_linux/linux-test-results-report.tar.gz -C docs/testresultslinux .

echo "...................."
echo "Operation Completed!"

if [ "$testsFailed" -ne 0 ]; then
    exit 1
fi
