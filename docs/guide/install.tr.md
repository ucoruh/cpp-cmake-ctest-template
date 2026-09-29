# Her şeyi kurun (Windows ve Linux/WSL)

Bu sayfa, şablonun betiklerinin kullandığı her aracı kurar ve her birinin gerçekten çalıştığını nasıl
kontrol edeceğinizi, görmeniz gereken çıktıyla birlikte gösterir. Kontrolleri her adımdan sonra
çalıştırın; bir şeyin eksik olduğunu sona kadar beklemeyin.

## Windows

### 1. Visual Studio 2022 Community (veya Ninja + MinGW-w64 GCC)

Bir C/C++ derleyicisine ihtiyacınız var. İkisi de çalışır; derleme betikleri hangisine sahip
olduğunuzu otomatik algılar (`detect-generator.bat`: `vswhere.exe` bulursa Visual Studio, yoksa
Ninja + `gcc`/`g++`).

- Visual Studio 2022 Community (ücretsiz): <https://visualstudio.microsoft.com/vs/community/> -
  kurulumda **"Desktop development with C++"** iş yükünü işaretleyin.
- Ya da Chocolatey ile MinGW-w64 GCC + Ninja (aşağıdaki 4. adım her hâlükârda Ninja ve CMake'i kurar).

Doğrulama:

```bat
"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
```

Beklenen çıktı (yol değişebilir): `C:\Program Files\Microsoft Visual Studio\2022\Community`

Bu hiçbir şey yazdırmıyorsa Visual Studio kurulu değildir; `gcc`/`g++` ve `ninja` PATH'te olduğu
sürece bu sorun değildir (bkz. 4. adım).

### 2. Chocolatey ve Scoop (paket yöneticileri)

`3-install-package-manager.bat` dosyasını çalıştırın. Henüz kurulu değilse
[Chocolatey](https://chocolatey.org/) (ve Scoop) kurar.

Doğrulama:

```bat
choco --version
```

Beklenen çıktı: bir sürüm numarası, örn. `2.3.0`.

### 3. Geri kalan her şey

`4-install-windows-enviroment.bat` dosyasını (Yönetici olarak, çünkü `choco install` kullanır)
çalıştırın. Şunları kurar: CMake, Ninja, Doxygen, `dotnet-reportgenerator-globaltool`, OpenCppCoverage,
`coverxygen` (bir Python paketi), lcov (`genhtml` için), Pandoc, Graphviz, Python, MikTeX, curl,
MARP-CLI ve mkdocs Python paketleri.

Her aracı doğrulayın:

```bat
cmake --version
ninja --version
doxygen --version
reportgenerator --version
py -3 -m pip show coverxygen
```

Beklenen çıktı (sürümler zamanla değişir, ama her komut hata değil bir şey yazdırmalı):

```text
cmake version 3.31.2
1.12.1
1.9.7
2026-09-29T22:36:30: Arguments
...
Name: coverxygen
Version: 1.8.2
```

**Önemli - `python` ile `py -3` farkı:** birçok makinede, PATH'teki düz `python` komutu bu projenin
araçlarının kurulu olduğu Python'dan *farklı* bir Python'a işaret eder (bu şablonun yazarı bunu bizzat
yaşadı: `python`, ilgisiz bir grafik uygulamasıyla gelen, `coverxygen` içermeyen bir Python 2.7'ye
işaret ediyordu). Derleme betikleri bunu sizin için zaten hallediyor (`detect-python.bat`; sırayla
`py -3`, `python3`, `python`'ı dener ve `coverxygen` içe aktarılabilen ilkini kullanır; hiçbiri
olmazsa tam olarak ne çalıştırmanız gerektiğini söyler). `python -m coverxygen` komutunu kendiniz
çalıştırıp `No module named coverxygen` hatası alırsanız, onun yerine `py -3 -m coverxygen ...`
kullanın, ya da `pip install`'ınızın gerçekte nereye gittiğini kontrol edin:

```bat
py -3 -m pip show coverxygen
```

### 4. genhtml için Perl gerekir

`genhtml` (lcov'dan) dosya uzantısı olmayan bir Perl betiğidir; `choco install lcov -y` onu kurar,
ama çalıştırmak için `strawberryperl` (ya da herhangi bir Perl) de PATH'te olmalıdır - derleme
betikleri bunu `detect-genhtml.bat` ile algılar ve Perl yoksa tüm derlemeyi başarısız kılmak yerine
yalnızca o native raporu net bir mesajla atlar.

```bat
where genhtml
where perl
```

### 5. PlantUML (isteğe bağlı)

PlantUML kullanan Doxygen diyagramları isteğe bağlıdır; `6_download_plantuml.bat` çalıştırılmamışsa
otomatik olarak atlanır (hata vermez - bkz. `docs/guide/troubleshooting.tr.md`). Bu diyagramları
istiyorsanız bir kez çalıştırın:

```bat
6_download_plantuml.bat
```

## Linux / WSL

Henüz kurmadıysanız önce WSL'i kurun: yönetici olarak açılmış bir PowerShell'de `wsl --install`,
ardından yeniden başlatın. Ubuntu terminalini açın ve çalıştırın:

```bash
chmod +x 4-install-wsl-environment.sh
./4-install-wsl-environment.sh
```

Bu (`apt` ile) şunları kurar: astyle, ninja-build, cmake, doxygen, pandoc, `librsvg2-bin`, python3,
curl, graphviz, lcov; (`pip` ile): mkdocs ve eklentileri, `coverxygen`, `junit2html`; ve - **yeni** -
resmi `dotnet-install.sh` betiği ile `~/.dotnet` içine kullanıcı bazlı, güncel bir .NET SDK, çünkü
birçok dağıtım (bu şablon WSL Ubuntu 20.04'e karşı test edildi) yalnızca çok eski bir .NET (3.1)
paketler ve bu, güncel `dotnet-reportgenerator-globaltool`'u çalıştıramaz (.NET 10 gerektirir). Betik
`~/.dotnet` ve `~/.dotnet/tools`'u otomatik olarak `~/.bashrc` içindeki `PATH`'e ekler; ardından yeni
bir terminal açın (ya da `source ~/.bashrc` çalıştırın).

Doğrulama:

```bash
cmake --version
doxygen --version
ninja --version
gcc --version
dotnet --version
reportgenerator --version
python3 -c "import coverxygen; print('coverxygen OK')"
```

Beklenen çıktı, "command not found" içermeyen gerçek sürüm numaraları olmalı ve `dotnet --version`
için `10.0.401` gibi bir şey görmelisiniz (`3.1.x` görürseniz, kurulum betiğindeki PATH değişikliğinin
etkili olması için yeni bir terminal açın, ya da kendiniz
`export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$PATH"` çalıştırın).

### GCC ve gcov sürümleri eşleşmelidir

Bir dağıtımda yan yana birden fazla GCC sürümü kurulu olabilir (bu şablonun WSL test makinesinde
gcc-7, gcc-9 *ve* gcc-13 vardı; sürümsüz varsayılan `gcc` 9.4.0'a işaret ederken `/usr/bin/gcov`,
`update-alternatives` ile gcov-**7**.5.0'a işaret ediyordu). GCC ve `gcov` farklı sürümlerse, kod
kapsama verisi sessizce boş üretilir (`geninfo: WARNING: GCOV did not produce any data`, ardından
`lcov: ERROR: no valid records found in tracefile`). `7-build-app-linux.sh` sizin için zaten eşleşen
bir GCC/`gcov` çifti seçer (mevcut olanların en yenisini tercih ederek; test makinesinde
`gcc-13`/`gcov-13`) ve hangisini seçtiğini yazdırır; `gcov`'u kendiniz elle çalıştırırsanız önce
sürümlerin uyduğunu kontrol edin:

```bash
gcc --version | head -1
gcov --version | head -1
```

### WSL bir Google Drive yolunu göremez

Klonunuz Google Drive ile senkronize bir Windows yolunda yaşıyorsa (örn.
`G:\My Drive\...\cpp-cmake-ctest-template`), WSL oraya hiç ulaşamaz:

```text
wsl: Failed to translate 'G:\My Drive\...'
```

Depoyu önce WSL'in kendi dosya sistemindeki bir yola (ya da herhangi bir yerel `C:\` yoluna)
kopyalayın ve `.sh` betiklerini oradan çalıştırın:

```bash
mkdir -p ~/work && cp -r "/mnt/c/yol/cpp-cmake-ctest-template" ~/work/
cd ~/work/cpp-cmake-ctest-template
./7-build-app-linux.sh
```

## Sıradaki adım

Bu şablonu kendi projenize dönüştürmek için [use-template.tr.md](use-template.tr.md) ile devam edin.
