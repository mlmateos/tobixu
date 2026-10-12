#!/bin/bash

for f in etc/environment etc/apt/sources.list etc/sddm.conf.d/tobixu-autologin.conf etc/skel/.config/kdeglobals; do
  [ -f "config/includes.chroot/$f" ] || { echo "PREFLIGHT FALTO: $f"; exit 1; }
done

umount /tmp 2>/dev/null || true
# F77: desmontar restos de hornos muertos antes de limpiar (corre como root)
mount | grep "/tobixu-iso/chroot/" | cut -d" " -f3 | sort -r | while read -r mp; do umount "$mp" 2>/dev/null || umount -l "$mp" 2>/dev/null || true; done
lb clean --all >/dev/null 2>&1
rm -f live-image-amd64.hybrid.iso SHA256SUMS "tobixu-0.1-sicaru-$(date +%Y%m%d)-amd64.iso"

LOG="build-$(date +%Y%m%d-%H%M).log"
{ df -h /tmp | tail -n 1; df -h /home | tail -n 1; } > "$LOG"

lb bootstrap --debug 2>&1 | tee -a "$LOG"; [ "${PIPESTATUS[0]}" -eq 0 ] || exit 1

# === CAPA 2: hornear paquetes TobiXu y sembrarlos en el chroot ===
echo "CAPA2: empaquetando tobixu-wallpapers..." | tee -a "$LOG"
mkdir -p config/includes.chroot/opt/tobixu-debs
rm -f config/includes.chroot/opt/tobixu-debs/*.deb
# Solo los paquetes que van en la ISO slim (plasma/lxqt/stem/arts son post-instalacion via apt)
for PKG in tobixu-desktop-gnome tobixu-desktop-xfce \
           tobixu-gnome-look tobixu-xfce-look \
           tobixu-wallpapers tobixu-keyboard
do
  [ -d "packages/$PKG" ] || { echo "CAPA2 FATAL: falta packages/$PKG" | tee -a "$LOG"; exit 1; }
  ( cd "packages/$PKG" && dpkg-buildpackage -us -uc -b ) 2>&1 | tail -n 3 | tee -a "$LOG"
  cp "$(ls -t packages/${PKG}_*.deb | head -1)" config/includes.chroot/opt/tobixu-debs/
done
ls -l config/includes.chroot/opt/tobixu-debs/ | tee -a "$LOG"
lb chroot    --debug 2>&1 | tee -a "$LOG"; [ "${PIPESTATUS[0]}" -eq 0 ] || exit 1

# === PUERTA: montajes + purga por dpkg (la autoridad que no miente) + triple testigo ===
mount -t proc proc chroot/proc 2>/dev/null
mount -t sysfs sysfs chroot/sys 2>/dev/null
mount --bind /dev chroot/dev 2>/dev/null
mount --bind /dev/pts chroot/dev/pts 2>/dev/null

echo "PUERTA: apt purge glob (intento)..." | tee -a "$LOG"
chroot chroot apt-get purge --yes 'lxqt-*' 'liblxqt*' 'libdbusmenu-lxqt*' >/dev/null 2>&1 || true
chroot chroot apt-get autoremove --purge --yes >/dev/null 2>&1 || true

echo "PUERTA: dpkg --purge --force-depends sobre CUALQUIER lxqt..." | tee -a "$LOG"
RESIDUOS=$(chroot chroot dpkg -l 2>/dev/null | awk '/lxqt|pcmanfm-qt|qterminal|lximage-qt|obconf-qt/{print $2}')
if [ -n "$RESIDUOS" ]; then
  chroot chroot dpkg --purge --force-depends $RESIDUOS 2>&1 | tail -n 3 | tee -a "$LOG"
fi

N_II=$(chroot chroot dpkg -l 2>/dev/null | grep -ciE "^ii.*(lxqt|pcmanfm-qt|qterminal|lximage-qt|obconf-qt)")
N_ANY=$(chroot chroot dpkg -l 2>/dev/null | grep -ciE "lxqt|pcmanfm-qt|qterminal|lximage-qt|obconf-qt")
N_SES=$(find chroot/usr/share/xsessions chroot/usr/share/wayland-sessions -iname "*lxqt*" 2>/dev/null | wc -l)
echo "PUERTA: ii=$N_II any=$N_ANY sesiones=$N_SES" | tee -a "$LOG"

for d in chroot/usr/share/applications/*calamares*.desktop; do
  [ -f "$d" ] || continue
  sed -i -e 's/^Name=.*/Name=Install Tobi Xu/' -e 's/^Name\[es\]=.*/Name[es]=Instalar Tobi Xu/' "$d"
  grep -q '^Name\[zh_CN\]=' "$d" || echo 'Name[zh_CN]=安装 Tobi Xu' >> "$d"
done
N_OK=$(grep -l "^Name=Install Tobi Xu" chroot/usr/share/applications/*calamares*.desktop 2>/dev/null | wc -l)
echo "PUERTA: puertas renombradas=$N_OK" | tee -a "$LOG"

umount chroot/dev/pts 2>/dev/null; umount chroot/dev 2>/dev/null
umount chroot/sys 2>/dev/null; umount chroot/proc 2>/dev/null

if [ "$N_II" -ne 0 ] || [ "$N_ANY" -ne 0 ] || [ "$N_SES" -ne 0 ] || [ "$N_OK" -eq 0 ]; then
  echo "PUERTA CERRADA: ii=$N_II any=$N_ANY ses=$N_SES nombre=$N_OK" | tee -a "$LOG"; exit 1
fi
echo "PUERTA ABIERTA" | tee -a "$LOG"

lb binary --debug 2>&1 | tee -a "$LOG"
rc=${PIPESTATUS[0]}
echo "LB EXIT: $rc" | tee -a "$LOG"

if [ "$rc" -eq 0 ] && [ -f live-image-amd64.hybrid.iso ]; then
  mv live-image-amd64.hybrid.iso "tobixu-0.1-sicaru-$(date +%Y%m%d)-amd64.iso"
  sha256sum "tobixu-0.1-sicaru-$(date +%Y%m%d)-amd64.iso" > SHA256SUMS
  echo "BAUTIZO COMPLETO" | tee -a "$LOG"
else
  echo "BAUTIZO ABORTADO" | tee -a "$LOG"; exit 1
fi
