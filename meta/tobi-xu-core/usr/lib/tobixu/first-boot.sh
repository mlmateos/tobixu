#!/bin/bash
# Trigger de primer arranque TobiXu 0.1.2
# Misiones: triada de locales + limpieza de fuentes trixie + renombrado de puerta
# Idempotente: un marcador en /var/lib/tobixu evita re-ejecucion
set -euo pipefail
MARKER="/var/lib/tobixu/.first-boot-done"
LOG="/var/log/tobixu-first-boot.log"
exec > >(tee -a "$LOG") 2>&1
echo "== $(date -Is) primer arranque TobiXu =="
# --- Mision 1: triada de locales ---
if command -v localectl >/dev/null 2>&1; then
    localectl set-locale \
        LANG=en_US.UTF-8 \
        LC_TIME=en_DK.UTF-8 \
        LC_MEASUREMENT=es_MX.UTF-8 \
        LC_NUMERIC=es_MX.UTF-8 \
        LC_MONETARY=es_MX.UTF-8 \
        LC_PAPER=es_MX.UTF-8 || echo "localectl: fallo parcial (no fatal)"
fi
# --- Mision 2: limpieza de fuentes trixie ---
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
# --- Mision 3: renombrado de puerta del instalado ---
if [ -f /usr/share/applications/calamares.desktop ]; then
    sed -i 's|^Name=.*Install Debian.*|Name=Install Tobi Xu|' \
           /usr/share/applications/calamares.desktop 2>/dev/null || true
fi
# --- Marcador ---
mkdir -p "$(dirname "$MARKER")"
date -Is > "$MARKER"
echo "== $(date -Is) primer arranque completado =="
