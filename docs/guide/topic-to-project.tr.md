# Proje konusundan kendi projenize

Bu bölüm, örnek "Calculator" (hesap makinesi) projesini (`utility` + `calculator` + `calculatorapp` +
googletest) kendi ders projenize nasıl dönüştüreceğinizi, her adımın soyut değil kopyala-yapıştır
olması için tek somut bir örnek konu üzerinden anlatır.

## Örnek konu: "Basit Stok Takip Sistemi"

Diyelim ki ders proje kılavuzunuz size **"Basit Stok Takip Sistemi"** (ürünleri takip et, stok ekle,
stok çıkar, azalan stokları raporla) konusunu verdi. Bu konu için tüm süreç aşağıdadır; kendi
konunuzda burada "envanter"/"ürün"/"stok" yerine kendi isim/fiillerinizi kullanın.

## 0. Projeyi `project.env` içinde adlandırın

Önce tek kimlik dosyasını düzenleyin - her betik, iş akışı, CMake ve MkDocs onu okur:

```text
PROJECT_NAME=inventory
VERSION=0.1.0
GITHUB_REPO=<siz>/<depo-adiniz>
```

Sürüm arşivleri `inventory-0.1.0-windows-x64-app.zip`, `inventory-0.1.0-linux-report-coverage-lcov.zip` gibi olur
(bkz. [İndirmeler](../downloads.md)).

## 1. Örnek klasörleri ve CMake hedeflerini yeniden adlandırın

Aynı üç katmanlı yapıyı koruyun (küçük bir `utility` kütüphanesi, gerçek `inventory` kütüphaneniz ve
çalıştırılabilir bir `inventoryapp` komut satırı demosu, artı `tests/`) - bu yapı size hem test
edilmiş bir kütüphane hem de çalıştırılabilir bir demo sağlar, kapsama da kütüphane üzerinde ölçülür.

```text
src/utility        -> olduğu gibi kalabilir (genel yardımcılar) ya da gerçekten gerekmiyorsa yeniden adlandırın
src/calculator     -> src/inventory olarak yeniden adlandırın
src/calculatorapp  -> src/inventoryapp olarak yeniden adlandırın
src/tests/calculator -> src/tests/inventory olarak yeniden adlandırın
```

