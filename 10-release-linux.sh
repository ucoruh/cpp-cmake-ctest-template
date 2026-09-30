#!/bin/bash
# 10-release-linux.sh [--dry-run]      (native Linux and WSL)
#
# Publishes a GitHub Release from the local release/ folder with the GitHub CLI (gh):
#   * the version comes from project.env (VERSION=1.1.0 -> tag v1.1.0); change it there
#   * refuses a dirty working tree and a commit that is not pushed yet
#   * builds everything first (7-build-all-linux.sh) unless --dry-run
#   * uploads EVERY file of release/ - the GitHub asset list is the local folder, one to one
# Uses no GitHub Actions minutes and works on a PRIVATE repository with the Free plan.
# --dry-run prints the gh command and the asset list and creates nothing (no gh login needed).
# See docs/guide/releases.en.md and docs/guide/showcase-without-pages.en.md.
set -u
cd "$(dirname "$(readlink -f "$0")")" || exit 1
# shellcheck disable=SC1091
source scripts/load-project-env-linux.sh || exit 1
source scripts/setup-path-linux.sh
source scripts/detect-python-linux.sh || exit 1

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1
TAG="v$VERSION"
echo "=== Release $PROJECT_NAME $TAG"

if [ "$DRY_RUN" -eq 0 ]; then
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        echo "ERROR: the working tree is not clean - commit or stash first (a release comes from committed code):" >&2
        git status --short; exit 1
    fi
    if [ -z "$(git branch -r --contains HEAD 2>/dev/null)" ]; then
        echo "ERROR: the current commit is not pushed yet - run: git push" >&2; exit 1
    fi
    command -v gh >/dev/null 2>&1 || { echo "ERROR: the GitHub CLI (gh) is not installed: https://cli.github.com/" >&2; exit 1; }
    gh auth status >/dev/null 2>&1 || { echo "ERROR: gh is not logged in. Run:  gh auth login   (GitHub.com, HTTPS, browser) and re-run." >&2; exit 1; }
    echo "Running the full build - reports - site - release/ pipeline (7-build-all-linux.sh)"
    ./7-build-all-linux.sh || { echo "ERROR: the build failed - not creating a release." >&2; exit 1; }
else
    echo "[DRY RUN] not building; using the existing release/ folder (run ./7-build-all-linux.sh first)"
    command -v gh >/dev/null 2>&1 || echo "[DRY RUN] note: gh is not installed - fine for a dry run, needed for a real release"
fi

shopt -s nullglob
assets=(release/*)
shopt -u nullglob
[ "${#assets[@]}" -gt 0 ] || { echo "ERROR: release/ is empty - run ./7-build-all-linux.sh first." >&2; exit 1; }

NOTES="$(mktemp --suffix=.md)"
$PY_CMD tools/release_assets.py notes --out "$NOTES" || { echo "ERROR: could not write the release notes." >&2; exit 1; }
SHA="$(git rev-parse HEAD)"

if [ "$DRY_RUN" -eq 1 ]; then
    echo
    echo "[DRY RUN] Would run:"
    echo "  gh release create $TAG release/* (${#assets[@]} files) --target $SHA --title \"$PROJECT_NAME $TAG\" --notes-file \"$NOTES\""
    echo "[DRY RUN] Assets that would be uploaded:"
    ls -1 release
    echo "[DRY RUN] No release was created."
    exit 0
fi

echo "Publishing with gh..."
gh release create "$TAG" "${assets[@]}" --target "$SHA" --title "$PROJECT_NAME $TAG" --notes-file "$NOTES" \
    || { echo "ERROR: gh release create failed (a release for $TAG may already exist, or you have no write access)." >&2; exit 1; }
echo "Release published: $REPO_URL/releases/tag/$TAG"
