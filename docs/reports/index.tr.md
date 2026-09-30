# Hangi rapor hangisi?

Her tam derleme (`7-build-all-windows.bat` / `./7-build-all-linux.sh`) aynı kod hakkında birbirinden *farklı* birkaç rapor
üretir, **Windows ve Linux için ayrı ayrı** (derleyici, platform makroları ve araç sürümleri nedeniyle farklılaşabilirler).
Bu sayfa her raporun ne olduğunu, hangi aracın ürettiğini ve neden hemen her şeyin iki tane olduğunu açıklar.

## Örüntü: ReportGenerator ile native araç

Kod kapsama ve belge kapsama için şablon, **iki bağımsız HTML raporu yan yana** üretir:

1. **[ReportGenerator](https://github.com/danielpalme/ReportGenerator)** - üçüncü taraf, ekosistemden bağımsız bir araç. Bir
   kapsama dosyasını (Cobertura XML ya da lcov `.info`) okur; eğilim grafikleri ve `README` içinde görünen küçük SVG
   rozetlerle şık bir HTML raporu üretir. Windows'ta da Linux'ta da, C++, Java ya da C# için aynı araçtır.
2. **Araç zincirinin native aracı** - Windows'ta [OpenCppCoverage](https://github.com/OpenCppCoverage/OpenCppCoverage)'ın kendi
   HTML çıktısı; Linux'ta [lcov'un `genhtml`](https://github.com/linux-test-project/lcov) ve [gcovr](https://gcovr.com/) araçları.
   ReportGenerator'dan önce C/C++ geliştiricilerinin kullandığı araçlar bunlardı.

Karşılaştırma bilerek yapılır: "kapsama raporu" tek bir sabit biçim değildir ve sayılar uyuşmalıdır (iyi bir tutarlılık kontrolü).

## Raporlar

Her rapor diskinizde bir `reports/<platform>/<tür>-<araç>/` klasörü, `release/` içinde bir arşiv
(`<proje>-<sürüm>-<platform>-<varlık>.zip`) ve bu sitede bir sayfadır.

| Klasör (`reports/<platform>/...`) | Sürüm varlığı | Araç | Ne gösterir |
| --- | --- | --- | --- |
| `tests-junit2html/` | `report-tests` | CTest `--output-junit` -> junit2html | Test durumu başına geçti/kaldı ve süre. Kapsama bilgisi yok. Bir test kaldığında önce buna bakın. |
| `coverage-reportgenerator/` | `report-coverage-reportgenerator` | ReportGenerator (Windows'ta Cobertura, Linux'ta lcov) | `calculator`, `utility` ve `calculatorapp`'in hangi satır, dal ve metotlarının testlerce çalıştırıldığı, eğilim grafikleriyle. |
| `coverage-opencppcoverage/` (Windows) | `report-coverage-opencppcoverage` | OpenCppCoverage | OpenCppCoverage'ın kendi HTML'i olarak **aynı** kapsama verisi. |
| `coverage-lcov/` (Linux) | `report-coverage-lcov` | lcov `genhtml` | lcov'un kendi HTML'i (dal kapsamasıyla) olarak **aynı** kapsama verisi. |
| `coverage-gcovr/` (Linux) | `report-coverage-gcovr` | gcovr | Aynı veri, ikinci, bağımsız bir gerçekleştirimden. |
| `doccoverage-reportgenerator/{lib,tests}/` | `report-doccoverage-reportgenerator` | coverxygen -> ReportGenerator | **Belge** kapsama: genel işlev ve sınıfların kaçında Doxygen yorumu var. Kütüphaneler ve test kaynakları. |
| `doccoverage-lcov/{lib,tests}/` | `report-doccoverage-lcov` | coverxygen -> `genhtml` | Aynı belge kapsama verisi, native lcov HTML'i. |
| `api-doxygen/{lib,tests}/html/` | `api-doxygen` | Doxygen | API başvurusunun kendisi (sınıflar, işlevler, grafikler). **API docs** sekmesine bakın. |

Rozetler (`README` içindeki küçük SVG görseller) ReportGenerator tarafından `assets/badges/<platform>/{coverage,doccoverage}/`
altına yazılır.

## Kod kapsama ile belge kapsama - karıştırmayın

- **Kod kapsama** şunu yanıtlar: *testler bu satırı **çalıştırdı** mı?*
- **Belge kapsama** şunu yanıtlar: *bu işlevin ya da sınıfın **Doxygen yorumu var** mı?* Tümüyle yorumlanmış bir işlevin kod
  kapsaması %0, tümüyle test edilmiş bir işlevin belge kapsaması %0 olabilir.

## Raporlar bu siteye nasıl girer

Raporlar başka araçların (ReportGenerator, genhtml, Doxygen ...) ürettiği bağımsız HTML'dir; bu yüzden her birinin burada, bir
`<iframe>` içinde gösteren kendi sayfası vardır - bkz. [Siteye HTML raporu gömme](../guide/reports-in-site.md). Yerelde siteyi
`9-open-site-windows.bat` / `9-open-site-linux.sh` sunar; GitHub Pages'te `.github/workflows/pages.yml` dağıtır (Pages'i olmayan
özel depoda bkz. [GitHub Pages olmadan projeyi gösterme](../guide/showcase-without-pages.md)).
