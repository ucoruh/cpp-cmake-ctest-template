# Şablonu kullanma

## 1. Kendi ÖZEL (private) deponuzu oluşturun ("Use this template", "Fork" değil)

Ders projeniz **özel** olmalıdır. Herkese açık bir deponun *fork*'u özel yapılamaz, bu yüzden fork **etmeyin**. Bunun yerine
depoyu *şablondan* oluşturun:

1. GitHub'da şablon deposunu açın ve yeşil **Use this template** düğmesine (sağ üst, *Code* düğmesinin yanında), ardından
   **Create a new repository**'ye tıklayın.
2. **Owner**: kendi hesabınız. **Repository name**: örn. `cen429-2026-adiniz-hesap-makinesi`. İsterseniz açıklama ekleyin.
3. Görünürlükte **Private** seçin (*Public* değil). "Include all branches" kapalı kalsın.
4. **Create repository**'ye tıklayın. Artık bu şablonun dosyalarını içeren, orijinalle **ortak git geçmişi olmayan** yepyeni
   bir depoya sahipsiniz.

### Hocayı ve takım arkadaşlarınızı ekleyin

*Kendi* yeni deponuzda: **Settings -> Collaborators -> Add people** (yeni arayüzde **Settings -> Collaborators and teams**),
hocanın GitHub kullanıcı adını (`ucoruh`) ve takım arkadaşlarınızınkini yazın, bir rol seçin (hocanın notlandırması için
**Read** yeter; takım arkadaşları için **Write**) ve davetleri gönderin. Özel bir depo, eklenmeyen herkese görünmezdir.

## 2. Klonlayın (googletest submodule ile birlikte)

```bash
git clone --recurse-submodules https://github.com/<siz>/<depo-adiniz>.git
cd <depo-adiniz>
```

`--recurse-submodules` olmadan ya da `--depth 1` ile klonladıysanız submodule betiğini çalıştırın (tekrar çalıştırmak güvenli;
tam geçmişi çekip yeniden dener):

```bat
0-init-submodules-windows.bat
```

```bash
./0-init-submodules-linux.sh
```

Beklenen çıktı `::: INIT SUBMODULES COMPLETED ::::` ile biter. Doğrulama:

```bash
git submodule status
```

Beklenen: `src/tests/googletest` için bir commit özetiyle (`-` ile değil) başlayan bir satır, örn.
` 063de7e9578f82b369302001269680b4b1553359 src/tests/googletest (v1.18.0)`. (Başta `-` varsa submodule henüz
başlatılmamıştır.)

## 3. Projenize ad verin: `project.env`

Depo kökündeki `project.env` dosyasını açın:

```text
PROJECT_NAME=calculator
VERSION=1.1.1
GITHUB_REPO=ucoruh/cpp-cmake-ctest-template
```

`PROJECT_NAME` değerini projenizin kısa, küçük harfli adı, `GITHUB_REPO` değerini `<siz>/<depo-adiniz>` yapın ve `VERSION`
değerini yayınlayacağınız sürüm olarak bırakın. **Tek yer burasıdır**: her betik, her iş akışı (workflow), CMake, MkDocs ve
sürüm arşivlerinin adları bunu okur. (C++ klasör ve hedef adları [Konudan projeye](topic-to-project.md) sayfasında.)

## 4. Numaralı betikler

Aynı numara = aynı iş; platform sonektir (`-windows.bat` veya `-linux.sh`; WSL Linux olanları kullanır).

