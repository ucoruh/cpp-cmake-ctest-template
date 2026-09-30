@echo off
@setlocal enableextensions
@cd /d "%~dp0"

rem Installs every tool the template uses. Run it from an ADMINISTRATOR terminal (Chocolatey needs it),
rem and run 3-install-package-manager-windows.bat first if `choco` is not installed yet.
rem Safe to re-run: installed tools are skipped / upgraded in place.

where choco >nul 2>&1
if errorlevel 1 (
    echo ERROR: Chocolatey ^(choco^) not found. Run 3-install-package-manager-windows.bat first.
    exit /b 1
)

echo === Build tools: CMake, Ninja, Doxygen, Graphviz, AStyle
choco install cmake ninja doxygen.install graphviz astyle -y --no-progress

echo === Coverage tools: OpenCppCoverage, lcov ^(genhtml^), Strawberry Perl ^(a Windows-native perl that runs genhtml^)
echo     Git for Windows / MSYS2 also put a perl on PATH, but its POSIX-style path handling breaks
echo     native Windows paths when running genhtml - see scripts\detect-genhtml-windows.bat
choco install opencppcoverage lcov strawberryperl -y --no-progress

echo === GitHub CLI ^(gh^) for 10-release-windows.bat
choco install gh -y --no-progress

echo === Python 3
py -3 --version >nul 2>&1
if errorlevel 1 (
    choco install python -y --no-progress
    echo Python was just installed: open a NEW terminal so that "py -3" is on PATH, then re-run this script.
    exit /b 0
)

echo === .NET SDK ^(needed only by the ReportGenerator global tool^)
where dotnet >nul 2>&1
if errorlevel 1 choco install dotnet-sdk -y --no-progress
echo === ReportGenerator
dotnet tool update --global dotnet-reportgenerator-globaltool
if errorlevel 1 dotnet tool install --global dotnet-reportgenerator-globaltool

echo === Python packages: mkdocs-material, coverxygen, junit2html ^(requirements.txt^)
py -3 -m pip install --user --upgrade -r requirements.txt
if errorlevel 1 (
    echo ERROR: pip failed - see the messages above.
    exit /b 1
)

echo === PlantUML ^(optional; used only if a diagram needs it^)
if not exist plantuml.jar (
    curl -sSL -f -o plantuml.jar https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar
    if errorlevel 1 (
        echo NOTE: plantuml.jar could not be downloaded - it is optional, continuing.
        del /Q plantuml.jar >nul 2>&1
    ) else (
        echo plantuml.jar downloaded.
    )
) else (
    echo plantuml.jar already present.
)

echo.
echo Done. Verify with the commands in docs\guide\install.en.md ^(cmake --version, doxygen --version, ...^).
if not defined NO_PAUSE pause
exit /b 0
