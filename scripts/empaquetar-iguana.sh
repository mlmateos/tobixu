#!/bin/sh
# Empaqueta tobixu-iguana desde theme/ (fuente unica de verdad).
set -e
cd "$(dirname "$0")/.."
PKG=meta/tobi-xu-iguana
rm -rf "$PKG/usr"
mkdir -p "$PKG/usr/share/color-schemes" \
         "$PKG/usr/share/konsole" \
         "$PKG/usr/share/plymouth/themes/tobixu" \
         "$PKG/usr/share/tobixu"
cp theme/plasma/IguanaNoche.colors       "$PKG/usr/share/color-schemes/"
cp theme/konsole/IguanaNoche.colorscheme "$PKG/usr/share/konsole/"
cp theme/plymouth/tobixu.plymouth        "$PKG/usr/share/plymouth/themes/tobixu/"
cp theme/plymouth/tobixu.script          "$PKG/usr/share/plymouth/themes/tobixu/"
cp theme/css/iguana.css                  "$PKG/usr/share/tobixu/"
dpkg-deb --build --root-owner-group "$PKG" build/
ARCHIVO="build/tobixu-iguana_0.1.0_all.deb"
if [ -f "$ARCHIVO" ]; then
    echo "OK: $ARCHIVO"
else
    echo "ERROR: no se encontro $ARCHIVO"
    exit 1
fi
