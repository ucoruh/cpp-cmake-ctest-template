@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem 9-open-site-windows.bat [port]      (default port 8000)
rem Serves the built site (site\) over a real local web server and opens it in your browser.
rem A server is required: every report page shows its report in an <iframe>, and browsers block
rem iframes of file:// pages. This is how a PRIVATE repository shows its site (GitHub Pages needs Pro):
rem   7-build-all-windows.bat  ->  9-open-site-windows.bat  -> http://localhost:8000/
rem See docs\guide\showcase-without-pages.en.md.

set "PORT=8000"
if not "%~1"=="" set "PORT=%~1"

if not exist "site\index.html" (
    echo site\index.html not found - build the site first: 7-build-all-windows.bat
    exit /b 1
)

set "PY_CMD="
py -3 --version >nul 2>&1 && set "PY_CMD=py -3"
if not defined PY_CMD python3 --version >nul 2>&1 && set "PY_CMD=python3"
if not defined PY_CMD python --version >nul 2>&1 && set "PY_CMD=python"
if not defined PY_CMD (
    echo ERROR: no Python ^(py -3 / python3 / python^) on PATH to serve the site. See docs\guide\install.en.md
    exit /b 1
)

echo Serving %CD%\site on http://localhost:%PORT%/  ^(close the server window to stop it^)
echo If port %PORT% is busy, run: 9-open-site-windows.bat ^<another-port^>
start "site on port %PORT% - close this window to stop the server" cmd /k "cd /d "%CD%\site" && %PY_CMD% -m http.server %PORT%"
ping -n 3 127.0.0.1 >nul
start "" "http://localhost:%PORT%/"
echo.
echo Opened http://localhost:%PORT%/ - the server keeps running in its own window.
exit /b 0
