#!/bin/bash
# 9-open-site-linux.sh [port]      (default port 8000; native Linux and WSL)
# Serves the built site (site/) over a real local web server and opens it in your browser.
# A server is required: every report page shows its report in an <iframe>, and browsers block
# iframes of file:// pages. This is how a PRIVATE repository shows its site (GitHub Pages needs Pro):
#   ./7-build-all-linux.sh  ->  ./9-open-site-linux.sh  -> http://localhost:8000/
# See docs/guide/showcase-without-pages.en.md. Press Ctrl+C to stop the server.
cd "$(dirname "$(readlink -f "$0")")" || exit 1
PORT="${1:-8000}"

open_it() {
    if command -v xdg-open >/dev/null 2>&1; then xdg-open "$1" >/dev/null 2>&1 &
    elif command -v wslview >/dev/null 2>&1; then wslview "$1"
    elif command -v cmd.exe >/dev/null 2>&1; then cmd.exe /c start "" "$1" >/dev/null 2>&1   # WSL: Windows opens it
    else echo "Open this URL in your browser: $1"; fi
}

[ -f site/index.html ] || { echo "site/index.html not found - build the site first: ./7-build-all-linux.sh" >&2; exit 1; }
# shellcheck disable=SC1091
source scripts/detect-python-linux.sh || exit 1

echo "Serving $(pwd)/site on http://localhost:$PORT/  (Ctrl+C stops it)"
( cd site && exec $PY_CMD -m http.server "$PORT" ) &
SERVER_PID=$!
# stop only the server this script started (by PID), never by process name
trap 'echo; echo "Stopping the local web server (pid $SERVER_PID)."; kill "$SERVER_PID" 2>/dev/null' EXIT INT TERM
sleep 1
kill -0 "$SERVER_PID" 2>/dev/null || { echo "ERROR: the web server did not start (is port $PORT already in use? try: ./9-open-site-linux.sh 8001)" >&2; exit 1; }
open_it "http://localhost:$PORT/"
wait "$SERVER_PID"
