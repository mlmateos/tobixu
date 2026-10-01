#!/bin/bash
# Autostart de un solo uso: pinta orbita-noche con la herramienta oficial
MARKER="$HOME/.tobixu-wallpaper-done"
[ -f "$MARKER" ] && exit 0
plasma-apply-wallpaperimage /usr/share/wallpapers/tobixu-orbita-noche.svg
(lookandfeeltool6 --apply org.tobixu.selva.desktop || lookandfeeltool --apply org.tobixu.selva.desktop) 2>/dev/null
date -Is > "$MARKER"
