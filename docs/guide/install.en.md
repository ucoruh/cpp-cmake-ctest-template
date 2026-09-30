# Install everything (Windows and Linux/WSL)

This page installs every tool the template's scripts use and shows how to check each one works, with the output
you should see. Run the checks after each step - do not wait until the end to discover something is missing.

The installers are two numbered scripts (same number = same job, platform as suffix):

| Step | Windows | Linux / WSL |
| --- | --- | --- |
| 3. package manager | `3-install-package-manager-windows.bat` (Chocolatey, Scoop) | - (apt is already there) |
| 4. every tool | `4-install-tools-windows.bat` (run as **Administrator**) | `./4-install-tools-linux.sh` (asks for `sudo`) |

> **Old names.** `4-install-windows-enviroment.bat` is now `4-install-tools-windows.bat`,
> `4-install-wsl-environment.sh` is `4-install-tools-linux.sh`, and `6_download_plantuml.bat` was folded into both
> (PlantUML is downloaded as the last step). The full old-to-new table is in the
> [README](https://github.com/ucoruh/cpp-cmake-ctest-template#old-name---new-name).

## Windows

### 1. Visual Studio 2022 Community (or Ninja + MinGW-w64 GCC)

You need a C/C++ compiler. Either works; the build scripts auto-detect which one you have
(`scripts\detect-generator-windows.bat`: Visual Studio if `vswhere.exe` finds it, otherwise Ninja + `gcc`/`g++`).

- Visual Studio 2022 Community (free): <https://visualstudio.microsoft.com/vs/community/> - in the installer tick
  the **"Desktop development with C++"** workload.
- Or MinGW-w64 GCC + Ninja via Chocolatey (step 3 installs Ninja and CMake either way).

Verify:

```bat
"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
```

Expected output (path will vary): `C:\Program Files\Microsoft Visual Studio\2022\Community`. If nothing is printed,
Visual Studio is not installed; that is fine as long as `gcc`/`g++` and `ninja` are on PATH.

### 2. Chocolatey and Scoop (package managers)

Run `3-install-package-manager-windows.bat`. Verify:

```bat
choco --version
```

Expected output: a version number, e.g. `2.5.0`.

### 3. Everything else

Open an **Administrator** terminal in the repository folder and run `4-install-tools-windows.bat`. It installs (and
upgrades in place, so it is safe to re-run): CMake, Ninja, Doxygen, Graphviz, AStyle, OpenCppCoverage, lcov
(`genhtml`), Strawberry Perl, the GitHub CLI (`gh`), Python 3 (if missing), the .NET SDK (if missing), the
ReportGenerator global tool, the Python packages from `requirements.txt` (mkdocs-material, coverxygen, junit2html)
and PlantUML (optional).

Verify each tool:

```bat
cmake --version
ninja --version
doxygen --version
reportgenerator --version
py -3 -m pip show coverxygen
py -3 -m mkdocs --version
gh --version
```

Expected output (versions change over time; each command must print something, not an error):

```text
cmake version 3.31.2
1.12.1
1.9.7
Arguments: ...
Name: coverxygen
Version: 1.8.2
mkdocs, version 1.6.1 from ...
gh version 2.x.x
```

**Important - `python` vs `py -3`:** on many machines the plain `python` command resolves to a *different* Python
than the one that has this project's tools installed (one author's `python` was a Python 2.7 bundled with an unrelated
graphics program, without `coverxygen`). The build scripts handle this: `scripts\detect-python-windows.bat` probes
`py -3`, then `python3`, then `python` for one that can import `coverxygen` and `mkdocs`, and tells you exactly what
to run if none can. If you run `python -m coverxygen` yourself and get `No module named coverxygen`, use
`py -3 -m coverxygen ...`, or check where `pip` installed it: `py -3 -m pip show coverxygen`.

### 4. genhtml needs a Windows-native Perl

`genhtml` (from lcov) is a Perl script with no file extension; `4-install-tools-windows.bat` installs it together with
Strawberry Perl. Git for Windows and MSYS2 also put a `perl` on PATH, but that one mishandles native Windows paths;
`scripts\detect-genhtml-windows.bat` skips any perl under `\usr\bin\` and uses the Windows-native one. If no suitable
Perl is found the native lcov reports are skipped with a clear message instead of failing the build.

```bat
where genhtml
where perl
```

### 5. PlantUML (optional)

Doxygen diagrams that use PlantUML are optional; `4-install-tools-windows.bat` downloads `plantuml.jar` into the
repository root (gitignored). If the download fails the script says so and continues - Doxygen simply skips those diagrams.

## Linux / WSL

Install WSL first if you have not: `wsl --install` from an elevated PowerShell, then reboot. Open the Ubuntu terminal and
run (from a folder on WSL's own filesystem, see below):

```bash
chmod +x *.sh scripts/*.sh
./4-install-tools-linux.sh
```

It installs via `apt`: build-essential, cmake, ninja-build, doxygen, graphviz, lcov, astyle, curl, zip, python3, pip;
via the official `dotnet-install.sh`: a **per-user, current .NET SDK in `~/.dotnet`** (many distros - the template was
tested on WSL Ubuntu 20.04 - only package .NET 3.1, too old for the current ReportGenerator); then ReportGenerator, the
Python packages from `requirements.txt` (mkdocs-material, coverxygen, junit2html, gcovr), `gh` (if apt has it) and
PlantUML. It adds `~/.dotnet`, `~/.dotnet/tools` and `~/.local/bin` to `PATH` in `~/.bashrc`; open a new terminal (or
`source ~/.bashrc`) afterwards. The build scripts also put these on PATH themselves (`scripts/setup-path-linux.sh`).

Verify:

```bash
cmake --version
doxygen --version
ninja --version
gcc --version
dotnet --version
reportgenerator --version
python3 -c "import coverxygen, mkdocs; print('python tools OK')"
```

Expected: real version numbers, no "command not found"; `dotnet --version` prints something like `10.0.x` (not `3.1.x` - if
you see `3.1.x`, open a new terminal, or run `export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$PATH"`).

### GCC and gcov must match

A distro can have several GCC versions side by side (a WSL test machine had gcc-7, gcc-9 *and* gcc-13, with the
unversioned `gcc` being 9.4.0 but `/usr/bin/gcov` pointing at gcov-**7**.5.0 through `update-alternatives`). If GCC and
`gcov` differ, coverage silently produces no data (`geninfo: WARNING: GCOV did not produce any data`, then
`lcov: ERROR: no valid records found in tracefile`). `scripts/detect-compiler-linux.sh` (used by `6-build-and-test-linux.sh`
and `7-build-all-linux.sh`) picks the newest GCC that has a same-version `gcov` and prints which pair it chose.

### WSL cannot see a Google Drive path

If your clone lives under a Google Drive path (`G:\My Drive\...`), WSL cannot reach it:

```text
wsl: Failed to translate 'G:\My Drive\...'
```

Copy the repository to WSL's own filesystem (or any local `C:\` path) and run the `.sh` scripts from there:

```bash
mkdir -p ~/work && cp -r "/mnt/c/path/to/your-repo" ~/work/
cd ~/work/your-repo
./7-build-all-linux.sh
```

## Next step

Continue with [Use the template](use-template.en.md).
