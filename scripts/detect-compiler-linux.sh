#!/bin/bash
# detect-compiler-linux.sh - SOURCE it.
#
# Picks a GCC and, critically, a *matching* gcov: a distro can have several GCC versions installed
# side by side (Ubuntu 20.04 has gcc-7, gcc-9 and gcc-13 here) and the default `gcc`/`gcov` are not
# guaranteed to be the same version. Coverage data written by one GCC version's .gcno/.gcda format
# is not always readable by a differently-versioned gcov ("version 'A94*', prefer 'A75*'" /
# "GCOV did not produce any data"). Prefer the newest GCC found and use the gcov with the same
# version suffix for lcov/gcovr.
#
# Sets: GCC_BIN, GXX_BIN, GCOV_BIN, NOASLR.
#   NOASLR is a command prefix ("setarch <arch> -R") that disables ASLR for the wrapped command:
#   on WSL2 a `gcov` process can spin forever at ~14 GB virtual memory instead of finishing in
#   milliseconds (known WSL2 ASLR interaction); harmless elsewhere.
GCC_BIN="gcc"
GCOV_BIN="gcov"
for ver in 14 13 12 11 10 9; do
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
NOASLR=""
if command -v setarch >/dev/null 2>&1; then
    NOASLR="setarch $(uname -m) -R"
fi
export GCC_BIN GXX_BIN GCOV_BIN NOASLR
