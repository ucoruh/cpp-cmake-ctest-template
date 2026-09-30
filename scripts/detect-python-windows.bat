@echo off
:: detect-python-windows.bat
::
:: On some machines the plain `python` command on PATH resolves to a Python bundled with an
:: unrelated application (a Python 2.7 that ships with Inkscape, for example) instead of a real
:: Python 3 that has this project's tools installed. This script finds a working Python 3.
::
:: Called with `call scripts\detect-python-windows.bat` (no setlocal on purpose, so the variables
:: below stay set for the caller).
::
:: If PY_CMD is already set in your environment (for example  set PY_CMD=py -3.12 ) and works,
:: it is used as it is.
::
:: Sets on success:
::   PY_CMD        command that runs Python 3, e.g. "py -3" or "python3"
::   PY_SCRIPTS    that interpreter's Scripts directory (console scripts such as junit2html.exe)
:: Returns errorlevel 1 if no Python 3 with the modules "coverxygen", "mkdocs" and "mkdocs_static_i18n" was found.

set "PY_PRESET=%PY_CMD%"
set "PY_CMD="
set "PY_SCRIPTS="

if defined PY_PRESET (
    %PY_PRESET% -c "import coverxygen, mkdocs, mkdocs_static_i18n" >nul 2>&1
    if not errorlevel 1 set "PY_CMD=%PY_PRESET%"
)
if not defined PY_CMD (
    py -3 -c "import coverxygen, mkdocs, mkdocs_static_i18n" >nul 2>&1
    if not errorlevel 1 set "PY_CMD=py -3"
)
if not defined PY_CMD (
    python3 -c "import coverxygen, mkdocs, mkdocs_static_i18n" >nul 2>&1
    if not errorlevel 1 set "PY_CMD=python3"
)
if not defined PY_CMD (
    python -c "import coverxygen, mkdocs, mkdocs_static_i18n" >nul 2>&1
    if not errorlevel 1 set "PY_CMD=python"
)

if not defined PY_CMD (
    echo [detect-python] ERROR: no Python 3 interpreter with the modules "coverxygen", "mkdocs" and "mkdocs_static_i18n" was found.
    echo [detect-python] The plain "python" command on this machine currently resolves to:
    where python 2>nul
    echo [detect-python] That is frequently the WRONG one ^(e.g. a Python 2 bundled with another
    echo [detect-python] application such as Inkscape or GIMP^) rather than a real Python 3. Fix: install
    echo [detect-python] a real Python 3 ^(python.org or `choco install python`^), then run:
    echo [detect-python]   py -3 -m pip install --user -r requirements.txt
    echo [detect-python] ^(or just 4-install-tools-windows.bat^) and re-run this script.
    exit /b 1
)

for /f "usebackq delims=" %%S in (`%PY_CMD% -c "import sysconfig; print(sysconfig.get_path('scripts', 'nt_user'))" 2^>nul`) do (
    set "PY_SCRIPTS=%%S"
)
if not exist "%PY_SCRIPTS%\junit2html.exe" (
    for /f "usebackq delims=" %%S in (`%PY_CMD% -c "import sysconfig; print(sysconfig.get_path('scripts'))" 2^>nul`) do (
        set "PY_SCRIPTS=%%S"
    )
)

echo [detect-python] Using "%PY_CMD%" ^(has coverxygen and mkdocs^); scripts directory: %PY_SCRIPTS%
exit /b 0
