#!/bin/bash
# ============================================================
# TobiXu v0.2 - Rolling release con GNOME + identidad
# hornear-v0.2.sh v2.0 - rediseño F95 CON la maquinaria probada v7.2
# Doctrinas: F9 (caja negra), F13 (sudoers hornear-*.sh), F28 (fail-fast CAPA2),
#            F34 (rsync --delete / build limpio), F77 (restos de hornos muertos)
# ============================================================
set -e

FECHA=$(date +%Y.%m.%d)
ISO_NOMBRE="tobixu-rolling-${FECHA}-amd64.iso"

# Paquetes de identidad v0.2 (base firme: sistema + look&feel + GNOME)
PAQUETES_V02="tobixu-wallpapers tobixu-keyboard tobixu-gnome-look tobixu-desktop-gnome tobixu-apt-repo-config"

# ---- Caja negra F9: testigo automatico de estados D ----
CAJA_PADRE=$$
(
  set +e
  sysctl -w kernel.hung_task_timeout_secs=60 >/dev/null 2>&1
  while kill -0 "$CAJA_PADRE" 2>/dev/null; do
    n=$(ps -eo stat= | awk '/^D/{c++} END{print c+0}')
    if [ "$n" -gt 0 ]; then
      {
        echo "== $(date -Is) procesos en D: $n =="
        ps -eo pid,ppid,stat,etime,time,cmd | awk 'NR==1 || $3 ~ /D/'
        dmesg -T | grep -B2 -A28 'blocked for more than' | tail -n 120
        for p in $(ps -eo pid=,stat= | awk '$2 ~ /^D/ {print $1}'); do
          echo "-- stack del $p --"
          cat /proc/$p/stack 2>/dev/null || echo '(sin stack)'
        done
      } >> /home/manuel/tobixu-iso/caja-negra.log
      sleep 300
    fi
    sleep 10
  done
) &
# ---- fin caja negra ----

cd /home/manuel/tobixu-iso || exit 1

# F77 + trap EXIT: desmontar restos de hornos muertos antes de limpiar y al salir
trap 'mount | grep "/tobixu-iso/chroot/" | cut -d" " -f3 | sort -r | while read -r mp; do umount "$mp" 2>/dev/null || umount -l "$mp" 2>/dev/null || true; done' EXIT
[ "$(id -u)" -ne 0 ] && { echo "HORNO: corre con sudo -n ./hornear-v0.2.sh (sudoers hornear-*.sh, F13)"; exit 1; }

LOG="build-v02-$(date +%Y%m%d-%H%M).log"

# === PREFLIGHT: la aduana v0.2 (fuentes de identidad + paquetes CAPA2) ===
for f in etc/environment etc/apt/sources.list; do
  [ -f "config/includes.chroot/$f" ] || { echo "PREFLIGHT FALTO: config/includes.chroot/$f" | tee -a "$LOG"; exit 1; }
done
[ -f "config/includes.chroot/etc/skel/.config/gnome-initial-setup-done" ] || echo "AVISO: marcador gnome-initial-setup-done ausente en skel" | tee -a "$LOG"
for PKG in $PAQUETES_V02; do
  [ -d "packages/$PKG" ] || { echo "PREFLIGHT FALTO: packages/$PKG" | tee -a "$LOG"; exit 1; }
done

umount /tmp 2>/dev/null || true
mount | grep "/tobixu-iso/chroot/" | cut -d" " -f3 | sort -r | while read -r mp; do umount "$mp" 2>/dev/null || umount -l "$mp" 2>/dev/null || true; done
lb clean --all >/dev/null 2>&1
rm -f live-image-amd64.hybrid.iso SHA256SUMS SHA256SUMS-* tobixu-rolling-*.iso

{ df -h /tmp | tail -n 1; df -h /home | tail -n 1; } > "$LOG"

