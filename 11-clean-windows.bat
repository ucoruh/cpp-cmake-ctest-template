@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem 11-clean-windows.bat - removes every generated folder and file; the next build starts from zero.
rem Re-runnable (a missing folder is not an error).
echo Removing generated folders...
for %%D in (build publish reports release site site-native docs\assets docs\raw docs\downloads .vs out) do (
    if exist "%%D" rd /S /Q "%%D"
)
echo Removing generated files in the repository root...
del /Q /F *.cov *_cobertura.xml *.log LastCoverageResults.log coverage_*.info .gitignore.new 2>nul
echo Clean complete.
if not defined NO_PAUSE pause
exit /b 0
