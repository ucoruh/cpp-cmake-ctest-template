@echo off
:: detect-genhtml.bat
::
:: `genhtml` (from lcov, e.g. `choco install lcov`) is a Perl script with no
:: file extension. `where genhtml` finds it, but cmd.exe still reports
:: "'genhtml' is not recognized" if you try to run it directly, because a
:: bare extension-less file is not something cmd knows how to execute; it
:: has to be run as `perl <path-to-genhtml>`. This script finds both genhtml
:: and perl and builds the right command line, or fails soft (this native
:: report is a nice-to-have alongside the ReportGenerator HTML, not a
:: required one) with a clear fix.
::
:: Called with `call detect-genhtml.bat` (no setlocal, so GENHTML_CMD stays
:: set for the caller).
::
:: Sets on success: GENHTML_CMD, e.g.  perl "C:\...\lcov\tools\bin\genhtml"
:: Returns errorlevel 1 if genhtml and/or perl could not be found.

set "GENHTML_CMD="
set "GENHTML_FILE="

for /f "usebackq delims=" %%G in (`where genhtml 2^>nul`) do (
    if not defined GENHTML_FILE set "GENHTML_FILE=%%G"
)

if not defined GENHTML_FILE (
    echo [detect-genhtml] genhtml ^(from lcov^) was not found on PATH; skipping the native
    echo [detect-genhtml] lcov/genhtml documentation-coverage report. Fix: choco install lcov -y
    exit /b 1
)

where perl >nul 2>&1
if errorlevel 1 (
    echo [detect-genhtml] Found genhtml at "%GENHTML_FILE%" but no perl interpreter to run it
    echo [detect-genhtml] with; skipping the native report. Fix: choco install strawberryperl -y
    exit /b 1
)

set "GENHTML_CMD=perl "%GENHTML_FILE%""
echo [detect-genhtml] Using: %GENHTML_CMD%
exit /b 0
