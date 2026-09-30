#!/bin/bash
# detect-python-linux.sh - SOURCE it. Sets PY_CMD to a Python 3 (python3, else python).
PY_CMD=""
if command -v python3 >/dev/null 2>&1; then
    PY_CMD="python3"
elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] == 3 else 1)' 2>/dev/null; then
    PY_CMD="python"
fi
if [ -z "$PY_CMD" ]; then
    echo "[detect-python] ERROR: no Python 3 found. Install it: sudo apt install python3 python3-pip" >&2
    return 1 2>/dev/null || exit 1
fi
export PY_CMD
