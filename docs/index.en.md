<div class="hero" markdown>
![logo](assets/logo.png){ .hero-logo }

# Calculator - C/C++ CMake + CTest course project template

<p class="tagline">A complete C/C++ template: CMake + CTest + googletest, every check reported twice
(ReportGenerator and the native tool) on Windows and on Linux, Doxygen API docs, and this site tying it all
together - a best-practice example for RTEU course projects.</p>

<p class="badges">
[![Build and Test](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/cpp.yml/badge.svg)](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/cpp.yml)
[![Pages](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/pages.yml/badge.svg)](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/pages.yml)
[![Release](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/release.yml/badge.svg)](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/release.yml)
[![Latest release](https://img.shields.io/github/v/release/ucoruh/cpp-cmake-ctest-template?label=latest)](https://github.com/ucoruh/cpp-cmake-ctest-template/releases/latest)
[![License](https://img.shields.io/github/license/ucoruh/cpp-cmake-ctest-template)](https://github.com/ucoruh/cpp-cmake-ctest-template/blob/main/LICENSE)
![Line coverage (Windows)](assets/badges/windows/coverage/badge_linecoverage.svg)
![Line coverage (Linux)](assets/badges/linux/coverage/badge_linecoverage.svg)
![Doc. coverage (Windows)](assets/badges/windows/doccoverage/badge_linecoverage.svg)
![Doc. coverage (Linux)](assets/badges/linux/doccoverage/badge_linecoverage.svg)
</p>

[:material-download: Download the latest release](https://github.com/ucoruh/cpp-cmake-ctest-template/releases/latest){ .md-button .md-button--primary }
[:material-rocket-launch: Use this template](guide/use-template.en.md){ .md-button }
[:fontawesome-brands-github: View on GitHub](https://github.com/ucoruh/cpp-cmake-ctest-template){ .md-button }

</div>

New here? **[Install](guide/install.en.md)** -> **[Use the template](guide/use-template.en.md)** ->
**[From a topic to your project](guide/topic-to-project.en.md)**. Türkçe: **[Kurulum](guide/install.tr.md)** ->
**[Şablonu kullanma](guide/use-template.tr.md)** -> **[Konudan projeye](guide/topic-to-project.tr.md)**.

## What is in this template

<div class="grid cards" markdown>

-   :material-cog-outline: **CMake + CTest + googletest**

    ---

    A `utility` library, a `calculator` library (unit-tested infix/postfix parsing) and a `calculatorapp`
    command-line demo. Builds on Windows (Visual Studio or Ninja + MinGW) and Linux / WSL (Ninja + GCC).

    [:octicons-arrow-right-24: Install & first build](guide/install.en.md)

-   :material-file-document-multiple-outline: **Every report, two ways, per platform**

    ---

    Unit tests, code coverage and documentation coverage - each with [ReportGenerator](https://github.com/danielpalme/ReportGenerator)
    and with the native tool (OpenCppCoverage, lcov `genhtml`, gcovr) - built separately on Windows and Linux.

    [:octicons-arrow-right-24: Which report is which?](reports/index.md)

-   :material-file-tree-outline: **API docs (Doxygen)**

    ---

    Libraries and test sources, for Windows and for Linux, with call and include graphs.

    [:octicons-arrow-right-24: API docs](api/index.md)

-   :material-tag-outline: **One numbered script set**

    ---

    `6-build-and-test`, `7-build-all`, `9-open-site`, `10-release` ... the same number is the same job, with
    `-windows.bat` / `-linux.sh` as suffix. One `project.env` names the project.

    [:octicons-arrow-right-24: The scripts](guide/use-template.en.md)

-   :material-monitor-share: **Show it without GitHub Pages**

    ---

    A private repository on GitHub Free has no Pages. `7-build-all` + `9-open-site` show the full site on
    http://localhost, and `release/` holds every output. A checklist for the demo.

    [:octicons-arrow-right-24: Showing your project without Pages](guide/showcase-without-pages.en.md)

-   :material-package-variant-closed: **Releases with every output**

    ---

    `release/` = the GitHub Release, one to one: app, libraries, every report, API docs, `site.zip`, source,
    `ASSETS.md` and `SHA256SUMS.txt`.

    [:octicons-arrow-right-24: Downloads](downloads.md)

-   :material-source-branch: **From topic to your own project**

    ---

    A worked walkthrough: rename the sample in one place, add your modules, write the tests first.

    [:octicons-arrow-right-24: Topic to project](guide/topic-to-project.en.md)

-   :material-lifebuoy: **Troubleshooting, from real errors**

    ---

    Real error messages met while building this template, and the exact fix for each.

    [:octicons-arrow-right-24: Troubleshooting](guide/troubleshooting.en.md)

</div>

## Reports, live

Each report has its own page in this site (a framed standalone HTML report with "Open in a new tab" and
"Download (zip)"). Jump straight to one, or open the **Reports** tab:

<div class="grid cards" markdown>

-   :material-microsoft-windows: **Windows**

    ---

    [Unit test results](reports/windows/tests-junit2html.md) ·
    [Code coverage - ReportGenerator](reports/windows/coverage-reportgenerator.md) ·
    [Code coverage - OpenCppCoverage](reports/windows/coverage-opencppcoverage.md) ·
    [Doc. coverage - ReportGenerator](reports/windows/doccoverage-reportgenerator.md) ·
    [Doc. coverage - lcov](reports/windows/doccoverage-lcov.md) ·
    [API docs - Doxygen](reports/windows/api-doxygen.md)

-   :material-linux: **Linux**

    ---

    [Unit test results](reports/linux/tests-junit2html.md) ·
    [Code coverage - ReportGenerator](reports/linux/coverage-reportgenerator.md) ·
    [Code coverage - lcov](reports/linux/coverage-lcov.md) ·
    [Code coverage - gcovr](reports/linux/coverage-gcovr.md) ·
    [Doc. coverage - ReportGenerator](reports/linux/doccoverage-reportgenerator.md) ·
    [Doc. coverage - lcov](reports/linux/doccoverage-lcov.md) ·
    [API docs - Doxygen](reports/linux/api-doxygen.md)

</div>

## Coverage ratios

| Coverage type | Windows | Linux (WSL / CI Ubuntu) |
| --- | --- | --- |
| Line | ![Line Coverage](assets/badges/windows/coverage/badge_linecoverage.svg) | ![Line Coverage](assets/badges/linux/coverage/badge_linecoverage.svg) |
| Branch | ![Branch Coverage](assets/badges/windows/coverage/badge_branchcoverage.svg) | ![Branch Coverage](assets/badges/linux/coverage/badge_branchcoverage.svg) |
| Method | ![Method Coverage](assets/badges/windows/coverage/badge_methodcoverage.svg) | ![Method Coverage](assets/badges/linux/coverage/badge_methodcoverage.svg) |
| Documentation | ![Doc coverage](assets/badges/windows/doccoverage/badge_linecoverage.svg) | ![Doc coverage](assets/badges/linux/doccoverage/badge_linecoverage.svg) |

## Build it yourself

```bash
# Windows (cmd.exe)                      # Linux / WSL
7-build-all-windows.bat                  ./7-build-all-linux.sh
9-open-site-windows.bat                  ./9-open-site-linux.sh     # serves the site on http://localhost:8000
```

Each full build takes roughly 10-20 minutes and produces `reports/<platform>/`, `site/` and `release/`.
Use `6-build-and-test-*` for the fast build + unit test loop.

----

Türkçe rehberler için **Kılavuz (TR)** sekmesine bakın; her sayfanın İngilizce (`.en.md`) ve Türkçe (`.tr.md`)
sürümü vardır.
