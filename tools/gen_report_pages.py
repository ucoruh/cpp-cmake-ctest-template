#!/usr/bin/env python3
"""(Re)generate the report pages: docs/reports/<platform>/<kind>-<tool>.en.md and .tr.md - one iframe page per
catalogue entry and language.

The pages are committed (they are hand-editable source); this script only saves typing when a report is added to
tools/report_catalog.py:

    python3 tools/gen_report_pages.py

Every page has: a title, a one-line explanation, "Open in a new tab" and "Download (zip)" buttons above a responsive
full-height lazy-loading <iframe>, and a fallback note. The site is bilingual (mkdocs-static-i18n, suffix mode): English
is the default at the site root, Turkish lives under /tr/. The standalone reports themselves are shared (site/raw/...), so
the relative paths differ by one level:

    English  site/reports/<platform>/<id>/index.html      -> ../../../raw/<platform>/<id>/<entry>
    Turkish  site/tr/reports/<platform>/<id>/index.html   -> ../../../../raw/<platform>/<id>/<entry>

Both work on GitHub Pages (/<repo>/... sub-path) and on http://localhost (9-open-site-*) because they are relative.
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import projectenv  # noqa: E402
from report_catalog import CATALOG, PLATFORM_TITLE, TAB_LABEL_TR  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
UP = {"en": "../../../", "tr": "../../../../"}   # page URL -> site root


def write_lf(path, text: str) -> None:
    """Write UTF-8 text with LF line endings (Path.write_text(newline=) needs Python 3.10)."""
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


def frame(src: str, title: str, platform: str, indent: str = "") -> str:
    lines = [
        f'<div class="report-frame" data-platform="{PLATFORM_TITLE[platform]}">',
        f'<iframe src="{src}" title="{title}" loading="lazy"></iframe>',
        '</div>',
    ]
    return "\n".join(indent + line for line in lines)


TEXT = {
    "en": {
        "open": "Open in a new tab", "download": "Download (zip)", "open_tab": 'Open "{label}" in a new tab',
        "note_title": "Report not showing?",
        "note": [
            "This page embeds a standalone HTML report (made by an external tool, outside MkDocs) in an",
            "`<iframe>`. Use the \"Open in a new tab\" button if the frame stays empty. Browsers block iframes",
            "of `file://` pages, so open the site with `9-open-site-windows.bat` / `9-open-site-linux.sh`",
            "(a tiny local web server). If this platform's report was not built on your machine",
            "(you ran only the other platform's `7-build-all-*` script), the frame stays empty - CI builds both.",
            "The same archive is attached to every release as `{project}-{version}-{platform}-{asset}.zip`.",
            "See [Showing an HTML report inside your site](../../guide/reports-in-site.md).",
        ],
    },
    "tr": {
        "open": "Yeni sekmede aç", "download": "İndir (zip)", "open_tab": '"{label}" sekmesini yeni sekmede aç',
        "note_title": "Rapor görünmüyor mu?",
        "note": [
            "Bu sayfa, harici bir araçla (MkDocs dışında) üretilmiş bağımsız bir HTML raporunu bir",
            "`<iframe>` içinde gösterir. Çerçeve boş kalırsa \"Yeni sekmede aç\" düğmesini kullanın. Tarayıcılar",
            "`file://` sayfalarındaki iframe'leri engeller; bu yüzden siteyi `9-open-site-windows.bat` /",
            "`9-open-site-linux.sh` ile açın (küçük bir yerel web sunucusu). Bu platformun raporu makinenizde",
            "üretilmediyse (yalnızca diğer platformun `7-build-all-*` betiğini çalıştırdınız) çerçeve boş kalır - CI ikisini de derler.",
            "Aynı arşiv her sürüme `{project}-{version}-{platform}-{asset}.zip` adıyla eklenir.",
            "Bkz. [Siteye HTML raporu gömme](../../guide/reports-in-site.md).",
        ],
    },
}


def page(e, lang: str, project: str, version: str) -> str:
    t = TEXT[lang]
    plat = PLATFORM_TITLE[e.platform]
    title = e.title if lang == "en" else e.title_tr
    desc = e.description if lang == "en" else e.description_tr
    raw = f"{UP[lang]}raw/{e.platform}/{e.folder}/"
    dl = f"{UP[lang]}downloads/{e.download_name}"
    first = raw + (e.tabs[0][1] if e.tabs else e.entry)
    out = [
        f"# {title} - {plat}",
        "",
        desc,
        "",
        '<div class="report-actions" markdown>',
        f'[:material-open-in-new: {t["open"]}]({first}){{ .md-button target="_blank" rel="noopener" }}',
        f'[:material-download: {t["download"]}]({dl}){{ .md-button .md-button--primary }}',
        "</div>",
        "",
    ]
    if e.tabs:
        for label, sub in e.tabs:
            shown = label if lang == "en" else TAB_LABEL_TR.get(label, label)
            out += [f'=== "{shown}"', "", frame(raw + sub, f"{title} - {plat} - {shown}", e.platform, "    "),
                    "    ", f'    [:material-open-in-new: {t["open_tab"].format(label=shown)}]({raw + sub})'
                    '{ target="_blank" rel="noopener" }', ""]
    else:
        out += [frame(raw + e.entry, f"{title} - {plat}", e.platform), ""]
    out += [f'!!! note "{t["note_title"]}"']
    out += ["    " + line.format(project=project, version=version, platform=e.platform, asset=e.asset) for line in t["note"]]
    out.append("")
    return "\n".join(out)


def main() -> int:
    env = projectenv.load(ROOT)
    n = 0
    for e in CATALOG:
        folder = ROOT / "docs" / "reports" / e.platform
        folder.mkdir(parents=True, exist_ok=True)
        for lang in ("en", "tr"):
            write_lf(folder / f"{e.id}.{lang}.md", page(e, lang, env["PROJECT_NAME"], env["VERSION"]))
            n += 1
    print(f"[gen_report_pages] wrote {n} page(s) under docs/reports/ (English and Turkish)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
