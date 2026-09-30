# GitHub Pages olmadan projeyi gösterme

Ders deponuz **özeldir (private)** (*Use this template -> Private* ile oluşturdunuz, bkz. [Şablonu kullanma](use-template.md))
ve büyük olasılıkla **GitHub Free** planındasınız. Bu planda özel bir depoda **GitHub Pages yoktur** (özel depoda Pages için
GitHub Pro/Team gerekir). Pages'in göstereceği her şeyi **yerelde** gösterebilirsiniz; aynı dosyalar, özel depolarda *çalışan*
GitHub Release içinde de taşınır.

## İki komut

Windows:

```bat
7-build-all-windows.bat
9-open-site-windows.bat
```

Linux / WSL:

```bash
./7-build-all-linux.sh
./9-open-site-linux.sh
```

1. `7-build-all-*` projeyi derler ve test eder, tüm raporları ve API belgelerini üretir, MkDocs sitesini derler ve `release/`
   klasörünü doldurur.
2. `9-open-site-*`, `site/` klasörünü küçük bir yerel web sunucusuyla **http://localhost:8000/** adresinde sunar ve tarayıcınızı
   açar. Bu site GitHub Pages'in göstereceğiyle aynıdır: ana sayfa, kılavuzlar, her rapor sayfası (her rapor bir çerçeve
   içinde, "Open in a new tab" ve "Download (zip)" ile), API belgeleri.

Rapor sayfaları `<iframe>` kullandığı ve tarayıcılar `file://` sayfalarında bunları engellediği için yerel bir web sunucusu
gerekir - `site/index.html` dosyasına çift tıklamayın.

## `release/` içinde ne var

Her çıktı kendi arşivinde, adı `<proje>-<sürüm>-<platform>[-<arch>]-<içerik>[-<araç>].<uzantı>`:

```text
calculator-1.1.0-windows-x64-app.zip              uygulama (açın, calculatorapp.exe çalıştırın)
calculator-1.1.0-windows-x64-lib-release.zip      kütüphaneler + başlıklar (ayrıca -lib-debug.zip)
calculator-1.1.0-windows-report-tests.zip         birim test sonuçları
calculator-1.1.0-windows-report-coverage-reportgenerator.zip     kod kapsama, iki aile
calculator-1.1.0-windows-report-coverage-opencppcoverage.zip
calculator-1.1.0-windows-report-doccoverage-reportgenerator.zip  belge kapsama, iki aile
calculator-1.1.0-windows-report-doccoverage-lcov.zip
calculator-1.1.0-windows-api-doxygen.zip          API belgeleri
calculator-1.1.0-source.zip                       kaynak kod
calculator-1.1.0-site.zip                         sitenin tamamı
ASSETS.md   SHA256SUMS.txt                        varlık tablosu ve sağlama toplamları (checksum)
```

(Linux'ta aynı adlar `linux` ve ikili dosyalar için `.tar.gz` ile.) Yerel bir derleme **kendi platformunuzun** varlıklarını ve
platformdan bağımsız olanları içerir; `ASSETS.md` eksik olan platformu söyler. CI iki platformu da derler.

## Sunum (proje gösterimi) kontrol listesi

Bir gün önce hazırlayın: makinenizde `7-build-all-*`, sonra bir kez `9-open-site-*` ile kontrol edin.

- [ ] **Yerel site ana sayfası** - `9-open-site-*` -> `http://localhost:8000/`: rozetler, proje adı ve sürümle ana sayfa.
- [ ] **Her rapor sayfası** - *Reports -> platformunuz*: birim test sonuçları, kod kapsama (ReportGenerator **ve** native araç -
      sayılar uyuşuyor mu?), belge kapsama (ikisi de). Kırmızı satırın ne demek olduğunu anlatın.
- [ ] **API belgeleri** - *API docs* sekmesi: kütüphanenizden bir sınıf açın, Doxygen yorumunu ve çağrı grafiğini gösterin.
- [ ] **`release/` klasör listesi** - klasörü açın (`dir release` / `ls release`): her çıktı için bir arşiv, `ASSETS.md`,
      `SHA256SUMS.txt`.
- [ ] **Uygulamayı release arşivinden çalıştırın** - `<proje>-<sürüm>-<platform>-x64-app.*` dosyasını boş bir klasöre açın ve proje
      konunuzdan bir girdiyle çalıştırın (`calculatorapp.exe` / `./calculatorapp`).
- [ ] **Sağlama toplamı doğrulama** (isteğe bağlı): `certutil -hashfile <dosya> SHA256` (Windows) ya da
      `sha256sum -c SHA256SUMS.txt` (Linux), `SHA256SUMS.txt` ile eşleşir.
- [ ] **GitHub** - depo sayfası: Actions sekmesi yeşil, (yayınladıysanız) release, hoca *Settings -> Collaborators* altında
      görünüyor.

## Aynı dosyalar GitHub Release olarak (özel depolarda çalışır)

```bat
10-release-windows.bat --dry-run
10-release-windows.bat
```

```bash
./10-release-linux.sh --dry-run
./10-release-linux.sh
```

`--dry-run`, `gh release create` komutunu ve yükleyeceği dosyaların listesini yazdırır - GitHub varlık listesi yerel `release/`
klasörüyle birebir aynıdır. Gerçek çalıştırma temiz bir çalışma ağacı, push edilmiş bir commit ve `gh auth login` ister
([Sürümler](releases.md)); etiket `project.env` içindeki `VERSION` değerinden `v<VERSION>` olur. Releases özel depolarda GitHub
Free'de çalışır ve size ve iş birlikçilerinize (hocaya) görünür.

## GitHub Pro (Student Developer Pack) varsa

O zaman Pages özel depoda da çalışır: `PAGES_ON_PRIVATE` depo değişkenini `true` yapın ve Pages'i açın (**Settings -> Pages ->
Deploy from a branch -> `gh-pages` / root**); *Deploy Pages* iş akışı aynı siteyi yayınlar. Ayrıntılar [Sürümler](releases.md)
sayfasında. Pro yoksa *Deploy Pages* iş akışı siteyi derler ve denetler ama dağıtımı atlar ve bu sayfaya işaret eden bir not yazar.
