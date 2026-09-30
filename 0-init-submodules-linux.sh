#!/bin/bash
# 0-init-submodules-linux.sh [update]      (native Linux and WSL)
#   (no argument)  initialise / check out the submodule commit this repository pins (googletest)
#   update         move the submodule(s) to the newest upstream commit (git submodule update --remote)
cd "$(dirname "$(readlink -f "$0")")" || exit 1

echo "::: INIT SUBMODULES BEGIN :::"
scripts/delete-desktop-ini-linux.sh quiet

echo "Sync submodule URLs from .gitmodules"
git submodule sync --recursive

if [ "${1:-}" = "update" ]; then
    echo "Update the submodule(s) to the newest upstream commit"
    git submodule update --init --remote --merge || { echo "[0-init-submodules] ERROR: submodule update failed." >&2; exit 1; }
    echo "::: INIT SUBMODULES COMPLETED :::"
    exit 0
fi

echo "Initialise and check out the pinned submodule commit(s)"
if ! git submodule update --init --recursive; then
    echo ""
    echo "[0-init-submodules] The submodule update failed. This usually happens when the"
    echo "[0-init-submodules] repository itself was cloned shallowly (git clone --depth 1), so the"
    echo "[0-init-submodules] submodule's pinned commit is not reachable yet. Fetching the"
    echo "[0-init-submodules] submodule's full history and retrying..."
    if [ -e src/tests/googletest/.git ]; then
        (
            cd src/tests/googletest || exit 1
            git fetch --unshallow origin 2>/dev/null || git fetch origin
        )
    fi
    if ! git submodule update --init --recursive; then
        echo ""
        echo "[0-init-submodules] ERROR: still could not initialise the submodule(s). Check your" >&2
        echo "[0-init-submodules] internet connection and that this clone is not shallow:" >&2
        echo "[0-init-submodules]   git rev-parse --is-shallow-repository   (true = shallow)" >&2
        echo "[0-init-submodules]   git fetch --unshallow" >&2
        echo "[0-init-submodules] then re-run this script." >&2
        exit 1
    fi
fi
echo "::: INIT SUBMODULES COMPLETED :::"
