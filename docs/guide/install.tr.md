# Her şeyi kurun (Windows ve Linux/WSL)

Bu sayfa, şablonun betiklerinin kullandığı her aracı kurar ve her birinin gerçekten çalıştığını nasıl kontrol edeceğinizi,
görmeniz gereken çıktıyla birlikte gösterir. Kontrolleri her adımdan sonra çalıştırın; bir şeyin eksik olduğunu sona kadar
beklemeyin.

Kurulum iki numaralı betikle yapılır (aynı numara = aynı iş, platform sonek olarak yazılır):

| Adım | Windows | Linux / WSL |
| --- | --- | --- |
| 3. paket yöneticisi | `3-install-package-manager-windows.bat` (Chocolatey, Scoop) | - (apt zaten var) |
| 4. tüm araçlar | `4-install-tools-windows.bat` (**Yönetici** olarak çalıştırın) | `./4-install-tools-linux.sh` (`sudo` ister) |

> **Eski adlar.** `4-install-windows-enviroment.bat` artık `4-install-tools-windows.bat`, `4-install-wsl-environment.sh`
> artık `4-install-tools-linux.sh`; `6_download_plantuml.bat` ikisinin içine katıldı (PlantUML son adımda indirilir). Eski
> ad -> yeni ad tablosunun tamamı [README](https://github.com/ucoruh/cpp-cmake-ctest-template#old-name---new-name)
> dosyasındadır.

## Windows

### 1. Visual Studio 2022 Community (veya Ninja + MinGW-w64 GCC)

Bir C/C++ derleyicisine ihtiyacınız var. İkisi de çalışır; derleme betikleri hangisine sahip olduğunuzu otomatik algılar
(`scripts\detect-generator-windows.bat`: `vswhere.exe` bulursa Visual Studio, yoksa Ninja + `gcc`/`g++`).

- Visual Studio 2022 Community (ücretsiz): <https://visualstudio.microsoft.com/vs/community/> - kurulumda
  **"Desktop development with C++"** iş yükünü işaretleyin.
- Ya da Chocolatey ile MinGW-w64 GCC + Ninja (3. adım her durumda Ninja ve CMake'i kurar).

Doğrulama:

```bat
"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
```

Beklenen çıktı (yol değişebilir): `C:\Program Files\Microsoft Visual Studio\2022\Community`. Hiçbir şey yazdırmıyorsa Visual
Studio kurulu değildir; `gcc`/`g++` ve `ninja` PATH'te olduğu sürece bu sorun değildir.

### 2. Chocolatey ve Scoop (paket yöneticileri)

`3-install-package-manager-windows.bat` dosyasını çalıştırın. Doğrulama:

```bat
choco --version
```

Beklenen çıktı: bir sürüm numarası, örn. `2.5.0`.

### 3. Geri kalan her şey

Depo klasöründe bir **Yönetici** terminali açın ve `4-install-tools-windows.bat` dosyasını çalıştırın. Şunları kurar (yerinde
yükseltir, yani tekrar çalıştırmak güvenlidir): CMake, Ninja, Doxygen, Graphviz, AStyle, OpenCppCoverage, lcov (`genhtml`),
Strawberry Perl, GitHub CLI (`gh`), Python 3 (yoksa), .NET SDK (yoksa), ReportGenerator global aracı, `requirements.txt`
içindeki Python paketleri (mkdocs-material, coverxygen, junit2html) ve PlantUML (isteğe bağlı).

Her aracı doğrulayın:

```bat
cmake --version
ninja --version
doxygen --version
reportgenerator --version
py -3 -m pip show coverxygen
py -3 -m mkdocs --version
gh --version
```

Beklenen çıktı (sürümler zamanla değişir, ama her komut hata değil bir şey yazdırmalı):

```text
cmake version 3.31.2
1.12.1
1.9.7
Arguments: ...
Name: coverxygen
Version: 1.8.2
mkdocs, version 1.6.1 from ...
gh version 2.x.x
```

**Önemli - `python` ile `py -3` farkı:** birçok makinede düz `python` komutu, bu projenin araçlarının kurulu olduğu Python'dan
*farklı* bir Python'a çıkar (bir yazarın `python` komutu, alakasız bir grafik programıyla gelen ve `coverxygen` içermeyen bir
Python 2.7'ydi). Derleme betikleri bunu sizin yerinize halleder: `scripts\detect-python-windows.bat` sırayla `py -3`,
`python3`, `python` komutlarını `coverxygen` ve `mkdocs` içe aktarabilen biri için dener; hiçbiri yoksa ne çalıştırmanız
gerektiğini söyler. `python -m coverxygen` komutunu kendiniz çalıştırıp `No module named coverxygen` alırsanız
`py -3 -m coverxygen ...` kullanın ya da `pip`'in nereye kurduğunu kontrol edin: `py -3 -m pip show coverxygen`.

### 4. genhtml için Windows'a özgü (native) Perl gerekir

`genhtml` (lcov'dan) uzantısız bir Perl betiğidir; `4-install-tools-windows.bat` onu Strawberry Perl ile birlikte kurar. Git for
Windows ve MSYS2 de PATH'e bir `perl` koyar ama o, Windows yollarını yanlış işler; `scripts\detect-genhtml-windows.bat`
`\usr\bin\` altındaki perl'leri atlar ve Windows'a özgü olanı kullanır. Uygun Perl yoksa lcov raporları derlemeyi
bozmadan, açık bir mesajla atlanır.

```bat
where genhtml
where perl
```

### 5. PlantUML (isteğe bağlı)

PlantUML kullanan Doxygen diyagramları isteğe bağlıdır; `4-install-tools-windows.bat` `plantuml.jar` dosyasını depo köküne
indirir (gitignore'dadır). İndirme başarısız olursa betik bunu söyler ve devam eder - Doxygen o diyagramları atlar.

## Linux / WSL

WSL kurulu değilse önce kurun: yükseltilmiş PowerShell'de `wsl --install`, sonra yeniden başlatın. Ubuntu terminalini açın ve
(WSL'in kendi dosya sisteminde bir klasörden, aşağıya bakın) çalıştırın:

```bash
chmod +x *.sh scripts/*.sh
./4-install-tools-linux.sh
```

`apt` ile şunları kurar: build-essential, cmake, ninja-build, doxygen, graphviz, lcov, astyle, curl, zip, python3, pip; resmî
`dotnet-install.sh` ile **`~/.dotnet` içine kullanıcıya özel, güncel bir .NET SDK** (birçok dağıtım - şablon WSL Ubuntu 20.04'te
denendi - yalnızca .NET 3.1 paketler, güncel ReportGenerator için çok eski); sonra ReportGenerator, `requirements.txt`
içindeki Python paketleri (mkdocs-material, coverxygen, junit2html, gcovr), `gh` (apt'de varsa) ve PlantUML. `~/.dotnet`,
`~/.dotnet/tools` ve `~/.local/bin` klasörlerini `~/.bashrc` içindeki `PATH`'e ekler; sonrasında yeni bir terminal açın (ya da
`source ~/.bashrc`). Derleme betikleri bunları kendileri de PATH'e koyar (`scripts/setup-path-linux.sh`).

Doğrulama:

```bash
cmake --version
doxygen --version
ninja --version
gcc --version
dotnet --version
reportgenerator --version
python3 -c "import coverxygen, mkdocs; print('python tools OK')"
```

Beklenen: gerçek sürüm numaraları, "command not found" yok; `dotnet --version` `10.0.x` gibi bir şey yazdırır (`3.1.x` değil -
`3.1.x` görürseniz yeni bir terminal açın ya da `export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$PATH"` çalıştırın).

### GCC ve gcov eşleşmeli

Bir dağıtımda birden çok GCC sürümü yan yana kurulu olabilir (bir WSL deneme makinesinde gcc-7, gcc-9 *ve* gcc-13 vardı; sürümsüz
`gcc` 9.4.0, ama `/usr/bin/gcov` `update-alternatives` ile gcov-**7**.5.0'a işaret ediyordu). GCC ve `gcov` farklıysa kapsama
sessizce veri üretmez (`geninfo: WARNING: GCOV did not produce any data`, ardından `lcov: ERROR: no valid records found in
tracefile`). `scripts/detect-compiler-linux.sh` (`6-build-and-test-linux.sh` ve `7-build-all-linux.sh` kullanır) aynı sürümlü
`gcov`'u olan en yeni GCC'yi seçer ve hangi çifti seçtiğini yazdırır.

### WSL, Google Drive yolunu göremez

Klonunuz bir Google Drive yolundaysa (`G:\My Drive\...`) WSL ona erişemez:

```text
wsl: Failed to translate 'G:\My Drive\...'
```

Depoyu WSL'in kendi dosya sistemine (ya da yerel bir `C:\` yoluna) kopyalayın ve `.sh` betiklerini oradan çalıştırın:

```bash
mkdir -p ~/work && cp -r "/mnt/c/path/to/your-repo" ~/work/
cd ~/work/your-repo
./7-build-all-linux.sh
```

## Sonraki adım

[Şablonu kullanma](use-template.md) sayfasıyla devam edin.
