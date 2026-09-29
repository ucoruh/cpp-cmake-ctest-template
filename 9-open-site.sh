#!/bin/bash
# chmod +x 9-open-site.sh
# ./9-open-site.sh [port]   (default port: 8000)
#
# Serves the built documentation site locally over a real HTTP server (not
# file://) and opens it in your browser. A real server is required because
# every report page embeds its report in an <iframe>, and most browsers block
# iframes whose src is a local file:// path - see
# docs/guide/reports-in-site.en.md. Run 7-build-app-linux.sh first so
# site/index.html and docs/ exist. Press Ctrl+C to stop the server.

currentDir=$(dirname "$(readlink -f "$0")")
cd "$currentDir" || exit 1

PORT="${1:-8000}"

open_it() {
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$1" >/dev/null 2>&1 &
    elif command -v wslview >/dev/null 2>&1; then
        wslview "$1"
    elif command -v cmd.exe >/dev/null 2>&1; then
        # WSL without wslview: hand off to Windows' own file association.
        # WSL2 forwards "localhost" to Windows automatically, so this also
        # works for the http://localhost:<port>/ URL below.
        cmd.exe /c start "" "$1" >/dev/null 2>&1
    else
        echo "Could not find a way to open a browser automatically."
        echo "Open this URL manually: $1"
    fi
}

if [ -f "site/index.html" ]; then
    SERVE_DIR="$(pwd)/site"
    SERVE_WHAT="the mkdocs site"
elif [ -f "docs/doxygenliblinux/html/index.html" ]; then
    echo "site/index.html not found (mkdocs build has not been run); serving the"
    echo "Doxygen library API documentation instead: docs/doxygenliblinux/html"
    SERVE_DIR="$(pwd)/docs/doxygenliblinux/html"
    SERVE_WHAT="the Doxygen library API documentation"
else
    echo "Neither site/index.html nor docs/doxygenliblinux/html/index.html was found." >&2
    echo "Run 7-build-app-linux.sh first, then re-run this script." >&2
    exit 1
fi

PY_CMD=""
if command -v python3 >/dev/null 2>&1; then
    PY_CMD="python3"
elif command -v py >/dev/null 2>&1; then
    PY_CMD="py -3"
elif command -v python >/dev/null 2>&1; then
    PY_CMD="python"
fi
if [ -z "$PY_CMD" ]; then
    echo "ERROR: no python3/python found on PATH to serve the site." >&2
    echo "Install Python - see docs/guide/install.en.md - then re-run this script." >&2
    exit 1
fi

echo "Starting a local HTTP server for $SERVE_WHAT ($SERVE_DIR) on port $PORT ..."
echo "If port $PORT is already in use, re-run as: ./9-open-site.sh <a-different-port>"

( cd "$SERVE_DIR" && exec $PY_CMD -m http.server "$PORT" ) &
SERVER_PID=$!

# Stop only the server process this script itself started (by PID), never by
# process name, when this script exits for any reason.
cleanup() {
    echo
    echo "Stopping the local HTTP server (pid $SERVER_PID)."
    kill "$SERVER_PID" 2>/dev/null
}
trap cleanup EXIT INT TERM

sleep 1
if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    echo "ERROR: the HTTP server did not start (port $PORT may already be in use)." >&2
    exit 1
fi

echo "Opening http://localhost:$PORT/ in your default browser"
open_it "http://localhost:$PORT/"

echo
echo "The site is being served at http://localhost:$PORT/ - press Ctrl+C here to stop it."
wait "$SERVER_PID"
