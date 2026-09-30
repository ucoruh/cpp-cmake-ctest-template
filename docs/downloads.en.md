# Downloads

Every release carries **all** outputs of the build as separate archives - the same names as in the local
`release/` folder (`7-build-all-*` creates it; `10-release-*` uploads it).

[:material-download: Latest release](https://github.com/ucoruh/cpp-cmake-ctest-template/releases/latest){ .md-button .md-button--primary }
[:material-tag-multiple: All releases](https://github.com/ucoruh/cpp-cmake-ctest-template/releases){ .md-button }

## Asset names

`<project>-<version>[-<platform>[-<arch>]]-<content>[-<tool>].<ext>` - the version has no `v`; platforms are
`windows`, `linux`, `macos`; architectures `x64`, `arm64`.

| Asset (example for `calculator` 1.1.1) | What is inside |
| --- | --- |
| `calculator-1.1.1-windows-x64-app.zip` | the application (`.zip` for Windows) |
| `calculator-1.1.1-linux-x64-app.tar.gz` | the application (`.tar.gz` for Linux and macOS: keeps the executable bit) |
| `calculator-1.1.1-macos-arm64-app.tar.gz` | the application, built by CI on macOS |
| `calculator-1.1.1-windows-x64-lib-release.zip`, `-lib-debug.zip` | libraries + headers (also `-linux-x64-lib-*.tar.gz`) |
| `calculator-1.1.1-<platform>-report-tests.zip` | unit test results (junit2html) |
| `calculator-1.1.1-<platform>-report-coverage-reportgenerator.zip` | code coverage, ReportGenerator |
| `calculator-1.1.1-windows-report-coverage-opencppcoverage.zip` | code coverage, OpenCppCoverage (Windows) |
| `calculator-1.1.1-linux-report-coverage-lcov.zip`, `-gcovr.zip` | code coverage, lcov genhtml and gcovr (Linux) |
| `calculator-1.1.1-<platform>-report-doccoverage-reportgenerator.zip`, `-lcov.zip` | documentation coverage, both families |
| `calculator-1.1.1-<platform>-api-doxygen.zip` | Doxygen API documentation |
| `calculator-1.1.1-source.zip` | source code, googletest submodule included |
| `calculator-1.1.1-site.zip` | this whole site, both platforms' reports (unzip, serve with a local web server) |
| `ASSETS.md`, `SHA256SUMS.txt` | the asset table and the checksums |

Check a download: `sha256sum -c SHA256SUMS.txt` (Linux) or `certutil -hashfile <file> SHA256` (Windows).
