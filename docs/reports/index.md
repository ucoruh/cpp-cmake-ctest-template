# Which report is which?

Every full build (`7-build-all-windows.bat` / `./7-build-all-linux.sh`) writes several *different* reports about the
same code, **separately for Windows and for Linux** (they can differ: compiler, platform macros, tool
versions). This page explains what each one is, which tool made it, and why there are two of almost everything.

## The pattern: ReportGenerator vs. the native tool

For code coverage and documentation coverage the template generates **two independent HTML reports side by
side**:

1. **[ReportGenerator](https://github.com/danielpalme/ReportGenerator)** - a third-party, ecosystem-agnostic tool.
   It reads a coverage file (Cobertura XML or lcov `.info`) and produces a polished HTML report with history charts
   and the small SVG badges shown in the `README`. It is the same tool on Windows and Linux and in C++, Java or C#.
2. **The native tool of the toolchain** - on Windows [OpenCppCoverage](https://github.com/OpenCppCoverage/OpenCppCoverage)'s
   own HTML export; on Linux [lcov's `genhtml`](https://github.com/linux-test-project/lcov) and
   [gcovr](https://gcovr.com/). These are what C/C++ developers used before ReportGenerator existed.

Comparing them is intentional: "coverage report" is not one fixed format, and the numbers should agree (a good sanity check).

## The reports

Each report is a folder `reports/<platform>/<kind>-<tool>/` on your disk, an archive in `release/`
(`<project>-<version>-<platform>-<asset>.zip`) and a page in this site.

| Folder (`reports/<platform>/...`) | Release asset | Tool | What it shows |
| --- | --- | --- | --- |
| `tests-junit2html/` | `report-tests` | CTest `--output-junit` -> junit2html | Pass/fail per test case with timing. No coverage information. Check this first when a test fails. |
| `coverage-reportgenerator/` | `report-coverage-reportgenerator` | ReportGenerator (Cobertura on Windows, lcov on Linux) | Which lines, branches and methods of `calculator`, `utility` and `calculatorapp` the tests executed, with history charts. |
| `coverage-opencppcoverage/` (Windows) | `report-coverage-opencppcoverage` | OpenCppCoverage | The **same** coverage data as OpenCppCoverage's own HTML. |
| `coverage-lcov/` (Linux) | `report-coverage-lcov` | lcov `genhtml` | The **same** coverage data as lcov's own HTML (with branch coverage). |
| `coverage-gcovr/` (Linux) | `report-coverage-gcovr` | gcovr | The same data from a second, independent implementation. |
| `doccoverage-reportgenerator/{lib,tests}/` | `report-doccoverage-reportgenerator` | coverxygen -> ReportGenerator | **Documentation** coverage: how many public functions and classes carry a Doxygen comment. Libraries and test sources. |
| `doccoverage-lcov/{lib,tests}/` | `report-doccoverage-lcov` | coverxygen -> `genhtml` | The same documentation-coverage data, native lcov HTML. |
| `api-doxygen/{lib,tests}/html/` | `api-doxygen` | Doxygen | The API reference itself (classes, functions, graphs). See the **API docs** tab. |

Badges (the small SVG images in the `README`) are written by ReportGenerator to `assets/badges/<platform>/{coverage,doccoverage}/`.

## Code coverage vs. documentation coverage - do not mix them up

- **Code coverage** answers: *did the tests **execute** this line?*
- **Documentation coverage** answers: *does this function or class **have a Doxygen comment**?* A fully commented
  function can have 0% code coverage, and a fully tested one 0% documentation coverage.

## How the reports get into this site

The reports are standalone HTML made by other tools (ReportGenerator, genhtml, Doxygen ...), so each gets its
own page here that shows it in a framed `<iframe>` - see
[Showing an HTML report inside your site](../guide/reports-in-site.en.md). Locally the site is served by
`9-open-site-windows.bat` / `9-open-site-linux.sh`; on GitHub Pages it is deployed by `.github/workflows/pages.yml`
(on a private repository without Pages, see
[Showing your project without GitHub Pages](../guide/showcase-without-pages.en.md)).
