# Code coverage (lcov genhtml) - Linux

The same coverage data as lcov's own native HTML report (`genhtml`, with branch coverage). Compare its numbers with the ReportGenerator report: they should agree.

<div class="report-actions" markdown>
[:material-open-in-new: Open in a new tab](../../../raw/linux/coverage-lcov/index.html){ .md-button target="_blank" rel="noopener" }
[:material-download: Download (zip)](../../../downloads/linux-coverage-lcov.zip){ .md-button .md-button--primary }
</div>

<div class="report-frame" data-platform="Linux">
<iframe src="../../../raw/linux/coverage-lcov/index.html" title="Code coverage (lcov genhtml) - Linux" loading="lazy"></iframe>
</div>

!!! note "Report not showing?"
    This page embeds a standalone HTML report (made by an external tool, outside MkDocs) in an
    `<iframe>`. Use the "Open in a new tab" button if the frame stays empty. Browsers block iframes
    of `file://` pages, so open the site with `9-open-site-windows.bat` / `9-open-site-linux.sh`
    (a tiny local web server). If this platform's report was not built on your machine
    (you ran only the other platform's `7-build-all-*` script), the frame stays empty - CI builds both.
    The same archive is attached to every release as `calculator-1.1.1-linux-report-coverage-lcov.zip`.
    See [Showing an HTML report inside your site](../../guide/reports-in-site.md).
