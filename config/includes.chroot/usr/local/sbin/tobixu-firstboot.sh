#!/bin/sh
# TobiXu v0.3d: identidad de primer arranque con voz
set -e
echo "TRIGGER: inicio de misiones"
grep -q "boot=live" /proc/cmdline && { echo "TRIGGER: live detectado, salgo"; exit 0; }

# Misión 1: Icono de usuario
AVATAR=/usr/share/tobixu/glyph.png
[ -f /usr/share/tobixu/tobixu-emblem-256.png ] && AVATAR=/usr/share/tobixu/tobixu-emblem-256.png
if [ -f "$AVATAR" ]; then
  mkdir -p /var/lib/AccountsService/users
  for u in $(awk -F: '$3>=1000 && $3<60000 {print $1}' /etc/passwd); do
    printf '[User]\nIcon=%s\n' "$AVATAR" > "/var/lib/AccountsService/users/$u"
  done
  echo "TRIGGER: misión 1 completada (icono de usuario)"
fi

# Misión 2: Río (fuentes firmadas)
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
  for river in /usr/share/tobixu/*.list; do
    [ -f "$river" ] && cp "$river" /etc/apt/sources.list.d/
  done
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    for theme in /usr/share/icons/*; do
      [ -d "$theme" ] && gtk-update-icon-cache -f "$theme" 2>/dev/null || true
    done
  fi
  touch /etc/tobixu-river-done
  echo "TRIGGER: misión 2 completada (río sid)"
fi

# Misión 3: Cache de iconos (sin duplicar)
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  for theme in /usr/share/icons/*; do
    [ -d "$theme" ] && gtk-update-icon-cache -f "$theme" 2>/dev/null || true
  done
  echo "TRIGGER: misión 3 completada (cache de iconos)"
fi

# Misión 4: Sesión XFCE
if [ -f /etc/lightdm/lightdm.conf ] && dpkg -s lightdm >/dev/null 2>&1 && dpkg -s tobixu-desktop-xfce >/dev/null 2>&1; then
  sed -i "s|^user-session=.*|user-session=xfce|" /etc/lightdm/lightdm.conf
  echo "TRIGGER: misión 4 completada (sesión xfce)"
fi

# Mision 5: SSH habilitado solo en instalado
if dpkg -s openssh-server >/dev/null 2>&1; then
  systemctl unmask ssh.service ssh.socket 2>/dev/null || true
  systemctl daemon-reload 2>/dev/null || true
  systemctl enable --now ssh.service 2>/dev/null || true
  echo "TRIGGER: mision 5 completada (sshd habilitado y corriendo)"
fi
touch /etc/tobixu-firstboot-done
echo "TRIGGER: todas las misiones completadas"
