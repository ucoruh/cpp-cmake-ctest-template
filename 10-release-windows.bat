@echo off
@setlocal enableextensions enabledelayedexpansion
@cd /d "%~dp0"

rem 10-release-windows.bat [--dry-run]
rem
rem Publishes a GitHub Release from the local release\ folder with the GitHub CLI (gh):
rem   * the version comes from project.env (VERSION=1.1.0 -> tag v1.1.0); change it there
rem   * refuses a dirty working tree and a commit that is not pushed yet
rem   * builds everything first (7-build-all-windows.bat) unless --dry-run
rem   * uploads EVERY file of release\ - the GitHub asset list is the local folder, one to one
rem Uses no GitHub Actions minutes and works on a PRIVATE repository with the Free plan.
rem --dry-run prints the gh command and the asset list and creates nothing (no gh login needed).
rem See docs\guide\releases.en.md and docs\guide\showcase-without-pages.en.md.

set "DRY_RUN=0"
if /I "%~1"=="--dry-run" set "DRY_RUN=1"

call "%~dp0scripts\load-project-env-windows.bat"
if errorlevel 1 exit /b 1
set "TAG=v%VERSION%"
echo === Release %PROJECT_NAME% %TAG%

if "%DRY_RUN%"=="0" (
    call :checkgit
    if errorlevel 1 exit /b 1
    call :checkgh
    if errorlevel 1 exit /b 1
    echo Running the full build - reports - site - release\ pipeline ^(7-build-all-windows.bat^)
    set "NO_PAUSE=1"
    call "%~dp07-build-all-windows.bat"
    if errorlevel 1 (
        echo ERROR: the build failed - not creating a release.
        exit /b 1
    )
) else (
    echo [DRY RUN] not building; using the existing release\ folder ^(run 7-build-all-windows.bat first^)
    where gh >nul 2>&1 || echo [DRY RUN] note: gh is not installed - fine for a dry run, needed for a real release ^(choco install gh -y^)
)

if not exist "release\*" (
    echo ERROR: release\ is empty - run 7-build-all-windows.bat first.
    exit /b 1
)

set "ASSETS="
set "ASSET_COUNT=0"
for %%F in ("release\*") do (
    set ASSETS=!ASSETS! "%%F"
    set /a ASSET_COUNT+=1
)

set "NOTES=%TEMP%\release-notes-%PROJECT_NAME%-%VERSION%.md"
call "%~dp0scripts\detect-python-windows.bat" >nul 2>&1
if not defined PY_CMD set "PY_CMD=py -3"
call %PY_CMD% tools\release_assets.py notes --out "%NOTES%"
if errorlevel 1 (
    echo ERROR: could not write the release notes.
    exit /b 1
)

for /f %%S in ('git rev-parse HEAD') do set "SHA=%%S"
if "%DRY_RUN%"=="1" (
    echo.
    echo [DRY RUN] Would run:
    echo   gh release create %TAG% release\* ^(!ASSET_COUNT! files^) --target %SHA% --title "%PROJECT_NAME% %TAG%" --notes-file "%NOTES%"
    echo [DRY RUN] Assets that would be uploaded:
    dir /B release
    echo [DRY RUN] No release was created.
    exit /b 0
)

echo Publishing with gh...
call gh release create %TAG% %ASSETS% --target %SHA% --title "%PROJECT_NAME% %TAG%" --notes-file "%NOTES%"
if errorlevel 1 (
    echo ERROR: gh release create failed ^(a release for %TAG% may already exist, or you have no write access^).
    exit /b 1
)
echo Release published: %REPO_URL%/releases/tag/%TAG%
exit /b 0

:checkgit
set "DIRTY="
for /f "delims=" %%U in ('git status --porcelain 2^>nul') do set "DIRTY=1"
if defined DIRTY (
    echo ERROR: the working tree is not clean - commit or stash first ^(a release comes from committed code^):
    git status --short
    exit /b 1
)
set "CONTAINED="
for /f "delims=" %%B in ('git branch -r --contains HEAD 2^>nul') do set "CONTAINED=1"
if not defined CONTAINED (
    echo ERROR: the current commit is not pushed yet - run: git push
    exit /b 1
)
exit /b 0

:checkgh
where gh >nul 2>&1
if errorlevel 1 (
    echo ERROR: the GitHub CLI ^(gh^) is not installed: choco install gh -y   ^(https://cli.github.com/^)
    exit /b 1
)
call gh auth status >nul 2>&1
if errorlevel 1 (
    echo ERROR: gh is not logged in. Run:  gh auth login
    echo        ^(GitHub.com, HTTPS, log in with the browser^) and re-run this script.
    exit /b 1
)
exit /b 0
