#!/bin/bash
# load-project-env-linux.sh
#
# Reads project.env (PROJECT_NAME, VERSION, GITHUB_REPO) from the repository root and
# derives the values every script needs. SOURCE it (do not execute it):
#     source "$(dirname "$(readlink -f "$0")")/scripts/load-project-env-linux.sh"
# Works for native Linux and for WSL (WSL is Linux).
#
# Sets/exports: PROJECT_NAME, VERSION, GITHUB_REPO, REPO_OWNER, REPO_NAME, SITE_URL,
#               REPO_URL, SITE_NAME, PLATFORM (linux), ARCH (x64 or arm64), ROOT_DIR.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ ! -f "$ROOT_DIR/project.env" ]; then
    echo "[load-project-env] ERROR: $ROOT_DIR/project.env not found." >&2
    return 1 2>/dev/null || exit 1
fi
set -a
# shellcheck disable=SC1091
. "$ROOT_DIR/project.env"
set +a
if [ -z "${PROJECT_NAME:-}" ] || [ -z "${VERSION:-}" ]; then
    echo "[load-project-env] ERROR: PROJECT_NAME and VERSION must be set in project.env." >&2
    return 1 2>/dev/null || exit 1
fi

PLATFORM="linux"
case "$(uname -m)" in
    aarch64|arm64) ARCH="arm64" ;;
    *)             ARCH="x64" ;;
esac
REPO_OWNER="${GITHUB_REPO%%/*}"
REPO_NAME="${GITHUB_REPO#*/}"
if [ -n "${GITHUB_REPO:-}" ]; then
    SITE_URL="https://${REPO_OWNER}.github.io/${REPO_NAME}/"
    REPO_URL="https://github.com/${GITHUB_REPO}"
else
    SITE_URL="http://localhost:8000/"
    REPO_URL="https://github.com/"
fi
SITE_NAME="$PROJECT_NAME"
export ROOT_DIR PLATFORM ARCH REPO_OWNER REPO_NAME SITE_URL REPO_URL SITE_NAME
