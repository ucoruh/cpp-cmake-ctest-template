# Ders adlandırma standardı

Üç ders proje şablonunun tümü (CMake ile C/C++, Maven ile Java, .NET ile C#) aynı standardı izler; birinde öğrendiğiniz
diğerlerinde de geçerlidir. Bu sayfa kısa özettir.

## 1. Tek kimlik dosyası: `project.env`

```text
PROJECT_NAME=calculator
VERSION=1.1.0
GITHUB_REPO=ucoruh/cpp-cmake-ctest-template
```

Her betik, iş akışı (workflow), araç, CMake ve MkDocs bunu okur. Projeyi yeniden adlandırmayı ya da sürümü artırmayı
**yalnızca burada** yapın.

## 2. Platform simgeleri (token)

`windows`, `linux` (yerel Linux **ve WSL** - WSL Linux'tur: aynı `.sh` betikleri, Linux ikili dosyaları) ve `macos` (yalnızca CI,
yalnızca uygulama). Mimariler `x64` / `arm64` yalnızca ikili dosya adlarında görünür. Dosya adında asla `win` ya da `wsl` yok.

## 3. Betikler: aynı numara aynı iştir

`NN-ad-windows.bat` ve `NN-ad-linux.sh`; yardımcılar aynı sonek kuralıyla `scripts/` içindedir.

| # | İş |
| --- | --- |
| 0 | `init-submodules` (yalnızca submodule olan yerde) |
| 1 | `configure-git-hooks` |
| 2 | `create-gitignore` |
| 3 | `install-package-manager` (yalnızca Windows) |
| 4 | `install-tools` |
| 5 | `format-code` |
| 6 | `build-and-test` (hızlı: derle + birim testleri) |
| 7 | `build-all` (6 + her rapor, API belgeleri, site, `release/` klasörü) |
| 8 | `run-app` |
| 9 | `open-site` |
| 10 | `release` |
| 11 | `clean` |

## 4. Yerel klasörler (hepsi gitignore'da)

```text
build/<platform>-<config>/          build/windows-debug, build/linux-release, ...
publish/<platform>-<arch>/          publish/windows-x64/{release,debug}/{bin,lib,include}
reports/<platform>/<tür>-<araç>/    reports/linux/coverage-lcov, reports/windows/tests-junit2html, ...
site/                               MkDocs sitesi (site/raw = bağımsız raporlar, site/downloads = zip'leri)
release/                            her çıktı için bir arşiv + ASSETS.md + SHA256SUMS.txt
```

## 5. Belgeler ve raporlar platform başınadır

Testler, kod kapsama (iki aile), belge kapsama (iki aile) ve API belgeleri Windows'ta **ve** Linux'ta üretilir ve ayrı
tutulur; her birinin adında platform bulunur - ikisi farklılaşabilir.

## 6. Sürüm varlıkları: `release/` = GitHub Release

`<proje>-<sürüm>[-<platform>[-<arch>]]-<içerik>[-<araç>].<uzantı>`, sürümde `v` yok; Windows ikili dosyaları ve her HTML için
`.zip`, Linux/macOS ikili dosyaları için `.tar.gz`. Tam liste için [İndirmeler](../downloads.md) sayfasına bakın.

## 7. Site: MkDocs Material, iki dilli

Ana sayfa, Kılavuz, Raporlar (Windows / Linux), API belgeleri, İndirmeler; koyu/açık tema; iki dilde arama; İngilizce kökte,
Türkçe `/tr/` altında (mkdocs-static-i18n, suffix modu: `ad.en.md` + `ad.tr.md`). **iframe kuralı:** yalnızca site üretecinin
dışında üretilmiş *bağımsız* HTML çerçevelenir (ReportGenerator, genhtml, gcovr, junit2html, OpenCppCoverage, Doxygen, JaCoCo,
Javadoc); kendi site gezinmesini taşıyan sayfa (Maven sitesi, DocFX) bağlantı olarak verilir, asla çerçevelenmez - bkz.
[Siteye HTML raporu gömme](reports-in-site.md).

## 8. CI ve sürümler

Windows ve Linux işleri derler, test eder, raporları ve API belgelerini üretir; macOS işi yalnızca uygulamayı derler; bir
birleştirme (merge) işi siteyi derler (yalnızca kendi sayfalarımızdaki bozuk bağlantıda hata), `main`'de Pages'i dağıtır
(Pages'i olmayan özel depoda atlanır - bkz. [GitHub Pages olmadan projeyi gösterme](showcase-without-pages.md)) ve
`v<VERSION>` etiketinde her varlığı `ASSETS.md` ve `SHA256SUMS.txt` ile yayınlar.
