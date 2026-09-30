#!/bin/bash
# Google Drive (and Windows) drop a hidden desktop.ini into every folder. Git must never see
# them: delete them and drop any that were staged. Usage: scripts/delete-desktop-ini-linux.sh [quiet]
cd "$(dirname "$(readlink -f "$0")")/.." || exit 1
[ "${1:-}" = "quiet" ] || echo "::: DELETE desktop.ini FILES :::"
find . -name desktop.ini -not -path './.git/*' -print0 2>/dev/null | while IFS= read -r -d '' f; do
    git rm --cached --force -q "$f" >/dev/null 2>&1
    rm -f "$f"
done
[ "${1:-}" = "quiet" ] || echo "::: DELETE OPERATION COMPLETED :::"
exit 0
