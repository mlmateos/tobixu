#!/bin/bash
# Autostart de un solo uso: pinta orbita-noche con la herramienta oficial
MARKER="$HOME/.tobixu-wallpaper-done"
[ -f "$MARKER" ] && exit 0
plasma-apply-wallpaperimage /usr/share/wallpapers/tobixu-orbita-noche.svg
date -Is > "$MARKER"
