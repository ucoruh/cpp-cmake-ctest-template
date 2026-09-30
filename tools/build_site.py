#!/usr/bin/env python3
"""Build the MkDocs Material site and put every standalone HTML report into it.

    python3 tools/build_site.py [--strict-reports]

1. copies assets/ -> docs/assets/ (logo, favicon, badges; gitignored copy)
2. mkdocs build --strict   (docs/ -> site/; the project name / URLs come from project.env via env vars)
3. copies reports/<platform>/<kind>-<tool>/ -> site/raw/<platform>/<kind>-<tool>/
   (the standalone HTML made by ReportGenerator, genhtml, Doxygen ... - shown in an <iframe> by the
   pages under reports/<platform>/) and writes site/downloads/<platform>-<kind>-<tool>.zip
4. runs tools/check_site_links.py (hard failure only for broken links in our own pages)

Whatever platform's reports exist under reports/ are included; CI puts both platforms there.
"""
from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import projectenv  # noqa: E402
from report_catalog import CATALOG, first_page  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent


def zip_folder(dest: Path, src: Path, skip_dirs=()) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as zf:
        for base, dirs, files in os.walk(src):
            dirs[:] = sorted(d for d in dirs if d not in skip_dirs)
            for name in sorted(files):
                p = Path(base) / name
                zf.write(p, p.relative_to(src))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--strict-reports", action="store_true", help="fail if any linked report is missing (CI)")
    ap.add_argument("--no-check", action="store_true", help="skip the link check")
    args = ap.parse_args()

    env = projectenv.load(ROOT)
    site = ROOT / "site"

    # 1. assets
    docs_assets = ROOT / "docs" / "assets"
    if docs_assets.exists():
        shutil.rmtree(docs_assets)
    shutil.copytree(ROOT / "assets", docs_assets, ignore=shutil.ignore_patterns("desktop.ini"))

    # 2. mkdocs
    sub_env = dict(os.environ)
    for key in ("SITE_NAME", "SITE_URL", "REPO_URL", "PROJECT_NAME", "VERSION", "GITHUB_REPO"):
        sub_env[key] = env.get(key, "")
    print("[build_site] mkdocs build --strict")
    r = subprocess.run([sys.executable, "-m", "mkdocs", "build", "--strict", "--clean"], cwd=ROOT, env=sub_env)
    if r.returncode != 0:
        print("[build_site] ERROR: mkdocs build failed. Install the tools: python -m pip install --user -r requirements.txt",
              file=sys.stderr)
        return r.returncode

    # 3. the standalone reports
    copied = 0
    for e in CATALOG:
        folder = ROOT / "reports" / e.platform / e.folder
        if not (folder / first_page(e)).is_file():
            print(f"[build_site] not built here: {e.platform}/{e.id}")
            continue
        skip = ("xml",) if e.kind == "api" else ()
        dest = site / "raw" / e.platform / e.folder
        shutil.copytree(folder, dest, ignore=shutil.ignore_patterns("desktop.ini", *skip))
        zip_folder(site / "downloads" / e.download_name, folder, skip)
        copied += 1
    print(f"[build_site] {copied} report(s) copied into site/raw/ with their download zips in site/downloads/")

    # 4. links
    if args.no_check:
        return 0
    cmd = [sys.executable, str(ROOT / "tools" / "check_site_links.py"), str(site)]
    if args.strict_reports:
        cmd.append("--strict-reports")
    return subprocess.run(cmd, cwd=ROOT).returncode


if __name__ == "__main__":
    sys.exit(main())
