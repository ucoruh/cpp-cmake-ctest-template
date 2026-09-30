#!/bin/bash
# 7-build-all-linux.sh - EVERYTHING on Linux (native Linux and WSL; WSL is Linux):
#   build + unit tests (6-build-and-test-linux.sh), then
#   reports/linux/<kind>-<tool>/   every HTML report (tests, code coverage, documentation coverage, Doxygen)
#   site/                          the MkDocs Material site with those reports inside
#   release/                       one archive per output + ASSETS.md + SHA256SUMS.txt
# Open the result with ./9-open-site-linux.sh. Re-runnable.
#
# WSL note: run it from a folder on WSL's own filesystem (e.g. ~/work/<repo>), not from /mnt/g/...
set -u
cd "$(dirname "$(readlink -f "$0")")" || exit 1
# shellcheck disable=SC1091
source scripts/load-project-env-linux.sh || exit 1
source scripts/setup-path-linux.sh
source scripts/detect-compiler-linux.sh
source scripts/detect-python-linux.sh || exit 1

echo "Check the required tools"
fail=0
for tool in doxygen cmake ninja lcov genhtml reportgenerator; do
    command -v "$tool" >/dev/null 2>&1 || { echo "ERROR: '$tool' not found on PATH." >&2; fail=1; }
done
$PY_CMD -c "import coverxygen, mkdocs" >/dev/null 2>&1 || {
    echo "ERROR: $PY_CMD lacks coverxygen/mkdocs. Fix: $PY_CMD -m pip install --user -r requirements.txt" >&2; fail=1; }
command -v junit2html >/dev/null 2>&1 || { echo "ERROR: junit2html not found (pip install --user junit2html)." >&2; fail=1; }
[ "$fail" -eq 0 ] || { echo "Run ./4-install-tools-linux.sh first, then re-run this script." >&2; exit 1; }
HAVE_GCOVR=0; command -v gcovr >/dev/null 2>&1 && HAVE_GCOVR=1
# lcov 2.x (Ubuntu 22.04+, GitHub's ubuntu-latest) is strict: it turns inconsistencies, unused --remove patterns
# and gcc/gcov mismatches into errors. lcov 1.x does not know those --ignore-errors names, so add them only for 2.x.
LCOV_MAJOR="$(lcov --version 2>/dev/null | grep -oE '[0-9]+' | head -1)"
LCOV_IGN=""
if [ "${LCOV_MAJOR:-0}" -ge 2 ]; then
    LCOV_IGN="--ignore-errors unused,mismatch,inconsistent,negative,gcov,source,empty"
fi
echo "lcov major version: ${LCOV_MAJOR:-unknown} ${LCOV_IGN:+(strict mode, using $LCOV_IGN)}"

./6-build-and-test-linux.sh || { echo "ERROR: the build or the unit tests failed - not building reports." >&2; exit 1; }

R="reports/$PLATFORM"; DATA="$R/data"; HIST="reports/history/$PLATFORM"
echo; echo "=== Fresh report and release folders"
rm -rf "$R" release site
mkdir -p "$R/logs" "$DATA" "$HIST" "$R/api-doxygen/lib" "$R/api-doxygen/tests" "$R/doccoverage-lcov" release

STRIP_FROM_PATH="$(pwd)"; export STRIP_FROM_PATH
PLANTUML_JAR_PATH=""; [ -f "$(pwd)/plantuml.jar" ] && PLANTUML_JAR_PATH="$(pwd)/plantuml.jar"; export PLANTUML_JAR_PATH

echo; echo "=== API documentation (Doxygen): libraries and test sources"
export DOXY_TITLE="$PROJECT_NAME (Linux) - library API" DOXY_OUT="$R/api-doxygen/lib" DOXY_LOG="$R/logs/doxygen-lib.log"
doxygen config/Doxyfile-lib || { echo "ERROR: doxygen failed on config/Doxyfile-lib." >&2; exit 1; }
export DOXY_TITLE="$PROJECT_NAME (Linux) - unit tests" DOXY_OUT="$R/api-doxygen/tests" DOXY_LOG="$R/logs/doxygen-tests.log"
doxygen config/Doxyfile-tests || { echo "ERROR: doxygen failed on config/Doxyfile-tests." >&2; exit 1; }

