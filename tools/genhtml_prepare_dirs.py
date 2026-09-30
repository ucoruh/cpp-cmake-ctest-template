#!/usr/bin/env python3
"""Pre-create the per-source-directory output folders that lcov's genhtml needs on Windows.

On Windows genhtml creates each sub folder of its report with  system("mkdir", $dir)  - one level at a time,
without -p - so a source file in src/calculator/header/ makes it fail with

    genhtml: ERROR: cannot create directory 'calculator\\header'!

because 'calculator' does not exist yet. genhtml only creates a folder that is missing, so creating the whole tree
first makes it work. Called by 7-build-all-windows.bat before every genhtml run:

    python tools/genhtml_prepare_dirs.py reports/windows/data/doccoverage-lib.info reports/windows/doccoverage-lcov/lib

Not needed on Linux (genhtml uses mkdir -p there).
"""
from __future__ import annotations

import os
import sys


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    info, out = sys.argv[1], sys.argv[2]
    dirs = set()
    with open(info, encoding="utf-8", errors="replace") as f:
        for line in f:
            if line.startswith("SF:"):
                path = line[3:].strip().replace("/", os.sep)
                dirs.add(os.path.dirname(path))
    if not dirs:
        print(f"[genhtml_prepare_dirs] no SF: lines in {info}")
        return 0
    # genhtml strips the longest common directory prefix of all source files from the folder names
    common = os.path.commonpath(sorted(dirs)) if len(dirs) > 1 else os.path.dirname(sorted(dirs)[0])
    for d in sorted(dirs):
        rel = os.path.relpath(d, common)
        if rel != ".":
            os.makedirs(os.path.join(out, rel), exist_ok=True)
    print(f"[genhtml_prepare_dirs] {len(dirs)} source folder(s) prepared under {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
