@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem Opens the built documentation site locally. Run 7-build-app-windows.bat
rem (or 7-build-doc-windows.bat) first so site\index.html and docs\ exist.

if exist "site\index.html" (
    echo Opening the mkdocs site: site\index.html
    start "" "site\index.html"
) else if exist "docs\doxygenlibwin\html\index.html" (
    echo site\index.html not found ^(mkdocs build has not been run^); opening the
    echo Doxygen library API documentation instead: docs\doxygenlibwin\html\index.html
    start "" "docs\doxygenlibwin\html\index.html"
) else (
    echo Neither site\index.html nor docs\doxygenlibwin\html\index.html was found.
    echo Run 7-build-app-windows.bat or 7-build-doc-windows.bat first, then re-run this script.
    exit /b 1
)
