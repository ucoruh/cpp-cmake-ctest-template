#!/bin/bash
# 10-release.sh [vX.Y.Z] [--dry-run]
# chmod +x 10-release.sh
#
# Builds everything locally (same pipeline as 7-build-app-linux.sh: binaries,
# native+ReportGenerator test/coverage reports, API docs, the mkdocs site),
# packs the whole site as site.zip, and publishes a GitHub Release with the
# GitHub CLI (gh). This uses NO GitHub Actions minutes and works on a private
# repository with the GitHub Free plan (releases are a Free-plan feature; see
# docs/guide/releases.en.md / releases.tr.md).
#
# --dry-run prints the `gh` command and the asset list without creating a
# release. Use it to check everything is in order first.

set -u

currentDir=$(dirname "$(readlink -f "$0")")
cd "$currentDir" || exit 1

DRY_RUN=0
VERSION_ARG=""
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        *) [ -z "$VERSION_ARG" ] && VERSION_ARG="$arg" ;;
    esac
done

echo "::: LOCAL RELEASE BUILD BEGIN :::"

echo "Check that the working tree is clean (a release should come from committed code)"
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    echo "ERROR: the working tree is not clean (git status --porcelain shows changes)." >&2
    echo "Commit, stash, or add to .gitignore what you do not want committed, then re-run." >&2
    git status --short
    exit 1
fi

echo "Determine version"
VERSION="$VERSION_ARG"
if [ -z "$VERSION" ] && [ -f VERSION ]; then
    VERSION=$(head -n1 VERSION)
fi
if [ -z "$VERSION" ]; then
    echo "ERROR: no version given. Usage: ./10-release.sh vX.Y.Z [--dry-run]" >&2
    echo "Or create a 'VERSION' file in the repo root containing e.g. v1.0.0" >&2
    exit 1
fi
echo "Version: $VERSION"

echo "Check that gh (GitHub CLI) is installed and logged in"
if ! command -v gh >/dev/null 2>&1; then
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "WARNING: the GitHub CLI (gh) is not installed - a real release cannot be published," >&2
        echo "  but a dry run needs no gh, so continuing. Install it before dropping --dry-run:" >&2
        echo "  https://cli.github.com/" >&2
    else
        echo "ERROR: the GitHub CLI (gh) is not installed. Install it: https://cli.github.com/" >&2
        exit 1
    fi
elif ! gh auth status >/dev/null 2>&1; then
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "WARNING: gh is installed but not logged in - a real release cannot be published," >&2
        echo "  but a dry run needs no gh login, so continuing. Log in before dropping --dry-run:" >&2
        echo "  gh auth login" >&2
    else
        echo "ERROR: gh is not logged in to GitHub. Run:" >&2
        echo "  gh auth login" >&2
        echo "and follow the prompts, then re-run this script. See docs/guide/releases.en.md." >&2
        exit 1
    fi
fi

if [ "$DRY_RUN" -eq 0 ]; then
    echo "Run the full build + report + site pipeline (same as 7-build-app-linux.sh)"
    if ! ./7-build-app-linux.sh; then
        echo "ERROR: the build failed; see the output above. Not creating a release." >&2
        exit 1
    fi
else
    echo "[DRY RUN] Skipping the actual build to keep the dry run fast. Run without"
    echo "[DRY RUN] --dry-run to build for real before publishing."
    mkdir -p release_linux
fi

echo "Package the site as site.zip"
if [ -d "site" ]; then
    rm -f release_linux/site.zip
    if command -v zip >/dev/null 2>&1; then
        (cd site && zip -qr ../release_linux/site.zip .)
    else
        python3 -c "
import shutil, sys
shutil.make_archive('release_linux/site', 'zip', 'site')
" && mv release_linux/site.zip.zip release_linux/site.zip 2>/dev/null
    fi
else
    echo "[DRY RUN] site/ does not exist yet (build not run); site.zip will not be listed."
fi

shopt -s nullglob
assets=(release_linux/*)
shopt -u nullglob
if [ "${#assets[@]}" -eq 0 ]; then
    echo "ERROR: no files found in release_linux/ to publish. Run the build first." >&2
    exit 1
fi

echo "Write release notes (links the live site AND every report page)"
notesFile=$(mktemp --suffix=.md)
if ! python3 tools/write_release_notes.py --version "$VERSION" --out "$notesFile"; then
    echo "WARNING: tools/write_release_notes.py failed; falling back to a minimal notes file."
    {
        echo "# $VERSION"
        echo ""
        echo "Built locally with 7-build-app-linux.sh and packaged by 10-release.sh."
        echo "See docs/reports.md (inside site.zip) for what each report is."
    } > "$notesFile"
fi

if [ "$DRY_RUN" -eq 1 ]; then
    echo ""
    echo "[DRY RUN] Would run:"
    echo "  gh release create $VERSION ${assets[*]} --title \"$VERSION\" --notes-file \"$notesFile\""
    echo "[DRY RUN] Assets that would be uploaded:"
    printf '  %s\n' "${assets[@]}"
    echo "[DRY RUN] No release was created."
    exit 0
fi

echo "Publish the release with gh"
if ! gh release create "$VERSION" "${assets[@]}" --title "$VERSION" --notes-file "$notesFile"; then
    echo "ERROR: gh release create failed. See messages above (common causes: not a" >&2
    echo "collaborator with write access, or a release with this tag already exists)." >&2
    exit 1
fi

echo "::: LOCAL RELEASE BUILD COMPLETED :::"
