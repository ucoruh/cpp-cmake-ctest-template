# The course naming standard

All three course project templates (C/C++ with CMake, Java with Maven, C# with .NET) follow the same standard, so what you
learn in one carries over to the others. This page is the short version.

## 1. One identity file: `project.env`

```text
PROJECT_NAME=calculator
VERSION=1.1.1
GITHUB_REPO=ucoruh/cpp-cmake-ctest-template
```

Every script, workflow, tool, CMake and MkDocs reads it. Rename the project or raise the version **only here**.

## 2. Platform tokens

`windows`, `linux` (native Linux **and WSL** - WSL is Linux: the same `.sh` scripts, Linux binaries) and `macos` (CI only, the
application only). Architectures `x64` / `arm64` appear only in binary names. Never `win` or `wsl` in a file name.

## 3. Scripts: the same number is the same job

`NN-name-windows.bat` and `NN-name-linux.sh`; helpers live in `scripts/` with the same suffix rule.

| # | Job |
| --- | --- |
| 0 | `init-submodules` (only where submodules exist) |
| 1 | `configure-git-hooks` |
| 2 | `create-gitignore` |
| 3 | `install-package-manager` (Windows only) |
| 4 | `install-tools` |
| 5 | `format-code` |
| 6 | `build-and-test` (fast: build + unit tests) |
| 7 | `build-all` (6 + every report, API docs, the site, the `release/` folder) |
| 8 | `run-app` |
| 9 | `open-site` |
| 10 | `release` |
| 11 | `clean` |

## 4. Local folders (all gitignored)

```text
build/<platform>-<config>/          build/windows-debug, build/linux-release, ...
publish/<platform>-<arch>/          publish/windows-x64/{release,debug}/{bin,lib,include}
reports/<platform>/<kind>-<tool>/   reports/linux/coverage-lcov, reports/windows/tests-junit2html, ...
site/                               the MkDocs site (site/raw = standalone reports, site/downloads = their zips)
release/                            one archive per output + ASSETS.md + SHA256SUMS.txt
```

## 5. Documentation and reports are per platform

Tests, code coverage (both families), documentation coverage (both families) and API docs are produced on Windows **and** on
Linux and kept apart, each with the platform in its name - they can differ between the two.

## 6. Release assets: `release/` = the GitHub Release

`<project>-<version>[-<platform>[-<arch>]]-<content>[-<tool>].<ext>`, version without `v`; `.zip` for Windows binaries and
everything HTML, `.tar.gz` for Linux/macOS binaries. See [Downloads](../downloads.md) for the full list.

## 7. The site: MkDocs Material, bilingual

Home, Guide, Reports (Windows / Linux), API docs, Downloads; dark/light; search in both languages; English at the root and
Turkish under `/tr/` (mkdocs-static-i18n, suffix mode: `name.en.md` + `name.tr.md`). **Iframe rule:** only *standalone* HTML
made outside the site generator is framed (ReportGenerator, genhtml, gcovr, junit2html, OpenCppCoverage, Doxygen, JaCoCo,
Javadoc); a page that carries its own site navigation (a Maven site, DocFX) is linked, never framed - see
[Showing an HTML report inside your site](reports-in-site.md).

## 8. CI and releases

Windows and Linux jobs build, test and produce the reports and API docs; a macOS job builds the application only; a merge job
builds the site (hard failure only on broken links inside our own pages), deploys Pages on `main` (skipped on a private
repository without Pages - see [Showing your project without GitHub Pages](showcase-without-pages.md)) and, on a `v<VERSION>`
tag, publishes every asset with `ASSETS.md` and `SHA256SUMS.txt`.
