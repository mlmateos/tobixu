#!/bin/bash
# ============================================================
# TobiXu v0.3a (XFCE) - hornear-v03a.sh
# Basado en v3.1 (probado en v02b) + paridad rc23 + cadena probada
# ============================================================
set -e
ESCRITORIO=xfce
FECHA=$(date +%Y.%m.%d)
ISO_NOMBRE="tobixu-xfce-rolling-${FECHA}-amd64.iso"
PAQUETES_V02="tobixu-wallpapers tobixu-keyboard tobixu-xfce-look tobixu-desktop-xfce"
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
# === Cambio de listas por escritorio ===
rm -f config/package-lists/010-*.list.chroot config/package-lists/015-*.list.chroot config/package-lists/20-*.list.chroot
cp tools/listas/${ESCRITORIO}/*.list.chroot config/package-lists/
ls config/package-lists/*.chroot 2>/dev/null
trap 'mount | grep "/tobixu-iso/chroot/" | cut -d" " -f3 | sort -r | while read -r mp; do umount "$mp" 2>/dev/null || umount -l "$mp" 2>/dev/null || true; done' EXIT
[ "$(id -u)" -ne 0 ] && { echo "HORNO: corre con sudo"; exit 1; }
LOG="build-v03a-xfce-$(date +%Y%m%d-%H%M).log"

# === PREFLIGHT ===
for f in etc/environment etc/apt/sources.list \
etc/lightdm/lightdm.conf \
etc/sudoers.d/tobixu-live \
etc/systemd/system/tobixu-live-user.service \
etc/skel/Desktop/tobixu-install.desktop \
etc/xdg/autostart/tobixu-live-desktop.desktop \
usr/local/bin/tobixu-live-user-create \
usr/local/bin/tobixu-live-desktop-setup \
usr/local/bin/tobixu-install-launcher \
usr/local/bin/tobixu-calamares-wrap \
usr/local/sbin/tobixu-firstboot.sh \
etc/systemd/system/tobixu-firstboot.service ; do
[ -f "config/includes.chroot/$f" ] || { echo "PREFLIGHT FALTO: includes.chroot/$f" | tee -a "$LOG"; exit 1; }
done
[ -x config/hooks/normal/0400-install-tobixu-debs.hook.chroot ] || { echo "PREFLIGHT FALTO: hook 0400" | tee -a "$LOG"; exit 1; }
[ -x config/hooks/normal/0401-enable-live-user.hook.chroot ] || { echo "PREFLIGHT FALTO: hook 0401" | tee -a "$LOG"; exit 1; }
[ -x config/hooks/normal/0402-enable-firstboot.hook.chroot ] || { echo "PREFLIGHT FALTO: hook 0402" | tee -a "$LOG"; exit 1; }
for PKG in $PAQUETES_V02; do
[ -d "packages/$PKG" ] || { echo "PREFLIGHT FALTO: packages/$PKG" | tee -a "$LOG"; exit 1; }
done

umount /tmp 2>/dev/null || true
mount | grep "/tobixu-iso/chroot/" | cut -d" " -f3 | sort -r | while read -r mp; do umount "$mp" 2>/dev/null || umount -l "$mp" 2>/dev/null || true; done
lb clean --all 2>&1 | tail -n 3 | tee -a "$LOG" || true
{ [ -d chroot ] || [ -d cache ] || [ -d binary ]; } && { echo "TESTIGO: residuos tras clean, borrando como root" | tee -a "$LOG"; rm -rf chroot cache binary .build; } || echo "TESTIGO: arbol limpio tras clean" | tee -a "$LOG"
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
N_ID=$(chroot chroot dpkg -l 2>/dev/null | grep -cE "^ii  (tobixu-wallpapers|tobixu-keyboard|tobixu-xfce-look|tobixu-desktop-xfce) " || true)
N_PTY=$(chroot chroot dpkg -l 2>/dev/null | grep -cE "^ii  xfce4-terminal " || true)
echo "PUERTA: ii=$N_II any=$N_ANY sesiones=$N_SES" | tee -a "$LOG"
echo "TESTIGO: identidad instalada $N_ID/$N_PAQ" | tee -a "$LOG"
echo "TESTIGO: xfce4-terminal=$N_PTY" | tee -a "$LOG"

chroot chroot dpkg -l 2>/dev/null | grep -E "^ii  (lightdm|xfce4-session) " | tee -a "$LOG" || true

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

chroot chroot sh -c 'command -v xfce4-terminal >/dev/null 2>&1 && update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(command -v xfce4-terminal)" 50' 2>/dev/null || true

N_ROT=$(chroot chroot dpkg -l 2>/dev/null | grep -cE "^i[UFH] " || true)
echo "TESTIGO: paquetes rotos en chroot=$N_ROT" | tee -a "$LOG"

GLYPH=$(chroot chroot sh -c 'dpkg -L tobixu-xfce-look tobixu-wallpapers 2>/dev/null | grep -m1 -iE "(glyph|glifo|logo).*\.(png|svg)$"' || true)
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
# === CURA FRENTE 1: sudo de fabrica (defaultGroups) ===
USERS_CONF=$(find chroot/etc/calamares chroot/usr/share/calamares -name users.conf 2>/dev/null | head -1)
if [ -n "$USERS_CONF" ]; then
grep -q "^    - sudo$" "$USERS_CONF" || sed -i '/^defaultGroups:/a\    - sudo' "$USERS_CONF"
echo "TESTIGO: sudo añadido a defaultGroups en $USERS_CONF" | tee -a "$LOG"
grep -A5 "defaultGroups:" "$USERS_CONF" | head -6 | tee -a "$LOG"
else
echo "PUERTA: users.conf no encontrado" | tee -a "$LOG"; FAIL=1
fi

# === CURA FRENTE 2: glifo sobre logos oficiales de Debian ===
if [ -f chroot/usr/share/tobixu/glyph.png ]; then
cp chroot/usr/share/tobixu/glyph.png chroot/usr/share/desktop-base/debian-logos/logo-256.png 2>/dev/null || true
cp chroot/usr/share/tobixu/glyph.png chroot/usr/share/desktop-base/debian-logos/logo-128.png 2>/dev/null || true
cp chroot/usr/share/tobixu/glyph.png chroot/usr/share/desktop-base/debian-logos/logo-64.png 2>/dev/null || true
echo "TESTIGO: glifo copiado sobre logos oficiales de Debian" | tee -a "$LOG"
else
echo "PUERTA: glifo ausente, no se puede sustituir remolino" | tee -a "$LOG"; FAIL=1
fi

# === CURA FRENTE 2 (continuacion): glifo como install-debian en hicolor ===
if [ -f chroot/usr/share/tobixu/glyph.png ]; then
mkdir -p chroot/usr/share/icons/hicolor/256x256/apps
cp chroot/usr/share/tobixu/glyph.png chroot/usr/share/icons/hicolor/256x256/apps/install-debian.png
echo "TESTIGO: glifo sembrado como install-debian en hicolor" | tee -a "$LOG"
fi


# === PORTON FRENTE 3: apps GNOME deben estar instaladas (con sus iconos en hicolor) ===

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

M_BIOS=$([ -d chroot/usr/lib/grub/i386-pc ] && echo si || echo no)
M_EFI=$([ -d chroot/usr/lib/grub/x86_64-efi ] && echo si || echo no)
echo "TESTIGO: modulos grub bios=$M_BIOS efi=$M_EFI" | tee -a "$LOG"
{ [ "$M_BIOS" = "si" ] && [ "$M_EFI" = "si" ]; } || { echo "PUERTA: faltan modulos grub de alguna firmware" | tee -a "$LOG"; FAIL=1; }
# Porton: los paquetes de la remove-list de Calamares que rc23 tenia instalados
LIVE_RM_PARIDAD="live-boot-doc live-config-doc live-tools"
FALTAN=""
for p in $LIVE_RM_PARIDAD; do
chroot chroot dpkg -s "$p" 2>/dev/null | grep -q 'Status: install ok installed' || FALTAN="$FALTAN $p"
done
if [ -n "$FALTAN" ]; then
echo "PUERTA: paridad rc23 rota, faltan en chroot:$FALTAN" | tee -a "$LOG"; FAIL=1
else
echo "TESTIGO: paridad rc23 de live-* completa en chroot" | tee -a "$LOG"
fi
# Porton: con --apt-indices false, todo nombre de la remove-list de Calamares
# debe estar instalado en el chroot, o apt dira "unable to locate" (rc=100) en el destino
REMOVE_LIST="live-boot live-boot-doc live-config live-config-doc live-config-systemd live-tools live-task-localisation live-task-recommended calamares-settings-debian"
FALTAN=""
for p in $REMOVE_LIST; do
chroot chroot dpkg -s "$p" 2>/dev/null | grep -q 'Status: install ok installed' || FALTAN="$FALTAN $p"
done
if [ -n "$FALTAN" ]; then
echo "PUERTA: remove-list de Calamares hallaria ausentes:$FALTAN" | tee -a "$LOG"; FAIL=1
else
echo "TESTIGO: remove-list de Calamares completa en chroot (9/9)" | tee -a "$LOG"
fi
# Glifo total: png y svg (embebido base64) de debian-logos
if [ -f chroot/usr/share/tobixu/glyph.png ]; then
DLOGOS=chroot/usr/share/desktop-base/debian-logos
for png in logo-64.png logo-128.png logo-256.png logo-text-64.png logo-text-128.png logo-text-256.png; do
cp chroot/usr/share/tobixu/glyph.png "$DLOGOS/$png" 2>/dev/null || true
done
B64=$(base64 -w0 chroot/usr/share/tobixu/glyph.png)
for svg in logo.svg logo-text.svg logo-text-version.svg; do
printf '<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256"><image width="256" height="256" href="data:image/png;base64,%s"/></svg>\n' "$B64" > "$DLOGOS/$svg" 2>/dev/null || true
done
echo "TESTIGO: glifo sobre todos los assets debian-logos (png+svg)" | tee -a "$LOG"
else
echo "PUERTA: glifo ausente, no se puede sustituir remolino" | tee -a "$LOG"; FAIL=1
fi
[ -f chroot/usr/local/sbin/tobixu-firstboot.sh ] || { echo "PUERTA: trigger firstboot ausente" | tee -a "$LOG"; FAIL=1; }
[ -L chroot/etc/systemd/system/multi-user.target.wants/tobixu-firstboot.service ] || { echo "PUERTA: firstboot NO habilitado" | tee -a "$LOG"; FAIL=1; }
# Wordmark deduplicado: png transparente 1x1 y svg con glifo + texto TobiXu
DLOGOS=chroot/usr/share/desktop-base/debian-logos
if [ -d "$DLOGOS" ]; then
TRANS="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
for png in logo-text-64.png logo-text-128.png logo-text-256.png; do
echo "$TRANS" | base64 -d > "$DLOGOS/$png" 2>/dev/null || true
done
if [ -f chroot/usr/share/tobixu/glyph.png ]; then
B64=$(base64 -w0 chroot/usr/share/tobixu/glyph.png)
for svg in logo-text.svg logo-text-version.svg; do
printf '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="128"><image x="0" y="0" width="128" height="128" href="data:image/png;base64,%s"/><text x="140" y="84" font-family="sans-serif" font-size="64" fill="#ffffff">TobiXu</text></svg>\n' "$B64" > "$DLOGOS/$svg" 2>/dev/null || true
done
fi
echo "TESTIGO: wordmark deduplicado (glifo+texto en svg, png transparentes)" | tee -a "$LOG"
fi
for f in fonts-noto-cjk fonts-noto-core bash-completion; do
chroot chroot dpkg -s "$f" >/dev/null 2>&1 || { echo "PUERTA: falta $f en chroot" | tee -a "$LOG"; FAIL=1; }
done
echo "TESTIGO: fuentes Noto y bash-completion presentes" | tee -a "$LOG"
[ -f chroot/usr/share/keyrings/tobixu-archive-keyring.gpg ] || { echo "PUERTA: keyring tobixu ausente (carro inerte)" | tee -a "$LOG"; FAIL=1; }
[ -f chroot/usr/share/tobixu/tobixu.list ] || { echo "PUERTA: fuente tobixu inerte ausente" | tee -a "$LOG"; FAIL=1; }
[ ! -f chroot/etc/apt/sources.list.d/tobixu.list ] || { echo "PUERTA: fuente tobixu ACTIVA en chroot (404 en lb binary)" | tee -a "$LOG"; FAIL=1; }
grep -q 'tobixu-river-done' chroot/usr/local/sbin/tobixu-firstboot.sh || { echo "PUERTA: trigger sin seccion rio" | tee -a "$LOG"; FAIL=1; }
grep -q 'sources.list.d/tobixu.list' chroot/usr/local/sbin/tobixu-firstboot.sh || { echo "PUERTA: trigger no activa la fuente tobixu" | tee -a "$LOG"; FAIL=1; }
[ -f chroot/usr/share/keyrings/debian-archive-keyring.gpg ] || { echo "PUERTA: keyring debian ausente (deb822 no firmable)" | tee -a "$LOG"; FAIL=1; }
echo "TESTIGO: rio presente (keyring+fuente inerte+trigger que activa)" | tee -a "$LOG"
# Verificaciones finales
{ [ "$N_II" -eq 0 ] && [ "$N_ANY" -eq 0 ] && [ "$N_SES" -eq 0 ]; } || { echo "PUERTA: residuos LXQt" | tee -a "$LOG"; FAIL=1; }
[ "$N_ID" -eq "$N_PAQ" ] || { echo "PUERTA: identidad incompleta ($N_ID/$N_PAQ)" | tee -a "$LOG"; FAIL=1; }
[ "$N_OK" -ge 1 ] || { echo "PUERTA: puerta Calamares sin renombrar" | tee -a "$LOG"; FAIL=1; }
[ "$N_PTY" -ge 1 ] || { echo "PUERTA: xfce4-terminal ausente" | tee -a "$LOG"; FAIL=1; }
[ "$M_SUD" = "440" ] || { echo "PUERTA: sudoers con modo $M_SUD" | tee -a "$LOG"; FAIL=1; }
[ "$N_ROT" -eq 0 ] || { echo "PUERTA: dependencias sin satisfacer en chroot" | tee -a "$LOG"; FAIL=1; }
[ -f chroot/etc/systemd/system/tobixu-live-user.service ] || { echo "PUERTA: unidad live-user ausente" | tee -a "$LOG"; FAIL=1; }
[ -L chroot/etc/systemd/system/multi-user.target.wants/tobixu-live-user.service ] || { echo "PUERTA: unidad live-user NO habilitada en chroot" | tee -a "$LOG"; FAIL=1; }
[ -f chroot/usr/local/bin/tobixu-calamares-wrap ] || { echo "PUERTA: wrapper calamares ausente" | tee -a "$LOG"; FAIL=1; }

# === PUERTA-2: registro de puerta, ultima escritura gana ===
if chroot chroot dpkg -s lightdm >/dev/null 2>&1; then
  chroot chroot sh -c 'printf "/usr/sbin/lightdm\n" > /etc/X11/default-display-manager; ln -sf /lib/systemd/system/lightdm.service /etc/systemd/system/display-manager.service'
  echo "TESTIGO: puerta registrada en PUERTA-2: lightdm" | tee -a "$LOG"
elif chroot chroot dpkg -s gdm3 >/dev/null 2>&1; then
  chroot chroot sh -c 'printf "/usr/sbin/gdm3\n" > /etc/X11/default-display-manager; ln -sf /lib/systemd/system/gdm3.service /etc/systemd/system/display-manager.service'
  echo "TESTIGO: puerta registrada en PUERTA-2: gdm3" | tee -a "$LOG"
fi
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
mkdir -p /home/manuel/projects/tobixu-isos/xfce/release
mkdir -p /home/manuel/projects/tobixu-isos/xfce/build
cp "$ISO_NOMBRE" /home/manuel/projects/tobixu-isos/xfce/build/
cp "SHA256SUMS-${FECHA}" /home/manuel/projects/tobixu-isos/xfce/build/
echo "COPIA: ISO en /home/manuel/projects/tobixu-isos/xfce/build/" | tee -a "$LOG"
else
echo "BAUTIZO ABORTADO" | tee -a "$LOG"; exit 1
fi
