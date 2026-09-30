# Siteye HTML raporu gömme

Şablonun ürettiği her rapor (Doxygen, ReportGenerator, OpenCppCoverage / lcov / gcovr, junit2html) bu MkDocs Material sitesinde
**kendi sayfasını** alır: başlık, tek satırlık açıklama, "Open in a new tab" ve "Download (zip)" düğmeleri ve rapor, biçimlendirilmiş,
duyarlı (responsive), tam yükseklikte, tembel yüklenen (lazy) bir `<iframe>` içinde. **Reports** ve **API docs** sekmelerine ya da
örnek olarak [Birim test sonuçları - Windows](../reports/windows/tests-junit2html.md) sayfasına bakın. Bu sayfa bunun tam olarak nasıl
çalıştığını anlatır; böylece proje konunuz için ekleyeceğiniz bir raporu (örneğin bir statik analiz aracı) aynı şekilde ekleyebilirsiniz.

## iframe kuralı: yalnızca bağımsız (standalone) HTML iframe içine girer

| `<iframe>` içine girer (site üretecinin **dışında** üretilmiş bağımsız HTML) | Asla çerçevelenmez - bağlantı verilir, yeni sekmede açılır |
| --- | --- |
| ReportGenerator, genhtml (lcov), gcovr, junit2html, OpenCppCoverage, Doxygen, JaCoCo, Javadoc, TRX-HTML | **Kendi site gezinmesini taşıyan** sayfa: Maven sitesi (Surefire, Checkstyle, PMD ...), DocFX sitesi, başka bir MkDocs sitesi |

Neden: `reports/linux/coverage-lcov/index.html` gibi bir rapor kendi içinde tamamlanmış tek bir sayfadır - sitemizin içinde
çerçevelenince etrafına bizim gezinmemiz gelir ve sorun olmaz. Zaten kendi menüsü, araması ve başlığı olan bir sayfa ise *sitenin içinde
bir site* gösterir (iki gezinme, çerçeve içinde çerçeve, bozuk göreli bağlantılar). Böyle bir siteye kendi sekmesini ve `target="_blank"`
ile düz bir bağlantı verin.

**Doğru** - bağımsız bir rapor, çerçevelenmiş:

```html
<div class="report-frame">
<iframe src="../../../raw/linux/coverage-lcov/index.html" title="Code coverage (lcov)" loading="lazy"></iframe>
</div>
```

**Yanlış** - kendi kendine gezinen bir site, çerçevelenmiş (menünün içinde menü olur):

```html
<iframe src="../../../native/maven-site/index.html"></iframe>
```

**Doğru** - aynı site, kendi başına bir site olarak açılacak şekilde bağlantılı:

```markdown
[:material-open-in-new: Open the Maven site](../../../native/index.html){ .md-button target="_blank" rel="noopener" }
```

(C++ şablonunda böyle bir site yoktur - Doxygen bağımsızdır, bu yüzden çerçevelenir. Bu dersin Java ve C# şablonları Maven sitesi /
DocFX sitesi üretir ve bu şekilde bağlar.)

## Parçalar

1. **Raporun kendisi**, derleme betiği tarafından `reports/<platform>/<tür>-<araç>/` altına yazılır (örneğin
   `reports/windows/coverage-reportgenerator/index.html`).
2. **`tools/build_site.py`** (`7-build-all-*` çalıştırır) MkDocs sitesini `site/` içine derler, sonra her rapor klasörünü
   `site/raw/<platform>/<tür>-<araç>/` olarak siteye kopyalar ve `site/downloads/<platform>-<tür>-<araç>.zip` yazar. (Ham HTML
   bilerek `raw/` altındadır: MkDocs, `reports/<platform>/<tür>-<araç>/index.html` yolunu *sayfa* için kullanır.)
