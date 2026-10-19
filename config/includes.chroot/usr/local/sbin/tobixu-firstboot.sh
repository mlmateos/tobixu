#!/bin/sh
# TobiXu v0.2: identidad de primer arranque en el sistema instalado
set -e
grep -q "boot=live" /proc/cmdline && exit 0
if [ -f /usr/share/tobixu/glyph.png ]; then
mkdir -p /var/lib/AccountsService/users
for u in $(awk -F: '$3>=1000 && $3<60000 {print $1}' /etc/passwd); do
printf '[User]\nIcon=/usr/share/tobixu/glyph.png\n' > "/var/lib/AccountsService/users/$u"
done
fi
# === RIO v0.2.1: fuentes firmadas y alineadas a sid (solo instalado) ===
if [ ! -f /etc/tobixu-river-done ]; then
if [ -f /etc/apt/sources.list ]; then
mv /etc/apt/sources.list /etc/apt/sources.list.tobixu-pre-river
fi
cat > /etc/apt/sources.list.d/debian.sources << 'DEB822'
Types: deb
URIs: http://deb.debian.org/debian
Suites: sid
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
DEB822
if [ -f /usr/share/tobixu/tobixu.list ]; then
cp /usr/share/tobixu/tobixu.list /etc/apt/sources.list.d/tobixu.list
fi
touch /etc/tobixu-river-done
fi
touch /etc/tobixu-firstboot-done
