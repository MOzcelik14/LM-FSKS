#!/bin/bash

set -e

# ------------------------------------------------------------------
# Renkler ve yardımcı yazdırma fonksiyonları
# ------------------------------------------------------------------
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'

# Genişliği ekrana göre otomatik ayarlar, bulunamazsa 60 kullanır
TERM_WIDTH=$(tput cols 2>/dev/null || echo 60)
LINE_WIDTH=$(( TERM_WIDTH < 70 ? TERM_WIDTH : 70 ))

hr() {
  printf "${DIM}%${LINE_WIDTH}s${RESET}\n" | tr ' ' '─'
}

section() {
  local title="$1"
  local color="${2:-$CYAN}"
  echo
  hr
  printf "${BOLD}${color} %s ${RESET}\n" "$title"
  hr
  echo
}

info() {
  printf "${BLUE}➜${RESET} %s\n" "$1"
}

success() {
  printf "${GREEN}✔${RESET} %s\n" "$1"
}

warn() {
  printf "${YELLOW}⚠${RESET} %s\n" "$1"
}

step_pause() {
  echo
  printf "${DIM}%s${RESET}" "$1"
  read -r
  echo
}

# ------------------------------------------------------------------
# Karşılama
# ------------------------------------------------------------------
clear
echo -e "${BOLD}${MAGENTA}"
cat << 'BANNER'
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ 
▀▀█  █        █ 
  █  █  █  █  █ 
  █  █  █  █  █ 
  █  █  █  █  █ 
  █  ▀▀▀▀▀▀▀  █ 
  ▀▀▀▀▀▀▀▀▀▀▀▀▀
BANNER
echo -e "${RESET}"
printf "${BOLD}== M. Özçelik LM Format Sonrası Kurulum Scripti ==${RESET}\n\n"
echo "M. Özçelik FSKS'ye hoşgeldiniz."
echo
echo "Bu script, Linux Mint kurulumundan sonra sistemi hızlı, düzenli ve"
echo "kullanıma hazır hale getirmek için gerekli uygulamaları, araçları ve"
echo "kişisel sistem ayarlarını otomatik olarak yapılandırır. Paket kurulumu,"
echo "gereksiz bileşenlerin temizlenmesi, terminal ve performans ayarları,"
echo "Flatpak uygulamaları ve çeşitli kullanıcı özelleştirmeleri tek bir"
echo "işlem altında gerçekleştirilir."

step_pause "Başlamak için Enter tuşuna basınız..."

# ------------------------------------------------------------------
# GRUB
# ------------------------------------------------------------------
section "GRUB PARAMETRELERİ EKLENİYOR" "$YELLOW"

info "acpi_backlight=native ve nvme_core.default_ps_max_latency_us=0 ekleniyor..."
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 intel_pstate=no_turbo acpi_backlight=native nvme_core.default_ps_max_latency_us=0"/' /etc/default/grub
sudo update-grub
success "GRUB güncellendi."

# ------------------------------------------------------------------
# Paketler
# ------------------------------------------------------------------
section "GEREKSİZ BİLEŞENLER KALDIRILIYOR VE YENİ PAKETLER KURULUYOR" "$RED"

info "NetworkManager-wait-online devre dışı bırakılıyor..."
sudo systemctl disable NetworkManager-wait-online.service

info "Paket listeleri güncelleniyor..."
sudo apt update

info "Gereksiz uygulamalar kaldırılıyor: firefox, thunderbird, transmission-gtk, hypnotix, warpinator, rhythmbox"
sudo apt purge -y firefox thunderbird transmission-gtk hypnotix warpinator rhythmbox
sudo apt autoremove --purge -y
success "Temizlik tamamlandı."

info "Fastfetch PPA'sı ekleniyor..."
sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
sudo apt update

info "Yeni paketler kuruluyor: numlockx, fish, steam, wine, winetricks, audacious, fastfetch, btop, rar, unrar, tlp, tlp-rdw"
sudo apt install -y numlockx fish steam wine winetricks audacious fastfetch btop rar unrar tlp tlp-rdw
success "Paket kurulumu tamamlandı."

info "Sidra indiriliyor..."
wget -q --show-progress \
  "https://github.com/wimpysworld/sidra/releases/download/0.4.1/Sidra-0.4.1-linux-amd64.deb" \
  -O /tmp/sidra.deb
sudo apt install -y /tmp/sidra.deb
rm -f /tmp/sidra.deb
success "Sidra kuruldu."

info "DAMX (Div Acer Manager Max) indiriliyor ve kuruluyor..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

DOWNLOAD_URL=$(curl -s https://api.github.com/repos/PXDiv/Div-Acer-Manager-Max/releases/latest \
    | grep '"browser_download_url"' \
    | grep -E '\.tar\.xz"' \
    | head -1 \
    | cut -d '"' -f 4)

