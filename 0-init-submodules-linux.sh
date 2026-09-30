#!/bin/bash
# chmod +x 0-init-submodules.sh
# ./0-init-submodules.sh

echo "::: INIT SUBMODULES BEGIN :::"

currentDir="$(pwd)"
cd "$(dirname "$(readlink -f "$0")")" || exit 1

find . -name 'desktop.ini' -print0 2>/dev/null | while IFS= read -r -d '' file; do
    git rm --cached --force "$file" >/dev/null 2>&1
    rm -f "$file"
done

echo "Sync submodule URLs from .gitmodules"
git submodule sync --recursive

echo "Initialise and check out the pinned submodule commit(s)"
if ! git submodule update --init --recursive; then
    echo ""
    echo "[0-init-submodules] The submodule update failed. This usually happens when the"
    echo "[0-init-submodules] repository itself was cloned shallowly (e.g. with"
    echo "[0-init-submodules] 'git clone --depth 1'), so the submodule's pinned commit is not"
    echo "[0-init-submodules] reachable from the shallow history yet. Fetching the submodule's"
    echo "[0-init-submodules] full history and retrying..."
    if [ -e src/tests/googletest/.git ]; then
        (
            cd src/tests/googletest || exit 1
            if ! git fetch --unshallow origin 2>/dev/null; then
                echo "[0-init-submodules] Submodule was not shallow; fetching normally instead."
                git fetch origin
            fi
        )
    fi
    if ! git submodule update --init --recursive; then
        echo ""
        echo "[0-init-submodules] ERROR: still could not initialise the submodule(s). Check your"
        echo "[0-init-submodules] internet connection and that this clone's .git directory is not"
        echo "[0-init-submodules] shallow: git rev-parse --is-shallow-repository. If it is, run:"
        echo "[0-init-submodules]   git fetch --unshallow"
        echo "[0-init-submodules] and re-run this script."
        cd "$currentDir" || true
        exit 1
    fi
fi

echo "::: INIT SUBMODULES COMPLETED :::"
cd "$currentDir" || true
