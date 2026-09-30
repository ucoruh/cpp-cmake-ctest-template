@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem Re-creates .gitignore: the standard GitHub/toptal templates for C, C++, CMake, Visual Studio, Java, Maven,
rem C#, Eclipse ... followed by this project's own rules (scripts\gitignore-project-rules.txt).
rem Only needed if .gitignore was lost or you want a fresh copy of the upstream templates.
rem (Overview of the technique: https://github.com/sloria/gig)

set "API_URL=https://www.toptal.com/developers/gitignore/api/c,csharp,vs,visualstudio,visualstudiocode,java,maven,c++,cmake,eclipse,netbeans"

curl -sS -f -o .gitignore.new "%API_URL%"
if errorlevel 1 (
    echo ERROR: could not download %API_URL% - .gitignore was left unchanged.
    del /Q .gitignore.new >nul 2>&1
    exit /b 1
)
copy /Y .gitignore.new .gitignore >nul
del /Q .gitignore.new
type scripts\gitignore-project-rules.txt >> .gitignore
echo .gitignore re-created from %API_URL% + scripts\gitignore-project-rules.txt
if not defined NO_PAUSE pause
exit /b 0
