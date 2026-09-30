@echo off
:: detect-python.bat
::
:: On some machines the plain `python` command on PATH resolves to a Python
:: bundled with an unrelated application (this project's own scripts hit a
:: Python 2.7 install that ships with Inkscape) instead of a real Python 3
:: with this project's tools (coverxygen, mkdocs) installed. This script
:: finds a working Python 3 instead of assuming `python` is the right one.
::
:: Called with `call detect-python.bat` (no setlocal here on purpose, so the
:: variables below stay set for the caller after this script returns).
::
:: Sets on success:
::   PY_CMD        command to run Python 3 with, e.g. "py -3" or "python3"
::   PY_SCRIPTS    that interpreter's Scripts directory (for tools that only
::                 install a console-script .exe, not a runnable module -
::                 e.g. junit2html)
:: Returns errorlevel 1 if no Python 3 with "coverxygen" installed was found.

set "PY_CMD="
set "PY_SCRIPTS="

py -3 -c "import coverxygen" >nul 2>&1
if not errorlevel 1 set "PY_CMD=py -3"

if not defined PY_CMD (
    python3 -c "import coverxygen" >nul 2>&1
    if not errorlevel 1 set "PY_CMD=python3"
)

if not defined PY_CMD (
    python -c "import coverxygen" >nul 2>&1
    if not errorlevel 1 set "PY_CMD=python"
)

if not defined PY_CMD (
    echo [detect-python] ERROR: no Python 3 interpreter with the "coverxygen" module was found.
    echo [detect-python] The plain "python" command on this machine currently resolves to:
    where python 2>nul
    echo [detect-python] That is frequently the WRONG one ^(e.g. a Python 2 bundled with
    echo [detect-python] another application, such as Inkscape or GIMP^) rather than a real
    echo [detect-python] Python 3. Fix: install a real Python 3 ^(python.org or
    echo [detect-python] `choco install python`^), then run:
    echo [detect-python]   py -3 -m pip install --user coverxygen mkdocs mkdocs-material junit2html
    echo [detect-python] and re-run this script.
    exit /b 1
)

for /f "usebackq delims=" %%S in (`%PY_CMD% -c "import sysconfig; print(sysconfig.get_path('scripts'))" 2^>nul`) do (
    set "PY_SCRIPTS=%%S"
)

echo [detect-python] Using "%PY_CMD%" ^(has coverxygen^); scripts directory: %PY_SCRIPTS%
exit /b 0
