#!/bin/bash
# hornear-v00.sh — ISO mínima: Debian sid + XFCE + Calamares. Sin identidad.
# Uso: sudo ./tools/hornear-v00.sh
set -euo pipefail

WORK_DIR="${WORK_DIR:-/home/manuel/tobixu-v00}"
FECHA="$(date +%Y%m%d)"
ISO_NOMBRE="tobixu-v00-${FECHA}-amd64.iso"

[ "$(id -u)" -eq 0 ] || { echo "Corre con sudo"; exit 1; }

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"
LOG="${WORK_DIR}/build-v00-$(date +%Y%m%d-%H%M).log"
exec > >(tee -a "$LOG") 2>&1

echo "=== hornear v0.0 — $(date) ==="
echo "WORK_DIR=$WORK_DIR"

# --- Limpieza total ---
lb clean --all 2>/dev/null || true
rm -rf config chroot binary* live-image-*.iso .build "$ISO_NOMBRE" SHA256SUMS*

# --- lb config ---
lb config \
  --distribution sid \
  --archive-areas "main contrib non-free non-free-firmware" \
  --binary-images iso-hybrid \
  --bootappend-live "boot=live components quiet splash username=user" \
  --debian-installer false \
  --memtest none \
  --iso-application "TobiXu" \
  --iso-publisher "TobiXu Project" \
  --iso-volume "TobiXu v0.0" \
  --linux-flavours amd64 \
  --apt-recommends false

# --- Estructura base ---
mkdir -p config/package-lists
mkdir -p config/hooks/normal
mkdir -p config/includes.chroot/etc/lightdm/lightdm.conf.d
mkdir -p config/includes.chroot/etc/skel

# ============================================================
# LISTAS DE PAQUETES
# ============================================================
cat > config/package-lists/00-base.list.chroot <<'EOF'
linux-image-amd64
live-boot
live-config
live-config-systemd
systemd-sysv
sudo
locales
console-setup
keyboard-configuration
tzdata
ca-certificates
curl
wget
nano
vim-tiny
less
man-db
rsync
openssh-client
zstd
xz-utils
EOF

cat > config/package-lists/10-firmware.list.chroot <<'EOF'
firmware-linux
firmware-iwlwifi
firmware-realtek
firmware-atheros
EOF

cat > config/package-lists/20-red.list.chroot <<'EOF'
network-manager
network-manager-applet
nm-connection-editor
wireless-tools
wpasupplicant
rfkill
EOF

cat > config/package-lists/30-xfce.list.chroot <<'EOF'
xserver-xorg
xserver-xorg-core
xserver-xorg-input-all
xserver-xorg-video-all
xfce4
xfce4-goodies
xfce4-terminal
thunar
lightdm
lightdm-gtk-greeter
dbus-x11
xinit
xfce-polkit
EOF

cat > config/package-lists/40-audio.list.chroot <<'EOF'
pipewire
pipewire-pulse
pipewire-alsa
wireplumber
alsa-utils
pavucontrol
EOF

cat > config/package-lists/50-instalador.list.chroot <<'EOF'
calamares
calamares-settings-debian
EOF

cat > config/package-lists/60-utilidades.list.chroot <<'EOF'
firefox-esr
mousepad
ristretto
file-roller
galculator
gvfs-backends
EOF

# ============================================================
# CONFIGURACIÓN PERSISTENTE (includes.chroot)
# ============================================================
mkdir -p config/includes.chroot/etc

echo "tobixu" > config/includes.chroot/etc/hostname

cat > config/includes.chroot/etc/hosts <<'EOF'
127.0.0.1   localhost
127.0.1.1   tobixu
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

cat > config/includes.chroot/etc/environment <<'EOF'
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
EOF

cat > config/includes.chroot/etc/lightdm/lightdm.conf.d/50-tobixu-autologin.conf <<'EOF'
[Seat:*]
autologin-user=user
autologin-user-timeout=0
autologin-session=xfce
EOF

# --- Regla polkit: usuario live del grupo sudo eleva sin prompt ---
mkdir -p config/includes.chroot/etc/polkit-1/rules.d
cat > config/includes.chroot/etc/polkit-1/rules.d/49-tobixu-live.rules <<'EOF'
// TobiXu: en el live, permitir al grupo sudo elevar privilegios vía pkexec
// y lanzar Calamares sin pedir contraseña de root.
polkit.addRule(function(action, subject) {
    if (subject.isInGroup("sudo") &&
        (action.id == "org.freedesktop.policykit.exec" ||
         action.id.indexOf("com.github.calamares") === 0)) {
        return polkit.Result.YES;
    }
});
EOF

# ============================================================
# HOOKS (se ejecutan dentro del chroot, en orden numérico)
# ============================================================
cat > config/hooks/normal/0100-enable-services.hook.chroot <<'EOF'
#!/bin/sh
set -e
systemctl enable lightdm.service || true
systemctl set-default graphical.target
systemctl enable NetworkManager.service || true
exit 0
EOF
chmod +x config/hooks/normal/0100-enable-services.hook.chroot

cat > config/hooks/normal/0200-set-live-password.hook.chroot <<'EOF'
#!/bin/sh
set -e
if ! id -u user >/dev/null 2>&1; then
    useradd -m -s /bin/bash user
fi
echo "user:live" | chpasswd
echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/live
chmod 0440 /etc/sudoers.d/live
exit 0
EOF
chmod +x config/hooks/normal/0200-set-live-password.hook.chroot

cat > config/hooks/normal/0300-rename-calamares.hook.chroot <<'EOF'
#!/bin/sh
set -e
for d in /usr/share/applications/*calamares*.desktop; do
  [ -f "$d" ] || continue
  sed -i -e 's/^Name=.*/Name=Install Tobi Xu/' "$d"
  grep -q '^Name\[es\]='     "$d" || echo 'Name[es]=Instalar Tobi Xu'    >> "$d"
  grep -q '^Name\[zh_CN\]='  "$d" || echo 'Name[zh_CN]=安装 Tobi Xu'      >> "$d"
done
exit 0
EOF
chmod +x config/hooks/normal/0300-rename-calamares.hook.chroot

# ============================================================
# BUILD
# ============================================================
echo "=== lb build ==="
lb build

if [ -f live-image-amd64.hybrid.iso ]; then
  mv live-image-amd64.hybrid.iso "$ISO_NOMBRE"
  sha256sum "$ISO_NOMBRE" > SHA256SUMS
  echo "=== LISTO: $WORK_DIR/$ISO_NOMBRE ==="
  ls -lh "$ISO_NOMBRE" SHA256SUMS
else
  echo "=== ERROR: no se generó ISO ==="
  exit 1
fi
