# Documentation coverage (lcov genhtml) - Linux

The same documentation-coverage data as a native lcov `genhtml` HTML report. Tabs: the libraries, and the test sources themselves.

<div class="report-actions" markdown>
[:material-open-in-new: Open in a new tab](../../../raw/linux/doccoverage-lcov/lib/index.html){ .md-button target="_blank" rel="noopener" }
[:material-download: Download (zip)](../../../downloads/linux-doccoverage-lcov.zip){ .md-button .md-button--primary }
</div>

=== "Libraries"

    <div class="report-frame" data-platform="Linux">
    <iframe src="../../../raw/linux/doccoverage-lcov/lib/index.html" title="Documentation coverage (lcov genhtml) - Linux - Libraries" loading="lazy"></iframe>
    </div>
    
    [:material-open-in-new: Open "Libraries" in a new tab](../../../raw/linux/doccoverage-lcov/lib/index.html){ target="_blank" rel="noopener" }

=== "Tests"

    <div class="report-frame" data-platform="Linux">
    <iframe src="../../../raw/linux/doccoverage-lcov/tests/index.html" title="Documentation coverage (lcov genhtml) - Linux - Tests" loading="lazy"></iframe>
    </div>
    
    [:material-open-in-new: Open "Tests" in a new tab](../../../raw/linux/doccoverage-lcov/tests/index.html){ target="_blank" rel="noopener" }

!!! note "Report not showing?"
    This page embeds a standalone HTML report (made by an external tool, outside MkDocs) in an
    `<iframe>`. Use the "Open in a new tab" button if the frame stays empty. Browsers block iframes
    of `file://` pages, so open the site with `9-open-site-windows.bat` / `9-open-site-linux.sh`
    (a tiny local web server). If this platform's report was not built on your machine
    (you ran only the other platform's `7-build-all-*` script), the frame stays empty - CI builds both.
    The same archive is attached to every release as `calculator-1.1.1-linux-report-doccoverage-lcov.zip`.
    See [Showing an HTML report inside your site](../../guide/reports-in-site.md).
