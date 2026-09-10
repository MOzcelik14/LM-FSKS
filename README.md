# LM-FSKS

Linux Mint kurulumu sonrasında sistemi hızlıca kişiselleştirmek, gerekli uygulamaları kurmak ve performans ayarlarını yapmak için hazırlanmış kurulum betiği.

## Özellikler

Betik aşağıdaki işlemleri otomatik olarak gerçekleştirir:

* GRUB kernel parametrelerini ekler

  * `acpi_backlight=native`
  * `nvme_core.default_ps_max_latency_us=0`
* Gereksiz varsayılan uygulamaları kaldırır

  * Thunderbird
  * Transmission
  * Warpinator
  * Rhythmbox
* Fastfetch PPA'sını ekler
* Temel uygulamaları kurar:

  * Fish
  * Steam
  * Wine
  * Winetricks
  * Audacious
  * Fastfetch
  * btop
  * rar / unrar
* **Sidra** `.deb` paketini GitHub Releases üzerinden indirip kurar
* Fish shell'i varsayılan shell yapar
* Starship prompt'u kurar
* Flatpak uygulamalarını kurar:

  * Kdenlive
  * Audacity
  * Tube Converter
  * ONLYOFFICE
  * ProtonUp-Qt
  * Spotify
  * Heroic Games Launcher
* Wine için gerekli bileşenleri kurar:

  * .NET 4.x
  * Visual C++ 2022
  * Visual C++ 6 SP6
  * Core Fonts
* DXVK 2.0.3 kurar
* zRAM yapılandırır
* 4 GB swapfile oluşturur
* Swappiness değerini `4` olarak ayarlar
* Fish yapılandırmasını oluşturur
* Fastfetch için özel konfigürasyon oluşturur

## Kullanım

Öncelikle betiği çalıştırılabilir hale getir:

```bash
chmod +x install.sh
```

Ardından çalıştır:

```bash
./install.sh
```

Betik sırasında `sudo` gerektiğinde şifreni isteyecektir.

## Gereksinimler

* Linux Mint
* İnternet bağlantısı
* `sudo` yetkisi
* x86_64 / amd64 sistem

Flatpak'ın sistemde kurulu ve Flathub deposunun eklenmiş olması gerekir.

## Kurulum Sonrası

Kurulum tamamlandığında sistemin yeniden başlatılması önerilir:

```bash
reboot
```

Yeniden başlatma sonrasında Fish ve Starship aktif olacak, terminal açıldığında Fastfetch otomatik olarak çalışacaktır.

## Bellek Yapılandırması

Script iki farklı swap mekanizması kullanır.

### zRAM

* Algoritma: `zstd`
* RAM'in `%50`'si
* Öncelik: `100`

### Disk swap

* Boyut: `4 GB`
* Öncelik: sistem varsayılanı

Swappiness:

```text
vm.swappiness = 4
```

Kurulumdan sonra kontrol etmek için:

```bash
free -h
swapon --show
zramctl
cat /proc/sys/vm/swappiness
```

## Wine / Gaming

Wine ortamı özellikle Windows uygulamaları ve oyunları için temel bileşenlerle hazırlanır.

Kurulan bileşenler:

```text
dotnet40
dotnet45
dotnet48
vcrun2022
vcrun6sp6
corefonts
dxvk2030
```

## Fastfetch

Fastfetch yapılandırması:

```text
~/.config/fastfetch/config.jsonc
```

Logo:

```text
~/.config/fastfetch/marin.png
```

> `marin.png` dosyasının ilgili konumda bulunması gerekir.

## Fish Alias'ları

Kurulumdan sonra aşağıdaki kısa komutlar kullanılabilir:

| Komut      | İşlev                       |
| ---------- | --------------------------- |
| `güncelle` | APT ve Flatpak güncellemesi |
| `temizle`  | Gereksiz paketleri temizler |
| `yükle`    | APT paketi kurar            |
| `fyükle`   | Flatpak kurar               |
| `sil`      | APT paketi kaldırır         |
| `fsil`     | Flatpak kaldırır            |
| `kapa`     | Sistemi kapatır             |
| `söyle`    | `echo` kısayolu             |

## Lisans

Bu script kişisel kullanım amacıyla hazırlanmıştır. İstediğiniz gibi değiştirebilir ve geliştirebilirsiniz.

