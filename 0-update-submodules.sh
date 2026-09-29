#!/bin/bash
# chmod +x 0-update-submodules.sh
# ./0-update-submodules.sh

echo "::: UPDATE SUBMODULES BEGIN :::"

currentDir="$(pwd)"
cd "$(dirname "$(readlink -f "$0")")" || exit 1

find . -name 'desktop.ini' -print0 2>/dev/null | while IFS= read -r -d '' file; do
    git rm --cached --force "$file" >/dev/null 2>&1
    rm -f "$file"
done

git submodule sync --recursive
if ! git submodule update --remote --merge; then
    echo "[0-update-submodules] ERROR: submodule update failed. See messages above." >&2
    cd "$currentDir" || true
    exit 1
fi

echo "::: UPDATE SUBMODULES COMPLETED :::"
cd "$currentDir" || true
