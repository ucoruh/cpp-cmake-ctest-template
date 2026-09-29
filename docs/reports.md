# Which report is which?

Every build script writes several *different* reports about the same code. They can look similar at
first glance, so this page explains what each one is, what tool produced it, and why there are two of
almost everything.

## The pattern: ReportGenerator vs. the native tool

For code coverage and documentation coverage, this template deliberately generates **two independent
HTML reports side by side**:

1. **[ReportGenerator](https://github.com/danielpalme/ReportGenerator)** - a third-party, ecosystem-agnostic
   tool. It reads a coverage file (Cobertura XML or lcov `.info`) and produces a polished HTML report with
   history charts and small SVG badges (the ones shown in `README.md`). It is the same tool regardless of
   whether the coverage came from Windows or Linux, C++, Java or C#.
2. **The native/older tool that ships with the toolchain itself** - on Windows this is
   [OpenCppCoverage](https://github.com/OpenCppCoverage/OpenCppCoverage)'s own HTML export; on Linux/WSL it
   is [lcov's genhtml](https://github.com/linux-test-project/lcov). These are the reports C/C++
   developers used long before ReportGenerator existed, and some CI systems still expect them directly.

Comparing them side by side is intentional: it shows that "coverage report" is not one fixed format, and
that the numbers should agree between the two independent tools (a good sanity check when something looks
wrong).

## Report folders (relative to docs/)

| Folder | Produced by | What it shows |
| --- | --- | --- |
| `doxygenlibwin/html`, `doxygenliblinux/html` | Doxygen | API documentation generated from the `calculator` and `utility` library headers/sources (Doxygen comments). This **is** the site, not just a report - see below. |
| `doxygentestwin/html`, `doxygentestlinux/html` | Doxygen | The same, but for the googletest test sources under `src/tests`, so you can browse what each test covers. |
| `testresultswin/index.html`, `testresultslinux/index.html` | CTest `--output-junit` -> junit2html | The native unit-test results report: pass/fail per test case, straight from CTest's own JUnit XML output. No coverage information, just pass/fail and timing. |
| `coveragereportlibwin/index.html`, `coveragereportliblinux/index.html` | ReportGenerator (from Cobertura/lcov) | Code coverage: which lines/branches/methods of `calculator`, `utility` and `calculatorapp` were executed by the googletest suite. History charts if you build more than once (`report_test_hist_*`). |
| `coveragenativelibwin/index.html` | OpenCppCoverage (`--export_type=html`) | The **same** code coverage data, Windows-native HTML report straight from OpenCppCoverage. Compare its numbers with `coveragereportlibwin` - they should match. |
| `coveragenativeliblinux/index.html` | genhtml (lcov) | The **same** code coverage data on Linux/WSL, native lcov/genhtml HTML report. gcovr output is included alongside it (`coveragenativeliblinux/gcovr/`) if gcovr is installed. |
| `coverxygenlibwin/index.html`, `coverxygenliblinux/index.html` | ReportGenerator (from a coverxygen-produced lcov `.info`) | **Documentation** coverage for the library: what fraction of public functions/classes actually have a Doxygen comment (not the same thing as test/code coverage!). |
| `coverxygennativelibwin/index.html`, `coverxygennativeliblinux/index.html` | genhtml (lcov) | The same documentation-coverage data as a native lcov/genhtml report. |
| `coverxygentestwin/index.html`, `coverxygentestlinux/index.html` | ReportGenerator | Documentation coverage for the test sources. |
| `coverxygennativetestwin/index.html`, `coverxygennativetestlinux/index.html` | genhtml (lcov) | The same, native report. |

Badges (the small SVG images used in `README.md`, e.g. line/branch/method coverage) live under
`assets/codecoverage*` (code coverage) and `assets/doccoverage*` (documentation coverage) and are also
produced by ReportGenerator (`-reporttypes:Badges`).

## "Documentation coverage" vs. "code coverage" - don't mix them up

- **Code coverage** (`coveragereport*` / `coveragenative*`) answers: *did the tests **execute** this line
  of code?*
- **Documentation coverage** (`coverxygen*`) answers: *does this function/class **have a Doxygen
  comment**?* It has nothing to do with whether the function was tested; a fully-commented function can
  have 0% code coverage, and a fully-tested function can have 0% documentation coverage.

## The site

`mkdocs build` (run by the main build scripts, or on its own via `9-open-site.bat` / `.sh`) turns this
`docs/` folder plus the reports above into one static site under `site/`, with a navigation menu linking
every report above. Doxygen's own HTML output (`doxygenlibwin/html`) is the primary API reference (the
ecosystem-native C++ "site"), and this mkdocs site is the index that ties every report, the guides and the
API docs together in one place - see `9-open-site.bat` / `9-open-site.sh`.
