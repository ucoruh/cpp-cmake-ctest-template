#!/usr/bin/env python3
"""Write release_win/README.md or release_linux/README.md: one line per archive
actually present in the release folder, what it contains, and the live site
URL - instructor requirement (Round 2, point 7): "a release/README.md (or
ASSETS.md) listing every archive, what is inside, and the site URL".

Single source of truth for the report descriptions: imports REPORTS from
tools/zip_reports.py (the same list used for the site's report pages and the
per-report zip files copied into this same release folder).

Usage:
    python3 tools/write_release_readme.py --release-dir release_win --platform Windows
    python3 tools/write_release_readme.py --release-dir release_linux --platform Linux
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from tools.zip_reports import REPORTS  # noqa: E402

SITE_URL = "https://ucoruh.github.io/cpp-cmake-ctest-template/"

# filename (without platform-specific bits already baked into REPORTS' ids) -> description
BINARIES = {
    "publish-binaries.tar.gz": "The installed library (.lib/.a + headers) and the calculatorapp executable, as `cmake --install` produces them (CMAKE_INSTALL_PREFIX).",
    "release-binaries.tar.gz": "The Release-configuration build output (library, calculatorapp, test executables) straight from the build tree.",
    "debug-binaries.tar.gz": "The Debug-configuration build output (library, calculatorapp, test executables) straight from the build tree.",
}
SITE_ARCHIVE = {
    "site.zip": "The full MkDocs Material site (this platform's reports embedded; both platforms if built via a workflow that merges them). Unzip and open index.html, or serve it with `python -m http.server` (a real HTTP server is needed for the embedded report <iframe>s) - see docs/guide/reports-in-site.en.md.",
}


def human_size(num_bytes: int) -> str:
    size = float(num_bytes)
    for unit in ("B", "KiB", "MiB", "GiB"):
        if size < 1024 or unit == "GiB":
            return f"{size:.0f} {unit}" if unit == "B" else f"{size:.1f} {unit}"
        size /= 1024
    return f"{size:.1f} GiB"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--release-dir", required=True)
    parser.add_argument("--platform", required=True, choices=["Windows", "Linux"])
    parser.add_argument("--site-url", default=SITE_URL)
    args = parser.parse_args()

    release_dir = Path(args.release_dir)
    if not release_dir.is_dir():
        print(f"[write_release_readme] ERROR: {release_dir} does not exist", file=sys.stderr)
        return 1

    # id -> (title, description) for this platform's reports, keyed by the zip filename.
    suffix = "win" if args.platform == "Windows" else "linux"
    report_by_zip = {
        f"{report_id}.zip": (title, description)
        for report_id, title, platform, description, _zip_source, _iframe_src in REPORTS
        if platform.lower() == args.platform.lower()
    }

    rows = []
    for f in sorted(release_dir.iterdir()):
        if not f.is_file() or f.suffix not in (".zip", ".gz"):
            continue
        name = f.name
        size = human_size(f.stat().st_size)
        if name in report_by_zip:
            title, description = report_by_zip[name]
            rows.append((name, size, f"**{title}.** {description}"))
        elif name in SITE_ARCHIVE:
            rows.append((name, size, SITE_ARCHIVE[name]))
        else:
            # binaries are named "<platform>-<suffix>", e.g. windows-publish-binaries.tar.gz
            matched = None
            for key, desc in BINARIES.items():
                if name.endswith(key):
                    matched = desc
                    break
            rows.append((name, size, matched or "(see docs/reports.md / README.md)"))

    lines = [
        f"# {args.platform} release archives",
        "",
        f"Built by `7-build-app-{suffix}.{'bat' if suffix == 'win' else 'sh'}` "
        f"(and packaged by `10-release.{'bat' if suffix == 'win' else 'sh'}` if you ran that). "
        f"Every report inside these archives is also viewable online, embedded in a page of its own, "
        f"on the live site: <{args.site_url}>",
        "",
        "| Archive | Size | Contents |",
        "| --- | --- | --- |",
    ]
    for name, size, desc in rows:
        lines.append(f"| `{name}` | {size} | {desc} |")
    lines.append("")
    lines.append('See `docs/reports.md` ("Which report is which?") for the full explanation of the '
                 "ReportGenerator-vs-native pattern used throughout.")
    lines.append("")

    readme = release_dir / "README.md"
    readme.write_text("\n".join(lines), encoding="utf-8", newline="\n")
    print(f"[write_release_readme] wrote {readme} ({len(rows)} archive(s) listed)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
