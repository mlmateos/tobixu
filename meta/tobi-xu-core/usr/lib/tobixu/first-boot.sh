#!/bin/bash
# Trigger de primer arranque TobiXu 0.1.2
# Misiones: triada v2 (en_US + en_GB 24h con dos puntos + es_MX metrico) + limpieza de fuentes trixie + renombrado de puerta
# Idempotente: un marcador en /var/lib/tobixu evita re-ejecucion
# Configurable: /etc/tobixu/defaults.conf (doctrina 13: semillas, no cadenas)
set -euo pipefail

MARKER="/var/lib/tobixu/.first-boot-done"
LOG="/var/log/tobixu-first-boot.log"
CONF="/etc/tobixu/defaults.conf"

# Semillas por defecto; el dueno puede sobreescribirlas en $CONF
APPLY_LOCALES=1
APPLY_SOURCES=1
APPLY_DOOR=1
DEF_LANG=en_US.UTF-8
DEF_LC_TIME=en_GB.UTF-8
DEF_LC_METRIC=es_MX.UTF-8
if [ -f "$CONF" ]; then
    . "$CONF"
    echo "conf: $CONF cargado"
fi

exec > >(tee -a "$LOG") 2>&1
echo "== $(date -Is) primer arranque TobiXu =="

# --- Mision 1: triada v2 de locales ---
if [ "$APPLY_LOCALES" = "1" ]; then
    if command -v localectl >/dev/null 2>&1; then
        localectl set-locale \
            LANG="$DEF_LANG" \
            LC_TIME="$DEF_LC_TIME" \
            LC_MEASUREMENT="$DEF_LC_METRIC" \
            LC_NUMERIC="$DEF_LC_METRIC" \
            LC_MONETARY="$DEF_LC_METRIC" \
            LC_PAPER="$DEF_LC_METRIC" || echo "localectl: fallo parcial (no fatal)"
    fi
else
    echo "mision 1 omitida por $CONF (APPLY_LOCALES=$APPLY_LOCALES)"
fi

# --- Mision 2: limpieza de fuentes trixie ---
if [ "$APPLY_SOURCES" = "1" ]; then
    SHOULD_UPDATE=0
    for f in /etc/apt/sources.list /etc/apt/sources.list.d/debian.sources \
             /etc/apt/sources.list.d/debian-backports.sources \
             /etc/apt/sources.list.d/debian-backports.list \
             /etc/apt/sources.list.d/debian.list; do
        if [ -f "$f" ] && grep -q -iE "trixie|stable-security|stable-updates" "$f" 2>/dev/null; then
            if [ "$f" = "/etc/apt/sources.list" ]; then
                : > "$f"
            else
                rm -f "$f"
            fi
            SHOULD_UPDATE=1
            echo "expulsado: $f"
        fi
    done
    [ "$SHOULD_UPDATE" -eq 1 ] && apt-get update -y || true
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

# --- Marcador ---
mkdir -p "$(dirname "$MARKER")"
date -Is > "$MARKER"
echo "== $(date -Is) primer arranque completado =="
