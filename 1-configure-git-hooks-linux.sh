#!/bin/bash
# 1-configure-git-hooks-linux.sh - copies scripts/hooks/pre-commit and pre-push into .git/hooks
# (an existing hook is kept as *.backup).
cd "$(dirname "$(readlink -f "$0")")" || exit 1
HOOKS_DIR=".git/hooks"
[ -d "$HOOKS_DIR" ] || { echo "ERROR: $HOOKS_DIR not found - run this from a git clone." >&2; exit 1; }
for h in pre-commit pre-push; do
    [ -f "$HOOKS_DIR/$h" ] && { echo "Backing up the current $h hook..."; cp -f "$HOOKS_DIR/$h" "$HOOKS_DIR/$h.backup"; }
    cp -f "scripts/hooks/$h" "$HOOKS_DIR/$h"
    chmod +x "$HOOKS_DIR/$h"
done
echo "Git hooks installed: pre-commit (AStyle + checks) and pre-push."
