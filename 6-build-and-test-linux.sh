#!/bin/bash
# 6-build-and-test-linux.sh - the FAST loop: configure, build (Debug and Release) and run the unit tests.
# Works on native Linux and in WSL (WSL is Linux: same script, Linux binaries).
#   build/linux-debug/      build tree, Debug   (bin/Debug/*, test-results.xml, gcov data)
#   build/linux-release/    build tree, Release
#   publish/linux-<arch>/{debug,release}/   cmake --install output (bin/, lib/, include/)
# Reports, API docs, the site and release/ come from 7-build-all-linux.sh.
#
# WSL note: run it from a folder on WSL's own filesystem (e.g. ~/work/<repo>), not from /mnt/g/...
# (a Google Drive path is not reachable from WSL, and DrvFs paths are very slow to build on).
set -u
cd "$(dirname "$(readlink -f "$0")")" || exit 1
# shellcheck disable=SC1091
source scripts/load-project-env-linux.sh || exit 1
source scripts/setup-path-linux.sh
source scripts/detect-compiler-linux.sh

echo "=== $PROJECT_NAME $VERSION - build and test on $PLATFORM-$ARCH"
echo "Compiler: $GCC_BIN/$GXX_BIN ($($GCC_BIN --version | head -1)), gcov: $GCOV_BIN"
for tool in cmake ninja "$GCC_BIN"; do
    command -v "$tool" >/dev/null 2>&1 || { echo "ERROR: '$tool' not found. Run ./4-install-tools-linux.sh first." >&2; exit 1; }
done
[ -f src/tests/googletest/CMakeLists.txt ] || { echo "ERROR: the googletest submodule is missing. Run ./0-init-submodules-linux.sh first." >&2; exit 1; }

rm -rf "publish/$PLATFORM-$ARCH"

one() {   # $1 = debug|release   $2 = Debug|Release
    local dir="build/$PLATFORM-$1"
    echo; echo "=== Configure $2 (Ninja)"
    cmake -S . -B "$dir" -G Ninja -DCMAKE_BUILD_TYPE="$2" -DCMAKE_C_COMPILER="$GCC_BIN" -DCMAKE_CXX_COMPILER="$GXX_BIN" \
        || { echo "ERROR: CMake configure failed for $2." >&2; return 1; }
    echo "=== Build $2"
    cmake --build "$dir" --config "$2" --parallel || { echo "ERROR: the $2 build failed." >&2; return 1; }
    echo "=== Unit tests $2 (CTest)"
    ( cd "$dir" && ctest -C "$2" --output-on-failure --output-junit test-results.xml --output-log test-results.log ) \
        || { echo "ERROR: one or more $2 tests failed - see $dir/test-results.log" >&2; return 1; }
    echo "=== Install $2 to publish/$PLATFORM-$ARCH/$1"
    cmake --install "$dir" --config "$2" --prefix "publish/$PLATFORM-$ARCH/$1" || { echo "ERROR: cmake --install failed for $2." >&2; return 1; }
}
one debug Debug || exit 1
one release Release || exit 1

echo
echo "...................."
echo "Build and tests OK  (build/$PLATFORM-debug, build/$PLATFORM-release, publish/$PLATFORM-$ARCH)"
echo "...................."
