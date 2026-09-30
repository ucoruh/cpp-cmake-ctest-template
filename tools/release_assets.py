#!/usr/bin/env python3
"""Build the release/ folder: one archive per output, same names locally and on GitHub.

Name pattern (version without "v"):
    <project>-<version>[-<platform>[-<arch>]]-<content>[-<tool>].<ext>
e.g. calculator-1.1.0-windows-x64-app.zip, calculator-1.1.0-linux-x64-app.tar.gz,
     calculator-1.1.0-linux-report-coverage-lcov.zip, calculator-1.1.0-site.zip

Sub-commands:
    pack     --platform windows|linux|macos --arch x64|arm64 [--app-only]
             app + library (release and debug) + every report/API-doc archive this machine built
    neutral  source.zip, site.zip (from site/), ASSETS.md, SHA256SUMS.txt
    notes    --out FILE        GitHub Release notes (site link, every asset, every report page)

.zip for Windows binaries and everything HTML; .tar.gz for Linux/macOS binaries (keeps the exec bit).
"""
from __future__ import annotations

import argparse
import hashlib
import os
import shutil
import subprocess
import sys
import tarfile
import zipfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import projectenv  # noqa: E402
from report_catalog import CATALOG, PLATFORM_TITLE, PLATFORMS  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent


def write_lf(path, text: str) -> None:
    """Write UTF-8 text with LF line endings (Path.write_text(newline=) needs Python 3.10)."""
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
RELEASE = ROOT / "release"


def prefix(env: dict) -> str:
    return f"{env['PROJECT_NAME']}-{env['VERSION']}"


def write_zip(dest: Path, src: Path, skip_dirs: tuple = ()) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists():
        dest.unlink()
    with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as zf:
        for base, dirs, files in os.walk(src):
            dirs[:] = sorted(d for d in dirs if d not in skip_dirs)
            for name in sorted(files):
                p = Path(base) / name
                zf.write(p, p.relative_to(src))


