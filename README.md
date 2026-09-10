# M. Özçelik | LM-FSKS

Linux Mint kurulumundan hemen sonra çalıştırılmak üzere hazırlanmış, sistemi hızlı ve kullanıma hazır hale getiren otomatik kurulum ve yapılandırma scripti.

## Ne Yapar?

Script sırasıyla şu işlemleri gerçekleştirir:

### 1. GRUB Parametreleri
- `acpi_backlight=native` ve `nvme_core.default_ps_max_latency_us=0` parametrelerini `GRUB_CMDLINE_LINUX_DEFAULT` içine ekler ve `update-grub` çalıştırır.

### 2. Paket Temizliği ve Kurulumu
- `NetworkManager-wait-online` servisini devre dışı bırakır.
- Gereksiz varsayılan uygulamaları kaldırır: `firefox`, `thunderbird`, `transmission-gtk`, `hypnotix`, `warpinator`, `rhythmbox`.
- Fastfetch PPA'sını (`ppa:zhangsongcui3371/fastfetch`) ekler.
- Yeni paketleri kurar: `numlockx`, `fish`, `steam`, `wine`, `winetricks`, `audacious`, `fastfetch`, `btop`, `rar`, `unrar`, `tlp`, `tlp-rdw`.
- GitHub üzerinden **Sidra** (`.deb`) indirir ve kurar.
- GitHub Releases API'sini kullanarak en güncel **DAMX (Div Acer Manager Max)** sürümünü indirir ve kurar.
- **JetBrainsMono Nerd Font**'u indirip `~/.local/share/fonts` altına kurar.

### 3. Shell Ayarları
- Varsayılan shell'i `fish` olarak ayarlar (`chsh`).
- **Starship** prompt'u kurar.

### 4. Flatpak Uygulamaları
Flathub üzerinden şu uygulamaları kurar:
- Kdenlive, Zen Browser, Audacity, TubeConverter, OnlyOffice, ProtonUp-Qt, Android Studio, Heroic Games Launcher.

### 5. Winetricks
Wine üzerinde aşağıdaki bileşenleri kurar:
- `dotnet40`, `dotnet45`, `dotnet48`, `vcrun2022`, `vcrun6sp6`, `corefonts`, `dxvk2030`.

### 6. zRAM ve Swap
- `zram-tools` kurar, zRAM'i `zstd` algoritması, `%50` bellek oranı ve `100` öncelik ile yapılandırır.
- Mevcut swap dosyasını kaldırıp 4 GB'lık yeni bir `swapfile` oluşturur ve `/etc/fstab`'a ekler.
- `vm.swappiness` değerini `4` olarak ayarlar.
- İşlem sonunda bellek/swap/zRAM durumunu ekrana yazdırır.

### 7. Fish Yapılandırması
`~/.config/fish/config.fish` dosyasını oluşturur:
- Etkileşimli oturum açılışında `fastfetch` çalıştırır.
- `starship` prompt'unu başlatır.
- Türkçe kısayol alias'ları tanımlar: `güncelle`, `temizle`, `yükle`, `fyükle`, `sil`, `fsil`, `kapa`, `söyle`.

### 8. Fastfetch Yapılandırması
`~/.config/fastfetch/config.jsonc` dosyasını Türkçe kısaltılmış anahtar isimleri (`is`, `lnx`, `pkgs`, `çs`, `mib`, `gib`, `ram`, `swp-zram`, `dep`) ve renkli bir alt modül ile oluşturur.

### 9. TLP Güç Yönetimi
Acer Nitro 5 (i5-12450H) için özel olarak ayarlanmış `/etc/tlp.conf` dosyası oluşturur:
- CPU governor: `powersave`, enerji-performans politikası dengeli/güç odaklı.
- AC'de %80, pilde %60 performans tavanı.
- Turbo Boost ve dinamik güç patlamaları (HWP dynamic boost) kapalı.
- Platform profili: prizde `quiet`, pilde `low-power`.
- Disk boşta kalma ve laptop modu senkron ayarları.

## Gereksinimler

- Yeni kurulmuş bir **Linux Mint** sistemi.
- İnternet bağlantısı (paket indirmeleri ve GitHub/Flathub erişimi için).
- `sudo` yetkisi.

## Kullanım

### Yerel Çalıştırma

```bash
chmod +x FSKS.sh
./FSKS.sh
```

### Uzaktan Çalıştırma (GitHub'dan direkt)

Repoyu klonlamadan, tek satırla doğrudan çalıştırmak için:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/MOzcelik14/LM-FSKS/main/FSKS.sh)
```

> **Neden `bash <(curl ...)` ve düz `curl | bash` değil?**
> Script içinde `step_pause` fonksiyonu `read -r` ile kullanıcıdan Enter beklediği için, klasik `curl ... | bash` pipe yönteminde stdin curl'e bağlı kalabilir ve bu bekleme adımları çalışmayabilir. Process substitution (`<(...)`) kullanmak, script'i gerçek bir dosyaymış gibi çalıştırır ve stdin'i (Enter beklemeleri, sudo şifre sorması) normal terminale bağlı tutar.

Script, başlangıçta ve sonunda kullanıcıdan Enter tuşuna basmasını bekler (`step_pause`), böylece hangi aşamada olduğunuzu takip edebilirsiniz.

## Önemli Notlar

- Script `set -e` ile çalıştığı için herhangi bir komut hata verirse işlem durur.
- TLP ve GRUB ayarları donanıma özeldir (Acer Nitro 5 AN515-58); farklı bir cihazda kullanmadan önce `CPU_MAX_PERF_ON_AC/BAT` ve platform profili değerlerini gözden geçirin.
- Script bazı varsayılan uygulamaları (Firefox, Thunderbird vb.) kaldırdığı için geri dönüşü olmayan bir temizlik yapar; çalıştırmadan önce ihtiyacınız olmadığından emin olun.
- Kurulum sonunda sistemi yeniden başlatmanız önerilir.

## Lisans

Kişisel kullanım için hazırlanmıştır. Dilediğiniz gibi kendi ihtiyaçlarınıza göre derleyebilirsiniz.
