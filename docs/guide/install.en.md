# Install everything (Windows and Linux/WSL)

This page installs every tool the template's scripts use, and shows you how to check each one
actually works, with the output you should see. Run the checks after each step - do not wait until
the end to discover something is missing.

## Windows

### 1. Visual Studio 2022 Community (or Ninja + MinGW-w64 GCC)

You need a C/C++ compiler. Either works; the build scripts auto-detect which one you have
(`detect-generator.bat`: Visual Studio if `vswhere.exe` finds it, otherwise Ninja + `gcc`/`g++`).

- Visual Studio 2022 Community (free): <https://visualstudio.microsoft.com/vs/community/> - in the
  installer, tick the **"Desktop development with C++"** workload.
- Or MinGW-w64 GCC + Ninja via Chocolatey (step 4 below installs Ninja and CMake for you either way).

Verify:

```bat
"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
```

Expected output (path will vary): `C:\Program Files\Microsoft Visual Studio\2022\Community`

If that prints nothing, Visual Studio is not installed; that is fine as long as `gcc`/`g++` and
`ninja` are on PATH (see step 4).

### 2. Chocolatey and Scoop (package managers)

Run `3-install-package-manager.bat`. It installs [Chocolatey](https://chocolatey.org/) (and Scoop) if
not already present.

Verify:

```bat
choco --version
```

Expected output: a version number, e.g. `2.3.0`.

### 3. Everything else

Run `4-install-windows-enviroment.bat` (as Administrator, since it uses `choco install`). It installs:
CMake, Ninja, Doxygen, the `dotnet-reportgenerator-globaltool`, OpenCppCoverage, `coverxygen` (a
Python package), lcov (for `genhtml`), Pandoc, Graphviz, Python, MikTeX, curl, MARP-CLI, and the
mkdocs Python packages.

Verify each tool:

```bat
cmake --version
ninja --version
doxygen --version
reportgenerator --version
py -3 -m pip show coverxygen
```

Expected output (versions will differ over time, but each command should print something, not an
error):

```text
cmake version 3.31.2
1.12.1
1.9.7
2026-09-29T22:36:30: Arguments
...
Name: coverxygen
Version: 1.8.2
```

**Important - `python` vs `py -3`:** on many machines, the plain `python` command on PATH resolves to
a *different* Python than the one that has this project's tools installed (this template's own
author hit this: `python` resolved to a Python 2.7 bundled with an unrelated graphics application,
with no `coverxygen`). The build scripts already handle this for you
(`detect-python.bat` probes `py -3`, then `python3`, then `python` for one that actually has
`coverxygen` importable, and tells you exactly what to run if none do). If you ever run
`python -m coverxygen` yourself and get `No module named coverxygen`, use `py -3 -m coverxygen ...`
instead, or check which Python your `pip install` actually went to:

```bat
py -3 -m pip show coverxygen
```

### 4. genhtml needs Perl

`genhtml` (from lcov) is a Perl script with no file extension; `choco install lcov -y` installs it,
but `strawberryperl` (or any Perl) must also be on PATH to run it - the build scripts detect this
with `detect-genhtml.bat` and skip that one native report with a clear message if Perl is missing,
rather than failing the whole build.

```bat
where genhtml
where perl
```

### 5. PlantUML (optional)

Doxygen diagrams that use PlantUML are optional and are skipped automatically if
`6_download_plantuml.bat` has not been run (no error - see
`docs/guide/troubleshooting.en.md`). Run it once if you want those diagrams:

```bat
6_download_plantuml.bat
```

## Linux / WSL

Install WSL first if you have not already: `wsl --install` from an elevated PowerShell, then reboot.
Open the Ubuntu terminal and run:

```bash
chmod +x 4-install-wsl-environment.sh
./4-install-wsl-environment.sh
```

This installs (via `apt`): astyle, ninja-build, cmake, doxygen, pandoc, `librsvg2-bin`, python3,
curl, graphviz, lcov; via `pip`: mkdocs and its plugins, `coverxygen`, `junit2html`; and - **new** -
a per-user, current .NET SDK via the official `dotnet-install.sh` script into `~/.dotnet`, because
many distros (this template was tested against WSL Ubuntu 20.04) only package a very old .NET (3.1)
that cannot run the current `dotnet-reportgenerator-globaltool` (it needs .NET 10). The script adds
`~/.dotnet` and `~/.dotnet/tools` to `PATH` in `~/.bashrc` automatically; open a new terminal (or
`source ~/.bashrc`) afterwards.

Verify:

```bash
cmake --version
doxygen --version
ninja --version
gcc --version
dotnet --version
reportgenerator --version
python3 -c "import coverxygen; print('coverxygen OK')"
```

Expected output should include real version numbers with no "command not found" and, for
`dotnet --version`, something like `10.0.401` (not `3.1.x` - if you see `3.1.x`, open a new terminal
so the PATH change from the install script takes effect, or run
`export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$PATH"` yourself).

### GCC and gcov must match

A distro can have several GCC versions installed side by side (this template's WSL test machine had
gcc-7, gcc-9 *and* gcc-13, with the default unversioned `gcc` pointing at 9.4.0 but `/usr/bin/gcov`
pointing at gcov-**7**.5.0 via `update-alternatives`). If GCC and `gcov` are different versions, code
coverage silently produces no data (`geninfo: WARNING: GCOV did not produce any data`, then
`lcov: ERROR: no valid records found in tracefile`). `7-build-app-linux.sh` already picks a matching
GCC/`gcov` pair for you (preferring the newest available, `gcc-13`/`gcov-13` on that test machine) and
prints which one it picked; if you ever run `gcov` by hand, check the versions agree first:

```bash
gcc --version | head -1
gcov --version | head -1
```

### WSL cannot see a Google Drive path

If your clone lives under a Windows path synced by Google Drive (e.g.
`G:\My Drive\...\cpp-cmake-ctest-template`), WSL cannot reach it at all:

```text
wsl: Failed to translate 'G:\My Drive\...'
```

Copy the repository to a path under WSL's own filesystem first (or any local `C:\` path), and run the
`.sh` scripts from there:

```bash
mkdir -p ~/work && cp -r "/mnt/c/path/to/cpp-cmake-ctest-template" ~/work/
cd ~/work/cpp-cmake-ctest-template
./7-build-app-linux.sh
```

## Next step

Continue with [use-template.en.md](use-template.en.md) to turn this template into your own project.