3. **Her rapor için `docs/reports/<platform>/<tür>-<araç>.md` altında küçük bir `.md` sayfası.** Sayfa
   `site/reports/<platform>/<tür>-<araç>/index.html` olur, yani site kökünün üç seviye altındadır; göreli yollar `../../../` ile başlar:

   ```markdown
   # Code coverage (lcov genhtml) - Linux

   lcov'un kendi native HTML raporuyla aynı kapsama verisi ...

   <div class="report-actions" markdown>
   [:material-open-in-new: Open in a new tab](../../../raw/linux/coverage-lcov/index.html){ .md-button target="_blank" rel="noopener" }
   [:material-download: Download (zip)](../../../downloads/linux-coverage-lcov.zip){ .md-button .md-button--primary }
   </div>

   <div class="report-frame" data-platform="Linux">
   <iframe src="../../../raw/linux/coverage-lcov/index.html" title="Code coverage (lcov) - Linux" loading="lazy"></iframe>
   </div>
   ```

   Yollar göreli olduğu için GitHub Pages'te (`https://<kullanici>.github.io/<depo>/...`, bir alt yol) ve
   `http://localhost:8000/` adresinde değişmeden çalışır. `.report-actions` ve `.report-frame` `docs/css/extra.css` içinde
   biçimlendirilir; `docs/js/extra.js`, bir rapor bu derlemede yoksa (örneğin yalnız Windows'ta derlenen makinede Linux raporları)
   boş çerçeve yerine kısa bir not gösterir.
4. **`mkdocs.yml` içinde bir nav girdisi**, `Reports -> Windows` ya da `Reports -> Linux` altında.

## Yeni bir rapor sayfası eklemek, adım adım

1. Aracınızın HTML çıktısını `reports/<platform>/<tür>-<araç>/` altına yazmasını sağlayın (`7-build-all-windows.bat` / `.sh`
   içinde mevcut raporların yanına ekleyin; klasörde bir `index.html` olmalı).
2. `tools/report_catalog.py` içine bir `Entry(...)` ekleyin (platform, tür, araç, başlık, tek satırlık açıklama, varlık adı).
   Katalog; sayfa üretecini, site kopyasını, indirme zip'ini ve `<proje>-<sürüm>-<platform>-<varlık>.zip` release varlık adını yönetir.
3. `python3 tools/gen_report_pages.py` çalıştırın - her girdi için `docs/reports/<platform>/<tür>-<araç>.md` dosyasını (yeniden) yazar.
4. Sayfayı `mkdocs.yml`'in `nav` bölümünde `Reports` altına ekleyin.
5. Yeniden derleyin (`7-build-all-*`), sonra `9-open-site-*` ile test edin - aşağıya bakın.

## Yerelde test etmek

Çerçevelenmiş bir sayfa gerçek bir web sunucusu ister: tarayıcılar `src` değeri `file://` yolu olan bir `<iframe>` yüklemeyi reddeder.
`9-open-site-*`, `site/` klasöründe `python -m http.server` başlatır, `http://localhost:8000/` adresini yazdırır ve tarayıcıyı açar:

```bat
9-open-site-windows.bat
```

```bash
./9-open-site-linux.sh
```

Yeni sayfayı **Reports** sekmesinden açın ve kontrol edin: çerçeve yükleniyor, "Open in a new tab" aynı raporu tek başına açıyor,
"Download (zip)" boş olmayan bir arşiv veriyor. Sunucuyu `Ctrl+C` (Linux) ya da sunucu penceresini kapatarak (Windows) durdurun.
`python3 tools/check_site_links.py site` bağlantı denetimini yeniden çalıştırır (üretilen HTML'i gezer ve kendi sayfalarımızdaki
bozuk bağlantıda hata verir; bağımsız raporların içindeki bozuk bağlantılar listelenir ama hata sayılmaz).

## Sık karşılaşılan sorunlar

| Belirti | Neden | Çözüm |
| --- | --- | --- |
| Çerçeve boş, ama rapor tek başına sorunsuz açılıyor | Yanlış göreli yol (sayfa site kökünün üç seviye altında: `../../../raw/...`) ya da `site/index.html` dosyasına çift tıkladınız (`file://`) | `../` sayısını yeniden sayın ve her zaman `9-open-site-*` ile test edin |
| Çerçevede "This report is not part of this build of the site" yazıyor | O platformun raporu bu makinede üretilmedi (yalnız diğer platformun `7-build-all-*` betiğini çalıştırdınız) | O platformda derleyin; CI ikisini de derler |
| "Download (zip)" 404 veriyor | Rapor klasörü yok ya da giriş sayfası yok, bu yüzden `build_site.py` atladı | `build_site.py` çıktısındaki "not built here" satırlarına bakın; rapor adımını düzeltin |
| Rapor klasörü siteye kopyalanmadı (Pages dağıtımı) | Rapor, birleştirme işinin indirdiği artifact'ta yoktu | `.github/workflows/pages.yml` dosyasına bakın: platform işleri `reports/<platform>` yüklemeli |
| `mkdocs build` bir nav dosyasının eksik olduğunu uyarıyor | Nav yolunda yazım hatası ya da sayfa üretilmedi | `docs/reports/` altındaki dosyayla karşılaştırın; `tools/gen_report_pages.py` çalıştırın |
| Tarayıcı konsolu: `Refused to display ... in a frame because it set 'X-Frame-Options'` | `src` değerini başka bir web sitesine verdiniz | Yalnızca bu siteden sunulan raporları çerçeveleyin; harici siteler için bağlantı verin |
| Çerçevede iki menü var | Kendi kendine gezinen bir siteyi (Maven/DocFX/MkDocs) çerçevelediniz | Onu yeni sekmede bağlayın - yukarıdaki iframe kuralı |
