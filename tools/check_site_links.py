#!/usr/bin/env python3
"""Check that every local link / src in the built site/ resolves to a real file.

Walks the actual rendered HTML (so it also catches a wrong relative path inside a hand-written
<iframe src="...">, <a href="...zip"> or <img src="...">), which mkdocs' own validator cannot.

Rules (instructor, Round 3): hard failure ONLY for broken links inside OUR OWN pages (the MkDocs
pages). The standalone reports under site/raw/ (Doxygen, ReportGenerator, genhtml ...) are made by
other tools; broken links inside them are listed for information but never fail the run.

A link from our pages INTO a report (site/raw/<platform>/..., site/downloads/<platform>-...):
  * platform not built at all on this machine (no site/raw/<platform>/ folder): skipped, counted;
  * platform built but that one report missing: a WARNING locally (a tool may be optional or may
    have been skipped), a hard failure with --strict-reports (what CI uses: everything is built there).

Usage:
    python3 tools/check_site_links.py [site] [--strict-reports] [--include-raw]
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlsplit

LINK_RE = re.compile(r'''(?:href|src)\s*=\s*["']([^"']+)["']''', re.IGNORECASE)
EXTERNAL_SCHEMES = {"http", "https", "mailto", "tel", "data", "javascript"}


def resolve(html_file: Path, site_root: Path, link: str, base: str = "/"):
    parts = urlsplit(link)
    if parts.scheme in EXTERNAL_SCHEMES or link.startswith("//"):
        return None
    path = unquote(parts.path)
    if not path:
        return None  # pure "#anchor"
    if path.startswith("/"):
        # root-absolute URL (the language switcher, canonical links): strip the site's base path (/<repo>/)
        if base != "/" and path.startswith(base):
            path = path[len(base):]
        target = site_root / path.lstrip("/")
    else:
        target = html_file.parent / path
    target = Path(str(target.resolve()))
    if target.is_dir():
        target = target / "index.html"
    return target


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("site", nargs="?", default="site")
    ap.add_argument("--strict-reports", action="store_true", help="a missing report is an error, not a warning")
    ap.add_argument("--include-raw", action="store_true", help="also list broken links inside the standalone reports")
    ap.add_argument("--base", default=None, help="site base path, default: the path of the SITE_URL environment variable")
    args = ap.parse_args()

    site_root = Path(args.site).resolve()
    base = args.base
    if base is None:
        base = urlsplit(os.environ.get("SITE_URL", "/")).path or "/"
    if not base.endswith("/"):
        base += "/"
    if not site_root.is_dir():
        print(f"[check_site_links] ERROR: {site_root} does not exist - run tools/build_site.py first.")
        return 1

    own_broken, report_missing, raw_broken = [], [], []
    checked = skipped = 0
    pages = 0
    for html_file in site_root.rglob("*.html"):
        rel_page = html_file.relative_to(site_root)
        if rel_page.name == "404.html":
            continue                      # MkDocs writes root-absolute URLs there (/<repo>/...), by design
        is_raw = rel_page.parts[0] == "raw"
        if is_raw and not args.include_raw:
            continue
        pages += 1
        text = html_file.read_text(encoding="utf-8", errors="replace")
        for link in LINK_RE.findall(text):
            target = resolve(html_file, site_root, link, base)
            if target is None:
                continue
            try:
                rel_target = target.relative_to(site_root)
            except ValueError:
                continue
            checked += 1
            if target.exists():
                continue
            if is_raw:
                raw_broken.append((rel_page, link))
                continue
            top = rel_target.parts[0] if rel_target.parts else ""
            if top == "raw" and len(rel_target.parts) > 1:
                if not (site_root / "raw" / rel_target.parts[1]).is_dir():
                    skipped += 1          # that platform was not built on this machine
                    continue
                report_missing.append((rel_page, link))
            elif top == "downloads":
                plat = rel_target.name.split("-", 1)[0]
                if not (site_root / "raw" / plat).is_dir():
                    skipped += 1
                    continue
                report_missing.append((rel_page, link))
            else:
                own_broken.append((rel_page, link))

    print(f"[check_site_links] checked {checked} local link(s) in {pages} page(s); "
          f"{skipped} link(s) into a platform that was not built here were skipped")
    if raw_broken:
        print(f"[check_site_links] info: {len(raw_broken)} broken link(s) inside standalone reports (not our pages):")
        for page, link in raw_broken[:20]:
            print(f"  {page} -> {link}")
    if report_missing:
        label = "ERROR" if args.strict_reports else "warning"
        print(f"[check_site_links] {label}: {len(report_missing)} link(s) to a report that was not built:")
        for page, link in report_missing:
            print(f"  {page} -> {link}")
    if own_broken:
        print(f"[check_site_links] ERROR: {len(own_broken)} BROKEN link(s) inside our own pages:")
        for page, link in own_broken:
            print(f"  {page} -> {link}")
    if own_broken or (report_missing and args.strict_reports):
        return 1
    print("[check_site_links] OK: every link in our own pages resolves.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
