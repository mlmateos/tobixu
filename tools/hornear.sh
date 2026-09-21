#!/bin/bash
# Horno v4: guardián de root, preflight visible, salida en vivo (tee), testamento y bautizo.
cd /home/manuel/tobixu-iso || exit 1
if [ "$(id -u)" -ne 0 ]; then echo "HORNO: esto se corre con sudo"; exit 1; fi
for f in etc/environment etc/apt/sources.list etc/sddm.conf.d/tobixu-autologin.conf etc/skel/.config/kdeglobals; do
  if [ ! -f "config/includes.chroot/$f" ]; then echo "PREFLIGHT FALLO: falta $f"; exit 1; fi
done
umount /tmp 2>/dev/null || true
LOG="build-$(date +%Y%m%d-%H%M).log"
echo "HORNO: encendido, log en $LOG"
{ df -h /tmp | tail -n 1; df -h /home | tail -n 1; } > "$LOG"
lb build --debug 2>&1 | tee -a "$LOG"
rc=${PIPESTATUS[0]}
echo "LB EXIT: $rc" | tee -a "$LOG"
df -h /home | tail -n 1 >> "$LOG"
if [ "$rc" -eq 0 ]; then
  mv live-image-amd64.hybrid.iso "tobixu-0.1-sicaru-$(date +%Y%m%d)-amd64.iso" 2>/dev/null || true
  sha256sum "tobixu-0.1-sicaru-$(date +%Y%m%d)-amd64.iso" > SHA256SUMS 2>/dev/null || true
fi
