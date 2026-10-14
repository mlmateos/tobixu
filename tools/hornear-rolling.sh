#!/bin/bash
set -e

FECHA=$(date +%Y.%m.%d)
ISO_NOMBRE="tobixu-rolling-${FECHA}-amd64.iso"

echo "=== Hornear snapshot ${FECHA} ==="

cd ~/tobixu-iso || exit 1

# Limpiar builds anteriores
lb clean

# Configurar
lb config \
    --distribution sid \
    --archive-areas "main contrib non-free non-free-firmware" \
    --apt-indices false \
    --apt-recommends false \
    --iso-application "TobiXu Rolling" \
    --iso-volume "TOBIXU_ROLLING" \
    --iso-preparer "Manuel Lopez Mateos" \
    --iso-publisher "TobiXu"

# Build
lb build

# Verificar tamaño
TAMANO=$(du -h live-image-amd64.hybrid.iso | awk '{print $1}')
echo "=== ISO generada: ${TAMANO} ==="

# Renombrar
mv live-image-amd64.hybrid.iso "${ISO_NOMBRE}"

# SHA256
sha256sum "${ISO_NOMBRE}" > "SHA256SUMS-${FECHA}"

echo "=== Snapshot ${ISO_NOMBRE} listo ==="
echo "Tamaño: ${TAMANO}"
echo "SHA256: $(cat SHA256SUMS-${FECHA})"
