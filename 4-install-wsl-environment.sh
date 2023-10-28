#!/bin/bash

echo "Installing Development Environment for WSL..."

echo "Installing Astyle..."
sudo apt install astyle -y

echo "Installing Ninja and Cmake..."
sudo apt install ninja-build cmake -y

echo "Installing Doxygen..."
sudo apt install doxygen -y

echo "Installing Reportgenerator..."
dotnet tool install --global dotnet-reportgenerator-globaltool

echo "Installing OpenCppCoverage via pip..."
pip install gcovr

echo "Installing converxygen doxygen XML parser..."
pip install coverxygen

echo "Installing Pandoc..."
sudo apt install pandoc -y

echo "Installing rsvg-convert..."
sudo apt install librsvg2-bin -y

echo "Installing Python..."
sudo apt install python3 python3-pip -y

echo "Installing MikTeX..."
# MikTeX might require an external PPA or manual installation on Linux

echo "Installing CuRL..."
sudo apt install curl -y

echo "Installing Graphviz..."
sudo apt install graphviz -y

pip install mkdocs \
            pymdown-extensions \
            mkdocs-material \
            mkdocs-material-extensions \
            mkdocs-simple-hooks \
            mkdocs-video \
            mkdocs-minify-plugin \
            mkdocs-git-revision-date-localized-plugin \
            mkdocs-static-i18n \
            mkdocs-with-pdf \
            qrcode \
            mkdocs-awesome-pages-plugin \
            mkdocs-embed-external-markdown \
            mkdocs-include-markdown-plugin \
            mkdocs-ezlinks-plugin \
            mkdocs-git-authors-plugin \
            mkdocs-git-committers-plugin \
            mkdocs-exclude \
            pptx2md \
		    junit2html

echo "Downloading PlantUML Jar..."
plantuml_latest_url=$(curl -s https://api.github.com/repos/plantuml/plantuml/releases/latest | jq -r ".assets[] | select(.name | endswith(\"plantuml.jar\")) | .browser_download_url")
curl -sL -o plantuml.jar "$plantuml_latest_url"

echo "PlantUML downloaded successfully!"

echo "Installing JQ..."
sudo apt install jq -y

# Pause for user input
read -p "Press enter to continue"