curl -L "$DOWNLOAD_URL" -o damx.tar.xz
tar -xJf damx.tar.xz

cd "$(find . -maxdepth 1 -type d -name 'DAMX-*' | head -1)"
chmod +x setup.sh
sudo ./setup.sh

cd /
rm -rf "$TMP_DIR"
success "DAMX kuruldu."

info "JetBrainsMono Nerd Font indiriliyor..."
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont && \
curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -o /tmp/JetBrainsMono.zip && \
unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerdFont && \
fc-cache -fv > /dev/null
success "Font kuruldu."

# ------------------------------------------------------------------
# Shell
# ------------------------------------------------------------------
section "SHELL AYARLANIYOR" "$GREEN"

info "Varsayılan shell fish olarak ayarlanıyor..."
chsh -s /usr/bin/fish

info "Starship prompt kuruluyor..."
curl -sS https://starship.rs/install.sh | sh -s -- -y
success "Shell ayarları tamamlandı."

# ------------------------------------------------------------------
# Flatpak
# ------------------------------------------------------------------
section "FLATPAK UYGULAMALARI" "$CYAN"

info "Flatpak uygulamaları kuruluyor..."
flatpak install flathub -y \
  org.kde.kdenlive \
  app.zen_browser.zen \
  org.audacityteam.Audacity \
  org.nickvision.tubeconverter \
  org.onlyoffice.desktopeditors \
  net.davidotek.pupgui2 \
  com.google.AndroidStudio \
  com.heroicgameslauncher.hgl
success "Flatpak uygulamaları kuruldu."

# ------------------------------------------------------------------
# Winetricks
# ------------------------------------------------------------------
section "Winetricks Dağıtılabilirleri kuruluyor..." "$MAGENTA"

info "dotnet40, dotnet45, dotnet48, vcrun2022, vcrun6sp6, corefonts, dxvk2030 kurulacak..."
winetricks -q dotnet40 dotnet45 dotnet48 vcrun2022 vcrun6sp6 corefonts dxvk2030
success "Winetricks kurulumu tamamlandı."

# ------------------------------------------------------------------
# ZRAM / Swap
# ------------------------------------------------------------------
section "ZRAM VE SWAPFILE KONFİGÜRASYONLARI" "$YELLOW"

info "zram-tools kuruluyor..."
sudo apt install -y zram-tools

info "zRAM yapılandırılıyor (zstd, %50, öncelik 100)..."
sudo tee /etc/default/zramswap >/dev/null <<EOF
ALGO=zstd
PERCENT=50
PRIORITY=100
EOF

sudo systemctl enable zramswap
sudo systemctl restart zramswap
success "zRAM etkinleştirildi."

info "Swap dosyası 4 GB olarak yeniden oluşturuluyor..."
sudo swapoff /swapfile 2>/dev/null || true
sudo rm -f /swapfile
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

sudo sed -i '\|^/swapfile|d' /etc/fstab
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null
success "Swap dosyası hazır."

info "Swappiness değeri 4 olarak ayarlanıyor..."
echo "vm.swappiness=4" | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null
sudo sysctl --system > /dev/null
success "Swappiness ayarlandı."

section "BELLEK DURUMU" "$CYAN"
free -h
echo
printf "${BOLD}Aktif swap alanları:${RESET}\n"
swapon --show
echo
printf "${BOLD}zRAM durumu:${RESET}\n"
zramctl
echo
printf "${BOLD}Swappiness değeri:${RESET} %s\n" "$(cat /proc/sys/vm/swappiness)"

# ------------------------------------------------------------------
# Fish yapılandırması
# ------------------------------------------------------------------
section "FISH YAPILANDIRILIYOR" "$GREEN"

mkdir -p ~/.config/fish

cat > ~/.config/fish/config.fish <<'EOF'
if status is-interactive
    echo " "
    set_color normal

    # Fastfetch
    fastfetch

    echo
end

# Starship
starship init fish | source

alias güncelle='sudo apt update || true && sudo apt upgrade -y && flatpak update'
alias temizle='sudo apt autoremove && sudo apt autoclean -y && flatpak uninstall --unused'
alias yükle='sudo apt install'
alias fyükle='flatpak install'
alias sil='sudo apt remove'
alias fsil='flatpak remove'
alias kapa='poweroff'
alias söyle='echo'
EOF
success "Fish yapılandırması tamamlandı."

# ------------------------------------------------------------------
# Fastfetch yapılandırması
# ------------------------------------------------------------------
section "FASTFETCH YAPILANDIRILIYOR" "$BLUE"

mkdir -p ~/.config/fastfetch

