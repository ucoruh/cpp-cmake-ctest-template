# Unit Test Results (native) (Windows)

The native unit-test results report: pass/fail per test case, straight from CTest's own JUnit XML output (CTest --output-junit, converted by junit2html). No coverage information, just pass/fail and timing.

<div class="report-actions" markdown>
[:material-open-in-new: Open in a new tab](../../testresultswin/index.html){ .md-button target="_blank" rel="noopener" }
[:material-download: Download (zip)](../../test-results-win.zip){ .md-button .md-button--primary }
</div>

<div class="report-frame">
<iframe src="../../testresultswin/index.html" title="Unit Test Results (native) (Windows)" loading="lazy"></iframe>
</div>

!!! note "Report not showing?"
    This page embeds the report with an `<iframe>`. If you opened the site straight from a `file://`
    path, some browsers block iframes there - serve the site locally instead
    (`9-open-site.bat` / `9-open-site.sh`, which starts a tiny local HTTP server and prints the URL to
    open), or use the "Open in a new tab" button above. If the report was never built on this platform
    yet (e.g. you only ran the Windows build script), the frame and the download button will 404 until
    you run the matching build script - see
    [Showing an HTML report inside your site](../guide/reports-in-site.en.md).
