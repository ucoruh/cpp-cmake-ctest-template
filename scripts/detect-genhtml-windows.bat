@echo off
:: detect-genhtml-windows.bat
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
:: The perl on PATH matters: on a machine with Git for Windows or MSYS2
:: installed, `where perl` commonly lists that MSYS-flavoured perl
:: (...\Git\usr\bin\perl.exe / ...\msys64\usr\bin\perl.exe) *before* a
:: Windows-native one - confirmed on this project's own test machine. That
:: perl runs genhtml but its POSIX-style path handling mishandles native
:: Windows absolute paths (e.g. produces "cannot create directory
:: 'C\Users\...'" - note the missing ':' after the drive letter), so the
:: report silently fails to write its index.html. Skip any perl whose path
:: contains "\usr\bin" and prefer a Windows-native one (e.g. Strawberry
:: Perl) instead.
::
:: Called with `call detect-genhtml-windows.bat` (no setlocal, so GENHTML_CMD stays
:: set for the caller).
::
:: Sets on success: GENHTML_CMD, e.g.  "C:\Strawberry\perl\bin\perl.exe" "C:\...\lcov\tools\bin\genhtml"
:: Returns errorlevel 1 if genhtml and/or a suitable perl could not be found.

set "GENHTML_CMD="
set "GENHTML_FILE="
set "PERL="

for /f "usebackq delims=" %%G in (`where genhtml 2^>nul`) do (
    if not defined GENHTML_FILE set "GENHTML_FILE=%%G"
)

if not defined GENHTML_FILE (
    echo [detect-genhtml] genhtml ^(from lcov^) was not found on PATH; skipping the native
    echo [detect-genhtml] lcov/genhtml documentation-coverage report. Fix: choco install lcov -y
    exit /b 1
)

for /f "delims=" %%P in ('where perl 2^>nul ^| findstr /V /I /L /C:"\usr\bin"') do if not defined PERL set "PERL=%%P"

if not defined PERL (
    echo [detect-genhtml] Found genhtml at "%GENHTML_FILE%" but no Windows-native perl interpreter
    echo [detect-genhtml] to run it with ^(only an MSYS/Git-for-Windows perl, under \usr\bin\, was
    echo [detect-genhtml] found on PATH - it mishandles native Windows paths^); skipping the native
    echo [detect-genhtml] report. Fix: choco install strawberryperl -y
    exit /b 1
)

set "GENHTML_CMD="%PERL%" "%GENHTML_FILE%""
echo [detect-genhtml] Using: %GENHTML_CMD%
exit /b 0