cat > ~/.config/fastfetch/config.jsonc <<'EOF'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json",
  "display": {
    "key": {
      "width": 10
    },
    "size": {
      "binaryPrefix": "jedec"
    },
    "separator": ""
  },
  "logo": {
    "type": "kitty-direct",
    "source": "~/.config/fastfetch/marin.png",
    "width": 20,
    "height": 10
  },
  "modules": [
    "break",
    {
      "type": "os",
      "key": "is",
      "keyColor": "yellow",
      "format": "{name}"
    },
    {
      "type": "kernel",
      "key": "lnx",
      "keyColor": "green"
    },
    {
      "type": "packages",
      "key": "pkgs",
      "keyColor": "cyan"
    },
    {
      "type": "uptime",
      "key": "çs",
      "keyColor": "green"
    },
    {
      "type": "cpu",
      "key": "mib",
      "keyColor": "red",
      "format": "{name}"
    },
    {
      "type": "gpu",
      "key": "gib",
      "keyColor": "red",
      "format": "{name}"
    },
    {
      "type": "memory",
      "key": "ram",
      "keyColor": "yellow",
      "format": "{used} / {total}"
    },
    {
      "type": "swap",
      "key": "swp-zram",
      "keyColor": "yellow",
      "format": "{used} / {total}"
    },
    {
      "type": "disk",
      "key": "dep",
      "keyColor": "cyan",
      "folders": [
        "/"
      ],
      "format": "{size-used} / {size-total}"
    },
    "break",
    {
      "type": "custom",
      "format": "\u001b[33m󰮯 \u001b[32m󰊠 \u001b[34m󰊠 \u001b[31m󰊠 \u001b[36m󰊠 \u001b[35m󰊠 \u001b[37m󰊠 \u001b[97m󰊠"
    }
  ]
}
EOF
success "Fastfetch yapılandırması tamamlandı."

# ------------------------------------------------------------------
# TLP
# ------------------------------------------------------------------
section "TLP GÜÇ VE PERFORMANS KONFİGÜRASYONLARI" "$RED"

cat << 'EOF' | sudo tee /etc/tlp.conf > /dev/null
# ------------------------------------------------------------------------------
# /etc/tlp.conf - TLP Acer Nitro 5 (i5-12450H) Özel Güç Ayarları
# ------------------------------------------------------------------------------

# TLP Güç Yöneticisini Aktif Et
TLP_ENABLE=1
TLP_WARN_LEVEL=3
TLP_DEFAULT_MODE=AC
TLP_PERSISTENT_DEFAULT=0

# Sürücü Ayarları
CPU_DRIVER_OPMODE_ON_AC=active
CPU_DRIVER_OPMODE_ON_BAT=active
CPU_SCALING_GOVERNOR_ON_AC=powersave
CPU_SCALING_GOVERNOR_ON_BAT=powersave

# İşlemci Güç Politikası (Sakin ve Dengeli Mod)
CPU_ENERGY_PERF_POLICY_ON_AC=balance_power
CPU_ENERGY_PERF_POLICY_ON_BAT=power

# İşlemci Performans Sınırları (%80 Güç Tavanı)
CPU_MIN_PERF_ON_AC=0
CPU_MAX_PERF_ON_AC=80
CPU_MIN_PERF_ON_BAT=0
CPU_MAX_PERF_ON_BAT=60

# Turbo Boost'u Tamamen Kapat (Ani Watt Fırlamasını Engeller)
CPU_BOOST_ON_AC=0
CPU_BOOST_ON_BAT=0

# Dinamik Akıllı Güç Patlamalarını Kapat
CPU_HWP_DYN_BOOST_ON_AC=0
CPU_HWP_DYN_BOOST_ON_BAT=0
NMI_WATCHDOG=0

# Acer Anakart Profili (Prizde Sessiz Mod, Pilde Tasarruf)
PLATFORM_PROFILE_ON_AC=quiet
PLATFORM_PROFILE_ON_BAT=low-power

# Disk ve Laptop Modu Senkronizasyon Ayarları
DISK_IDLE_SECS_ON_AC=0
DISK_IDLE_SECS_ON_BAT=2
MAX_LOST_WORK_SECS_ON_AC=15
MAX_LOST_WORK_SECS_ON_BAT=60
EOF

sudo systemctl enable tlp
sudo tlp start
success "TLP yapılandırması tamamlandı."

# ------------------------------------------------------------------
# Bitiş
# ------------------------------------------------------------------
echo
hr
printf "${BOLD}${GREEN}   ✔ KURULUM TAMAMLANDI   ${RESET}\n"
hr
echo
printf "${YELLOW}Kurulum tamamlandı. Sistemi yeniden başlatmanız önerilir. İyi günler!${RESET}\n"

step_pause "Çıkmak için Enter tuşuna basınız..."
