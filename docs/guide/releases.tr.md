# Özel depo: sürümler (releases) ve site

Ders deponuz **özeldir (private)** (yalnızca siz ve eklediğiniz kişiler görebilir) ve çoğu öğrenci
**GitHub Free** planındadır. Bu sayfa bu kombinasyonun neler yapıp neler yapamadığını ve bu şablonun
bu sınırların etrafından nasıl dolaştığını açıklar.

## GitHub Free (özel depo) ile Pro (Student Pack) üzerinde neler çalışır

| Özellik | GitHub Free, özel depo | GitHub Pro (Student Developer Pack ile ücretsiz) |
| --- | --- | --- |
| Releases (bir etiket + yüklenen dosyalar, dosya başına 2 GiB'a kadar, 1000 varlığa kadar) | **Çalışır** - `10-release.bat`/`.sh` ve release GitHub Actions iş akışının kullandığı budur. | Çalışır (fark yok). |
| GitHub Actions | Çalışır - ayda 2.000 dakika, 500 MB artifact deposu. | Çalışır - ayda 3.000 dakika, 1 GB artifact deposu. |
| GitHub Pages | **Özel bir depoda çalışmaz.** | Özel bir depoda çalışır. |

Releases Free'de çalıştığı ama Pages çalışmadığı için, bu şablon derlenen siteyi GitHub Pages'e
güvenmek yerine **release'in içinde** indirilebilir bir `site.zip` olarak gönderir:

1. Release'in `site.zip`'ini indirin.
2. Açın (unzip).
3. Açılan klasördeki `index.html`'i doğrudan açın, **ya da** açılan klasörü
   `python -m http.server` ile sunup yazdırılan `http://localhost:.../` adresini açın - gömülü
   rapor sayfaları `<iframe>` kullanır ve çoğu tarayıcı bunu açılmış (unzip edilmiş) düz bir
   `file://` yolundan engeller (kendi derlediğiniz sitede `9-open-site.bat`/`.sh`'nin yerel bir
   sunucu çalıştırmasıyla aynı neden - bkz. [reports-in-site.tr.md](reports-in-site.tr.md)).

## `.github/workflows/pages.yml` deponuzda nasıl davranır

`pages.yml`, `main`'e her push'ta çalışır. Her zaman tam siteyi **derler** (her iki platformun
raporları birleştirilmiş, `mkdocs build --strict` ve `tools/check_site_links.py` ile bağlantıları
kontrol edilmiş) - böylece derleme bozulması her durumda yakalanır; yalnızca **dağıtım (deploy)**
adımını atlar:

- **Genel (public) depo** (bu şablonun kendi deposu, `ucoruh/cpp-cmake-ctest-template`, genel/public'tir):
  Pages otomatik olarak dağıtılır. Canlı site: <https://ucoruh.github.io/cpp-cmake-ctest-template/>.
- **Pro/Team olmadan özel (private) depo**: dağıtım adımı atlanır. İş akışı, Actions günlüğüne bir
  `::notice` ve o çalışmanın sayfasının en üstüne bir özet yazdırır (Actions sekmesi -> ilgili
  çalışma -> Summary) ve nedenini açıklar; yukarıdaki gibi release içindeki `site.zip` siteyi almanın
  yolu olmaya devam eder.
- **Pro/Team ile özel (private) depo** (örn. Student Developer Pack): **depo değişkenini (repository
  variable)** `PAGES_ON_PRIVATE` olarak `true` yapın (**Settings -> Secrets and variables -> Actions ->
  Variables sekmesi -> New repository variable**, ad `PAGES_ON_PRIVATE`, değer `true`), sonra iş
  akışını yeniden çalıştırın (**Actions sekmesi -> Deploy Pages -> Run workflow**, ya da tekrar push
  edin). Pages'in kendisini de bir kez açın: **Settings -> Pages -> Source -> Deploy from a branch ->
  `gh-pages` / `(root)`** - iş akışı ilk başarılı dağıtımda `gh-pages` dalını oluşturur, ama bu ayarı
  sizin yerinize açmaz.

## GitHub Student Developer Pack'i alın (isteğe bağlı, size Pro verir)

Pages'in özel deponuzda doğrudan çalışmasını istiyorsanız (zip/unzip adımı olmadan), üniversite e-posta
adresinizle [GitHub Student Developer Pack](https://education.github.com/pack) için başvurun;
genellikle kayıt kanıtı da yüklemeniz gerekir (bir öğrenci kimliği fotoğrafı ya da benzeri). Onay
birkaç dakikadan birkaç güne kadar sürebilir. Onaylandıktan sonra, doğrulanmış bir öğrenci olduğunuz
sürece hesabınız ücretsiz GitHub Pro alır, bu da özel depolarda Pages'i içerir (Settings -> Pages ->
etkinleştir, bir dal/klasör seçin).

## Öğretim üyesini collaborator olarak ekleyin

Özel bir deponun release'leri yalnızca erişimi olan kişilere görünür. Release'leriniz (ve deponun
geri kalanı) değerlendirme için görülebilsin diye öğretim üyesini (`ucoruh`) collaborator olarak
ekleyin: **Settings -> Collaborators and teams -> Add people** -> GitHub kullanıcı adlarını girin ->
bir rol seçin (değerlendirme için Read yeterlidir) -> daveti gönderin.

## `gh` (GitHub CLI) kurulumu ve girişi

Hem `10-release.bat`/`.sh` hem de elle release süreci `gh` kullanır.

Windows:

```bat
choco install gh -y
```

Linux/WSL:

```bash
sudo apt install gh -y
# ya da bu paket dağıtımınızda/sürümünüzde yoksa:
# bkz. https://github.com/cli/cli/blob/trunk/docs/install_linux.md
```

Giriş yapın (etkileşimli, bir tarayıcı açar):

```bash
gh auth login
```

Soruları yanıtlayın: **GitHub.com** -> **HTTPS** -> **Login with a web browser** (ya da zaten bir
kişisel erişim token'ınız varsa bir token) -> açılan tarayıcı penceresinde terminalinizde gösterilen
tek seferlik kodu izleyin.

Doğrulama:

```bash
gh auth status
```

Beklenen çıktı şuna benzer bir satır içerir:

```text
✓ Logged in to github.com account <kullanıcı-adınız> (keyring)
```

## Bir release'i yerel olarak yayımlama (Actions dakikası kullanılmaz)

```bat
10-release.bat v1.0.0
```

```bash
./10-release.sh v1.0.0
```

Önce her şeyi gerçekten bir release oluşturmadan kontrol etmek için `--dry-run` ekleyin:

```bat
10-release.bat v1.0.0 --dry-run
```

Bu, her şeyi derler (7-build-app-windows.bat`/`.sh` ile aynı hat), `site.zip`'i ve tüm
`.tar.gz` rapor/ikili arşivlerini `release_win/` (ya da `release_linux/`) içine paketler ve *hiçbir
şey oluşturmadan* tam olarak hangi `gh release create` komutunu çalıştıracağını ve hangi dosyaları
yükleyeceğini yazdırır. Listeden memnun olduğunuzda gerçekten yayımlamak için `--dry-run`'ı kaldırın.

Çalışma ağacınızda commit edilmemiş değişiklikler varsa (`git status --porcelain` boş değilse) betik
çalışmayı reddeder - önce commit edin ya da stash'leyin, böylece bir release her zaman gerçek bir
commit'e karşılık gelir.

## Alternatif: release'i GitHub Actions ile derleyin

`.github/workflows/release.yml` aynı şeyi yapar, ama GitHub'ın sunucularında, bir `v*` etiketi push
ederek ya da elle çalıştırarak tetiklenir (Actions sekmesi -> Release -> Run workflow). Günlük
kullanımda yerel betiği tercih edin; bunu özellikle kendi makineniz yerine temiz, tekrarlanabilir bir
ortamda derlenmiş bir release istediğinizde kullanın. Actions dakikası harcar (elle
`7-build-app-windows.bat` çalıştırmakla kabaca aynı ~15-20 dakika) - GitHub Free'de bu, ara sıra
release yapmak için ayda 2.000 dakikalık bütçenin rahatlıkla içindedir, ama her push'ta çalıştırmayın
(bu yüzden `push:`'a bağlanmamıştır).

## Sorun giderme

| Belirti | Düzeltme |
| --- | --- |
| `gh release create` 403 ya da 404 ile başarısız oluyor | Ya `gh` giriş yapmamış (`gh auth status`), ya da hesabınızın depoya yazma erişimi yok (sahibi olmanız, ya da yazma erişimi olan bir collaborator olmanız gerekir - değerlendirme için eklenen öğretim üyesi gibi salt-okunur collaborator'lar release yayımlayamaz). |
| Release oluşturuldu, ama öğretim üyesi göremediğini söylüyor | Depo özel ve henüz collaborator olarak eklenmemiş - yukarıya bakın. |
| `gh release create` varlık boyutuyla ilgili bir şeyle başarısız oluyor | 2 GiB'ın üzerinde tek bir dosya, ya da toplam 1000'den fazla dosya, tek bir release'e yüklenemez. Bu şablonun kendi arşivleri buna hiç yaklaşmaz; büyük veri dosyaları eklediyseniz onları hariç tutun ya da farklı şekilde bölün. |
| Özel bir depo için Settings'te Pages açılmıyor | GitHub Pro/Team'de değilsiniz (ve henüz Student Pack'iniz yok) - yukarıya bakın; bu arada release'in içindeki `site.zip`'i kullanın. |
