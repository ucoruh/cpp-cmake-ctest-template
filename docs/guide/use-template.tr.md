# Şablonu kullanma

## 1. Kendi deponuzu oluşturun

GitHub'da şablon deposunu açın ve **"Use this template" -> "Create a new repository"**'ye tıklayın.
Kendi depo adınızı seçin (örn. `cen429-2026-adiniz-calculator`) ve **private (özel)** yapın (ders
depoları özeldir; bunun GitHub Pages/Actions/Releases için ne anlama geldiğine bakın:
[releases.tr.md](releases.tr.md)). Bu size, şablonun dosyalarına sahip ama orijinaliyle **hiçbir
paylaşılan git geçmişi olmayan** yepyeni bir depo verir - commit'leriniz sizindir.

Özel bir deponun değerlendirme için görünür olması için öğretim üyesini şimdiden collaborator olarak
ekleyin (Settings -> Collaborators) - bkz. [releases.tr.md](releases.tr.md).

## 2. Klonlayın

```bash
git clone https://github.com/<siz>/<depo-adiniz>.git
cd <depo-adiniz>
```

(SSH anahtarınız varsa o da çalışır: `git clone git@github.com:<siz>/<depo-adiniz>.git`.)

## 3. googletest alt modülünü başlatın

```bat
0-init-submodules.bat
```

ya da Linux/WSL'de:

```bash
chmod +x 0-init-submodules.sh
./0-init-submodules.sh
```

Beklenen çıktı şununla biter:

```text
::: INIT SUBMODULES COMPLETED ::::
```

`git clone --depth 1` ile (sığ/shallow bir klon) klonladıysanız, alt modülün sabitlenmiş commit'i
henüz erişilebilir olmadığından ilk `git submodule update --init` başarısız olabilir - bu betik artık
alt modülün tüm geçmişini otomatik olarak çekip yeniden dener; sizin ekstra bir şey yapmanıza gerek
yoktur.

Alt modülün gerçekten orada olduğunu doğrulayın:

```bash
git submodule status
```

Beklenen çıktı: `src/tests/googletest` için bir commit hash'iyle başlayan bir satır (`-` ile değil),
örn.

```text
 063de7e9578f82b369302001269680b4b1553359 src/tests/googletest (v1.18.0)
```

(Başta boşluk yerine `-` olması alt modülün henüz başlatılmadığı anlamına gelir.)

## 4. İlk derleme

Windows:

```bat
7-build-app-windows.bat
```

Linux/WSL (WSL'in kendi dosya sistemindeki bir yoldan, `/mnt/g/...` değil - bkz.
[install.tr.md](install.tr.md)):

```bash
chmod +x 7-build-app-linux.sh
./7-build-app-linux.sh
```

Bu, ilk seferinde kabaca 10-20 dakika sürer (Doxygen, kapsama toplama ve mkdocs sitesi hepsi
çalışır). Sonunda şunu görmelisiniz:

```text
....................
Operation Completed!
....................
```

ve (Windows'ta) çıktının daha önceki bir yerinde `100% tests passed, 0 tests failed out of 47`
(kendi testlerinizi ekledikçe bu sayı artar).

## 5. Siteyi açın

```bat
9-open-site.bat
```

```bash
./9-open-site.sh
```

Bu, `mkdocs` tarafından üretilen ve her raporu bağlayan `site/index.html`'i açar - her birinin ne
olduğu için bkz. [../reports.md](../reports.md) ("Hangi rapor hangisi?").

## Sıradaki adım

Örnek hesap makinesini kendi proje konunuza dönüştürmek için
[topic-to-project.tr.md](topic-to-project.tr.md) ile devam edin.