echo; echo "=== Documentation coverage: coverxygen reads the Doxygen XML and writes lcov data"
$PY_CMD -m coverxygen --xml-dir "$R/api-doxygen/lib/xml" --src-dir ./ --format lcov --exclude '.*\.md$' --output "$DATA/doccoverage-lib.info" \
    || { echo "ERROR: coverxygen failed for the libraries." >&2; exit 1; }
$PY_CMD -m coverxygen --xml-dir "$R/api-doxygen/tests/xml" --src-dir ./ --format lcov --exclude '.*\.md$' --output "$DATA/doccoverage-tests.info" \
    || { echo "ERROR: coverxygen failed for the unit tests." >&2; exit 1; }

echo "=== Documentation coverage, family 1: ReportGenerator (HTML + history + badges)"
DOCFILTERS='-*.md;-*.xml;-*[generated];-*build*'
reportgenerator "-title:$PROJECT_NAME library documentation coverage (Linux)" "-reports:$DATA/doccoverage-lib.info" \
    "-targetdir:$R/doccoverage-reportgenerator/lib" "-reporttypes:Html" "-filefilters:$DOCFILTERS" "-historydir:$HIST/doccoverage-lib" || exit 1
reportgenerator "-title:$PROJECT_NAME test documentation coverage (Linux)" "-reports:$DATA/doccoverage-tests.info" \
    "-targetdir:$R/doccoverage-reportgenerator/tests" "-reporttypes:Html" "-filefilters:$DOCFILTERS" "-historydir:$HIST/doccoverage-tests" || exit 1
reportgenerator "-reports:$DATA/doccoverage-lib.info" "-targetdir:assets/badges/linux/doccoverage" "-reporttypes:Badges" "-filefilters:$DOCFILTERS" || true

echo "=== Documentation coverage, family 2: native lcov genhtml"
genhtml $LCOV_IGN --legend --title "$PROJECT_NAME library documentation coverage - genhtml (Linux)" "$DATA/doccoverage-lib.info" -o "$R/doccoverage-lcov/lib" \
    || echo "WARNING: genhtml doc-coverage report (libraries) failed; continuing."
genhtml $LCOV_IGN --legend --title "$PROJECT_NAME test documentation coverage - genhtml (Linux)" "$DATA/doccoverage-tests.info" -o "$R/doccoverage-lcov/tests" \
    || echo "WARNING: genhtml doc-coverage report (tests) failed; continuing."

echo; echo "=== Unit test results: CTest JUnit XML to HTML (junit2html)"
mkdir -p "$R/tests-junit2html"
junit2html "build/$PLATFORM-debug/test-results.xml" "$R/tests-junit2html/index.html" || { echo "ERROR: junit2html failed." >&2; exit 1; }

echo; echo "=== Code coverage (gcov data written by the Debug test run)"
# geninfo (lcov's capture driver) can deadlock reading gcov's output pipe for certain .gcno files on
# some machines (reproduced with lcov 1.14 on WSL2 Ubuntu 20.04) - gcov itself finishes in milliseconds.
# Bound it with `timeout`; if it triggers, the lcov-based reports are skipped and gcovr (an independent
# implementation) still runs. See docs/guide/troubleshooting.en.md.
LCOV_TIMEOUT=180
LCOV_OK=1
INFO="$DATA/coverage.info"
if ! timeout "$LCOV_TIMEOUT" $NOASLR lcov --gcov-tool "$GCOV_BIN" $LCOV_IGN --rc lcov_branch_coverage=1 --capture --initial --directory "build/$PLATFORM-debug" --output-file "$INFO"; then
    echo "WARNING: lcov --capture --initial did not finish within ${LCOV_TIMEOUT}s; skipping the lcov-based coverage reports."
    LCOV_OK=0
