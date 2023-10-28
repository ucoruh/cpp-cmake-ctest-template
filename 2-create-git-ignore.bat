@echo off

set API_URL=https://www.toptal.com/developers/gitignore/api/c,csharp,vs,visualstudio,visualstudiocode,java,maven,c++,cmake,eclipse,netbeans
set OUTPUT_FILE=.gitignore

REM Set the running folder to the current working folder
cd /d "%~dp0"

REM Download the API results using curl
curl -s -o %OUTPUT_FILE% %API_URL%

echo Downloaded .gitignore file from %API_URL% and saved as %OUTPUT_FILE%

pause

