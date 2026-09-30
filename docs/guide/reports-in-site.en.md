# Showing an HTML report inside your site

Every report the template generates (Doxygen, ReportGenerator, OpenCppCoverage / lcov / gcovr, junit2html) gets its **own
page** in this MkDocs Material site: a title, a one-line explanation, "Open in a new tab" and "Download (zip)" buttons and
the report inside a styled, responsive, full-height, lazy-loading `<iframe>`. See the **Reports** and **API docs** tabs, or
[Unit test results - Windows](../reports/windows/tests-junit2html.md) for one example. This page explains exactly how, so
you can add a report of your own (for example a static-analysis tool for your project topic).

## The iframe rule: only standalone HTML goes into an iframe

| Goes into an `<iframe>` (standalone HTML made **outside** the site generator) | Never framed - link it, opens in a new tab |
| --- | --- |
| ReportGenerator, genhtml (lcov), gcovr, junit2html, OpenCppCoverage, Doxygen, JaCoCo, Javadoc, TRX-HTML | A page that carries **its own site navigation**: a Maven site (Surefire, Checkstyle, PMD, ...), a DocFX site, another MkDocs site |

Why: a report such as `reports/linux/coverage-lcov/index.html` is one self-contained page - framed inside our site it
adds our navigation around it and all is well. A page that already has its own menu, search and header would show *a site
inside the site* (two navigations, a frame inside a frame, broken relative links). Give such a site its own tab and a plain
link with `target="_blank"`.

**Right** - a standalone report, framed:

```html
<div class="report-frame">
<iframe src="../../../raw/linux/coverage-lcov/index.html" title="Code coverage (lcov)" loading="lazy"></iframe>
</div>
```

**Wrong** - a self-navigating site, framed (you get a menu inside a menu):

```html
<iframe src="../../../native/maven-site/index.html"></iframe>
```

**Right** - the same site, linked so it opens as its own site:

```markdown
[:material-open-in-new: Open the Maven site](../../../native/index.html){ .md-button target="_blank" rel="noopener" }
```

(The C++ template has no such site - Doxygen is standalone, so it is framed. The Java and C# templates of this course
build a Maven site / DocFX site and link them this way.)

## The pieces

1. **The report itself** is written by the build script to `reports/<platform>/<kind>-<tool>/` (for example
   `reports/windows/coverage-reportgenerator/index.html`).
2. **`tools/build_site.py`** (run by `7-build-all-*`) builds the MkDocs site into `site/`, then copies every report folder
   into the site as `site/raw/<platform>/<kind>-<tool>/` and writes `site/downloads/<platform>-<kind>-<tool>.zip`. (Raw
   HTML lives under `raw/` on purpose: MkDocs owns `reports/<platform>/<kind>-<tool>/index.html` for the *page*.)
3. **One small `.md` page per report** under `docs/reports/<platform>/<kind>-<tool>.md`. The page is
   `site/reports/<platform>/<kind>-<tool>/index.html`, three levels below the site root, so the relative paths start with
   `../../../`:

   ```markdown
   # Code coverage (lcov genhtml) - Linux

   The same coverage data as lcov's own native HTML report ...

   <div class="report-actions" markdown>
   [:material-open-in-new: Open in a new tab](../../../raw/linux/coverage-lcov/index.html){ .md-button target="_blank" rel="noopener" }
   [:material-download: Download (zip)](../../../downloads/linux-coverage-lcov.zip){ .md-button .md-button--primary }
   </div>

   <div class="report-frame" data-platform="Linux">
   <iframe src="../../../raw/linux/coverage-lcov/index.html" title="Code coverage (lcov) - Linux" loading="lazy"></iframe>
   </div>
   ```

   The paths work unchanged on GitHub Pages (`https://<user>.github.io/<repo>/...`, a sub-path) and on
   `http://localhost:8000/` because they are relative. `.report-actions` and `.report-frame` are styled in
   `docs/css/extra.css`; `docs/js/extra.js` shows a short note instead of an empty frame when a report is not part of the build
   (for example the Linux reports on a Windows-only machine).
4. **A nav entry** in `mkdocs.yml`, under `Reports -> Windows` or `Reports -> Linux`.

## Adding a new report page, step by step

1. Make your tool write its HTML to `reports/<platform>/<kind>-<tool>/` (add it to `7-build-all-windows.bat` / `.sh` next
   to the existing reports; the folder needs an `index.html`).
2. Add an `Entry(...)` to `tools/report_catalog.py` (platform, kind, tool, title, one-line description, asset name).
   The catalogue drives the page generator, the site copy, the download zip and the release asset name
   `<project>-<version>-<platform>-<asset>.zip`.
3. Run `python3 tools/gen_report_pages.py` - it (re)writes `docs/reports/<platform>/<kind>-<tool>.md` for every entry.
4. Add the page under `Reports` in `mkdocs.yml`'s `nav`.
5. Rebuild (`7-build-all-*`), then `9-open-site-*` and test - see below.

## Testing it locally

A framed page needs a real web server: browsers refuse to load an `<iframe>` whose `src` is a `file://` path. `9-open-site-*`
starts `python -m http.server` on the `site/` folder, prints `http://localhost:8000/` and opens the browser:

```bat
9-open-site-windows.bat
```

```bash
./9-open-site-linux.sh
```

Open the new page from the **Reports** tab and check: the frame loads, "Open in a new tab" opens the same report alone,
"Download (zip)" gives a non-empty archive. `Ctrl+C` (Linux) or closing the server window (Windows) stops the server.
`python3 tools/check_site_links.py site` re-runs the link check (it walks the rendered HTML and fails on any broken link
in our own pages; broken links inside the standalone reports are listed but never fail).

## Common problems

| Symptom | Cause | Fix |
| --- | --- | --- |
| The frame is blank, but the report opens fine on its own | Wrong relative path (the page is three levels below the site root: `../../../raw/...`), or you double-clicked `site/index.html` (`file://`) | Recount the `../`, and always test through `9-open-site-*` |
| The frame shows "This report is not part of this build of the site" | That platform's report was not built on this machine (you ran only the other platform's `7-build-all-*`) | Build on that platform; CI builds both |
| "Download (zip)" gives 404 | The report folder is missing or has no entry page, so `build_site.py` skipped it | Look at the "not built here" lines of `build_site.py`'s output; fix the report step |
| The report folder was not copied into the site (Pages deploy) | The report was not in the artifact the merge job downloaded | Check `.github/workflows/pages.yml`: the platform jobs must upload `reports/<platform>` |
| `mkdocs build` warns that a nav file is missing | Typo in the nav path, or the page was not generated | Compare with the file under `docs/reports/`; run `tools/gen_report_pages.py` |
| Browser console: `Refused to display ... in a frame because it set 'X-Frame-Options'` | You pointed the `src` at another website | Only frame reports served from this same site; link to (do not frame) external sites |
| Two menus in the frame | You framed a self-navigating site (Maven/DocFX/MkDocs) | Link it in a new tab instead - the iframe rule above |
