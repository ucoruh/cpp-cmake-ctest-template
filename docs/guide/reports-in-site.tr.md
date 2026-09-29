# Bir HTML raporunu sitenizin içinde gösterme

Bu şablonun ürettiği her rapor (Doxygen, ReportGenerator, OpenCppCoverage/lcov/gcovr, junit2html)
MkDocs Material sitesinde kendi sayfasına sahiptir; rapor, üstünde "Yeni sekmede aç" ve "İndir (zip)"
düğmeleri bulunan, biçimlendirilmiş ve duyarlı (responsive) bir `<iframe>` içinde gösterilir - sitenin
**Reports** sekmesine bakın, ya da tek bir örnek için
[reports/test-results-win.md](../reports/test-results-win.md) sayfasını görüntüleyin. Bu sayfa bunun
tam olarak nasıl çalıştığını anlatır; böylece kendi eklediğiniz bir raporu (örneğin proje konunuz için
eklediğiniz bir statik analiz aracını) aynı şekilde ekleyebilirsiniz.

## Üç parça

1. **Raporun kendisi** `docs/<bir-klasor>/` altına yazılır (örn. `docs/testresultswin/index.html`) -
   şablona dahil her rapor için bunu zaten yapı (build) betikleri yapar. MkDocs, `docs_dir` altındaki
   her dosyayı (yalnızca `.md` değil) olduğu gibi `site/` içine kopyalar; yani bir rapor klasörü
   `docs/` altında bir kez oluştuktan sonra, sitede aynı göreli (relative) URL'de zaten erişilebilirdir
   - bunun için ekstra bir adım gerekmez.
2. **Her rapor için `docs/reports/` altında küçük bir `.md` sayfası**, örn.
   `docs/reports/test-results-win.md`:

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

   `../../` öneki önemlidir: `docs/reports/<id>.md`, MkDocs'un "dizin URL'leri" (directory URLs)
   özelliğiyle `site/reports/<id>/index.html` olarak derlenir - bu, site kökünün iki seviye altındadır;
   her rapor klasörü de doğrudan site kökünün altında yer alır. Bu yüzden her rapor sayfası, hangi
   rapor olduğuna bakılmaksızın aynı `../../<klasor>/index.html` kalıbını kullanır. Yeni sayfanızı
   `docs/reports/` dışında başka bir yere koyarsanız bu hesabı yeniden yapın - derlenmiş sitede boş bir
   çerçeve görmenizin ama raporu doğrudan açtığınızda çalışmasının bir numaralı nedeni budur.

   `.report-actions` / `.report-frame` sınıfları `docs/css/extra.css` içinde biçimlendirilmiştir
   (duyarlı, temaya uyumlu bir iframe kutusu ve iki `.md-button`); `.md-button`/`.md-button--primary`
   ise mkdocs-material'in `attr_list` markdown eklentisiyle (zaten `mkdocs.yml`'de etkin) gelir.

3. **`mkdocs.yml` içinde bir gezinme (nav) satırı**, `Reports > Windows` veya `Reports > Linux` altında:

   ```yaml
       - Reports:
           - Windows:
               - "Unit Test Results (native)": "reports/test-results-win.md"
   ```

## Yeni bir rapor sayfası eklemek, adım adım

1. Aracınızın HTML raporunu `docs/` altına bir yere yazdığından emin olun, örn.
   `docs/mytoolwin/index.html` (klasör oluşturma + aracın çalıştırılmasını, mevcut raporların yaptığı
   gibi `7-build-app-windows.bat`/`.sh` içine ekleyin).
