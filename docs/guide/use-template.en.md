# Use the template

## 1. Create your own repository from it

On GitHub, open the template repository and click **"Use this template" -> "Create a new
repository"**. Pick your own repository name (e.g. `cen429-2026-yourname-calculator`), and make it
**private** (course repositories are private; see
[releases.en.md](releases.en.md) for what that means for GitHub Pages/Actions/Releases). This gives
you a brand-new repository with this template's files but **no shared git history** with the
original - your commits are yours.

Add the instructor as a collaborator now (Settings -> Collaborators) so a private repository is still
visible for grading - see [releases.en.md](releases.en.md).

## 2. Clone it

```bash
git clone https://github.com/<you>/<your-repo>.git
cd <your-repo>
```

(SSH works too if you have a key set up: `git clone git@github.com:<you>/<your-repo>.git`.)

## 3. Initialise the googletest submodule

```bat
0-init-submodules.bat
```

or on Linux/WSL:

```bash
chmod +x 0-init-submodules.sh
./0-init-submodules.sh
```

Expected output ends with:

```text
::: INIT SUBMODULES COMPLETED ::::
```

If you cloned with `git clone --depth 1` (a shallow clone), the first `git submodule update --init`
can fail because the submodule's pinned commit is not reachable yet - this script now retries after
fetching the submodule's full history automatically; you do not need to do anything extra.

Verify the submodule is really there:

```bash
git submodule status
```

Expected output: a line starting with a commit hash (not `-`) for `src/tests/googletest`, e.g.

```text
 063de7e9578f82b369302001269680b4b1553359 src/tests/googletest (v1.18.0)
```

(A leading `-` instead of a space means the submodule is not initialised yet.)

## 4. First build

Windows:

```bat
7-build-app-windows.bat
```

Linux/WSL (from a path under WSL's own filesystem, not `/mnt/g/...` - see
[install.en.md](install.en.md)):

```bash
chmod +x 7-build-app-linux.sh
./7-build-app-linux.sh
```

This takes roughly 10-20 minutes the first time (Doxygen, coverage collection, and the mkdocs site
all run). At the end you should see:

```text
....................
Operation Completed!
....................
```

and (on Windows) `100% tests passed, 0 tests failed out of 47` earlier in the output (the exact count
grows as you add your own tests).

## 5. Open the site

```bat
9-open-site.bat
```

```bash
./9-open-site.sh
```

This opens `site/index.html` (built by `mkdocs`), which links every report - see
[../reports.md](../reports.md) ("Which report is which?") for what each one is.

## Next step

Continue with [topic-to-project.en.md](topic-to-project.en.md) to turn the sample calculator into
your own project topic.
