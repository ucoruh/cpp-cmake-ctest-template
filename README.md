# Calculator Project Library Generation and Testing Template

[![Build and Test](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/cpp.yml/badge.svg)](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/cpp.yml)
[![Pages](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/pages.yml/badge.svg)](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/pages.yml)
[![Release](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/release.yml/badge.svg)](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/release.yml)
[![Latest release](https://img.shields.io/github/v/release/ucoruh/cpp-cmake-ctest-template?label=latest)](https://github.com/ucoruh/cpp-cmake-ctest-template/releases/latest)
[![License](https://img.shields.io/github/license/ucoruh/cpp-cmake-ctest-template)](LICENSE)

**Live site (built by CI, every report embedded): <https://ucoruh.github.io/cpp-cmake-ctest-template/>**

## Overview

This project is a C/C++ course-project template: a small `utility` library, a `calculator` library
(with unit-tested infix/postfix expression parsing), a `calculatorapp` command-line demo, and a
googletest suite, wired up with CMake + CTest. It generates two independent HTML reports for every
report family (a third-party one via [ReportGenerator](https://github.com/danielpalme/ReportGenerator)
and the ecosystem's native/older tool), Doxygen API documentation, and a site that links all of them.
See [docs/reports.md](docs/reports.md) ("Which report is which?") once you have built it.

**New to this template?** Start with the step-by-step guides in [docs/guide/](docs/guide/)
(English and Turkish): [install](docs/guide/install.en.md) |
[use the template](docs/guide/use-template.en.md) |
[from a project topic to your own project](docs/guide/topic-to-project.en.md) |
[daily workflow](docs/guide/daily-workflow.en.md) |
[troubleshooting](docs/guide/troubleshooting.en.md) |
[private repository: releases and the site](docs/guide/releases.en.md)
(Türkçe: [kurulum](docs/guide/install.tr.md) | [şablonu kullanma](docs/guide/use-template.tr.md) |
[konudan projeye](docs/guide/topic-to-project.tr.md) |
[günlük iş akışı](docs/guide/daily-workflow.tr.md) |
[sorun giderme](docs/guide/troubleshooting.tr.md) |
[özel depo ve sürümler](docs/guide/releases.tr.md)).

## Requirements

- CMake >= 3.16 (matches the googletest submodule's own `cmake_minimum_required`; tested with 3.31 on
  Windows, 4.2 on WSL Ubuntu 20.04, and current CMake on GitHub Actions' runners)
- C++ standard: 17 by default (GoogleTest 1.15+ requires it); override with
  `-DCMAKE_CXX_STANDARD=...` if you need to test against an older standard
- GoogleTest (git submodule, pinned to v1.18.0 - run `0-init-submodules.bat`/`.sh`)
- **Windows**: Visual Studio 2022 Community (Desktop development with C++), *or* Ninja + MinGW-w64
  GCC - the build scripts auto-detect which one you have (`detect-generator.bat`); no specific
  Visual Studio version is required.
- **Linux/WSL**: Ninja + GCC (the build script picks a GCC version with a matching `gcov`
  automatically, see [docs/guide/troubleshooting.en.md](docs/guide/troubleshooting.en.md))

## Setup Development Environment

See [docs/guide/install.en.md](docs/guide/install.en.md) / [install.tr.md](docs/guide/install.tr.md)
for the full walkthrough with verification commands and expected output. Short version:

### Step-0 (Windows and WSL)

Initialise the googletest submodule: `0-init-submodules.bat` (Windows) or `0-init-submodules.sh`
(Linux/WSL). Safe to re-run; retries automatically if the repository was cloned shallowly.

### Step-1 (Run on Windows, Can Effect on WSL)

Run `1-configure-git-hooks.bat` to copy the `pre-commit`/`pre-push` scripts into `.git/hooks`, which
check README.md/.gitignore/Doxyfiles are present and format staged code with AStyle.

### Step-2 (Run on Windows, Can Effect on WSL)

If `.gitignore` is missing, run `2-create-git-ignore.bat` to (re)create it.

### Step-3 (Only Windows)

Install package managers used by the next step: run `3-install-package-manager.bat` (installs
Chocolatey and Scoop).

### Step-4 (Only Windows)

Run `4-install-windows-enviroment.bat` (as Administrator) to install CMake, Ninja, Doxygen,
ReportGenerator, OpenCppCoverage, coverxygen, lcov (`genhtml`), and the mkdocs toolchain.

### Step-5 (Only WSL)

Open the WSL Ubuntu terminal, go to the project folder, and run `4-install-wsl-environment.sh`. It
also installs a per-user, current .NET SDK (needed by ReportGenerator - see
[docs/guide/troubleshooting.en.md](docs/guide/troubleshooting.en.md) if `dotnet`/`reportgenerator`
still resolve to an old version afterwards).

## Generate Development Environment

Run `9-clean-configure-app-windows.bat` to (re)configure the CMake project (Visual Studio if
installed, otherwise Ninja).

## Build, Test and Package Application on Windows

Run `7-build-app-windows.bat` to build, test, generate every report (native + ReportGenerator), and
package the application on Windows.

Also `7-build-doc-windows.bat` to only (re)generate documentation/doc-coverage, and
`8-build-test-windows.bat` to only build and test.

## Build, Test and Package Application on WSL

Run `7-build-app-linux.sh` for the same pipeline on Linux/WSL. **Run it from a path under WSL's own
filesystem** (e.g. `~/work/cpp-cmake-ctest-template`), not a Windows Google-Drive-synced path - WSL
cannot reach those; see [docs/guide/install.en.md](docs/guide/install.en.md).

## Open the site

`9-open-site.bat` / `9-open-site.sh` start a tiny local HTTP server over the built `site/` folder and
open it in your browser (falls back to the Doxygen API docs if the site has not been built yet). A
real HTTP server, not `file://`, is required because every report page embeds its report in an
`<iframe>`, and most browsers block iframes from `file://` pages - see
[docs/guide/reports-in-site.en.md](docs/guide/reports-in-site.en.md). Press `Ctrl+C` in that terminal
to stop the server when you are done.

## Publish a release

`10-release.bat`/`.sh` build everything, package it (including the whole site as `site.zip`), and
publish it as a GitHub Release with the GitHub CLI (`gh`) - works on a private repository with
GitHub Free, uses no GitHub Actions minutes. Add `--dry-run` to preview without publishing. See
[docs/guide/releases.en.md](docs/guide/releases.en.md) for `gh` setup, the Student Developer Pack,
and adding a collaborator so a private release is visible for grading.

## Clean Project

Run `9-clean-project.bat` (Windows) or `9-clean-project.sh` (Linux/WSL) to remove every generated
output folder.

## Supported Platforms

![Ubuntu badge](assets/badge-ubuntu.svg)

![macOS badge](assets/badge-macos.svg)

![Windows badge](assets/badge-windows.svg)

### Test Coverage Ratios

> **Note** : There is a known bug on doxygen following badges are in different folder but has same name for this reason in doxygen html report use same image for all content [Images with same name overwrite each other in output directory · Issue #8362 · doxygen/doxygen · GitHub](https://github.com/doxygen/doxygen/issues/8362). README.md and WebPage show correct badges.

| Coverage Type | Windows OS                                                             | Linux OS (WSL-Ubuntu 20.04)                                              |
| ------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Line Based    | ![Line Coverage](assets/codecoveragelibwin/badge_linecoverage.svg)     | ![Line Coverage](assets/codecoverageliblinux/badge_linecoverage.svg)     |
| Branch Based  | ![Branch Coverage](assets/codecoveragelibwin/badge_branchcoverage.svg) | ![Branch Coverage](assets/codecoverageliblinux/badge_branchcoverage.svg) |
| Method Based  | ![Method Coverage](assets/codecoveragelibwin/badge_methodcoverage.svg) | ![Method Coverage](assets/codecoverageliblinux/badge_methodcoverage.svg) |

### Documentation Coverage Ratios

|                    | Windows OS                                                        | Linux OS (WSL-Ubuntu 20.04)                                         |
| ------------------ | ----------------------------------------------------------------- | ------------------------------------------------------------------- |
| **Coverage Ratio** | ![Line Coverage](assets/doccoveragelibwin/badge_linecoverage.svg) | ![Line Coverage](assets/doccoverageliblinux/badge_linecoverage.svg) |

Both a [ReportGenerator](https://github.com/danielpalme/ReportGenerator) HTML report (with these
badges and a history trend) **and** the native tool's own HTML report (OpenCppCoverage on Windows,
lcov's `genhtml`/`gcovr` on Linux) are generated side by side - see
[docs/reports.md](docs/reports.md).

#### Install Test Results to HTML Converter

We are using [GitHub - inorton/junit2html: Turn Junit XML reports into self contained HTML reports](https://github.com/inorton/junit2html) to convert junit xml formatted test results to HTML page for reporting also we store logs during test. Use following commands to install this module with pip

```bash
pip install junit2html
```

### Github Actions

Three workflows under `.github/workflows/`:

- `cpp.yml` - builds and tests (CMake configure + build Release + `ctest`) on every push and pull
  request, on Windows and Ubuntu - intentionally lean, no report generation, so it stays fast and does
  not use many Actions minutes.
- `pages.yml` - on push to `main` (and manually): builds the full report+site pipeline on both
  Windows and Ubuntu runners, merges both platforms' reports into one site, and deploys it to the
  `gh-pages` branch (GitHub Pages). On a **private** repository this step is skipped unless the
  repository variable `PAGES_ON_PRIVATE` is `true` (GitHub Pages needs GitHub Pro/Team, e.g. via the
  Student Developer Pack) - see [docs/guide/releases.en.md](docs/guide/releases.en.md).
- `release.yml` - on a `v*` tag push (or manually): builds everything on both platforms and publishes
  a GitHub Release with every asset (Windows + Linux binaries, all reports, API docs, `site.zip`).
  Prefer the local `10-release.bat`/`.sh` script day to day; it does the same thing without using any
  Actions minutes.

### Build App on Windows

We have already configured script for build operations. `7-build-app-windows.bat` have complete all required tasks and copy outputs to release folder.  

**Operation Completed in roughly 15-20 minutes** (longer than earlier versions of this template,
because it now also produces the native OpenCppCoverage/genhtml reports alongside ReportGenerator's).

- Clean project outputs

- Create required folders

- Run doxygen for documentation

- Run coverxygen for document coverage report

- Run Report Generator (and, if available, native lcov `genhtml`) for the documentation coverage report

- Configure the project (Visual Studio if installed, else Ninja - auto-detected)

- Build Project Debug and Release

- Install/Copy Required Library and Headers

- Run Tests (native JUnit XML -> `junit2html`)

- Run OpenCppCoverage for coverage data collection, both a ReportGenerator HTML report and OpenCppCoverage's own native HTML report

- Copy output report to webpage folder

- Run mkdocs to build the site (`site/`), linking every report - see `docs/reports.md`

- Compress outputs to release folder, everything is ready for deployment. 

### Build App on WSL/Linux

We are running WSL on Windows 10/11 and solve our virtual machine problem. We make cross-platform development. After development before commit we run and test app on Windows and WSL with this scripts. To run on WSL you need to install WSL first - see [docs/guide/install.en.md](docs/guide/install.en.md), including a real WSL2 gcov/lcov compatibility issue we hit and worked around (see [docs/guide/troubleshooting.en.md](docs/guide/troubleshooting.en.md)).

you can use our public notes

- https://github.com/coruhtech/vs-docker-wsl-cpp-development

- [GitHub - ucoruh/ns3-wsl-win10-setup: ns3 windows 10 WSL2 setup and usage](https://github.com/ucoruh/ns3-wsl-win10-setup)

After WSL installation, run `7-build-app-linux.sh` from a path under WSL's own filesystem (not a Windows Google-Drive path); this will provide similar tasks with Windows and will generate reports and libraries in the `release_linux` folder. 

----

$End-Of-File$
