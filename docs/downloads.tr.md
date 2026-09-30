# İndirmeler

Her sürüm, derlemenin **tüm** çıktılarını ayrı arşivler olarak taşır - yerel `release/` klasörüyle aynı adlarla
(`7-build-all-*` onu oluşturur; `10-release-*` yükler).

[:material-download: Son sürüm](https://github.com/ucoruh/cpp-cmake-ctest-template/releases/latest){ .md-button .md-button--primary }
[:material-tag-multiple: Tüm sürümler](https://github.com/ucoruh/cpp-cmake-ctest-template/releases){ .md-button }

## Varlık (asset) adları

`<proje>-<sürüm>[-<platform>[-<arch>]]-<içerik>[-<araç>].<uzantı>` - sürümde `v` yoktur; platformlar `windows`, `linux`,
`macos`; mimariler `x64`, `arm64`.

| Varlık (`calculator` 1.1.0 örneği) | İçinde ne var |
| --- | --- |
| `calculator-1.1.0-windows-x64-app.zip` | uygulama (Windows için `.zip`) |
| `calculator-1.1.0-linux-x64-app.tar.gz` | uygulama (Linux ve macOS için `.tar.gz`: çalıştırma bitini korur) |
| `calculator-1.1.0-macos-arm64-app.tar.gz` | uygulama, CI'da macOS üzerinde derlenir |
| `calculator-1.1.0-windows-x64-lib-release.zip`, `-lib-debug.zip` | kütüphaneler + başlıklar (ayrıca `-linux-x64-lib-*.tar.gz`) |
| `calculator-1.1.0-<platform>-report-tests.zip` | birim test sonuçları (junit2html) |
| `calculator-1.1.0-<platform>-report-coverage-reportgenerator.zip` | kod kapsama, ReportGenerator |
| `calculator-1.1.0-windows-report-coverage-opencppcoverage.zip` | kod kapsama, OpenCppCoverage (Windows) |
| `calculator-1.1.0-linux-report-coverage-lcov.zip`, `-gcovr.zip` | kod kapsama, lcov genhtml ve gcovr (Linux) |
| `calculator-1.1.0-<platform>-report-doccoverage-reportgenerator.zip`, `-lcov.zip` | belge kapsama, iki aile |
| `calculator-1.1.0-<platform>-api-doxygen.zip` | Doxygen API belgeleri |
| `calculator-1.1.0-source.zip` | kaynak kod, googletest submodule dahil |
| `calculator-1.1.0-site.zip` | bu sitenin tamamı, iki platformun raporlarıyla (açın, yerel web sunucusuyla sunun) |
| `ASSETS.md`, `SHA256SUMS.txt` | varlık tablosu ve sağlama toplamları |

İndirmeyi doğrulayın: `sha256sum -c SHA256SUMS.txt` (Linux) ya da `certutil -hashfile <dosya> SHA256` (Windows).
