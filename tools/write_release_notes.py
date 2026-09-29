#!/usr/bin/env python3
"""Write the GitHub Release notes body: links the live site, links every
report page on the site (not just the site root), and summarizes the asset
categories. Instructor requirement (Round 2, point 7): "its notes link to the
live site and to each report page on the site".

Single source of truth: imports REPORTS from tools/zip_reports.py (the same
list behind the site's report pages and the per-report release archives).

Usage:
    python3 tools/write_release_notes.py --version v1.0.0 --out release/NOTES.md
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from tools.zip_reports import REPORTS  # noqa: E402

SITE_URL = "https://ucoruh.github.io/cpp-cmake-ctest-template/"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--site-url", default=SITE_URL)
    args = parser.parse_args()

    site = args.site_url.rstrip("/")
    lines = [
        f"## {args.version}",
        "",
        f"Live site (updated separately, on every push to `main`): <{site}/>",
        "",
        "### Every report, linked",
        "",
        "Each report below has its own page on the live site (styled `<iframe>` + \"Open in a new "
        "tab\" + \"Download (zip)\") and, in this release, its own `.zip` archive with the same name.",
        "",
    ]
    for group in ("Windows", "Linux"):
        lines.append(f"**{group}:**")
        lines.append("")
        for report_id, title, platform, _description, _zip_source, _iframe_src in REPORTS:
            if platform != group:
                continue
            lines.append(f"- [{title}]({site}/reports/{report_id}/) - `{report_id}.zip`")
        lines.append("")

    lines += [
        "### Other assets",
        "",
        "- `*-publish-binaries.tar.gz`, `*-release-binaries.tar.gz`, `*-debug-binaries.tar.gz` "
        "(Windows + Linux) - the built library, calculatorapp executable and test executables.",
        "- `site.zip` - the full site (both platforms' reports embedded). Unzip and open `index.html`, "
        "or serve it with `python -m http.server` (a real HTTP server is needed for the embedded "
        "report iframes).",
        "",
        'See `docs/reports.md` ("Which report is which?") in the source, or the "Reports" tab on the '
        "live site, for what each report shows and how the ReportGenerator/native families differ.",
        "",
    ]

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text("\n".join(lines), encoding="utf-8", newline="\n")
    print(f"[write_release_notes] wrote {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
