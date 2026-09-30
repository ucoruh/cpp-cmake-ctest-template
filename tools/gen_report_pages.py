#!/usr/bin/env python3
"""(Re)generate docs/reports/<platform>/<kind>-<tool>.md - one iframe page per catalogue entry.

The pages are committed (they are hand-editable source), this script only saves typing when a
report is added to tools/report_catalog.py:

    python3 tools/gen_report_pages.py

Every page has: a title, a one-line explanation, "Open in a new tab" and "Download (zip)" buttons
above a responsive full-height lazy-loading <iframe>, and a fallback note. The paths are relative
and work on GitHub Pages (/<repo>/...) and on http://localhost (9-open-site-*):

    site/reports/<platform>/<id>/index.html   <- the page          (3 levels below the site root)
    site/raw/<platform>/<id>/<entry>          <- the standalone HTML report
    site/downloads/<platform>-<id>.zip        <- its zip
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import projectenv  # noqa: E402
from report_catalog import CATALOG, PLATFORM_TITLE  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent


def write_lf(path, text: str) -> None:
    """Write UTF-8 text with LF line endings (Path.write_text(newline=) needs Python 3.10)."""
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
UP = "../../../"  # page URL -> site root (reports/<platform>/<id>/)


def frame(src: str, title: str, platform: str, indent: str = "") -> str:
    lines = [
        f'<div class="report-frame" data-platform="{PLATFORM_TITLE[platform]}">',
        f'<iframe src="{src}" title="{title}" loading="lazy"></iframe>',
        '</div>',
    ]
    return "\n".join(indent + line for line in lines)


def page(e, project: str, version: str) -> str:
    plat = PLATFORM_TITLE[e.platform]
    raw = f"{UP}raw/{e.platform}/{e.folder}/"
    dl = f"{UP}downloads/{e.download_name}"
    first = raw + (e.tabs[0][1] if e.tabs else e.entry)
    out = [
        f"# {e.title} - {plat}",
        "",
        e.description,
        "",
        '<div class="report-actions" markdown>',
        f'[:material-open-in-new: Open in a new tab]({first}){{ .md-button target="_blank" rel="noopener" }}',
        f'[:material-download: Download (zip)]({dl}){{ .md-button .md-button--primary }}',
        "</div>",
        "",
    ]
    if e.tabs:
        for label, sub in e.tabs:
            out += [f'=== "{label}"', "", frame(raw + sub, f"{e.title} - {plat} - {label}", e.platform, "    "),
                    "    ", f'    [:material-open-in-new: Open "{label}" in a new tab]({raw + sub})'
                    '{ target="_blank" rel="noopener" }', ""]
    else:
        out += [frame(raw + e.entry, f"{e.title} - {plat}", e.platform), ""]
    out += [
        '!!! note "Report not showing?"',
        "    This page embeds a standalone HTML report (made by an external tool, outside MkDocs) in an",
        "    `<iframe>`. Use the \"Open in a new tab\" button if the frame stays empty. Browsers block iframes",
        "    of `file://` pages, so open the site with `9-open-site-windows.bat` / `9-open-site-linux.sh`",
        "    (a tiny local web server). If this platform's report was not built on your machine",
        f"    (you ran only the other platform's `7-build-all-*` script), the frame stays empty - CI builds both.",
        f"    The same archive is attached to every release as `{project}-{version}-{e.platform}-{e.asset}.zip`.",
        "    See [Showing an HTML report inside your site](../../guide/reports-in-site.en.md).",
        "",
    ]
    return "\n".join(out)


def main() -> int:
    env = projectenv.load(ROOT)
    n = 0
    for e in CATALOG:
        path = ROOT / "docs" / "reports" / e.platform / f"{e.id}.md"
        path.parent.mkdir(parents=True, exist_ok=True)
        write_lf(path, page(e, env["PROJECT_NAME"], env["VERSION"]))
        n += 1
    print(f"[gen_report_pages] wrote {n} page(s) under docs/reports/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
