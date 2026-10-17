#!/bin/bash
# ============================================================
# TobiXu v0.2 - hornear-v02c.sh
# Basado en v3.1 (probado en v02b) + paridad rc23 + cadena probada
# ============================================================
set -e
FECHA=$(date +%Y.%m.%d)
ISO_NOMBRE="tobixu-rolling-${FECHA}-amd64.iso"
PAQUETES_V02="tobixu-wallpapers tobixu-keyboard tobixu-gnome-look tobixu-desktop-gnome"
N_PAQ=$(echo $PAQUETES_V02 | wc -w)

# ---- Caja negra F9 ----
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
trap 'mount | grep "/tobixu-iso/chroot/" | cut -d" " -f3 | sort -r | while read -r mp; do umount "$mp" 2>/dev/null || umount -l "$mp" 2>/dev/null || true; done' EXIT
[ "$(id -u)" -ne 0 ] && { echo "HORNO: corre con sudo"; exit 1; }
LOG="build-v02c-$(date +%Y%m%d-%H%M).log"

# === PREFLIGHT ===
for f in etc/environment etc/apt/sources.list \
etc/gdm3/custom.conf \
etc/sudoers.d/tobixu-live \
etc/systemd/system/tobixu-live-user.service \
etc/skel/Desktop/tobixu-install.desktop \
etc/xdg/autostart/tobixu-live-desktop.desktop \
usr/local/bin/tobixu-live-user-create \
usr/local/bin/tobixu-live-desktop-setup \
usr/local/bin/tobixu-install-launcher \
usr/local/bin/tobixu-calamares-wrap ; do
[ -f "config/includes.chroot/$f" ] || { echo "PREFLIGHT FALTO: includes.chroot/$f" | tee -a "$LOG"; exit 1; }
done
[ -x config/hooks/normal/0400-install-tobixu-debs.hook.chroot ] || { echo "PREFLIGHT FALTO: hook 0400" | tee -a "$LOG"; exit 1; }
[ -x config/hooks/normal/0401-enable-live-user.hook.chroot ] || { echo "PREFLIGHT FALTO: hook 0401" | tee -a "$LOG"; exit 1; }
for PKG in $PAQUETES_V02; do
[ -d "packages/$PKG" ] || { echo "PREFLIGHT FALTO: packages/$PKG" | tee -a "$LOG"; exit 1; }
done

umount /tmp 2>/dev/null || true
mount | grep "/tobixu-iso/chroot/" | cut -d" " -f3 | sort -r | while read -r mp; do umount "$mp" 2>/dev/null || umount -l "$mp" 2>/dev/null || true; done
lb clean --all >/dev/null 2>&1
rm -f live-image-amd64.hybrid.iso SHA256SUMS SHA256SUMS-* tobixu-rolling-*.iso
{ df -h /tmp | tail -n 1; df -h /home | tail -n 1; } > "$LOG"

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

echo "[1/5] lb bootstrap" | tee -a "$LOG"
lb bootstrap --debug 2>&1 | tee -a "$LOG"
rc=${PIPESTATUS[0]}
[ "$rc" -eq 0 ] || { echo "FALLO TESTIGO: lb bootstrap rc=$rc" | tee -a "$LOG"; exit 1; }

