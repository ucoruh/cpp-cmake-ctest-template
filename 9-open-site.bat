@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem Serves the built documentation site locally over a real HTTP server (not
rem file://) and opens it in your browser. A real server is required because
rem every report page embeds its report in an <iframe>, and most browsers
rem block iframes whose src is a local file:// path - see
rem docs\guide\reports-in-site.en.md. Run 7-build-app-windows.bat (or
rem 7-build-doc-windows.bat) first so site\index.html and docs\ exist.
rem
rem Usage: 9-open-site.bat [port]   (default port: 8000)

set "PORT=8000"
if not "%~1"=="" set "PORT=%~1"

if exist "site\index.html" (
    set "SERVE_DIR=%CD%\site"
    set "SERVE_WHAT=the mkdocs site"
) else if exist "docs\doxygenlibwin\html\index.html" (
    echo site\index.html not found ^(mkdocs build has not been run^); serving the
    echo Doxygen library API documentation instead: docs\doxygenlibwin\html
    set "SERVE_DIR=%CD%\docs\doxygenlibwin\html"
    set "SERVE_WHAT=the Doxygen library API documentation"
) else (
    echo Neither site\index.html nor docs\doxygenlibwin\html\index.html was found.
    echo Run 7-build-app-windows.bat or 7-build-doc-windows.bat first, then re-run this script.
    exit /b 1
)

echo Detect a Python 3 to serve the site over HTTP
set "PY_CMD="
py -3 --version >nul 2>&1 && set "PY_CMD=py -3"
if not defined PY_CMD (
    python3 --version >nul 2>&1 && set "PY_CMD=python3"
)
if not defined PY_CMD (
    python --version >nul 2>&1 && set "PY_CMD=python"
)
if not defined PY_CMD (
    echo ERROR: no Python ^(py -3 / python3 / python^) found on PATH to serve the site.
    echo Install Python - see docs\guide\install.en.md - then re-run this script.
    exit /b 1
)

echo Starting a local HTTP server for %SERVE_WHAT% ^(%SERVE_DIR%^) on port %PORT% ...
echo If port %PORT% is already in use, re-run as: 9-open-site.bat ^<a-different-port^>
start "cpp-cmake-ctest-template site (port %PORT%) - close this window to stop the server" ^
    cmd /k "cd /d "%SERVE_DIR%" && %PY_CMD% -m http.server %PORT%"

rem Give the server a moment to bind the port before opening the browser.
ping -n 3 127.0.0.1 >nul

echo Opening http://localhost:%PORT%/ in your default browser
start "" "http://localhost:%PORT%/"

echo.
echo The site is being served at http://localhost:%PORT%/ in a separate window.
echo Close that window (or press Ctrl+C inside it) when you are done to stop the server.
