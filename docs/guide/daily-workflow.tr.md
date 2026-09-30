# Günlük iş akışı

## Dal (branch), commit, push

```bash
git checkout -b feature/inventory-add-stock
# ... dosyaları düzenleyin ...
git status --short
git add src/inventory/ src/tests/inventory/
git commit -m "Add Inventory::addStock with negative-quantity validation"
git push -u origin feature/inventory-add-stock
```

GitHub'da `main`'e bir pull request açın. `.github/workflows/cpp.yml` push'ta ve PR'da otomatik çalışır (yapılandır, Release
derle, `ctest`). Bilerek hafiftir (Doxygen, kapsama, site yok); birkaç dakikada biter ve her push'ta Actions dakikalarını
tüketmez; dakika bütçesi için [Sürümler](releases.md) sayfasına bakın.

## Günlük döngü: derle ve test et

```bat
6-build-and-test-windows.bat
```

```bash
./6-build-and-test-linux.sh
```

Debug ve Release derler, tüm birim testlerini çalıştırır (yaklaşık bir dakika). Hata olursa betik, başarısız test adlarıyla ve
`build/<platform>-debug/test-results.log` ile durur.

## Commit'ten önce kodunuzu biçimlendirin

```bat
5-format-code-windows.bat
```

```bash
./5-format-code-linux.sh
```

Git kancalarını bir kez kurduysanız (`1-configure-git-hooks-windows.bat` / `./1-configure-git-hooks-linux.sh`), `pre-commit`
hazırlanmış (staged) `.c/.cpp/.h` dosyalarında AStyle'ı otomatik çalıştırır ve biçimlenmiş sonucu yeniden hazırlar.

## Kilometre taşı, sunum ya da yardım istemeden önce: her şeyi derleyin

```bat
7-build-all-windows.bat
9-open-site-windows.bat
```

```bash
./7-build-all-linux.sh
./9-open-site-linux.sh
```

`7-build-all-*` = `6-build-and-test-*` + tüm raporlar + API belgeleri + site + `release/` klasörü. `9-open-site-*` siteyi
`http://localhost:8000/` adresinde sunar.

## Her şey nereye düşer

Bunların hepsi üretilir ve gitignore'dadır - asla commit etmeyin.

| Ne | Nerede |
| --- | --- |
| Derleme ağaçları | `build/windows-debug/`, `build/windows-release/`, `build/linux-debug/`, `build/linux-release/` |
| Derlenen ikili dosyalar, kütüphaneler, başlıklar | `publish/<platform>-<arch>/{release,debug}/{bin,lib,include}` (örn. `publish/windows-x64/release/bin/calculatorapp.exe`) |
| Tüm HTML raporları ve API belgeleri | `reports/<platform>/<tür>-<araç>/` (örn. `reports/linux/coverage-lcov/index.html`) - bkz. [Hangi rapor hangisi?](../reports/index.md) |
| ReportGenerator eğilim geçmişi | `reports/history/<platform>/` |
| Derlenen site (bunu açın) | `site/index.html`, `9-open-site-*` ile |
| Her çıktı ayrı bir arşiv olarak | `release/` (`ASSETS.md` listeler, `SHA256SUMS.txt` özetleri içerir) |

## Bir raporu hızlıca okumak

1. `9-open-site-*`, ardından **Reports** sekmesi: platformunuzu seçin.
2. Kapsama raporunda **kırmızı / turuncu satırlar** = hiçbir test tarafından çalıştırılmamış: test ekleyin ya da nedenini
   anlayın (gerçekten ulaşılamaz savunma kodu).
3. Aynı rapor için ReportGenerator sayısını native aracın sayısıyla karşılaştırın (`coverage-reportgenerator` ile
   `coverage-opencppcoverage` / `coverage-lcov`). Yakın olmalılar; büyük fark genellikle birinin eski veriye baktığı anlamına
   gelir (derlemeyi yeniden çalıştırın).
4. `tests-junit2html` test başına geçti/kaldı gösterir, kapsama yok; derleme başarısız test bildirdiyse önce buna bakın.

## CI (GitHub Actions)

- `.github/workflows/cpp.yml`: her push/PR'da derle ve test et (Windows + Ubuntu, yalnız Release, rapor yok).
- `.github/workflows/pages.yml`: `main`'e push'ta: Windows ve Linux işleri testleri, raporları ve API belgelerini üretir; bir
  birleştirme (merge) işi iki platformun raporlarıyla siteyi derler, bağlantılarını denetler ve GitHub Pages'e dağıtır (Pages'i
  olmayan özel depoda atlanır - bkz. [GitHub Pages olmadan projeyi gösterme](showcase-without-pages.md)).
- `.github/workflows/release.yml`: `v*` etiketinde: Windows, Linux ve macOS işleri, sonra her varlığı (asset) yayınlar. Günlük
  işte yerelde `10-release-*` tercih edin - aynı varlıklar, Actions dakikası yok ([Sürümler](releases.md)).

## Temizlik

```bat
11-clean-windows.bat
```

```bash
./11-clean-linux.sh
```

`build/`, `publish/`, `reports/`, `site/`, `release/` ve diğer üretilen dosyaları siler. Tekrar çalıştırılabilir.
