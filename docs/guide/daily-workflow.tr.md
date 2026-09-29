# Günlük iş akışı

## Dal aç, commit at, push et

```bash
git checkout -b feature/envanter-stok-ekleme
# ... dosyaları düzenleyin ...
git status --short
git add src/inventory/ src/tests/inventory/
git commit -m "Negatif miktar doğrulamasıyla Inventory::addStock eklendi"
git push -u origin feature/envanter-stok-ekleme
```

GitHub'da `main`'e bir pull request açın. `.github/workflows/cpp.yml`, push'ta ve PR'da otomatik
çalışır (yapılandır, Release derle, `ctest`) - kasıtlı olarak sadedir (Doxygen yok, kapsama yok, site
yok), böylece birkaç dakikada biter ve her push'ta Actions dakikası harcamaz; dakika bütçesi için bkz.
[releases.tr.md](releases.tr.md).

## Commit atmadan önce kodunuzu biçimlendirin

```bat
5-format-code.bat
```

```bash
astyle --options=astyle-options.txt --recursive "*.h" "*.cpp"
```

Git kancalarını kurduysanız (`1-configure-git-hooks.bat`, bir kez), `pre-commit` staged
`.c/.cpp/.h/.cs/.java` dosyalarında AStyle'ı otomatik çalıştırır ve biçimlendirilmiş sonucu yeniden
stage'ler.

## Bir kilometre taşından önce / yardım istemeden önce tam yerel hattı çalıştırın

```bat
7-build-app-windows.bat
```

```bash
./7-build-app-linux.sh
```

Ardından raporlara göz atmak için `9-open-site.bat` / `.sh`.

## Her şey nereye iner

| Ne | Nerede |
| --- | --- |
| Derlenen ikili dosyalar | `publish_win/`, `build_win/build/{Debug,Release}/` (Linux: `publish_linux/`, `build_linux/build/...`) |
| Tüm raporlar + belgeler, site kaynağı | `docs/` (bkz. [../reports.md](../reports.md)) |
| Derlenen site (bunu açın) | `site/index.html` |
| Paketlenmiş ikili dosyalar + raporlar (`.tar.gz`) | `release_win/` / `release_linux/` |
| ReportGenerator'ın kullandığı kapsama/belge-kapsama eğilim geçmişi | `report_test_hist_win/`, `report_doc_lib_hist_win/`, vb. (commit edilmez - bkz. `.gitignore`) |

`docs/*`'ın hiçbiri (elle yazılan `.md` sayfaları hariç), `site/`, `build_*`, `publish_*`, `release_*`
commit edilmez - hepsi derleme betikleri tarafından yeniden üretilir (bkz. `.gitignore`).

## Bir raporu hızlıca okuma

1. `site/index.html`'i (ya da doğrudan `docs/reports.md`'yi) açın.
2. Bir kapsama raporunda **kırmızı/turuncu satırlar** = hiçbir test tarafından çalıştırılmamış - ya
   bir test ekleyin ya da nedenini anlayın (örn. gerçekten erişilemez savunma kodu).
3. Aynı rapor için ReportGenerator sayısını ve native aracın sayısını karşılaştırın (örn.
   `coveragereportlibwin` ile `coveragenativelibwin`) - yakın olmalılar; büyük bir fark genellikle
   ikisinden birinin eski veriye baktığı anlamına gelir (derlemeyi yeniden çalıştırın).
4. `testresultswin/index.html` (ya da `testresultslinux/...`) - test durumu başına geçti/kaldı, kapsama
   bilgisi yok; derleme betiği başarısız test bildirdiyse önce bakılacak olan budur.

## CI (GitHub Actions)

`.github/workflows/cpp.yml` her push/PR'da derler ve test eder (Windows + Ubuntu, yalnızca Release,
rapor üretimi yok - yukarı bakın). `.github/workflows/release.yml` yavaş, tam hattır (Doxygen +
raporlar + site + bir GitHub Release); yalnızca bir `v*` etiketinde ya da elle tetiklenen bir
`workflow_dispatch`'te çalışır - nedeni için bkz. [releases.tr.md](releases.tr.md), günlük kullanımda
yerel `10-release.bat`/`.sh` betiğini tercih edin (Actions dakikası kullanılmaz).

## Temizlik

```bat
9-clean-project.bat
```

```bash
./9-clean-project.sh
```