echo "[2/5] CAPA2: empaquetando identidad v0.2..." | tee -a "$LOG"
mkdir -p config/includes.chroot/opt/tobixu-debs
rm -f config/includes.chroot/opt/tobixu-debs/*.deb
for PKG in $PAQUETES_V02; do
[ -d "packages/$PKG" ] || { echo "CAPA2 FATAL: falta packages/$PKG" | tee -a "$LOG"; exit 1; }
( cd "packages/$PKG" && dpkg-buildpackage -us -uc -b ) 2>&1 | tail -n 3 | tee -a "$LOG"
cp "$(ls -t packages/${PKG}_*.deb | head -1)" config/includes.chroot/opt/tobixu-debs/
done
ls -l config/includes.chroot/opt/tobixu-debs/ | tee -a "$LOG"

echo "[3/5] lb chroot (hooks 0400+0401)" | tee -a "$LOG"
lb chroot --debug 2>&1 | tee -a "$LOG"
rc=${PIPESTATUS[0]}
[ "$rc" -eq 0 ] || { echo "FALLO TESTIGO: lb chroot rc=$rc" | tee -a "$LOG"; exit 1; }

# === PUERTA ===
echo "[4/5] PUERTA" | tee -a "$LOG"
mkdir -p chroot/proc chroot/sys chroot/dev chroot/dev/pts 2>/dev/null || true
mount -t proc proc chroot/proc 2>/dev/null || true
mount -t sysfs sysfs chroot/sys 2>/dev/null || true
mount --bind /dev chroot/dev 2>/dev/null || true
mount --bind /dev/pts chroot/dev/pts 2>/dev/null || true

chroot chroot apt-get purge --yes 'lxqt-*' 'liblxqt*' 'libdbusmenu-lxqt*' >/dev/null 2>&1 || true
chroot chroot apt-get autoremove --purge --yes >/dev/null 2>&1 || true
RESIDUOS=$(chroot chroot dpkg -l 2>/dev/null | awk '/lxqt|pcmanfm-qt|qterminal|lximage-qt|obconf-qt/{print $2}' || true)
if [ -n "$RESIDUOS" ]; then
chroot chroot dpkg --purge --force-depends $RESIDUOS 2>&1 | tail -n 3 | tee -a "$LOG" || true
fi

N_II=$(chroot chroot dpkg -l 2>/dev/null | grep -ciE "^ii.*(lxqt|pcmanfm-qt|qterminal|lximage-qt|obconf-qt)" || true)
N_ANY=$(chroot chroot dpkg -l 2>/dev/null | grep -ciE "lxqt|pcmanfm-qt|qterminal|lximage-qt|obconf-qt" || true)
N_SES=$(find chroot/usr/share/xsessions chroot/usr/share/wayland-sessions -iname "*lxqt*" 2>/dev/null | wc -l || true)
N_ID=$(chroot chroot dpkg -l 2>/dev/null | grep -cE "^ii  (tobixu-wallpapers|tobixu-keyboard|tobixu-gnome-look|tobixu-desktop-gnome) " || true)
N_PTY=$(chroot chroot dpkg -l 2>/dev/null | grep -cE "^ii  ptyxis " || true)
echo "PUERTA: ii=$N_II any=$N_ANY sesiones=$N_SES" | tee -a "$LOG"
echo "TESTIGO: identidad instalada $N_ID/$N_PAQ" | tee -a "$LOG"
echo "TESTIGO: ptyxis=$N_PTY" | tee -a "$LOG"

chroot chroot dpkg -l 2>/dev/null | grep -E "^ii  (gdm3|gnome-session) " | tee -a "$LOG" || true

for d in chroot/usr/share/applications/*calamares*.desktop; do
[ -f "$d" ] || continue
sed -i -e 's/^Name=.*/Name=Install Tobi Xu/' -e 's/^Name\[es\]=.*/Name[es]=Instalar Tobi Xu/' "$d"
grep -q '^Name\[zh_CN\]=' "$d" || echo 'Name[zh_CN]=安装 Tobi Xu' >> "$d"
done
N_OK=$(grep -l "^Name=Install Tobi Xu" chroot/usr/share/applications/*calamares*.desktop 2>/dev/null | wc -l || true)
echo "TESTIGO: puertas renombradas=$N_OK" | tee -a "$LOG"

chmod 0440 chroot/etc/sudoers.d/tobixu-live 2>/dev/null || true
M_SUD=$(stat -c %a chroot/etc/sudoers.d/tobixu-live 2>/dev/null || echo none)
echo "TESTIGO: modo sudoers=$M_SUD" | tee -a "$LOG"

chroot chroot sh -c 'command -v ptyxis >/dev/null 2>&1 && update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(command -v ptyxis)" 50' 2>/dev/null || true

N_ROT=$(chroot chroot dpkg -l 2>/dev/null | grep -cE "^i[UFH] " || true)
echo "TESTIGO: paquetes rotos en chroot=$N_ROT" | tee -a "$LOG"

GLYPH=$(chroot chroot sh -c 'dpkg -L tobixu-gnome-look tobixu-wallpapers 2>/dev/null | grep -m1 -iE "(glyph|glifo|logo).*\.(png|svg)$"' || true)
if [ -n "$GLYPH" ]; then
mkdir -p chroot/usr/share/tobixu chroot/var/lib/AccountsService/users
cp "chroot$GLYPH" chroot/usr/share/tobixu/glyph.png 2>/dev/null || true
printf '[User]\nIcon=/usr/share/tobixu/glyph.png\n' > chroot/var/lib/AccountsService/users/user
echo "TESTIGO: glifo sembrado desde $GLYPH" | tee -a "$LOG"
else
echo "AVISO: glifo no encontrado en paquetes de identidad" | tee -a "$LOG"
fi

CALBIN=$(chroot chroot sh -c 'command -v calamares' 2>/dev/null || true)
echo "TESTIGO: binario calamares=$CALBIN" | tee -a "$LOG"

FAIL=0

# Cadena probada: calamares-install-debian (rc23)
if [ -x chroot/usr/bin/calamares-install-debian ]; then
for d in chroot/usr/share/applications/*calamares*.desktop; do
[ -f "$d" ] || continue
sed -i 's|^Exec=.*|Exec=calamares-install-debian|' "$d"
done
echo "TESTIGO: Exec calamares=calamares-install-debian (cadena probada rc23)" | tee -a "$LOG"
else
echo "PUERTA: falta /usr/bin/calamares-install-debian en chroot" | tee -a "$LOG"; FAIL=1
fi

# Verificaciones finales
{ [ "$N_II" -eq 0 ] && [ "$N_ANY" -eq 0 ] && [ "$N_SES" -eq 0 ]; } || { echo "PUERTA: residuos LXQt" | tee -a "$LOG"; FAIL=1; }
[ "$N_ID" -eq "$N_PAQ" ] || { echo "PUERTA: identidad incompleta ($N_ID/$N_PAQ)" | tee -a "$LOG"; FAIL=1; }
[ "$N_OK" -ge 1 ] || { echo "PUERTA: puerta Calamares sin renombrar" | tee -a "$LOG"; FAIL=1; }
[ "$N_PTY" -ge 1 ] || { echo "PUERTA: ptyxis ausente" | tee -a "$LOG"; FAIL=1; }
[ "$M_SUD" = "440" ] || { echo "PUERTA: sudoers con modo $M_SUD" | tee -a "$LOG"; FAIL=1; }
[ "$N_ROT" -eq 0 ] || { echo "PUERTA: dependencias sin satisfacer en chroot" | tee -a "$LOG"; FAIL=1; }
[ -f chroot/etc/systemd/system/tobixu-live-user.service ] || { echo "PUERTA: unidad live-user ausente" | tee -a "$LOG"; FAIL=1; }
[ -L chroot/etc/systemd/system/multi-user.target.wants/tobixu-live-user.service ] || { echo "PUERTA: unidad live-user NO habilitada en chroot" | tee -a "$LOG"; FAIL=1; }
[ -f chroot/usr/local/bin/tobixu-calamares-wrap ] || { echo "PUERTA: wrapper calamares ausente" | tee -a "$LOG"; FAIL=1; }

umount chroot/dev/pts 2>/dev/null || true; umount chroot/dev 2>/dev/null || true
umount chroot/sys 2>/dev/null || true; umount chroot/proc 2>/dev/null || true

if [ "$FAIL" -ne 0 ]; then echo "PUERTA CERRADA" | tee -a "$LOG"; exit 1; fi
echo "PUERTA ABIERTA" | tee -a "$LOG"

echo "[5/5] lb binary" | tee -a "$LOG"
lb binary --debug 2>&1 | tee -a "$LOG"
rc=${PIPESTATUS[0]}
echo "LB EXIT: $rc" | tee -a "$LOG"

if [ "$rc" -eq 0 ] && [ -f live-image-amd64.hybrid.iso ]; then
mv live-image-amd64.hybrid.iso "$ISO_NOMBRE"
sha256sum "$ISO_NOMBRE" > "SHA256SUMS-${FECHA}"
echo "BAUTIZO COMPLETO: $ISO_NOMBRE" | tee -a "$LOG"
echo "SHA256: $(cut -d' ' -f1 SHA256SUMS-${FECHA})" | tee -a "$LOG"
else
echo "BAUTIZO ABORTADO" | tee -a "$LOG"; exit 1
fi
