# API belgeleri

API başvurusu, kaynak koddaki yorumlardan **Doxygen** ile üretilir (sınıflar, işlevler, ad alanları, çağrı ve include
grafikleri). **Windows** ve **Linux** için ayrı ayrı üretilir - ikisi farklılaşabilir (derleyiciye özgü kod, platform
makroları) - ve her birinin iki bölümü vardır: kütüphaneler ve birim test kaynakları.

<div class="grid cards" markdown>

-   :material-microsoft-windows: **Doxygen - Windows**

    ---

    Kütüphaneler (`utility`, `calculator`, `calculatorapp`) ve googletest kaynakları, `7-build-all-windows.bat` ile üretilir.

    [:octicons-arrow-right-24: Windows API belgelerini aç](../reports/windows/api-doxygen.md)

-   :material-linux: **Doxygen - Linux**

    ---

    Aynısı Linux için (yerel Linux ve WSL), `./7-build-all-linux.sh` ile üretilir.

    [:octicons-arrow-right-24: Linux API belgelerini aç](../reports/linux/api-doxygen.md)

</div>

Belge kapsama (kaç genel sembolün yorumu var) bir *rapordur*, API belgesi değildir: bkz.
[Hangi rapor hangisi?](../reports/index.md).
