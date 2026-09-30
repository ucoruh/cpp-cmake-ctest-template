<div class="hero" markdown>
![logo](../assets/logo.png){ .hero-logo }

# Calculator - C/C++ CMake + CTest ders projesi şablonu

<p class="tagline">Eksiksiz bir C/C++ şablonu: CMake + CTest + googletest, her kontrol Windows'ta ve Linux'ta iki kez
raporlanır (ReportGenerator ve native araç), Doxygen API belgeleri ve hepsini bir araya getiren bu site - RTEÜ ders
projeleri için en iyi uygulama örneği.</p>

<p class="badges" markdown="span">
[![Build and Test](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/cpp.yml/badge.svg)](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/cpp.yml)
[![Pages](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/pages.yml/badge.svg)](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/pages.yml)
[![Release](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/release.yml/badge.svg)](https://github.com/ucoruh/cpp-cmake-ctest-template/actions/workflows/release.yml)
[![Latest release](https://img.shields.io/github/v/release/ucoruh/cpp-cmake-ctest-template?label=latest)](https://github.com/ucoruh/cpp-cmake-ctest-template/releases/latest)
[![License](https://img.shields.io/github/license/ucoruh/cpp-cmake-ctest-template)](https://github.com/ucoruh/cpp-cmake-ctest-template/blob/main/LICENSE)
![Satır kapsama (Windows)](../assets/badges/windows/coverage/badge_linecoverage.svg)
![Satır kapsama (Linux)](../assets/badges/linux/coverage/badge_linecoverage.svg)
![Belge kapsama (Windows)](../assets/badges/windows/doccoverage/badge_linecoverage.svg)
![Belge kapsama (Linux)](../assets/badges/linux/doccoverage/badge_linecoverage.svg)
</p>

[:material-download: Son sürümü indir](https://github.com/ucoruh/cpp-cmake-ctest-template/releases/latest){ .md-button .md-button--primary }
[:material-rocket-launch: Bu şablonu kullan](guide/use-template.md){ .md-button }
[:fontawesome-brands-github: GitHub'da görüntüle](https://github.com/ucoruh/cpp-cmake-ctest-template){ .md-button }

</div>

Yeni misiniz? **[Kurulum](guide/install.md)** -> **[Şablonu kullanma](guide/use-template.md)** ->
**[Konudan projeye](guide/topic-to-project.md)**. Site iki dillidir: başlıktaki dil seçiciyi kullanın (English / Türkçe).

## Bu şablonda neler var

<div class="grid cards" markdown>

-   :material-cog-outline: **CMake + CTest + googletest**

    ---

    Bir `utility` kütüphanesi, bir `calculator` kütüphanesi (birim testli infix/postfix ayrıştırma) ve bir `calculatorapp`
    komut satırı demosu. Windows'ta (Visual Studio ya da Ninja + MinGW) ve Linux / WSL'de (Ninja + GCC) derlenir.

    [:octicons-arrow-right-24: Kurulum ve ilk derleme](guide/install.md)

-   :material-file-document-multiple-outline: **Her rapor iki yolla, platform başına**

    ---

    Birim testleri, kod kapsama ve belge kapsama - her biri hem [ReportGenerator](https://github.com/danielpalme/ReportGenerator)
    ile hem de native araçla (OpenCppCoverage, lcov `genhtml`, gcovr) - Windows'ta ve Linux'ta ayrı ayrı üretilir.

    [:octicons-arrow-right-24: Hangi rapor hangisi?](reports/index.md)

-   :material-file-tree-outline: **API belgeleri (Doxygen)**

    ---

    Kütüphaneler ve test kaynakları için, Windows ve Linux'ta, çağrı ve include grafikleriyle.

    [:octicons-arrow-right-24: API belgeleri](api/index.md)

-   :material-tag-outline: **Tek bir numaralı betik takımı**

    ---

    `6-build-and-test`, `7-build-all`, `9-open-site`, `10-release` ... aynı numara aynı iştir; sonek olarak `-windows.bat` /
    `-linux.sh`. Projeyi tek bir `project.env` adlandırır.

    [:octicons-arrow-right-24: Betikler](guide/use-template.md)

-   :material-monitor-share: **GitHub Pages olmadan gösterin**

    ---

    GitHub Free'de özel bir depoda Pages yoktur. `7-build-all` + `9-open-site` sitenin tamamını http://localhost üzerinde
    gösterir, `release/` her çıktıyı içerir. Sunum için kontrol listesi.

    [:octicons-arrow-right-24: Pages olmadan projeyi gösterme](guide/showcase-without-pages.md)

-   :material-package-variant-closed: **Her çıktıyla sürümler**

    ---

    `release/` = GitHub Release, birebir: uygulama, kütüphaneler, her rapor, API belgeleri, `site.zip`, kaynak, `ASSETS.md` ve
    `SHA256SUMS.txt`.

    [:octicons-arrow-right-24: İndirmeler](downloads.md)

-   :material-source-branch: **Konudan kendi projenize**

    ---

    Uygulamalı bir yürüyüş: örneği tek yerden yeniden adlandırın, modüllerinizi ekleyin, önce testleri yazın.

    [:octicons-arrow-right-24: Konudan projeye](guide/topic-to-project.md)

-   :material-lifebuoy: **Gerçek hatalardan sorun giderme**

    ---

    Bu şablon derlenirken karşılaşılan gerçek hata iletileri ve her biri için kesin çözüm.

    [:octicons-arrow-right-24: Sorun giderme](guide/troubleshooting.md)

</div>

## Raporlar, canlı

Her raporun bu sitede kendi sayfası vardır (çerçeve içinde bağımsız HTML raporu, "Yeni sekmede aç" ve "İndir (zip)" ile).
Doğrudan birine gidin ya da **Reports** sekmesini açın:

<div class="grid cards" markdown>

-   :material-microsoft-windows: **Windows**

    ---

    [Birim test sonuçları](reports/windows/tests-junit2html.md) ·
    [Kod kapsama - ReportGenerator](reports/windows/coverage-reportgenerator.md) ·
    [Kod kapsama - OpenCppCoverage](reports/windows/coverage-opencppcoverage.md) ·
    [Belge kapsama - ReportGenerator](reports/windows/doccoverage-reportgenerator.md) ·
    [Belge kapsama - lcov](reports/windows/doccoverage-lcov.md) ·
    [API belgeleri - Doxygen](reports/windows/api-doxygen.md)

-   :material-linux: **Linux**

    ---

    [Birim test sonuçları](reports/linux/tests-junit2html.md) ·
    [Kod kapsama - ReportGenerator](reports/linux/coverage-reportgenerator.md) ·
    [Kod kapsama - lcov](reports/linux/coverage-lcov.md) ·
    [Kod kapsama - gcovr](reports/linux/coverage-gcovr.md) ·
    [Belge kapsama - ReportGenerator](reports/linux/doccoverage-reportgenerator.md) ·
    [Belge kapsama - lcov](reports/linux/doccoverage-lcov.md) ·
    [API belgeleri - Doxygen](reports/linux/api-doxygen.md)

</div>

## Kapsama oranları

| Kapsama türü | Windows | Linux (WSL / CI Ubuntu) |
| --- | --- | --- |
| Satır | ![Satır kapsama](../assets/badges/windows/coverage/badge_linecoverage.svg) | ![Satır kapsama](../assets/badges/linux/coverage/badge_linecoverage.svg) |
| Dal (branch) | ![Dal kapsama](../assets/badges/windows/coverage/badge_branchcoverage.svg) | ![Dal kapsama](../assets/badges/linux/coverage/badge_branchcoverage.svg) |
| Metot | ![Metot kapsama](../assets/badges/windows/coverage/badge_methodcoverage.svg) | ![Metot kapsama](../assets/badges/linux/coverage/badge_methodcoverage.svg) |
| Belge | ![Belge kapsama](../assets/badges/windows/doccoverage/badge_linecoverage.svg) | ![Belge kapsama](../assets/badges/linux/doccoverage/badge_linecoverage.svg) |

## Kendiniz derleyin

```bash
# Windows (cmd.exe)                      # Linux / WSL
7-build-all-windows.bat                  ./7-build-all-linux.sh
9-open-site-windows.bat                  ./9-open-site-linux.sh     # siteyi http://localhost:8000 adresinde sunar
```

Her tam derleme yaklaşık 10-20 dakika sürer ve `reports/<platform>/`, `site/` ve `release/` üretir. Hızlı derleme + birim test
döngüsü için `6-build-and-test-*` kullanın.
