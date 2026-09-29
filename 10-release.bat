@echo off
setlocal enabledelayedexpansion
@cd /d "%~dp0"

rem 10-release.bat [vX.Y.Z] [--dry-run]
rem
rem Builds everything locally (same pipeline as 7-build-app-windows.bat: binaries,
rem native+ReportGenerator test/coverage reports, API docs, the mkdocs site),
rem packs the whole site as site.zip, and publishes a GitHub Release with the
rem GitHub CLI (gh). This uses NO GitHub Actions minutes and works on a private
rem repository with the GitHub Free plan (releases are a Free-plan feature; see
rem docs/guide/releases.en.md / releases.tr.md).
rem
rem --dry-run prints the `gh` command and the asset list without creating a
rem release. Use it to check everything is in order first.

set "DRY_RUN=0"
set "VERSION_ARG="

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="--dry-run" (
    set "DRY_RUN=1"
    shift
    goto parse_args
)
if not defined VERSION_ARG (
    set "VERSION_ARG=%~1"
)
shift
goto parse_args
:args_done

echo ::: LOCAL RELEASE BUILD BEGIN :::

echo Check that the working tree is clean (a release should come from committed code)
set "DIRTY=0"
for /f "delims=" %%U in ('git status --porcelain 2^>nul') do (
    set "DIRTY=1"
)
if "%DIRTY%"=="1" (
    echo ERROR: the working tree is not clean ^(git status --porcelain shows changes^).
    echo Commit, stash, or add to .gitignore what you do not want committed, then re-run.
    git status --short
    exit /b 1
)

echo Determine version
set "VERSION=%VERSION_ARG%"
if not defined VERSION (
    if exist VERSION (
        set /p VERSION=<VERSION
    )
)
if not defined VERSION (
    echo ERROR: no version given. Usage: 10-release.bat vX.Y.Z [--dry-run]
    echo Or create a "VERSION" file in the repo root containing e.g. v1.0.0
    exit /b 1
)
echo Version: %VERSION%

echo Check that gh ^(GitHub CLI^) is installed and logged in
where gh >nul 2>&1
if errorlevel 1 (
    echo ERROR: the GitHub CLI ^(gh^) is not installed. Install it: https://cli.github.com/
    echo   choco install gh -y
    exit /b 1
)
call gh auth status >nul 2>&1
if errorlevel 1 (
    echo ERROR: gh is not logged in to GitHub. Run:
    echo   gh auth login
    echo and follow the prompts ^(pick GitHub.com, HTTPS, and log in with a browser^),
    echo then re-run this script. See docs/guide/releases.en.md for details.
    exit /b 1
)

if "%DRY_RUN%"=="0" (
    echo Run the full build + report + site pipeline ^(same as 7-build-app-windows.bat^)
    call "%~dp07-build-app-windows.bat" < nul
    if errorlevel 1 (
        echo ERROR: the build failed; see the output above. Not creating a release.
        exit /b 1
    )
) else (
    echo [DRY RUN] Skipping the actual build to keep the dry run fast. Run without
    echo [DRY RUN] --dry-run to build for real before publishing.
    if not exist release_win mkdir release_win
)

echo Package the site as site.zip
if exist "site" (
    if exist release_win\site.zip del /Q release_win\site.zip
    powershell -NoProfile -Command "Compress-Archive -Path 'site\*' -DestinationPath 'release_win\site.zip' -Force"
    if errorlevel 1 (
        echo ERROR: could not package site.zip.
        exit /b 1
    )
) else (
    echo [DRY RUN] site\ does not exist yet ^(build not run^); site.zip will not be listed.
)

set "ASSET_LIST="
for %%F in ("release_win\*") do (
    set "ASSET_LIST=!ASSET_LIST! "%%F""
)

if not defined ASSET_LIST (
    echo ERROR: no files found in release_win\ to publish. Run the build first.
    exit /b 1
)

echo Write release notes (links the live site AND every report page)
set "NOTES_FILE=%TEMP%\release-notes-%RANDOM%.md"
call "%~dp0detect-python.bat" >nul 2>&1
if not defined PY_CMD set "PY_CMD=py -3"
call %PY_CMD% "%~dp0tools\write_release_notes.py" --version "%VERSION%" --out "%NOTES_FILE%"
if errorlevel 1 (
    echo WARNING: tools\write_release_notes.py failed; falling back to a minimal notes file.
    echo # %VERSION% > "%NOTES_FILE%"
    echo. >> "%NOTES_FILE%"
    echo Built locally with 7-build-app-windows.bat and packaged by 10-release.bat. >> "%NOTES_FILE%"
    echo See docs/reports.md ^(inside site.zip^) for what each report is. >> "%NOTES_FILE%"
)

if "%DRY_RUN%"=="1" (
    echo.
    echo [DRY RUN] Would run:
    echo   gh release create %VERSION%%ASSET_LIST% --title "%VERSION%" --notes-file "%NOTES_FILE%"
    echo [DRY RUN] Assets that would be uploaded:
    dir /B release_win 2>nul
    echo [DRY RUN] No release was created.
    exit /b 0
)

echo Publish the release with gh
call gh release create %VERSION%%ASSET_LIST% --title "%VERSION%" --notes-file "%NOTES_FILE%"
if errorlevel 1 (
    echo ERROR: gh release create failed. See messages above ^(common causes: not a
    echo collaborator with write access, or a release with this tag already exists^).
    exit /b 1
)

echo ::: LOCAL RELEASE BUILD COMPLETED :::
