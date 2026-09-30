# Daily workflow

## Branch, commit, push

```bash
git checkout -b feature/inventory-add-stock
# ... edit files ...
git status --short
git add src/inventory/ src/tests/inventory/
git commit -m "Add Inventory::addStock with negative-quantity validation"
git push -u origin feature/inventory-add-stock
```

Open a pull request into `main` on GitHub. `.github/workflows/cpp.yml` runs automatically (configure, build Release,
`ctest`) on the push and on the PR. It is intentionally lean (no Doxygen, no coverage, no site) so it finishes in a couple
of minutes and does not burn Actions minutes on every push; see [Releases](releases.md) for the minutes budget.

## The everyday loop: build and test

```bat
6-build-and-test-windows.bat
```

```bash
./6-build-and-test-linux.sh
```

Builds Debug and Release and runs all unit tests (about a minute). Failures stop the script with the failing test names and
`build/<platform>-debug/test-results.log`.

## Format your code before committing

```bat
5-format-code-windows.bat
```

```bash
./5-format-code-linux.sh
```

If you installed the git hooks once (`1-configure-git-hooks-windows.bat` / `./1-configure-git-hooks-linux.sh`), `pre-commit`
runs AStyle automatically on staged `.c/.cpp/.h` files and re-stages the formatted result.

## Before a milestone, a demo, or asking for help: build everything

```bat
7-build-all-windows.bat
9-open-site-windows.bat
```

```bash
./7-build-all-linux.sh
./9-open-site-linux.sh
```

`7-build-all-*` = `6-build-and-test-*` + every report + API docs + the site + the `release/` folder. `9-open-site-*` serves
the site on `http://localhost:8000/`.

## Where everything lands

All of these are generated and gitignored - never commit them.

| What | Where |
| --- | --- |
| Build trees | `build/windows-debug/`, `build/windows-release/`, `build/linux-debug/`, `build/linux-release/` |
| Built binaries, libraries, headers | `publish/<platform>-<arch>/{release,debug}/{bin,lib,include}` (e.g. `publish/windows-x64/release/bin/calculatorapp.exe`) |
| Every HTML report and the API docs | `reports/<platform>/<kind>-<tool>/` (e.g. `reports/linux/coverage-lcov/index.html`) - see [Which report is which?](../reports/index.md) |
| ReportGenerator trend history | `reports/history/<platform>/` |
| The built site (open this) | `site/index.html` via `9-open-site-*` |
| Every output as one archive each | `release/` (`ASSETS.md` lists them, `SHA256SUMS.txt` has the checksums) |

## Reading a report quickly

1. `9-open-site-*`, then the **Reports** tab: pick your platform.
2. **Red / orange lines** in a coverage report = not executed by any test: add a test or understand why (genuinely
   unreachable defensive code).
3. Compare the ReportGenerator number with the native tool's number for the same report (`coverage-reportgenerator`
   vs `coverage-opencppcoverage` / `coverage-lcov`). They should be close; a big difference usually means one of them
   looked at stale data (re-run the build).
4. `tests-junit2html` shows pass/fail per test case, no coverage; check it first if the build reported failing tests.

## CI (GitHub Actions)

- `.github/workflows/cpp.yml`: build and test on every push/PR (Windows + Ubuntu, Release only, no reports).
- `.github/workflows/pages.yml`: on push to `main`: Windows and Linux jobs build tests, reports and API docs; a merge job
  builds the site with both platforms' reports, checks its links and deploys it to GitHub Pages (skipped on a private
  repository without Pages - see [Showing your project without GitHub Pages](showcase-without-pages.md)).
- `.github/workflows/release.yml`: on a `v*` tag: Windows, Linux and macOS jobs, then publishes every asset. Prefer
  `10-release-*` locally day to day - same assets, no Actions minutes ([Releases](releases.md)).

## Cleaning up

```bat
11-clean-windows.bat
```

```bash
./11-clean-linux.sh
```

Removes `build/`, `publish/`, `reports/`, `site/`, `release/` and the other generated files. Re-runnable.
