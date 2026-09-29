#!/bin/bash
# chmod +x 9-open-site.sh
# ./9-open-site.sh
#
# Opens the built documentation site locally. Run 7-build-app-linux.sh first
# so site/index.html and docs/ exist.

currentDir=$(dirname "$(readlink -f "$0")")
cd "$currentDir" || exit 1

open_it() {
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$1" >/dev/null 2>&1 &
    elif command -v wslview >/dev/null 2>&1; then
        wslview "$1"
    elif command -v cmd.exe >/dev/null 2>&1; then
        # WSL without wslview: hand off to Windows' own file association.
        cmd.exe /c start "" "$(wslpath -w "$1")" >/dev/null 2>&1
    else
        echo "Could not find a way to open a browser automatically."
        echo "Open this file manually: $1"
    fi
}

if [ -f "site/index.html" ]; then
    echo "Opening the mkdocs site: site/index.html"
    open_it "$(pwd)/site/index.html"
elif [ -f "docs/doxygenliblinux/html/index.html" ]; then
    echo "site/index.html not found (mkdocs build has not been run); opening the"
    echo "Doxygen library API documentation instead: docs/doxygenliblinux/html/index.html"
    open_it "$(pwd)/docs/doxygenliblinux/html/index.html"
else
    echo "Neither site/index.html nor docs/doxygenliblinux/html/index.html was found." >&2
    echo "Run 7-build-app-linux.sh first, then re-run this script." >&2
    exit 1
fi
