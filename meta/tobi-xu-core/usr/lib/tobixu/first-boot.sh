#!/bin/bash
# Trigger de primer arranque TobiXu 0.1.4
# Misiones: triada v2 por escritura directa (F15) + despensa sid garantizada (F16)
#          + expulsion trixie + puerta renombrada
# Idempotente: marcador en /var/lib/tobixu evita re-ejecucion
# Configurable: /etc/tobixu/defaults.conf (doctrina 13: semillas, no cadenas)
set -euo pipefail

MARKER="/var/lib/tobixu/.first-boot-done"
LOG="/var/log/tobixu-first-boot.log"
CONF="/etc/tobixu/defaults.conf"

APPLY_LOCALES=1
APPLY_SOURCES=1
APPLY_DOOR=1
APPLY_GRUB=1
DEF_LANG=en_US.UTF-8
DEF_LC_TIME=en_GB.UTF-8
DEF_LC_METRIC=es_MX.UTF-8
if [ -f "$CONF" ]; then
    . "$CONF"
    echo "conf: $CONF cargado"
fi

exec > >(tee -a "$LOG") 2>&1
echo "== $(date -Is) primer arranque TobiXu =="

# --- Mision 1: triada v2 por escritura directa ---
# (F15: localectl necesita agente polkit; en boot temprano no hay audiencia)
if [ "$APPLY_LOCALES" = "1" ]; then
    cat > /etc/locale.conf <<LOCALE_EOF
LANG=$DEF_LANG
LC_TIME=$DEF_LC_TIME
LC_MEASUREMENT=$DEF_LC_METRIC
LC_NUMERIC=$DEF_LC_METRIC
LC_MONETARY=$DEF_LC_METRIC
LC_PAPER=$DEF_LC_METRIC
LOCALE_EOF
    echo "mision 1: locale.conf escrito directo (triada v2)"
else
    echo "mision 1 omitida por $CONF (APPLY_LOCALES=$APPLY_LOCALES)"
fi

# --- Mision 2: reponer despensa sid ANTES de barrer trixie (F16) ---
if [ "$APPLY_SOURCES" = "1" ]; then
    SID_SOURCE=/etc/apt/sources.list.d/debian.sources
    if ! grep -qs "unstable" "$SID_SOURCE" 2>/dev/null; then
        mkdir -p /etc/apt/sources.list.d
        cat > "$SID_SOURCE" <<SID_EOF
Types: deb
URIs: http://deb.debian.org/debian
Suites: unstable
Components: main non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
SID_EOF
        echo "mision 2: repuesta despensa sid en $SID_SOURCE"
    fi
    for f in /etc/apt/sources.list /etc/apt/sources.list.d/debian-backports.sources \
             /etc/apt/sources.list.d/debian-backports.list \
             /etc/apt/sources.list.d/debian.list; do
        if [ -f "$f" ] && grep -q -iE "trixie|stable-security|stable-updates" "$f" 2>/dev/null; then
            if [ "$f" = "/etc/apt/sources.list" ]; then
                : > "$f"
            else
                rm -f "$f"
            fi
            echo "expulsado: $f"
        fi
    done
    apt-get update -y || true
else
    echo "mision 2 omitida por $CONF (APPLY_SOURCES=$APPLY_SOURCES)"
fi

# --- Mision 3: renombrado de puerta del instalado ---
if [ "$APPLY_DOOR" = "1" ]; then
    if [ -f /usr/share/applications/calamares.desktop ]; then
        sed -i 's|^Name=.*Install Debian.*|Name=Install Tobi Xu|' \
               /usr/share/applications/calamares.desktop 2>/dev/null || true
    fi
else
    echo "mision 3 omitida por $CONF (APPLY_DOOR=$APPLY_DOOR)"
fi

# --- Mision 4: preseed de grub-pc (F17: el grub que pregunta a nadie) ---
if [ "$APPLY_GRUB" = "1" ]; then
    RAIZ=$(findmnt -n -o SOURCE / 2>/dev/null || true)
    DISCO=$(lsblk -ndo pkname "$RAIZ" 2>/dev/null || true)
    if [ -n "$DISCO" ]; then
        echo "grub-pc grub-pc/install_devices multiselect /dev/$DISCO" | debconf-set-selections
        echo "mision 4: preseed grub-pc -> /dev/$DISCO"
    else
        echo "mision 4: disco raiz no detectable (entorno exotico); se omite"
    fi
else
    echo "mision 4 omitida por $CONF (APPLY_GRUB=$APPLY_GRUB)"
fi

# --- Marcador ---
mkdir -p "$(dirname "$MARKER")"
date -Is > "$MARKER"
echo "== $(date -Is) primer arranque completado =="
