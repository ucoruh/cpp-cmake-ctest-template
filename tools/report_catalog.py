#!/usr/bin/env python3
"""The catalogue of HTML reports: the single source of truth for every tool and page.

One entry per report, per platform. From it we derive
  * the local folder            reports/<platform>/<kind>-<tool>/
  * the MkDocs page             docs/reports/<platform>/<kind>-<tool>.md   (tools/gen_report_pages.py)
  * the raw HTML in the site    site/raw/<platform>/<kind>-<tool>/         (tools/build_site.py)
  * the download in the site    site/downloads/<platform>-<kind>-<tool>.zip
  * the release asset           <project>-<version>-<platform>-<asset>.zip (tools/release_assets.py)

To add a report: add an Entry below, produce its folder under reports/<platform>/ in the build
scripts, run  python3 tools/gen_report_pages.py  and add the page to the nav in mkdocs.yml.
See docs/guide/reports-in-site.en.md.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

PLATFORMS = ("windows", "linux")
PLATFORM_TITLE = {"windows": "Windows", "linux": "Linux", "macos": "macOS"}


@dataclass(frozen=True)
class Entry:
    platform: str
    kind: str            # tests | coverage | doccoverage | api
    tool: str            # junit2html | reportgenerator | opencppcoverage | lcov | gcovr | doxygen
    title: str
    description: str
    entry: str = "index.html"               # entry page inside the folder (single-frame reports)
    tabs: Optional[tuple] = None            # ((label, "sub/entry.html"), ...) for multi-frame reports
    asset: str = ""                         # asset name part, e.g. "report-coverage-reportgenerator"

    @property
    def id(self) -> str:
        return f"{self.kind}-{self.tool}"

    @property
    def folder(self) -> str:                # relative to reports/<platform>/
        return self.id

    @property
    def download_name(self) -> str:         # in site/downloads/
        return f"{self.platform}-{self.id}.zip"

    @property
    def title_tr(self) -> str:
        return TR[(self.kind, self.tool)][0]

    @property
    def description_tr(self) -> str:
        return TR[(self.kind, self.tool)][1]


# Turkish title / description per (kind, tool) - the site is bilingual (mkdocs-static-i18n, EN at the root, TR under /tr/)
TR = {
    ("tests", "junit2html"): (
        "Birim test sonuçları (JUnit HTML)",
        "Her test durumu için geçti/kaldı ve süre; doğrudan CTest'in kendi JUnit XML çıktısından (`ctest --output-junit`) "
        "junit2html ile üretilir. Kapsama bilgisi yok - yalnızca her testin geçip geçmediği."),
    ("coverage", "reportgenerator"): (
        "Kod kapsama (ReportGenerator)",
        "calculator, utility ve calculatorapp'in hangi satırlarının, dallarının (branch) ve metotlarının googletest paketi "
        "tarafından çalıştırıldığını gösteren ReportGenerator HTML raporu (yapılar arası eğilim grafikleriyle)."),
    ("coverage", "opencppcoverage"): (
        "Kod kapsama (OpenCppCoverage)",
        "Aynı kapsama verisi, OpenCppCoverage'ın kendi native HTML çıktısı (`--export_type=html`) olarak. Sayılarını "
        "ReportGenerator raporuyla karşılaştırın: uyuşmalıdır."),
    ("coverage", "lcov"): (
        "Kod kapsama (lcov genhtml)",
        "Aynı kapsama verisi, lcov'un kendi native HTML raporu (`genhtml`, dal kapsamasıyla) olarak. Sayılarını "
        "ReportGenerator raporuyla karşılaştırın: uyuşmalıdır."),
    ("coverage", "gcovr"): (
        "Kod kapsama (gcovr)",
        "Aynı kapsama verisi, gcovr'ın bağımsız HTML raporu olarak (lcov'un yanında ikinci, ayrı bir gerçekleştirim). "
        "Yalnızca gcovr kuruluysa üretilir."),
    ("doccoverage", "reportgenerator"): (
        "Belge kapsama (ReportGenerator)",
        "Genel (public) işlev ve sınıfların ne kadarının Doxygen yorumu taşıdığı (coverxygen çıktısı, ReportGenerator ile "
        "gösterilir). Test kapsamasıyla aynı şey değildir. Sekmeler: kütüphaneler ve test kaynaklarının kendisi."),
    ("doccoverage", "lcov"): (
        "Belge kapsama (lcov genhtml)",
        "Aynı belge kapsama verisi, native bir lcov `genhtml` HTML raporu olarak. Sekmeler: kütüphaneler ve test "
        "kaynaklarının kendisi."),
    ("api", "doxygen"): (
        "API belgeleri (Doxygen)",
        "Kaynak yorumlarından Doxygen'in ürettiği API başvurusu: sınıflar, işlevler, çağrı ve include grafikleri. "
        "Sekmeler: kütüphaneler ve testler."),
}
TAB_LABEL_TR = {"Libraries": "Kütüphaneler", "Tests": "Testler"}


def _entries(platform: str) -> list:
    p = platform
    out = [
        Entry(p, "tests", "junit2html", "Unit test results (JUnit HTML)",
              "Pass/fail per test case with timing, straight from CTest's own JUnit XML output "
              "(`ctest --output-junit`) converted by junit2html. No coverage information - only "
              "whether every test passed.",
              asset="report-tests"),
        Entry(p, "coverage", "reportgenerator", "Code coverage (ReportGenerator)",
              "Which lines, branches and methods of calculator, utility and calculatorapp were executed "
              "by the googletest suite, as an HTML report from ReportGenerator (with history charts "
              "across builds).",
              asset="report-coverage-reportgenerator"),
    ]
    if p == "windows":
        out.append(Entry(p, "coverage", "opencppcoverage", "Code coverage (OpenCppCoverage)",
                         "The same coverage data as OpenCppCoverage's own native HTML export "
                         "(`--export_type=html`). Compare its numbers with the ReportGenerator report: "
                         "they should agree.",
                         asset="report-coverage-opencppcoverage"))
    else:
        out.append(Entry(p, "coverage", "lcov", "Code coverage (lcov genhtml)",
                         "The same coverage data as lcov's own native HTML report (`genhtml`, with branch "
                         "coverage). Compare its numbers with the ReportGenerator report: they should agree.",
                         asset="report-coverage-lcov"))
        out.append(Entry(p, "coverage", "gcovr", "Code coverage (gcovr)",
                         "The same coverage data as gcovr's independent HTML report (a second, separate "
                         "implementation next to lcov). Only produced when gcovr is installed.",
                         asset="report-coverage-gcovr"))
    out += [
        Entry(p, "doccoverage", "reportgenerator", "Documentation coverage (ReportGenerator)",
              "What fraction of the public functions and classes carry a Doxygen comment (coverxygen output "
              "rendered by ReportGenerator). Not the same thing as test coverage. Tabs: the libraries, "
              "and the test sources themselves.",
              tabs=(("Libraries", "lib/index.html"), ("Tests", "tests/index.html")),
              asset="report-doccoverage-reportgenerator"),
        Entry(p, "doccoverage", "lcov", "Documentation coverage (lcov genhtml)",
              "The same documentation-coverage data as a native lcov `genhtml` HTML report. Tabs: the "
              "libraries, and the test sources themselves.",
              tabs=(("Libraries", "lib/index.html"), ("Tests", "tests/index.html")),
              asset="report-doccoverage-lcov"),
        Entry(p, "api", "doxygen", "API documentation (Doxygen)",
              "The API reference generated by Doxygen from the source comments: classes, functions, "
              "call and include graphs. Tabs: the libraries, and the test sources.",
              tabs=(("Libraries", "lib/html/index.html"), ("Tests", "tests/html/index.html")),
              asset="api-doxygen"),
    ]
    return out


CATALOG = [e for plat in PLATFORMS for e in _entries(plat)]


def for_platform(platform: str) -> list:
    return [e for e in CATALOG if e.platform == platform]


def first_page(e: Entry) -> str:
    """Path of the report's first HTML page relative to its folder."""
    return e.tabs[0][1] if e.tabs else e.entry


def all_pages(e: Entry) -> list:
    return [t[1] for t in e.tabs] if e.tabs else [e.entry]