| # | İş | Windows | Linux / WSL |
| --- | --- | --- | --- |
| 0 | googletest submodule'ünü başlat (`update` = en yeni sürüm) | `0-init-submodules-windows.bat` | `0-init-submodules-linux.sh` |
| 1 | git kancalarını (hooks) kur | `1-configure-git-hooks-windows.bat` | `1-configure-git-hooks-linux.sh` |
| 2 | `.gitignore` dosyasını yeniden oluştur | `2-create-gitignore-windows.bat` | `2-create-gitignore-linux.sh` |
| 3 | paket yöneticileri | `3-install-package-manager-windows.bat` | - |
| 4 | tüm araçları kur | `4-install-tools-windows.bat` | `4-install-tools-linux.sh` |
| 5 | kodu biçimlendir | `5-format-code-windows.bat` | `5-format-code-linux.sh` |
| 6 | **hızlı**: derle + birim testleri | `6-build-and-test-windows.bat` | `6-build-and-test-linux.sh` |
| 7 | **her şey**: 6 + raporlar + API belgeleri + site + `release/` | `7-build-all-windows.bat` | `7-build-all-linux.sh` |
| 8 | örnek uygulamayı çalıştır | `8-run-app-windows.bat` | `8-run-app-linux.sh` |
| 9 | siteyi sun + aç (http://localhost:8000) | `9-open-site-windows.bat` | `9-open-site-linux.sh` |
| 10 | `release/` klasörünü GitHub Release olarak yayınla | `10-release-windows.bat` | `10-release-linux.sh` |
| 11 | üretilen tüm klasörleri temizle | `11-clean-windows.bat` | `11-clean-linux.sh` |

Yardımcı betikler (Python / üretici / genhtml / derleyici algılama, `project.env` yükleyici) `scripts/` içindedir.

### Eski ad -> yeni ad

Bu şablonun eski bir sürümünü ya da eski bir kılavuzu izlediyseniz, her şeyin yeni yeri:


| Old | New |
| --- | --- |
| `7-build-app-windows.bat`, `7-build-doc-windows.bat` | `7-build-all-windows.bat` |
| `7-build-app-linux.sh` | `7-build-all-linux.sh` |
| `8-build-test-windows.bat` | `6-build-and-test-windows.bat` (new: `6-build-and-test-linux.sh`) |
| `4-install-windows-enviroment.bat` | `4-install-tools-windows.bat` |
| `4-install-wsl-environment.sh` | `4-install-tools-linux.sh` |
| `6_download_plantuml.bat` | folded into `4-install-tools-windows.bat` / `4-install-tools-linux.sh` |
| `0-init-submodules.bat` / `.sh` | `0-init-submodules-windows.bat` / `0-init-submodules-linux.sh` |
| `0-update-submodules.bat` / `.sh` | `0-init-submodules-windows.bat update` / `0-init-submodules-linux.sh update` |
| `1-configure-git-hooks.bat` | `1-configure-git-hooks-windows.bat` (new: `-linux.sh`) |
| `2-create-git-ignore.bat` | `2-create-gitignore-windows.bat` (new: `-linux.sh`) |
| `3-install-package-manager.bat` | `3-install-package-manager-windows.bat` |
| `5-format-code.bat` | `5-format-code-windows.bat` (new: `-linux.sh`) |
| `9-open-site.bat` / `.sh` | `9-open-site-windows.bat` / `9-open-site-linux.sh` |
| `9-clean-project.bat` / `.sh`, `9-clean-configure-app-windows.bat` | `11-clean-windows.bat` / `11-clean-linux.sh` |
| `10-release.bat` / `.sh` | `10-release-windows.bat` / `10-release-linux.sh` |
| `detect-python.bat`, `detect-generator.bat`, `detect-genhtml.bat` | `scripts/detect-python-windows.bat`, `scripts/detect-generator-windows.bat`, `scripts/detect-genhtml-windows.bat` |
| `delete_desktop_ini.bat` / `.sh` | `scripts/delete-desktop-ini-windows.bat` / `scripts/delete-desktop-ini-linux.sh` |
| `DoxyfileLibWin`, `DoxyfileLibLinux`, `DoxyfileTestWin`, `DoxyfileTestLinux` | `config/Doxyfile-lib`, `config/Doxyfile-tests` (platform values come from environment variables) |
| `VERSION` file | `project.env` |
| `build_win/`, `build_linux/` | `build/windows-debug/`, `build/windows-release/`, `build/linux-debug/`, ... |
| `publish_win/`, `publish_linux/` | `publish/windows-x64/{release,debug}/`, `publish/linux-x64/{release,debug}/` |
| `release_win/`, `release_linux/` | `release/` (one folder; assets carry the platform in their name) |
| `docs/coveragereportlibwin`, `docs/coveragenativelibwin`, `docs/doxygenlibwin`, `docs/testresultswin`, `docs/coverxygen*` ... (and the `*linux` twins) | `reports/<windows or linux>/<kind>-<tool>/` |
| `report_test_hist_win/`, `report_doc_lib_hist_win/` ... | `reports/history/<windows or linux>/` |
| `assets/codecoveragelibwin/`, `assets/doccoveragelibwin/` (and `*linux`) | `assets/badges/<windows or linux>/{coverage,doccoverage}/` |

## 5. İlk derleme

Windows:

```bat
7-build-all-windows.bat
```

Linux / WSL (WSL'in kendi dosya sistemindeki bir yoldan, `/mnt/g/...` değil - bkz. [Kurulum](install.md)):

```bash
chmod +x *.sh scripts/*.sh
./7-build-all-linux.sh
```

İlk seferde yaklaşık 10-20 dakika sürer (Doxygen, kapsama, site). Günlük döngü için `6-build-and-test-*` kullanın (yaklaşık
bir dakika). Sonunda şunu görmelisiniz:

```text
....................
Operation completed. release\ now holds:
calculator-1.1.1-windows-api-doxygen.zip
...
```

ve daha önce `100% tests passed, 0 tests failed out of 46` (sayı kendi testlerinizle artar).

## 6. Siteyi açın ve uygulamayı çalıştırın

```bat
9-open-site-windows.bat
8-run-app-windows.bat "2+3*(4-1)"
```

```bash
./9-open-site-linux.sh
./8-run-app-linux.sh "2+3*(4-1)"
```

`9-open-site-*`, `site/` klasörünü `http://localhost:8000/` adresinde sunar (her rapor sayfası raporunu bir `<iframe>` içinde
gösterdiği için gerçek bir web sunucusu gerekir) ve tarayıcınızı açar. Her rapor
[Hangi rapor hangisi?](../reports/index.md) sayfasında açıklanır. Proje sunumu için
[GitHub Pages olmadan projeyi gösterme](showcase-without-pages.md) sayfasını izleyin.

## Sonraki adım

[Konudan projeye](topic-to-project.md) sayfasıyla devam edin.
