# Showing your project without GitHub Pages

Your course repository is **private** (you created it with *Use this template -> Private*, see
[Use the template](use-template.en.md)) and you are probably on **GitHub Free**. On that plan a private repository has
**no GitHub Pages** (Pages for private repositories needs GitHub Pro/Team). Everything Pages would show can be shown
**locally**, and the same files travel in a GitHub Release, which *does* work on private repositories.

## The two commands

Windows:

```bat
7-build-all-windows.bat
9-open-site-windows.bat
```

Linux / WSL:

```bash
./7-build-all-linux.sh
./9-open-site-linux.sh
```

1. `7-build-all-*` builds and tests the project, produces every report and the API docs, builds the MkDocs site and fills the
   `release/` folder.
2. `9-open-site-*` serves `site/` on **http://localhost:8000/** with a tiny local web server and opens your browser. The
   site is the same one GitHub Pages would show: landing page, guides, every report page (each report framed, with "Open in
   a new tab" and "Download (zip)"), the API docs.

A local web server is needed because report pages use `<iframe>`s and browsers block those on `file://` pages - do not
double-click `site/index.html`.

## What is in `release/`

Every output as its own archive, named `<project>-<version>-<platform>[-<arch>]-<content>[-<tool>].<ext>`:

```text
calculator-1.1.0-windows-x64-app.zip              the application (extract and run calculatorapp.exe)
calculator-1.1.0-windows-x64-lib-release.zip      libraries + headers (also -lib-debug.zip)
calculator-1.1.0-windows-report-tests.zip         unit test results
calculator-1.1.0-windows-report-coverage-reportgenerator.zip     code coverage, both families
calculator-1.1.0-windows-report-coverage-opencppcoverage.zip
calculator-1.1.0-windows-report-doccoverage-reportgenerator.zip  documentation coverage, both families
calculator-1.1.0-windows-report-doccoverage-lcov.zip
calculator-1.1.0-windows-api-doxygen.zip          API documentation
calculator-1.1.0-source.zip                       source code
calculator-1.1.0-site.zip                         the whole site
ASSETS.md   SHA256SUMS.txt                        the asset table and the checksums
```

(On Linux the same names with `linux` and `.tar.gz` for binaries.) A local build holds **your platform's** assets plus the
neutral ones; `ASSETS.md` names the platform whose assets are missing. CI builds both platforms.

## Demonstration checklist (project presentation)

Prepare the day before: `7-build-all-*` on your machine, then `9-open-site-*` once to check it.

- [ ] **Local site home** - `9-open-site-*` -> `http://localhost:8000/`: the landing page with the badges, the project
      name and version.
- [ ] **Each report page** - *Reports -> your platform*: unit test results, code coverage (ReportGenerator **and** the
      native tool - do the numbers agree?), documentation coverage (both). Say what a red line means.
- [ ] **API docs** - the *API docs* tab: open a class of your library, show its Doxygen comment and the call graph.
- [ ] **`release/` folder listing** - open the folder (`dir release` / `ls release`): one archive per output, `ASSETS.md`,
      `SHA256SUMS.txt`.
- [ ] **Run the app from the release archive** - unzip `<project>-<version>-<platform>-x64-app.*` into an empty folder and
      run it (`calculatorapp.exe` / `./calculatorapp`) with an input from your project topic.
- [ ] **Verify a checksum** (optional): `certutil -hashfile <file> SHA256` (Windows) or `sha256sum -c SHA256SUMS.txt`
      (Linux) matches `SHA256SUMS.txt`.
- [ ] **GitHub** - the repository page: Actions tab green, the release (if you published one), the instructor listed
      under *Settings -> Collaborators*.

## The same files as a GitHub Release (works on private repositories)

```bat
10-release-windows.bat --dry-run
10-release-windows.bat
```

```bash
./10-release-linux.sh --dry-run
./10-release-linux.sh
```

`--dry-run` prints the `gh release create` command and the list of files it would upload - the GitHub asset list is the local
`release/` folder, one to one. The real run needs a clean working tree, a pushed commit and `gh auth login` (see
[Releases](releases.en.md)); the tag is `v<VERSION>` from `project.env`. Releases work on GitHub Free for private repositories
and are visible to you and your collaborators (the instructor).

## If you have GitHub Pro (Student Developer Pack)

Then Pages also works for a private repository: set the repository variable `PAGES_ON_PRIVATE` to `true` and turn Pages on
(**Settings -> Pages -> Deploy from a branch -> `gh-pages` / root**); the *Deploy Pages* workflow publishes the same site.
Details in [Releases](releases.en.md). Without Pro, the *Deploy Pages* workflow builds and checks the site but skips the
deploy and prints a notice pointing to this page.
