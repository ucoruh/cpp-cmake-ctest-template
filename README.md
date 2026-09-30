# Calculator - C/C++ CMake + CTest course project template

[![Build and Test](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/cpp.yml/badge.svg)](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/cpp.yml)
[![Pages](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/pages.yml/badge.svg)](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/pages.yml)
[![Release](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/release.yml/badge.svg)](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/release.yml)
[![Latest release](https://img.shields.io/github/v/release/ucoruh/cpp-cmake-ctest-template?label=latest)](https://github.com/ucoruh/cpp-cmake-ctest-template/releases/latest)
[![License](https://img.shields.io/github/license/ucoruh/cpp-cmake-ctest-template)](LICENSE)

**Live site (built by CI, every report embedded): <https://ucoruh.github.io/cpp-cmake-ctest-template/>**

## Start here: create YOUR private repository from this template

Use **"Use this template"**, not "Fork": a fork of a public repository cannot be made private, and your
course project must be private.

1. On this repository's page click the green **Use this template** button (top right) ->
   **Create a new repository**.
2. **Owner**: your account. **Repository name**: e.g. `cen429-2026-<yourname>-<topic>`.
3. Choose **Private** (not Public) and click **Create repository**. (Tick "Include all branches" only if
   you know why - normally leave it off.)
4. In *your* new repository: **Settings -> Collaborators -> Add people**: add the instructor
   (`ucoruh`) and your team mates, so a private repository can be graded.
5. Clone it with the submodule (googletest) and run the first build:

   ```bash
   git clone --recurse-submodules https://github.com/<you>/<your-repo>.git
   cd <your-repo>
   ```

   Windows: `7-build-all-windows.bat`  -  Linux / WSL: `./7-build-all-linux.sh`  (install the tools first:
   `4-install-tools-*`, see [docs/guide/install.en.md](docs/guide/install.en.md)).
6. Show the result locally, **no GitHub Pages needed**: `9-open-site-windows.bat` /
   `./9-open-site-linux.sh` opens the full site (every report, the API docs) on `http://localhost:8000`, and
   the `release/` folder holds every output (app, libraries, all reports, API docs, `site.zip`, source,
   `ASSETS.md`, `SHA256SUMS.txt`). See
   [Showing your project without GitHub Pages](docs/guide/showcase-without-pages.en.md).

GitHub Pages does not work for private repositories on the Free plan, releases do: `10-release-*` publishes
the same `release/` folder as a GitHub Release (works on private repositories).

## Overview

A small `utility` library, a `calculator` library (unit-tested infix/postfix expression parsing), a
`calculatorapp` command-line demo and a googletest suite, wired up with CMake + CTest. Every check is
reported **twice** - with [ReportGenerator](https://github.com/danielpalme/ReportGenerator) and with the
ecosystem's native tool - for unit tests, code coverage and documentation coverage, on **Windows and
Linux separately**, plus Doxygen API docs, all tied together in a MkDocs Material site. See
[docs/reports/index.md](docs/reports/index.md) ("Which report is which?").

The site is bilingual (mkdocs-static-i18n: English at the root, Turkish under `/tr/`, language switcher in the header).
Guides (English / Turkish): [install](docs/guide/install.en.md) / [kurulum](docs/guide/install.tr.md) |
[use the template](docs/guide/use-template.en.md) / [şablonu kullanma](docs/guide/use-template.tr.md) |
[topic to project](docs/guide/topic-to-project.en.md) / [konudan projeye](docs/guide/topic-to-project.tr.md) |
[daily workflow](docs/guide/daily-workflow.en.md) / [günlük iş akışı](docs/guide/daily-workflow.tr.md) |
[reports inside the site](docs/guide/reports-in-site.en.md) / [siteye rapor gömme](docs/guide/reports-in-site.tr.md) |
[showing your project without Pages](docs/guide/showcase-without-pages.en.md) / [Pages olmadan gösterme](docs/guide/showcase-without-pages.tr.md) |
[releases](docs/guide/releases.en.md) / [sürümler](docs/guide/releases.tr.md) |
[troubleshooting](docs/guide/troubleshooting.en.md) / [sorun giderme](docs/guide/troubleshooting.tr.md).

## One project identity: `project.env`

```text
PROJECT_NAME=calculator
VERSION=1.1.1
GITHUB_REPO=ucoruh/cpp-cmake-ctest-template
```

Every script, every workflow, the Python tools, CMake and MkDocs read this file. Rename your project or
raise the version **here, once**. `VERSION=1.1.1` releases as tag `v1.1.1`.

## The numbered scripts (same number = same job; platform as suffix)

Every job exists as `NN-name-windows.bat` and `NN-name-linux.sh` (native Linux **and WSL** - WSL is Linux, same
`.sh`, Linux binaries). Helper scripts live in `scripts/`.

| # | Job | Windows | Linux / WSL |
| --- | --- | --- | --- |
| 0 | initialise the googletest submodule (`update` = newest upstream) | `0-init-submodules-windows.bat` | `0-init-submodules-linux.sh` |
| 1 | install the git hooks (AStyle on commit) | `1-configure-git-hooks-windows.bat` | `1-configure-git-hooks-linux.sh` |
| 2 | re-create `.gitignore` | `2-create-gitignore-windows.bat` | `2-create-gitignore-linux.sh` |
| 3 | install Chocolatey / Scoop | `3-install-package-manager-windows.bat` | - |
| 4 | install every tool (incl. PlantUML) | `4-install-tools-windows.bat` | `4-install-tools-linux.sh` |
| 5 | format the code (AStyle) | `5-format-code-windows.bat` | `5-format-code-linux.sh` |
| 6 | **fast loop**: build + unit tests | `6-build-and-test-windows.bat` | `6-build-and-test-linux.sh` |
| 7 | **everything**: 6 + all reports + API docs + site + `release/` | `7-build-all-windows.bat` | `7-build-all-linux.sh` |
| 8 | run the sample app | `8-run-app-windows.bat` | `8-run-app-linux.sh` |
| 9 | serve + open the site on http://localhost:8000 | `9-open-site-windows.bat` | `9-open-site-linux.sh` |
| 10 | publish `release/` as a GitHub Release (`--dry-run` first) | `10-release-windows.bat` | `10-release-linux.sh` |
| 11 | clean every generated folder | `11-clean-windows.bat` | `11-clean-linux.sh` |

### Old name -> new name

| Old | New |
| --- | --- |
| `7-build-app-windows.bat`, `7-build-doc-windows.bat` | `7-build-all-windows.bat` |
| `7-build-app-linux.sh` | `7-build-all-linux.sh` |
| `8-build-test-windows.bat` | `6-build-and-test-windows.bat` (new: `6-build-and-test-linux.sh`) |
| `4-install-windows-enviroment.bat` | `4-install-tools-windows.bat` |
| `4-install-wsl-environment.sh` | `4-install-tools-linux.sh` |
| `6_download_plantuml.bat` | folded into `4-install-tools-windows.bat` / `4-install-tools-linux.sh` |
| `0-init-submodules.bat` / `.sh` | `0-init-submodules-windows.bat` / `0-init-submodules-linux.sh` |
| `0-update-submodules.bat` / `.sh` | `0-init-submodules-windows.bat update` / `0-init-submodules-linux.sh update` |
| `1-configure-git-hooks.bat` | `1-configure-git-hooks-windows.bat` (new: `-linux.sh`) |
| `2-create-git-ignore.bat` | `2-create-gitignore-windows.bat` (new: `-linux.sh`) |
| `3-install-package-manager.bat` | `3-install-package-manager-windows.bat` |
| `5-format-code.bat` | `5-format-code-windows.bat` (new: `-linux.sh`) |
| `9-open-site.bat` / `.sh` | `9-open-site-windows.bat` / `9-open-site-linux.sh` |
| `9-clean-project.bat` / `.sh`, `9-clean-configure-app-windows.bat` | `11-clean-windows.bat` / `11-clean-linux.sh` |
| `10-release.bat` / `.sh` | `10-release-windows.bat` / `10-release-linux.sh` |
| `detect-python.bat`, `detect-generator.bat`, `detect-genhtml.bat` | `scripts/detect-python-windows.bat`, `scripts/detect-generator-windows.bat`, `scripts/detect-genhtml-windows.bat` |
| `delete_desktop_ini.bat` / `.sh` | `scripts/delete-desktop-ini-windows.bat` / `scripts/delete-desktop-ini-linux.sh` |
| `DoxyfileLibWin`, `DoxyfileLibLinux`, `DoxyfileTestWin`, `DoxyfileTestLinux` | `config/Doxyfile-lib`, `config/Doxyfile-tests` (platform values come from environment variables) |
| `VERSION` file | `project.env` |
| `build_win/`, `build_linux/` | `build/windows-debug/`, `build/windows-release/`, `build/linux-debug/`, ... |
| `publish_win/`, `publish_linux/` | `publish/windows-x64/{release,debug}/`, `publish/linux-x64/{release,debug}/` |
| `release_win/`, `release_linux/` | `release/` (one folder; assets carry the platform in their name) |
| `docs/coveragereportlibwin`, `docs/coveragenativelibwin`, `docs/doxygenlibwin`, `docs/testresultswin`, `docs/coverxygen*` ... (and the `*linux` twins) | `reports/<windows\|linux>/<kind>-<tool>/` |
| `report_test_hist_win/`, `report_doc_lib_hist_win/` ... | `reports/history/<windows\|linux>/` |
| `assets/codecoveragelibwin/`, `assets/doccoveragelibwin/` (and `*linux`) | `assets/badges/<windows\|linux>/{coverage,doccoverage}/` |

## Folders (all generated ones are gitignored)

```text
build/<platform>-<config>/       e.g. build/windows-debug, build/linux-release   (CMake build trees)
publish/<platform>-<arch>/       e.g. publish/windows-x64/{release,debug}/{bin,lib,include}
reports/<platform>/<kind>-<tool>/   e.g. reports/linux/coverage-lcov, reports/windows/tests-junit2html
reports/history/<platform>/      ReportGenerator trend history
site/                            the MkDocs site (site/raw = standalone reports, site/downloads = their zips)
release/                         one archive per output + ASSETS.md + SHA256SUMS.txt
```

## Release assets (local `release/` = GitHub Release, one to one)

`<project>-<version>[-<platform>[-<arch>]]-<content>[-<tool>].<ext>`, version without `v`; platforms `windows`,
`linux`, `macos` (CI, app only); architectures `x64`, `arm64`; `.zip` for Windows binaries and all HTML,
`.tar.gz` for Linux/macOS binaries.

```text
calculator-1.1.1-windows-x64-app.zip            calculator-1.1.1-linux-x64-app.tar.gz     calculator-1.1.1-macos-arm64-app.tar.gz
calculator-1.1.1-windows-x64-lib-release.zip    calculator-1.1.1-windows-x64-lib-debug.zip   (same for linux, .tar.gz)
calculator-1.1.1-<platform>-report-tests.zip
calculator-1.1.1-<platform>-report-coverage-reportgenerator.zip
calculator-1.1.1-windows-report-coverage-opencppcoverage.zip
calculator-1.1.1-linux-report-coverage-lcov.zip     calculator-1.1.1-linux-report-coverage-gcovr.zip
calculator-1.1.1-<platform>-report-doccoverage-reportgenerator.zip
calculator-1.1.1-<platform>-report-doccoverage-lcov.zip
calculator-1.1.1-<platform>-api-doxygen.zip
calculator-1.1.1-source.zip   calculator-1.1.1-site.zip   ASSETS.md   SHA256SUMS.txt
```

A student builds on one platform, so a local `release/` holds that platform's assets plus the neutral ones;
`ASSETS.md` says which platform's assets are missing. CI builds both.

## Requirements

- CMake >= 3.16 (the googletest submodule's own minimum), C++17 by default
- GoogleTest (git submodule, pinned to v1.18.0 - `0-init-submodules-*`)
- **Windows**: Visual Studio 2022 Community (Desktop development with C++) *or* Ninja + MinGW-w64 GCC -
  `scripts/detect-generator-windows.bat` picks whichever you have
- **Linux / WSL**: Ninja + GCC (a GCC with a matching `gcov` is chosen automatically)
- Python 3 with `requirements.txt` (mkdocs-material, coverxygen, junit2html, gcovr), .NET SDK (ReportGenerator),
  Doxygen, lcov - all installed by `4-install-tools-*`. See [docs/guide/install.en.md](docs/guide/install.en.md).

## Supported platforms

![Linux badge](assets/badge-linux.svg)
![macOS badge](assets/badge-macos.svg)
![Windows badge](assets/badge-windows.svg)

### Test coverage ratios

| Coverage type | Windows OS                                                                  | Linux OS (WSL / CI Ubuntu)                                                |
| ------------- | --------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| Line          | ![Line Coverage](assets/badges/windows/coverage/badge_linecoverage.svg)     | ![Line Coverage](assets/badges/linux/coverage/badge_linecoverage.svg)     |
| Branch        | ![Branch Coverage](assets/badges/windows/coverage/badge_branchcoverage.svg) | ![Branch Coverage](assets/badges/linux/coverage/badge_branchcoverage.svg) |
| Method        | ![Method Coverage](assets/badges/windows/coverage/badge_methodcoverage.svg) | ![Method Coverage](assets/badges/linux/coverage/badge_methodcoverage.svg) |

### Documentation coverage ratios

|                    | Windows OS                                                                  | Linux OS (WSL / CI Ubuntu)                                                |
| ------------------ | --------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| **Coverage ratio** | ![Line Coverage](assets/badges/windows/doccoverage/badge_linecoverage.svg)  | ![Line Coverage](assets/badges/linux/doccoverage/badge_linecoverage.svg)  |

Both a ReportGenerator HTML report (with these badges and a history trend) **and** the native tool's own
report (OpenCppCoverage on Windows, lcov `genhtml` and gcovr on Linux) are generated side by side.

## GitHub Actions

Workflows under `.github/workflows/`:

- `cpp.yml` - on every push and pull request: builds and tests on Windows and Ubuntu (Release), lean, no reports.
- `pages.yml` - on push to `main` (and manually): Windows and Linux jobs build tests + reports + API docs, a
  merge job builds the MkDocs site with both platforms' reports, checks its links and deploys it to the `gh-pages`
  branch. On a **private** repository the deploy is skipped unless the repository variable `PAGES_ON_PRIVATE` is
  `true` (Pages needs GitHub Pro/Team); the notice points to
  [Showing your project without GitHub Pages](docs/guide/showcase-without-pages.en.md).
- `release.yml` - on a `v*` tag (or manually): Windows, Linux and macOS jobs (macOS builds the app only), then a
  merge job builds the site and publishes every asset above with `ASSETS.md` and `SHA256SUMS.txt`. Prefer the
  local `10-release-*` script day to day: same assets, no Actions minutes.

## Install test-results converter (junit2html)

Test results are converted with [junit2html](https://github.com/inorton/junit2html); `4-install-tools-*` installs
it together with the other Python tools (`pip install --user -r requirements.txt`).

## WSL

Run the `.sh` scripts from a folder on WSL's own filesystem (`~/work/<repo>`), not from a Windows Google Drive path -
WSL cannot reach those. See [docs/guide/install.en.md](docs/guide/install.en.md) and the WSL2 gcov/lcov notes in
[docs/guide/troubleshooting.en.md](docs/guide/troubleshooting.en.md). Related notes:
[coruhtech/vs-docker-wsl-cpp-development](https://github.com/coruhtech/vs-docker-wsl-cpp-development),
[ucoruh/ns3-wsl-win10-setup](https://github.com/ucoruh/ns3-wsl-win10-setup).
