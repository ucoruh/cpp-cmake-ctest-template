# Code Coverage (native: lcov genhtml + gcovr) (Linux)

The same code-coverage data, as lcov's own genhtml HTML report, with gcovr's independent HTML report alongside it (coveragenativeliblinux/gcovr) when gcovr is installed. Compare all three - they should agree.

<div class="report-actions" markdown>
[:material-open-in-new: Open in a new tab](../../coveragenativeliblinux/index.html){ .md-button target="_blank" rel="noopener" }
[:material-download: Download (zip)](../../coverage-native-linux.zip){ .md-button .md-button--primary }
</div>

<div class="report-frame">
<iframe src="../../coveragenativeliblinux/index.html" title="Code Coverage (native: lcov genhtml + gcovr) (Linux)" loading="lazy"></iframe>
</div>

!!! note "Report not showing?"
    This page embeds the report with an `<iframe>`. If you opened the site straight from a `file://`
    path, some browsers block iframes there - serve the site locally instead
    (`9-open-site.bat` / `9-open-site.sh`, which starts a tiny local HTTP server and prints the URL to
    open), or use the "Open in a new tab" button above. If the report was never built on this platform
    yet (e.g. you only ran the Windows build script), the frame and the download button will 404 until
    you run the matching build script - see
    [Showing an HTML report inside your site](../guide/reports-in-site.en.md).
