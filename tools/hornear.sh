#!/bin/bash
# Hornea un build en la Forja bajo setsid, con testamento y bautizo de ISO.
cd /home/manuel/tobixu-iso || exit 1
umount /tmp 2>/dev/null || true
LOG="build-$(date +%Y%m%d-%H%M).log"
{ df -h /tmp | tail -n 1; df -h /home | tail -n 1; } > "$LOG"
lb build --debug >> "$LOG" 2>&1
rc=$?
echo "LB EXIT: $rc" >> "$LOG"
df -h /home | tail -n 1 >> "$LOG"
if [ "$rc" -eq 0 ]; then
  mv live-image-amd64.hybrid.iso "tobixu-0.1-sicaru-$(date +%Y%m%d)-amd64.iso" 2>/dev/null || true
  sha256sum "tobixu-0.1-sicaru-$(date +%Y%m%d)-amd64.iso" > SHA256SUMS 2>/dev/null || true
fi
