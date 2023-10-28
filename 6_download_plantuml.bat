@echo off
setlocal enabledelayedexpansion

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