Yeniden adlandırdığınız her `CMakeLists.txt`'de, `set(LIBNAME calculator)` / `set(APPNAME
calculatorapp)` / `set(TESTNAME calculator)` satırlarını `inventory` / `inventoryapp` / `inventory`
olarak değiştirin, ve `../calculator/...`'a referans veren `target_include_directories` /
`target_link_libraries` yollarını düzeltin.

## 2. C++ ad alanını (namespace) yeniden adlandırın

`Coruh::Calculator` -> kendi seçiminiz, örn. `Coruh::Inventory` (isterseniz `Coruh` yerine kendi
adınızı/rumuzunuzu kullanın - bu sadece bir namespace, zorunluluk değil). Güncelleyin:

- `src/inventory/header/*.h` (eskiden `calculator.h`): sınıf adı, namespace, header guard.
- `src/inventory/src/*.cpp`: `using namespace ...`, `#include` yolları.
- `src/inventoryapp/src/inventoryapp.cpp`: `using namespace ...`, `#include` yolu.
- `src/tests/inventory/*_test.cpp`: `using namespace ...`, `#include` yolu, `TEST_F` fixture sınıf
  adı.

## 3. Önce testlerinizi, sonra kütüphane kodunu yazın

Bu şablon, kendi örnek mantığını (infix/postfix ifade ayrıştırma) tam olarak birim test edilebilir
olsun diye uygulamadan kütüphaneye taşıdı - kendi mantığınız için de aynısını yapın. "Basit Stok Takip
Sistemi" için:

1. Önce kütüphanenin genel API'sini (örn. `Inventory::addStock`, `Inventory::removeStock`,
   `Inventory::lowStockItems`) başlık dosyasında, Doxygen yorumlarıyla tasarlayın (bunlar belge
   kapsama raporunu besler - bkz. `reports/index.md`).
2. Bu API'ye karşı googletest test durumlarını *uygulamadan önce* yazın - normal durumlar, sınır
   durumları (örn. kalan tüm stoğu tam olarak çıkarmak) ve her hata durumu (örn. var olandan fazla
   stok çıkarmak, negatif miktar eklemek, bilinmeyen bir ürün kimliği) - örüntü için bkz.
   `src/tests/calculator/expressionParser_test.cpp` (küçük bir modülün normal, öncelik, parantez,
   ondalık ve her hata yolunu kapsayan 28 test durumu - kendi modülünüzde de aynı derecede kapsamlı
   olmayı hedefleyin).
3. Testler geçene kadar kütüphane kodunu uygulayın (`6-build-and-test-windows.bat` / `./6-build-and-test-linux.sh`, ya da `build/<platform>-debug` içinde `ctest -C Debug --output-on-failure`).
4. Uygulamayı (`inventoryapp`) ince bir sürücü olarak tutun: girdi oku, kütüphaneyi çağır, çıktı
   yazdır, `main()` içinde gerçek mantık yok - tıpkı artık yalnızca bir satır okuyup
   `ExpressionParser::evaluateInfix`'i çağıran `calculatorapp.cpp` gibi.

## 4. Kendi modüllerinizi ekleyin

İkinci bir kütüphaneye mi ihtiyacınız var (örn. envanteri bir dosyaya kalıcı hale getiren bir
`storage` modülü)? `src/utility/`'nin örüntüsünü kopyalayın: kendi klasörü, kendi
`CMakeLists.txt`'i (`set(LIBNAME storage)`), kendi `target_include_directories`'i, üst düzey
`CMakeLists.txt`'e bir `option(ENABLE_STORAGE "..." ON)` ile eklenmiş ve ona bağlı
`add_subdirectory(${ROOT}/storage)`, ve kendi `src/tests/storage/CMakeLists.txt` + test dosyası,
`src/tests/CMakeLists.txt`'e eklenmiş.

## 5. Kapsamı koruyun

Bir kütüphanenin `src/` klasörüne her `.cpp` dosyası eklediğinizde, test kapsamı bir sonraki tam
derleme betiği çalıştırmanızda otomatik olarak `reports/windows/coverage-reportgenerator` / `coverage-opencppcoverage`
(ve `reports/linux/coverage-*` altında) görünecektir - her `CMakeLists.txt`'teki `file(GLOB ...)` yeni dosyaları
otomatik olarak yakalar, OpenCppCoverage / lcov de derlenen her şeyi ölçer. Ekstra yapılandırılacak
bir şey yoktur; sadece her yeni fonksiyonun onu çalıştıran en az bir testi olduğundan emin olun
(kapsama raporunun satır satır görünümünde hâlâ kırmızı/kapsanmamış bir şey var mı kontrol edin).

## 6. Bir modülü "bitti" saymadan önce kontrol listesi

- [ ] Namespace/sınıf/hedef adları tutarlı şekilde yeniden adlandırıldı (hiçbir şeyin atlanmadığından
      emin olmak için eski adı arayın: `grep -rn "Calculator" src/`).
- [ ] Her genel sınıf/fonksiyonda Doxygen yorumu var (`\brief`, `@param`, `@return`, `@throws`).
- [ ] Şunlar için testler var: normal girdi, sınır girdisi, her hata/istisna yolu.
- [ ] `6-build-and-test-*` 0 hatayla geçiyor.
- [ ] Derleyici uyarısı yok (GCC/Clang'da `-Wall -Wextra` bu şablonun `CMakeLists.txt`'inde zaten
      varsayılan olarak açık; derleme çıktısını izleyin).
- [ ] Tam derleme betiği (`7-build-all-windows.bat` / `.sh`) baştan sona çalışıyor; kapsama raporu
      yeni modülü, kasıtlı olarak test dışı bırakmadığınız kırmızı (test edilmemiş) satır olmadan
      gösteriyor.
- [ ] README.md, "Calculator" değil gerçek projenizi anlatacak şekilde güncellendi.

## Sıradaki adım

[daily-workflow.tr.md](daily-workflow.tr.md) ile devam edin.
