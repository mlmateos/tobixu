#!/bin/sh
# TobiXu v0.4d: SSH solo en instalado, tras network-online, sin mascaras
set -e
grep -q "boot=live" /proc/cmdline && exit 0
# Recomendados vivos en el instalado (idempotente; el 90 gana al 00 de live-build)
mkdir -p /etc/apt/apt.conf.d
printf 'APT::Install-Recommends "true";\nAPT::Install-Suggests "false";\n' > /etc/apt/apt.conf.d/90tobixu-recommends
echo "TRIGGER-SSH: recomendados encendidos en instalado"
[ -f /etc/tobixu-ssh-done ] && exit 0
if ! dpkg -s openssh-server >/dev/null 2>&1; then
  for i in 1 2 3 4 5 6; do getent hosts deb.debian.org >/dev/null 2>&1 && break; sleep 5; done
  apt-get update -qq || true
  apt-get install -y openssh-server || { echo "TRIGGER-SSH: FALLIDA instalacion"; exit 0; }
fi
systemctl disable ssh.socket 2>/dev/null || true
systemctl enable ssh.service 2>/dev/null || true
systemctl start ssh.service 2>/dev/null || true
if ss -tln | grep -q ':22 '; then
  echo "TRIGGER-SSH: completada (sshd escuchando en puerto 22)"
else
  echo "TRIGGER-SSH: FALLIDA (sshd no escucha)"
  journalctl -u ssh.service --no-pager | tail -5 || true
fi
touch /etc/tobixu-ssh-done