fi
if [ "$LCOV_OK" -eq 1 ] && ! timeout "$LCOV_TIMEOUT" $NOASLR lcov --gcov-tool "$GCOV_BIN" $LCOV_IGN --rc lcov_branch_coverage=1 --capture --directory "build/$PLATFORM-debug" --output-file "$INFO"; then
    echo "WARNING: lcov --capture did not finish within ${LCOV_TIMEOUT}s; skipping the lcov-based coverage reports."
    LCOV_OK=0
fi

if [ "$LCOV_OK" -eq 1 ]; then
    lcov --gcov-tool "$GCOV_BIN" $LCOV_IGN --rc lcov_branch_coverage=1 --remove "$INFO" '/usr/*' --output-file "$INFO"
    lcov --gcov-tool "$GCOV_BIN" $LCOV_IGN --rc lcov_branch_coverage=1 --remove "$INFO" '*/googletest/*' --output-file "$INFO"
    lcov --gcov-tool "$GCOV_BIN" $LCOV_IGN --rc lcov_branch_coverage=1 --list "$INFO"

    echo "=== Code coverage, native family: lcov genhtml"
    genhtml $LCOV_IGN --legend --branch-coverage --title "$PROJECT_NAME unit test code coverage - genhtml (Linux)" "$INFO" -o "$R/coverage-lcov" \
        || echo "WARNING: genhtml code-coverage report failed; continuing."

    echo "=== Code coverage, family 1: ReportGenerator (HTML + history + badges)"
    SRCDIRS='src'
    COVFILTERS='-*minkernel\*;-*gtest*;-*a\_work\*;-*gtest-*;-*gtest.cc;-*gtest.h;-*build*'
    reportgenerator "-title:$PROJECT_NAME unit test code coverage (Linux)" "-reports:$INFO" "-targetdir:$R/coverage-reportgenerator" \
        "-reporttypes:Html" "-sourcedirs:$SRCDIRS" "-filefilters:$COVFILTERS" "-historydir:$HIST/coverage" || exit 1
    reportgenerator "-reports:$INFO" "-targetdir:assets/badges/linux/coverage" "-reporttypes:Badges" "-sourcedirs:$SRCDIRS" "-filefilters:$COVFILTERS" || true
fi

if [ "$HAVE_GCOVR" -eq 1 ]; then
    echo "=== Code coverage, native family: gcovr (independent of lcov)"
    mkdir -p "$R/coverage-gcovr"
    # --exclude only filters the *report*; gcovr still runs gcov on every .gcda it finds, including
    # googletest's big gtest-all.cc.gcda, which reproduced the same gcov-pipe hang. --gcov-exclude and
    # --exclude-directories skip it before gcov is invoked; timeout is the second safety net.
    if ! timeout "$LCOV_TIMEOUT" $NOASLR gcovr --root . --object-directory "build/$PLATFORM-debug" --gcov-executable "$GCOV_BIN" \
        --exclude 'src/tests/googletest/.*' --gcov-exclude '.*/googletest.*' --exclude-directories '.*/googletest.*' \
        --html-details "$R/coverage-gcovr/index.html"; then
        echo "WARNING: gcovr did not finish within ${LCOV_TIMEOUT}s or failed; continuing without it."
    fi
fi

echo; echo "=== release/: one archive per output"
$PY_CMD tools/release_assets.py pack --platform "$PLATFORM" --arch "$ARCH" || exit 1

echo "=== The MkDocs site with every report inside"
$PY_CMD tools/build_site.py || { echo "ERROR: the site build or its link check failed - see the messages above." >&2; exit 1; }

echo "=== release/: source.zip, site.zip, ASSETS.md, SHA256SUMS.txt"
$PY_CMD tools/release_assets.py neutral || exit 1

echo
echo "...................."
echo "Operation completed. release/ now holds:"
ls -1 release
echo "Open the site with ./9-open-site-linux.sh"
echo "...................."
