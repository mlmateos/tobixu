#!/bin/bash
# ---- Caja negra F9 (v7.2): testigo automatico de estados D.
# ---- Vive dentro del horno: unico lugar con root en forja dado el sudoers.
# ---- Muere solo cuando muere el horno.
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
# Horno v7: limpieza a fondo, purga verificada ANTES del binary, bautizo automatico.
cd /home/manuel/tobixu-iso || exit 1
[ "$(id -u)" -ne 0 ] && { echo "HORNO: sudo"; exit 1; }

for f in etc/environment etc/apt/sources.list etc/sddm.conf.d/tobixu-autologin.conf etc/skel/.config/kdeglobals; do
  [ -f "config/includes.chroot/$f" ] || { echo "PREFLIGHT FALTO: $f"; exit 1; }
done

umount /tmp 2>/dev/null || true
lb clean --all >/dev/null 2>&1
rm -f live-image-amd64.hybrid.iso SHA256SUMS "tobixu-0.1-sicaru-$(date +%Y%m%d)-amd64.iso"

LOG="build-$(date +%Y%m%d-%H%M).log"
{ df -h /tmp | tail -n 1; df -h /home | tail -n 1; } > "$LOG"

lb bootstrap --debug 2>&1 | tee -a "$LOG"; [ "${PIPESTATUS[0]}" -eq 0 ] || exit 1
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
