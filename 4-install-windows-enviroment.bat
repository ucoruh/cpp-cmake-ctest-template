@echo off
@setlocal enableextensions
@cd /d "%~dp0"

echo Installing Windows Development Environment...

echo Installing Astyle...

choco install astyle

echo Installing Ninja and Cmake...

choco install ninja cmake

echo Installing Doxygen...

choco install doxygen.install -y

echo Installing Reportgenerator...

dotnet tool install --global dotnet-reportgenerator-globaltool

echo Installing OpenCppCoverage...

choco install opencppcoverage -y

echo Installing converxygen doxygen XML parser
pip install coverxygen

echo Installing LCOV Report Generator...
choco install lcov -y
echo lcov and genhtml located on C:\ProgramData\chocolatey\lib\lcov\tools\bin\


rem force re-install need "--force --force-dependencies -y" parameters

REM Test if Pandoc is installed
where pandoc >nul 2>&1
if %errorlevel%==0 (
    echo Pandoc is already installed.
) else (
    echo Installing Pandoc...
    choco install pandoc -y
)

REM Test if rsvg-convert is installed
where rsvg-convert >nul 2>&1
if %errorlevel%==0 (
    echo rsvg-convert is already installed.
) else (
    echo Installing rsvg-convert...
    choco install rsvg-convert -y
)

REM Test if Python is installed
where python >nul 2>&1
if %errorlevel%==0 (
    echo Python is already installed.
) else (
    echo Installing Python...
    choco install python -y
)

REM Test if Miktex is installed
where miktex >nul 2>&1
if %errorlevel%==0 (
    echo Miktex is already installed.
) else (
    echo Installing Miktex...
    choco install miktex -y
)

REM Test if CuRL is installed
where curl >nul 2>&1
if %errorlevel%==0 (
    echo curl is already installed.
) else (
    echo Installing CuRL...
    choco install curl -y
)

REM Test if MARP-CLI is installed
where marp >nul 2>&1
if %errorlevel%==0 (
    echo MARP-CLI is already installed.
) else (
    echo Installing MARP-CLI...
    choco install marp-cli -y
)

REM Test if Doxygen is installed
where doxygen >nul 2>&1
if %errorlevel%==0 (
    echo MARP-CLI is already installed.
) else (
    echo Installing Doxygen...
    choco install doxygen.install -y
)

REM Test if Doxygen is installed
where dot >nul 2>&1
if %errorlevel%==0 (
    echo Graphviz is already installed.
) else (
    echo Installing Graphviz...
    choco install graphviz -y
)

pip install mkdocs
pip install pymdown-extensions
pip install mkdocs-material
pip install mkdocs-material-extensions
pip install mkdocs-simple-hooks
pip install mkdocs-video
pip install mkdocs-minify-plugin
pip install mkdocs-git-revision-date-localized-plugin
pip install mkdocs-minify-plugin
pip install mkdocs-static-i18n
pip install mkdocs-with-pdf
pip install qrcode
pip install mkdocs-awesome-pages-plugin
pip install mkdocs-embed-external-markdown
pip install mkdocs-include-markdown-plugin
pip install mkdocs-ezlinks-plugin
pip install mkdocs-git-authors-plugin
pip install mkdocs-git-committers-plugin
pip install mkdocs-exclude

pip install pptx2md

pip install junit2html

echo Download Plantuml Jar...

echo Deleting PlantUML jar file...
del plantuml.jar

echo Download and install jq
curl -sL -o jq.exe https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe

echo Extract download URL that ends with "plantuml.jar" from JSON response using jq
for /f "delims=" %%a in ('curl -s https://api.github.com/repos/plantuml/plantuml/releases/latest ^| jq -r ".assets[] | select(.name | endswith(\"plantuml.jar\")) | .browser_download_url"') do (
    set download_url=%%a
)

echo Download plantuml.jar
curl -sL -o plantuml.jar "%download_url%"

echo Download URL: %download_url%
echo PlantUML downloaded successfully!

echo Deleting PlantUML jar file...
del jq.exe

pause