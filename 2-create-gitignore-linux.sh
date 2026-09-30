#!/bin/bash
# 2-create-gitignore-linux.sh - re-creates .gitignore: the standard GitHub/toptal templates for C, C++,
# CMake, Visual Studio, Java, Maven, C#, Eclipse ... followed by this project's own rules
# (scripts/gitignore-project-rules.txt). Only needed if .gitignore was lost or you want fresh templates.
cd "$(dirname "$(readlink -f "$0")")" || exit 1
API_URL="https://www.toptal.com/developers/gitignore/api/c,csharp,vs,visualstudio,visualstudiocode,java,maven,c++,cmake,eclipse,netbeans"
if ! curl -sS -f -o .gitignore.new "$API_URL"; then
    echo "ERROR: could not download $API_URL - .gitignore was left unchanged." >&2
    rm -f .gitignore.new
    exit 1
fi
mv -f .gitignore.new .gitignore
cat scripts/gitignore-project-rules.txt >> .gitignore
echo ".gitignore re-created from $API_URL + scripts/gitignore-project-rules.txt"
