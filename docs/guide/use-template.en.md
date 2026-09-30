# Use the template

## 1. Create your own PRIVATE repository from it ("Use this template", not "Fork")

Your course project must be **private**. A *fork* of a public repository cannot be made private, so do **not** fork.
Create a repository *from the template* instead:

1. Open the template repository on GitHub and click the green **Use this template** button (top right, next to
   *Code*), then **Create a new repository**.
2. **Owner**: your own account. **Repository name**: e.g. `cen429-2026-yourname-calculator`. Add a description if you like.
3. Under visibility choose **Private** (not *Public*). Leave "Include all branches" off.
4. Click **Create repository**. You now own a brand-new repository with this template's files and **no shared git
   history** with the original.

### Add the instructor and your team mates

In *your* new repository: **Settings -> Collaborators -> Add people** (on newer layouts: **Settings -> Collaborators and
teams**), type the instructor's GitHub username (`ucoruh`) and your team mates', pick a role (**Read** is enough for the
instructor to grade; team mates need **Write**) and send the invitations. A private repository is invisible to everyone
who is not added.

## 2. Clone it (with the googletest submodule)

```bash
git clone --recurse-submodules https://github.com/<you>/<your-repo>.git
cd <your-repo>
```

If you cloned without `--recurse-submodules`, or with `--depth 1`, run the submodule script (safe to re-run, it retries
after fetching the full history):

```bat
0-init-submodules-windows.bat
```

```bash
./0-init-submodules-linux.sh
```

Expected output ends with `::: INIT SUBMODULES COMPLETED ::::`. Verify:

```bash
git submodule status
```

Expected: a line starting with a commit hash (not `-`) for `src/tests/googletest`, e.g.
` 063de7e9578f82b369302001269680b4b1553359 src/tests/googletest (v1.18.0)`. (A leading `-` means the submodule is not
initialised yet.)

## 3. Name your project: `project.env`

Open `project.env` in the repository root:

```text
PROJECT_NAME=calculator
VERSION=1.1.0
GITHUB_REPO=ucoruh/cpp-cmake-ctest-template
```

Set `PROJECT_NAME` to your project's short lowercase name, `GITHUB_REPO` to `<you>/<your-repo>` and keep `VERSION` as
the version you are about to release. **This is the only place**: every script, every workflow, CMake, MkDocs and the
release archive names read it. (The C++ folders and target names are covered in
[From a topic to your project](topic-to-project.en.md).)

## 4. The numbered scripts

Same number = same job; the platform is the suffix (`-windows.bat` or `-linux.sh`; WSL uses the Linux ones).

| # | Job | Windows | Linux / WSL |
| --- | --- | --- | --- |
| 0 | initialise the googletest submodule (`update` = newest upstream) | `0-init-submodules-windows.bat` | `0-init-submodules-linux.sh` |
| 1 | install the git hooks | `1-configure-git-hooks-windows.bat` | `1-configure-git-hooks-linux.sh` |
| 2 | re-create `.gitignore` | `2-create-gitignore-windows.bat` | `2-create-gitignore-linux.sh` |
| 3 | package managers | `3-install-package-manager-windows.bat` | - |
| 4 | install every tool | `4-install-tools-windows.bat` | `4-install-tools-linux.sh` |
| 5 | format the code | `5-format-code-windows.bat` | `5-format-code-linux.sh` |
| 6 | **fast**: build + unit tests | `6-build-and-test-windows.bat` | `6-build-and-test-linux.sh` |
| 7 | **everything**: 6 + reports + API docs + site + `release/` | `7-build-all-windows.bat` | `7-build-all-linux.sh` |
| 8 | run the sample app | `8-run-app-windows.bat` | `8-run-app-linux.sh` |
| 9 | serve + open the site on http://localhost:8000 | `9-open-site-windows.bat` | `9-open-site-linux.sh` |
| 10 | publish `release/` as a GitHub Release | `10-release-windows.bat` | `10-release-linux.sh` |
| 11 | clean every generated folder | `11-clean-windows.bat` | `11-clean-linux.sh` |

Helper scripts (Python / generator / genhtml / compiler detection, the `project.env` loader) live in `scripts/`.

### Old name -> new name

If you followed an older version of this template, or an older guide, here is where everything went:


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
| `docs/coveragereportlibwin`, `docs/coveragenativelibwin`, `docs/doxygenlibwin`, `docs/testresultswin`, `docs/coverxygen*` ... (and the `*linux` twins) | `reports/<windows or linux>/<kind>-<tool>/` |
| `report_test_hist_win/`, `report_doc_lib_hist_win/` ... | `reports/history/<windows or linux>/` |
| `assets/codecoveragelibwin/`, `assets/doccoveragelibwin/` (and `*linux`) | `assets/badges/<windows or linux>/{coverage,doccoverage}/` |

## 5. First build

Windows:

```bat
7-build-all-windows.bat
```

Linux / WSL (from a path under WSL's own filesystem, not `/mnt/g/...` - see [Install](install.en.md)):

```bash
chmod +x *.sh scripts/*.sh
./7-build-all-linux.sh
```

Takes roughly 10-20 minutes the first time (Doxygen, coverage, the site). Use `6-build-and-test-*` (about a minute)
for the everyday loop. At the end you should see:

```text
....................
Operation completed. release\ now holds:
calculator-1.1.0-windows-api-doxygen.zip
...
```

and earlier `100% tests passed, 0 tests failed out of 46` (the count grows with your own tests).

## 6. Open the site and run the app

```bat
9-open-site-windows.bat
8-run-app-windows.bat "2+3*(4-1)"
```

```bash
./9-open-site-linux.sh
./8-run-app-linux.sh "2+3*(4-1)"
```

`9-open-site-*` serves `site/` on `http://localhost:8000/` (a real web server is required because every report page
shows its report in an `<iframe>`) and opens your browser. Every report is explained in
[Which report is which?](../reports/index.md). For the project demonstration follow
[Showing your project without GitHub Pages](showcase-without-pages.en.md).

## Next step

Continue with [From a topic to your project](topic-to-project.en.md).