def write_targz(dest: Path, src: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists():
        dest.unlink()
    with tarfile.open(dest, "w:gz") as tf:
        for base, dirs, files in os.walk(src):
            dirs.sort()
            for name in sorted(files):
                p = Path(base) / name
                tf.add(p, arcname=str(p.relative_to(src)).replace("\\", "/"))


def binary_ext(platform: str) -> str:
    return "zip" if platform == "windows" else "tar.gz"


def write_binary_archive(dest: Path, src: Path, platform: str) -> None:
    if platform == "windows":
        write_zip(dest, src)
    else:
        write_targz(dest, src)


def fresh(path: Path) -> Path:
    if path.exists():
        shutil.rmtree(path)
    return path


def pack(env: dict, platform: str, arch: str, app_only: bool) -> int:
    pre = prefix(env)
    ext = binary_ext(platform)
    made = []
    pub = ROOT / "publish" / f"{platform}-{arch}"

    # --- the application: every installed executable that is not a unit-test binary ---
    bindir = pub / "release" / "bin"
    apps = [p for p in sorted(bindir.glob("*")) if p.is_file() and "_tests" not in p.stem] if bindir.is_dir() else []
    if not apps:
        print(f"[release_assets] ERROR: no application found in {bindir} - run 6-build-and-test first.", file=sys.stderr)
        return 1
    stage = fresh(ROOT / "publish" / f".stage-{platform}-app")
    stage.mkdir(parents=True)
    for a in apps:
        shutil.copy2(a, stage / a.name)
    for extra in ("LICENSE", "README.md"):
        if (ROOT / extra).is_file():
            shutil.copy2(ROOT / extra, stage / extra)
    dest = RELEASE / f"{pre}-{platform}-{arch}-app.{ext}"
    write_binary_archive(dest, stage, platform)
    shutil.rmtree(stage)
    made.append(dest)

    if not app_only:
        # --- the library, release and debug configurations (lib/ + include/) ---
        for cfg in ("release", "debug"):
            src = pub / cfg
            libs = [d for d in ("lib", "include") if (src / d).is_dir()]
            if not libs:
                print(f"[release_assets] skip lib-{cfg}: {src} has no lib/ or include/")
                continue
            stage = fresh(ROOT / "publish" / f".stage-{platform}-lib-{cfg}")
            for d in libs:
                shutil.copytree(src / d, stage / d)
            dest = RELEASE / f"{pre}-{platform}-{arch}-lib-{cfg}.{ext}"
            write_binary_archive(dest, stage, platform)
            shutil.rmtree(stage)
            made.append(dest)

        # --- every report / API-doc folder this machine built ---
        for e in CATALOG:
            if e.platform != platform:
                continue
            folder = ROOT / "reports" / platform / e.folder
            pages = [folder / p for p in ([t[1] for t in e.tabs] if e.tabs else [e.entry])]
            if not folder.is_dir() or not all(p.is_file() for p in pages):
                print(f"[release_assets] skip {platform}/{e.id}: not built on this machine")
                continue
            dest = RELEASE / f"{pre}-{platform}-{e.asset}.zip"
            write_zip(dest, folder, skip_dirs=("xml",) if e.kind == "api" else ())
            made.append(dest)
    for m in made:
        print(f"[release_assets] wrote {m.relative_to(ROOT)} ({m.stat().st_size / 1024:.0f} KiB)")
    return 0


def git_source_files() -> list:
    out = subprocess.run(["git", "ls-files", "--recurse-submodules", "-z"], cwd=ROOT, capture_output=True, check=True)
    return [f for f in out.stdout.decode("utf-8").split("\0") if f and not f.endswith("desktop.ini")]


def neutral(env: dict) -> int:
    pre = prefix(env)
    RELEASE.mkdir(exist_ok=True)
    # source.zip: every tracked file, submodules included (googletest), under <project>-<version>/
    src_zip = RELEASE / f"{pre}-source.zip"
    if src_zip.exists():
        src_zip.unlink()
    with zipfile.ZipFile(src_zip, "w", zipfile.ZIP_DEFLATED) as zf:
        for rel in git_source_files():
            p = ROOT / rel
            if p.is_file():
                zf.write(p, f"{pre}/{rel}")
    print(f"[release_assets] wrote {src_zip.relative_to(ROOT)}")
    # site.zip: the MkDocs site (both platforms' reports if they were built)
    site = ROOT / "site"
    if site.is_dir():
        site_zip = RELEASE / f"{pre}-site.zip"
        write_zip(site_zip, site)
        print(f"[release_assets] wrote {site_zip.relative_to(ROOT)}")
    else:
        print("[release_assets] no site/ folder yet - run tools/build_site.py first; site.zip not written")
    write_assets_md(env)
    write_checksums()
    return 0


# ---- describing the assets ---------------------------------------------------------------
def describe(env: dict, name: str):
    """(platform, content, tool, site-page path) for a release file name, or None."""
    pre = prefix(env) + "-"
    if not name.startswith(pre):
        return None
    rest = name[len(pre):]
    for ext in (".tar.gz", ".zip"):
        if rest.endswith(ext):
            rest = rest[: -len(ext)]
            break
    if rest == "source":
        return ("all", "Source code (with the googletest submodule)", "git", "")
    if rest == "site":
        return ("all", "The whole MkDocs site, both platforms' reports (unzip, then serve and open index.html)",
                "MkDocs Material", "")
    for plat in (*PLATFORMS, "macos"):
        if not rest.startswith(plat + "-"):
            continue
        tail = rest[len(plat) + 1:]
        for arch in ("x64", "arm64"):
            if tail.startswith(arch + "-"):
                what = tail[len(arch) + 1:]
                if what == "app":
                    return (plat, f"Application executable ({arch})", "CMake", "")
                if what in ("lib-release", "lib-debug"):
                    return (plat, f"Libraries + headers, {what.split('-')[1]} build ({arch})", "CMake", "")
        for e in CATALOG:
            if e.platform == plat and tail == e.asset:
                return (plat, e.title, e.tool, f"reports/{plat}/{e.id}/")
    return None


def asset_rows(env: dict) -> list:
    rows = []
    for f in sorted(RELEASE.glob("*")):
        if not f.is_file() or f.name in ("ASSETS.md", "SHA256SUMS.txt"):
            continue
        d = describe(env, f.name)
        rows.append((f.name, *(d if d else ("?", "?", "?", ""))))
    return rows


def write_assets_md(env: dict) -> None:
    site = env["SITE_URL"]
    rows = asset_rows(env)
    lines = [
        f"# {env['PROJECT_NAME']} {env['VERSION']} - release assets", "",
        f"Live site: <{site}>  (also inside `{prefix(env)}-site.zip`: unzip it and serve it with a local web server)", "",
        "| File | Platform | Content | Tool | Site page |", "| --- | --- | --- | --- | --- |",
    ]
    for name, plat, content, tool, link in rows:
        page = f"[{link}]({site}{link})" if link else ""
        lines.append(f"| `{name}` | {plat} | {content} | {tool} | {page} |")
    present = {r[1] for r in rows}
    lines.append("")
    for plat in (*PLATFORMS, "macos"):
        if plat not in present:
            why = ("the macOS app is built by CI only" if plat == "macos"
                   else "build on that platform (or let CI build both) to get them")
            lines.append(f"- No **{PLATFORM_TITLE[plat]}** assets in this folder: {why}.")
    lines += ["", "Verify a download: `sha256sum -c SHA256SUMS.txt` (Linux) or "
              "`certutil -hashfile <file> SHA256` (Windows).", ""]
    write_lf(RELEASE / "ASSETS.md", "\n".join(lines))
    print(f"[release_assets] wrote release/ASSETS.md ({len(rows)} asset(s))")


def write_checksums() -> None:
    lines = []
    for f in sorted(RELEASE.glob("*")):
        if f.is_file() and f.name != "SHA256SUMS.txt":
            lines.append(f"{hashlib.sha256(f.read_bytes()).hexdigest()}  {f.name}")
    write_lf(RELEASE / "SHA256SUMS.txt", "\n".join(lines) + "\n")
    print(f"[release_assets] wrote release/SHA256SUMS.txt ({len(lines)} file(s))")


def notes(env: dict, out: Path) -> int:
    site = env["SITE_URL"].rstrip("/")
    tag = "v" + env["VERSION"]
    lines = [
        f"## {env['PROJECT_NAME']} {tag}", "",
        f"Live site (every report, the API docs and the guides): <{site}/>", "",
        "### Assets", "",
        "| File | Platform | Content |", "| --- | --- | --- |",
    ]
    for name, plat, content, _tool, _link in asset_rows(env):
        lines.append(f"| `{name}` | {plat} | {content} |")
    lines += ["", "Every file has a checksum in `SHA256SUMS.txt`; `ASSETS.md` explains each asset.", "",
              "### Every report page on the site", ""]
    for plat in PLATFORMS:
        lines.append(f"**{PLATFORM_TITLE[plat]}:**")
        lines.append("")
        for e in CATALOG:
            if e.platform == plat:
                lines.append(f"- [{e.title}]({site}/reports/{plat}/{e.id}/)")
        lines.append("")
    lines += ['See "Which report is which?" (`docs/reports/index.md`) for what each report shows and how the '
              "ReportGenerator and native families differ.", ""]
    out.parent.mkdir(parents=True, exist_ok=True)
    write_lf(out, "\n".join(lines))
    print(f"[release_assets] wrote {out}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("pack")
    p.add_argument("--platform", required=True, choices=["windows", "linux", "macos"])
    p.add_argument("--arch", required=True, choices=["x64", "arm64"])
    p.add_argument("--app-only", action="store_true")
    sub.add_parser("neutral")
    n = sub.add_parser("notes")
    n.add_argument("--out", required=True)
    args = ap.parse_args()
    env = projectenv.load(ROOT)
    if args.cmd == "pack":
        return pack(env, args.platform, args.arch, args.app_only)
    if args.cmd == "neutral":
        return neutral(env)
    return notes(env, Path(args.out))


if __name__ == "__main__":
    sys.exit(main())
