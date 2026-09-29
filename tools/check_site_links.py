#!/usr/bin/env python3
"""Check that every local link/src in the built site/ folder resolves to a real file.

Round 2 instructor requirement: "Every link on the site must resolve (check the
built site with a link checker ... before pushing)". mkdocs' own ``--strict``
flag (used by the Pages-deploy workflow) already catches broken *nav* entries
and unresolved *markdown* links; this script is a second, independent check
that walks the actual rendered HTML (so it also catches a broken relative path
inside a hand-written <iframe src="...">, <a href="...zip">, <img src="...">,
etc. - exactly the kind of mistake the "report pages" work in this repo is
prone to).

Usage:
    python3 tools/check_site_links.py [site]   # default site dir: "site"

Exits 1 and prints every broken link if any are found, 0 otherwise.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import urlsplit

LINK_RE = re.compile(r'''(?:href|src)\s*=\s*["']([^"']+)["']''', re.IGNORECASE)
EXTERNAL_SCHEMES = {"http", "https", "mailto", "tel", "data", "javascript"}


def resolve(html_file: Path, site_root: Path, link: str) -> Path | None:
    """Return the on-disk path a relative link should point to, or None if
    the link is external/anchor-only and should be skipped."""
    parts = urlsplit(link)
    if parts.scheme in EXTERNAL_SCHEMES:
        return None
    path = parts.path
    if not path:
        return None  # pure "#anchor" link on the same page
    if path.startswith("/"):
        target = site_root / path.lstrip("/")
    else:
        target = (html_file.parent / path).resolve()
    if target.is_dir():
        target = target / "index.html"
    return target


def main() -> int:
    site_root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("site")
    if not site_root.is_dir():
        print(f"[check_site_links] ERROR: {site_root} does not exist - run the mkdocs build first.")
        return 1

    broken: list[tuple[Path, str]] = []
    checked = 0
    for html_file in site_root.rglob("*.html"):
        text = html_file.read_text(encoding="utf-8", errors="replace")
        for link in LINK_RE.findall(text):
            target = resolve(html_file, site_root, link)
            if target is None:
                continue
            checked += 1
            try:
                target.relative_to(site_root.resolve())
            except ValueError:
                continue  # link escapes the site root (shouldn't happen); not our concern here
            if not target.exists():
                broken.append((html_file.relative_to(site_root), link))

    print(f"[check_site_links] checked {checked} local link(s) across "
          f"{len(list(site_root.rglob('*.html')))} page(s)")
    if broken:
        print(f"[check_site_links] {len(broken)} BROKEN link(s):")
        for page, link in broken:
            print(f"  {page} -> {link}")
        return 1
    print("[check_site_links] all local links resolve.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
