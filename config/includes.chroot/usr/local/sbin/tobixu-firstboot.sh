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
touch /etc/tobixu-firstboot-done
