# Showing an HTML report inside your site

Every report this template generates (Doxygen, ReportGenerator, OpenCppCoverage/lcov/gcovr,
junit2html) gets its **own page** in the MkDocs Material site, showing the report inside a styled,
responsive `<iframe>` with "Open in a new tab" and "Download (zip)" buttons above it - see the
**Reports** tab on the site, or [reports/test-results-win.md](../reports/test-results-win.md) for one
example rendered. This page explains exactly how that works, so you can add a report of your own
(e.g. a static-analysis tool you add for your project topic) the same way.

## The three pieces

1. **The report itself** lands somewhere under `docs/<some-folder>/` (e.g.
   `docs/testresultswin/index.html`) - every build script already does this for the reports built in.
   MkDocs copies **every** file under `docs_dir` (not just `.md` files) into `site/` as-is, so once a
   report folder exists under `docs/`, it is already reachable at that same relative URL in the site -
   no extra step needed for that part.
2. **One small `.md` page per report** under `docs/reports/`, e.g. `docs/reports/test-results-win.md`:

   ```markdown
   # Unit Test Results (native) (Windows)

   The native unit-test results report: pass/fail per test case, straight from CTest's own JUnit XML
   output (CTest --output-junit, converted by junit2html). No coverage information, just pass/fail and
   timing.

   <div class="report-actions" markdown>
   [:material-open-in-new: Open in a new tab](../../testresultswin/index.html){ .md-button target="_blank" rel="noopener" }
   [:material-download: Download (zip)](../../test-results-win.zip){ .md-button .md-button--primary }
   </div>

   <div class="report-frame">
   <iframe src="../../testresultswin/index.html" title="Unit Test Results (native) (Windows)" loading="lazy"></iframe>
   </div>
   ```

   The `../../` prefix is important: `docs/reports/<id>.md` is built to `site/reports/<id>/index.html`
   (MkDocs' "directory URLs"), which is **two** levels below the site root, and every report folder
   lives directly under the site root - so every report page uses the same `../../<folder>/index.html`
   pattern, regardless of which report it is. If you put your new page anywhere other than directly
   inside `docs/reports/`, recompute this - that is the #1 cause of a report page that shows a blank
   frame in the built site but worked when you opened the report file directly.

   `.report-actions` / `.report-frame` are styled in `docs/css/extra.css` (a responsive, themed
   iframe box plus two `.md-button`s); `.md-button`/`.md-button--primary` are built into
   mkdocs-material via the `attr_list` markdown extension (already enabled in `mkdocs.yml`).

3. **A `mkdocs.yml` nav entry**, under `Reports > Windows` or `Reports > Linux`:

   ```yaml
       - Reports:
           - Windows:
               - 'Unit Test Results (native)': 'reports/test-results-win.md'
   ```

## Adding a new report page, step by step

1. Make sure your tool writes its HTML report somewhere under `docs/`, e.g.
   `docs/mytoolwin/index.html` (add the folder creation + tool invocation to
   `7-build-app-windows.bat`/`.sh`, the same way the existing reports do it).
2. Add one line to the `REPORTS` list in `tools/zip_reports.py` (id, title, platform, one-line
   description, the folder to zip, and the report's own `index.html` path) - this makes the build
   scripts zip it automatically for the "Download (zip)" button.
3. Copy an existing page under `docs/reports/` (e.g. `test-results-win.md`) to
   `docs/reports/mytool-win.md` and edit the title/description/paths to match.
4. Add a line for it under `mkdocs.yml`'s `nav: Reports:` section.
5. Rebuild (`7-build-app-windows.bat` or `.sh`) and test locally - see below.

## Testing it locally

Reports need a real HTTP server, not a `file://` path - many browsers refuse to load an `<iframe>`
whose `src` is a local file for security reasons (this is the browser's own same-origin/`file://`
restriction, not something this template's iframe/CSS can work around). `9-open-site.bat` / `.sh`
already do this for you:

```bat
9-open-site.bat
```

```bash
./9-open-site.sh
```

Both start `python -m http.server` (or `py -3 -m http.server`) rooted at `site/`, print the URL
(typically `http://localhost:8000/`), and open it in your default browser. Open the new report page
from the **Reports** tab and confirm the frame loads, "Open in a new tab" opens the same report
directly, and "Download (zip)" downloads a non-empty archive. Press `Ctrl+C` in that terminal to stop
the server.

## Common problems

| Symptom | Cause | Fix |
| --- | --- | --- |
| The report page's `<iframe>` is blank/shows an error, but the report file itself opens fine when you browse to it directly | Wrong relative path (see the "two levels up" rule above), or you tested by double-clicking `site/index.html` (`file://`) instead of using `9-open-site.bat`/`.sh` | Recount the `../../` levels from `docs/reports/<id>.md`, and always test through the local HTTP server. |
| The report page 404s / the frame shows the browser's own "file not found" page | The report was never generated on this platform in this build (e.g. you only ran `7-build-app-windows.bat`, so no `docs/*linux*` folders exist yet) | Run the matching build script for that platform, or check the **Reports** tab entry is under the right platform group. |
| "Download (zip)" 404s even though the report page/iframe works | `tools/zip_reports.py` was not run after the report was generated, or your new entry's `zip_source` folder name has a typo | Re-run the full build script (it calls `zip_reports.py` right before `mkdocs build`), or run `py -3 tools/zip_reports.py` by hand and check its printed folder-by-folder output. |
| `mkdocs build` prints `WARNING - A reference to '....md' is included in the 'nav' configuration, which is not found` for one of your new `docs/reports/*.md` entries | Typo in the `mkdocs.yml` nav path, or the `.md` file was not saved/is in the wrong folder | Compare the nav path character-for-character against the actual file path under `docs/reports/`. |
| The site is live on GitHub Pages but a report iframe is blank there specifically (works locally) | The report folder was not included in the artifact that the Pages workflow deployed (e.g. it only ran on one OS's job and the merge step did not copy it) | Check `.github/workflows/pages.yml` - the "merge Windows + Linux reports" step must copy every `docs/<folder>` your report needs into the final `docs/` before `mkdocs build`. |
| An external site would refuse to be shown in your iframe (`X-Frame-Options: DENY` / `Content-Security-Policy: frame-ancestors 'none'` in the browser console) | Not applicable to this template's own reports (they are static files on the same site, so no framing restriction applies) - this only bites if you point a report page's `src` at a *different* website. | Only embed reports that are copied into `docs/` and served from this same site; link to (do not iframe) anything external. |
