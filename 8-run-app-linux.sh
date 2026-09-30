#!/bin/bash
# 8-run-app-linux.sh ["2+3*(4-1)"]
# Runs the sample application from publish/linux-<arch>/release/bin (built by 6-build-and-test-linux.sh).
#   no argument  -> interactive: type an expression when asked
#   an argument  -> that expression is evaluated and the result printed (non-interactive)
cd "$(dirname "$(readlink -f "$0")")" || exit 1
# shellcheck disable=SC1091
source scripts/load-project-env-linux.sh || exit 1

find_app() {
    APP=""
    for f in "publish/$PLATFORM-$ARCH/release/bin/"*; do
        [ -f "$f" ] && [ -x "$f" ] && [[ "$f" != *_tests ]] && { APP="$f"; break; }
    done
}
find_app
if [ -z "$APP" ]; then
    echo "No built application found - building it first (6-build-and-test-linux.sh)..."
    ./6-build-and-test-linux.sh || exit 1
    find_app
fi
[ -n "$APP" ] || { echo "ERROR: no application executable in publish/$PLATFORM-$ARCH/release/bin" >&2; exit 1; }
echo "Running $APP"
if [ $# -eq 0 ]; then
    exec "$APP"
else
    echo "$1" | "$APP"
fi
