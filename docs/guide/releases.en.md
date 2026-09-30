# Private repository: releases and the site

Your course repository is **private** (only you and people you add can see it), and most students
are on the **GitHub Free** plan. This page explains what that combination can and cannot do, and how
this template works around the limits.

## What works on GitHub Free (private repo) vs. Pro (Student Pack)

| Feature | GitHub Free, private repo | GitHub Pro (free via the Student Developer Pack) |
| --- | --- | --- |
| Releases (a tag + uploaded files, up to 2 GiB per file, up to 1000 assets) | **Works** - this is what `10-release-windows.bat`/`.sh` and the release GitHub Actions workflow use. | Works (no difference). |
| GitHub Actions | Works - 2,000 minutes/month, 500 MB of artifact storage. | Works - 3,000 minutes/month, 1 GB of artifact storage. |
| GitHub Pages | **Does not work on a private repository.** | Works on a private repository. |

Because releases work on Free and Pages does not, this template ships the built site as a
downloadable `site.zip` **inside the release**, instead of relying on GitHub Pages:

1. Download the release's `site.zip`.
2. Unzip it.
3. Open `index.html` in the unzipped folder directly, **or** serve the unzipped folder with
   `python -m http.server` and open the printed `http://localhost:.../` URL - the embedded report
   pages use `<iframe>`s, which most browsers block from a plain unzipped `file://` path (same reason
   `9-open-site-windows.bat`/`.sh` run a local server for the site you build yourself - see
   [reports-in-site.en.md](reports-in-site.en.md)).

## How `.github/workflows/pages.yml` behaves on your repository

`pages.yml` runs on every push to `main`. It always **builds** the full site (both platforms' reports
merged, link-checked with `mkdocs build --strict` and `tools/check_site_links.py`) so build breakage is
caught either way - it only skips the **deploy** step. On a private repository the skip notice points to
[Showing your project without GitHub Pages](showcase-without-pages.en.md):

- **Public repository** (this template's own repo, `ucoruh/cpp-cmake-ctest-template`, is public): Pages
  deploys automatically. Live site: <https://ucoruh.github.io/cpp-cmake-ctest-template/>.
- **Private repository without Pro/Team**: the deploy step is skipped. The workflow prints a
  `::notice` in the Actions log and a summary at the top of that run's page (Actions tab -> the run ->
  Summary) explaining why, and `site.zip` in the release remains the way to get the site (see above).
- **Private repository with Pro/Team** (e.g. the Student Developer Pack): set the **repository
  variable** `PAGES_ON_PRIVATE` to `true` (**Settings -> Secrets and variables -> Actions -> Variables
  tab -> New repository variable**, name `PAGES_ON_PRIVATE`, value `true`), then re-run the workflow
  (**Actions tab -> Deploy Pages -> Run workflow**, or push again). Also turn Pages itself on once:
  **Settings -> Pages -> Source -> Deploy from a branch -> `gh-pages` / `(root)`** - the workflow
  creates the `gh-pages` branch on its first successful deploy, but does not flip this setting for you.

## Get the GitHub Student Developer Pack (optional, gives you Pro)

If you want Pages to work directly on your private repository (no zip/unzip step), apply for the
[GitHub Student Developer Pack](https://education.github.com/pack) with your university email
address; you typically also need to upload proof of enrollment (a student ID photo or similar).
Approval can take anywhere from a few minutes to a few days. Once approved, your account gets GitHub
Pro for free for as long as you are a verified student, which includes Pages on private repositories
(Settings -> Pages -> enable, pick a branch/folder).

## Add the instructor as a collaborator

A private repository's releases are only visible to people with access. Add the instructor
(`ucoruh`) as a collaborator so your releases (and the rest of the repository) can be seen for
grading: **Settings -> Collaborators and teams -> Add people** -> enter their GitHub username ->
pick a role (Read is enough for grading) -> send the invitation.

## Installing and logging in to `gh` (the GitHub CLI)

Both `10-release-windows.bat`/`.sh` and the manual release process use `gh`.

Windows:

```bat
choco install gh -y
```

Linux/WSL:

```bash
sudo apt install gh -y
# or, if that package is not available on your distro/version:
# see https://github.com/cli/cli/blob/trunk/docs/install_linux.md
```

Log in (interactive, opens a browser):

```bash
gh auth login
```

Answer the prompts: **GitHub.com** -> **HTTPS** -> **Login with a web browser** (or a token, if you
already have a personal access token) -> follow the one-time code shown in your terminal in the
browser window that opens.

Verify:

```bash
gh auth status
```

Expected output includes a line like:

```text
✓ Logged in to github.com account <your-username> (keyring)
```

## Publishing a release locally (no Actions minutes used)

The version comes from `project.env` (`VERSION=1.1.0` -> tag `v1.1.0`); change it there, commit and push, then:

```bat
10-release-windows.bat --dry-run
10-release-windows.bat
```

```bash
./10-release-linux.sh --dry-run
./10-release-linux.sh
```

`--dry-run` builds nothing: it reads the existing `release/` folder and prints exactly the `gh release create` command it
*would* run and the list of files it would upload, without creating anything (it needs no `gh` login). Run
`7-build-all-*` first to fill `release/`. The real run builds everything (`7-build-all-*`), then uploads **every file of
`release/`** - the GitHub release's asset list is the local folder, one to one:

```text
calculator-1.1.0-windows-x64-app.zip, ...-lib-release.zip, ...-lib-debug.zip
calculator-1.1.0-windows-report-tests.zip, ...-report-coverage-reportgenerator.zip, ...-report-coverage-opencppcoverage.zip
calculator-1.1.0-windows-report-doccoverage-reportgenerator.zip, ...-report-doccoverage-lcov.zip, ...-api-doxygen.zip
calculator-1.1.0-source.zip, calculator-1.1.0-site.zip, ASSETS.md, SHA256SUMS.txt
```

(a local build holds the assets of the platform you built on; `ASSETS.md` says which platform is missing - the GitHub
Actions release workflow builds Windows, Linux and macOS.) The script refuses to run if your working tree has uncommitted
changes or your commit is not pushed yet, so a release always corresponds to a real commit.

## Alternative: build the release with GitHub Actions instead

`.github/workflows/release.yml` does the same thing, but on GitHub's servers, triggered by pushing a
`v*` tag or running it manually (Actions tab -> Release -> Run workflow). Prefer the local script day
to day; use this when you specifically want a release built by a clean, reproducible environment
instead of your own machine. It takes Actions minutes (roughly the same ~15-20 minutes as running
`7-build-all-windows.bat` by hand, per platform) - on GitHub Free that is well within the 2,000 minutes/month
budget for occasional releases, but do not run it on every push (it is not wired to `push:` for that
reason).

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `gh release create` fails with a 403 or 404 | Either `gh` is not logged in (`gh auth status`), or your account does not have write access to the repository (you need to be the owner, or a collaborator with write access - read-only collaborators, like the instructor added for grading, cannot publish releases). |
| Release created, but the instructor says they cannot see it | The repository is private and they were not added as a collaborator yet - see above. |
| `gh release create` fails with something about asset size | A single file over 2 GiB, or more than 1000 files total, cannot be uploaded to one release. This template's own archives are nowhere near that; if you added large data files, exclude them or split them differently. |
| Pages does not turn on in Settings for a private repo | You are not on GitHub Pro/Team (and do not have the Student Pack yet) - see above; use the `site.zip` inside the release instead in the meantime. |