2. `tools/zip_reports.py` içindeki `REPORTS` listesine bir satır ekleyin (id, başlık, platform, tek
   satırlık açıklama, zip'lenecek klasör ve raporun kendi `index.html` yolu) - bu, "İndir (zip)"
   düğmesi için yapı betiklerinin onu otomatik olarak zip'lemesini sağlar.
3. `docs/reports/` altındaki mevcut bir sayfayı (örn. `test-results-win.md`) `docs/reports/mytool-win.md`
   olarak kopyalayın ve başlığı/açıklamayı/yolları buna göre düzenleyin.
4. `mkdocs.yml`'nin `nav: Reports:` bölümüne onun için bir satır ekleyin.
5. Yeniden derleyin (`7-build-app-windows.bat` veya `.sh`) ve aşağıdaki gibi yerelde test edin.

## Yerelde test etme

Raporlar gerçek bir HTTP sunucusu gerektirir, `file://` yolu değil - birçok tarayıcı, güvenlik
nedeniyle `src`'si yerel bir dosya olan bir `<iframe>`'i yüklemeyi reddeder (bu tarayıcının kendi
same-origin/`file://` kısıtlamasıdır, bu şablonun iframe/CSS'iyle aşılabilecek bir şey değildir).
`9-open-site.bat` / `.sh` bunu sizin için zaten yapar:

```bat
9-open-site.bat
```

```bash
./9-open-site.sh
```

İkisi de `site/` kökünde `python -m http.server` (veya `py -3 -m http.server`) başlatır, URL'yi
yazdırır (genellikle `http://localhost:8000/`) ve varsayılan tarayıcınızda açar. **Reports**
sekmesinden yeni rapor sayfasını açın; çerçevenin yüklendiğini, "Yeni sekmede aç"ın aynı raporu
doğrudan açtığını ve "İndir (zip)"in boş olmayan bir arşiv indirdiğini doğrulayın. İşiniz bitince o
terminalde `Ctrl+C` ile sunucuyu durdurun.

## Sık karşılaşılan sorunlar

| Belirti | Neden | Çözüm |
| --- | --- | --- |
| Rapor sayfasındaki `<iframe>` boş/hata gösteriyor, ama rapor dosyasının kendisini doğrudan açtığınızda sorunsuz çalışıyor | Yanlış göreli yol (yukarıdaki "iki seviye yukarı" kuralına bakın), ya da `9-open-site.bat`/`.sh` yerine `site/index.html`'e çift tıklayarak (`file://`) test ettiniz | `docs/reports/<id>.md`'den itibaren `../../` seviyelerini yeniden sayın ve her zaman yerel HTTP sunucusu üzerinden test edin. |
| Rapor sayfası 404 veriyor / çerçeve tarayıcının kendi "dosya bulunamadı" sayfasını gösteriyor | Rapor bu derlemede bu platform için hiç üretilmemiş (örn. yalnızca `7-build-app-windows.bat` çalıştırdınız, bu yüzden `docs/*linux*` klasörleri henüz yok) | O platform için ilgili yapı betiğini çalıştırın, ya da **Reports** sekmesindeki girdinin doğru platform grubunda olduğunu kontrol edin. |
| Rapor sayfası/iframe çalıştığı halde "İndir (zip)" 404 veriyor | Rapor üretildikten sonra `tools/zip_reports.py` çalıştırılmamış, ya da yeni girdinizin `zip_source` klasör adında bir yazım hatası var | Tam yapı betiğini yeniden çalıştırın (`mkdocs build`'den hemen önce `zip_reports.py`'yi zaten çağırır), ya da `py -3 tools/zip_reports.py`'yi elle çalıştırıp klasör klasör yazdırdığı çıktıyı kontrol edin. |
| `mkdocs build`, yeni `docs/reports/*.md` girdilerinizden biri için "A reference to ... is included in the nav configuration, which is not found" uyarısı yazdırıyor | `mkdocs.yml` nav yolunda yazım hatası, ya da `.md` dosyası kaydedilmemiş/yanlış klasörde | Nav yolunu `docs/reports/` altındaki gerçek dosya yoluyla karakter karakter karşılaştırın. |
| Site GitHub Pages'te canlı ama özellikle bir rapor iframe'i orada boş (yerelde çalışıyor) | Rapor klasörü, Pages iş akışının dağıttığı çıktıya dahil edilmemiş (örn. yalnızca bir işletim sistemi işinde çalıştı ve birleştirme adımı onu kopyalamadı) | `.github/workflows/pages.yml`'yi kontrol edin - "Windows + Linux raporlarını birleştir" adımı, raporunuzun ihtiyaç duyduğu her `docs/<klasor>`'ü `mkdocs build`'den önce nihai `docs/` içine kopyalamalıdır. |
| Harici bir site, iframe'inizde gösterilmeyi reddediyor (tarayıcı konsolunda X-Frame-Options: DENY / Content-Security-Policy: frame-ancestors 'none') | Bu şablonun kendi raporları için geçerli değildir (aynı sitede sunulan statik dosyalardır, bu yüzden herhangi bir çerçeveleme kısıtlaması uygulanmaz) - bu yalnızca bir rapor sayfasının `src`'sini başka bir web sitesine yönlendirirseniz sorun olur | Yalnızca `docs/` içine kopyalanan ve bu sitenin kendisinden sunulan raporları iframe'leyin; harici herhangi bir şeye iframe değil, bağlantı (link) verin. |