# === Configurar live-build (F92: repo firmado via config/archives persistido) ===
echo "[cfg] lb config v0.2 rolling" | tee -a "$LOG"
export LB_BOOTSTRAP_INCLUDE="ca-certificates"
lb config \
    --distribution sid \
    --archive-areas "main contrib non-free non-free-firmware" \
    --apt-indices false \
    --apt-recommends false \
    --iso-application "TobiXu Rolling v0.2" \
    --iso-volume "TOBIXU_ROLLING" \
    --iso-preparer "Manuel Lopez Mateos" \
    --iso-publisher "TobiXu" \
    --memtest none \
    --firmware-binary false \
    --firmware-chroot false

# === lb bootstrap ===
echo "[1/5] lb bootstrap" | tee -a "$LOG"
lb bootstrap --debug 2>&1 | tee -a "$LOG"; [ "${PIPESTATUS[0]}" -eq 0 ] || exit 1

# === CAPA 2: ELIMINADA (F92: paquetes ya publicados en repo) ===
echo "[2/5] CAPA2: omitida (paquetes en repo GitHub)" | tee -a "$LOG"

echo "[3/5] lb chroot" | tee -a "$LOG"
lb chroot --debug 2>&1 | tee -a "$LOG"; [ "${PIPESTATUS[0]}" -eq 0 ] || exit 1

# === PUERTA: montajes + purga por dpkg (la autoridad que no miente) + testigos ===
echo "[4/5] PUERTA" | tee -a "$LOG"
mount -t proc proc chroot/proc 2>/dev/null
mount -t sysfs sysfs chroot/sys 2>/dev/null
mount --bind /dev chroot/dev 2>/dev/null
mount --bind /dev/pts chroot/dev/pts 2>/dev/null

chroot chroot apt-get purge --yes 'lxqt-*' 'liblxqt*' 'libdbusmenu-lxqt*' >/dev/null 2>&1 || true
chroot chroot apt-get autoremove --purge --yes >/dev/null 2>&1 || true
RESIDUOS=$(chroot chroot dpkg -l 2>/dev/null | awk '/lxqt|pcmanfm-qt|qterminal|lximage-qt|obconf-qt/{print $2}')
if [ -n "$RESIDUOS" ]; then
  chroot chroot dpkg --purge --force-depends $RESIDUOS 2>&1 | tail -n 3 | tee -a "$LOG"
fi

N_II=$(chroot chroot dpkg -l 2>/dev/null | grep -ciE "^ii.*(lxqt|pcmanfm-qt|qterminal|lximage-qt|obconf-qt)")
N_ANY=$(chroot chroot dpkg -l 2>/dev/null | grep -ciE "lxqt|pcmanfm-qt|qterminal|lximage-qt|obconf-qt")
N_SES=$(find chroot/usr/share/xsessions chroot/usr/share/wayland-sessions -iname "*lxqt*" 2>/dev/null | wc -l)
echo "PUERTA: ii=$N_II any=$N_ANY sesiones=$N_SES" | tee -a "$LOG"

# Testigos v0.2: GNOME vivo + identidad de fabrica
chroot chroot dpkg -l 2>/dev/null | grep -E "^ii  (gdm3|gnome-session|tobixu-gnome-look|tobixu-desktop-gnome) " | tee -a "$LOG"

# Renombrado de la puerta del instalador (trilingüe)
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

# === lb binary + bautizo por contenido (doctrina 12) ===
echo "[5/5] lb binary" | tee -a "$LOG"
lb binary --debug 2>&1 | tee -a "$LOG"
rc=${PIPESTATUS[0]}
echo "LB EXIT: $rc" | tee -a "$LOG"

if [ "$rc" -eq 0 ] && [ -f live-image-amd64.hybrid.iso ]; then
  mv live-image-amd64.hybrid.iso "$ISO_NOMBRE"
  sha256sum "$ISO_NOMBRE" > "SHA256SUMS-${FECHA}"
  # Firma GPG del bautizo (tarea fría 3): descomentar cuando la clave viva en forja
  # gpg --detach-sign --armor "SHA256SUMS-${FECHA}"
  echo "BAUTIZO COMPLETO: $ISO_NOMBRE" | tee -a "$LOG"
  echo "SHA256: $(cut -d' ' -f1 SHA256SUMS-${FECHA})" | tee -a "$LOG"
else
  echo "BAUTIZO ABORTADO" | tee -a "$LOG"; exit 1
fi

