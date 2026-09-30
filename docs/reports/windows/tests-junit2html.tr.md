# Birim test sonuçları (JUnit HTML) - Windows

Her test durumu için geçti/kaldı ve süre; doğrudan CTest'in kendi JUnit XML çıktısından (`ctest --output-junit`) junit2html ile üretilir. Kapsama bilgisi yok - yalnızca her testin geçip geçmediği.

<div class="report-actions" markdown>
[:material-open-in-new: Yeni sekmede aç](../../../../raw/windows/tests-junit2html/index.html){ .md-button target="_blank" rel="noopener" }
[:material-download: İndir (zip)](../../../../downloads/windows-tests-junit2html.zip){ .md-button .md-button--primary }
</div>

<div class="report-frame" data-platform="Windows">
<iframe src="../../../../raw/windows/tests-junit2html/index.html" title="Birim test sonuçları (JUnit HTML) - Windows" loading="lazy"></iframe>
</div>

!!! note "Rapor görünmüyor mu?"
    Bu sayfa, harici bir araçla (MkDocs dışında) üretilmiş bağımsız bir HTML raporunu bir
    `<iframe>` içinde gösterir. Çerçeve boş kalırsa "Yeni sekmede aç" düğmesini kullanın. Tarayıcılar
    `file://` sayfalarındaki iframe'leri engeller; bu yüzden siteyi `9-open-site-windows.bat` /
    `9-open-site-linux.sh` ile açın (küçük bir yerel web sunucusu). Bu platformun raporu makinenizde
    üretilmediyse (yalnızca diğer platformun `7-build-all-*` betiğini çalıştırdınız) çerçeve boş kalır - CI ikisini de derler.
    Aynı arşiv her sürüme `calculator-1.1.0-windows-report-tests.zip` adıyla eklenir.
    Bkz. [Siteye HTML raporu gömme](../../guide/reports-in-site.md).
