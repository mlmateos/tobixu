#!/bin/bash
set -e

# TobiXu v0.2 - Rolling release con GNOME + identidad
# Doctrina: F92 (apt desde repo firmado), F93 (no parchar síntomas), F95 (rediseño limpio)

FECHA=$(date +%Y.%m.%d)
ISO_NOMBRE="tobixu-rolling-${FECHA}-amd64.iso"

echo "=== Hornear TobiXu v0.2 snapshot ${FECHA} ==="

# Usar ruta absoluta para evitar que sudo cambie ~ a /root
cd /home/manuel/tobixu-iso || exit 1

# Limpiar builds anteriores
echo "[1/5] Limpiando builds anteriores..."
lb clean --all

# Configurar live-build
echo "[2/5] Configurando live-build..."
lb config \
    --distribution sid \
    --archive-areas "main contrib non-free non-free-firmware" \
    --bootstraps "ca-certificates" \
    --apt-indices false \
    --apt-recommends false \
    --iso-application "TobiXu Rolling v0.2" \
    --iso-volume "TOBIXU_ROLLING" \
    --iso-preparer "Manuel Lopez Mateos" \
    --iso-publisher "TobiXu" \
    --memtest none \
    --firmware-binary false \
    --firmware-chroot false

# Build completo
echo "[3/5] Ejecutando lb bootstrap..."
lb bootstrap

echo "[4/5] Ejecutando lb chroot..."
lb chroot

echo "[5/5] Ejecutando lb binary..."
lb binary

# Verificar resultado
if [ ! -f live-image-amd64.hybrid.iso ]; then
    echo "ERROR: No se generó la ISO"
    exit 1
fi

# Renombrar y firmar
mv live-image-amd64.hybrid.iso "${ISO_NOMBRE}"
sha256sum "${ISO_NOMBRE}" > "SHA256SUMS-${FECHA}"

# Verificar tamaño
TAMANO=$(du -h "${ISO_NOMBRE}" | awk '{print $1}')

echo ""
echo "=========================================="
echo "ISO generada exitosamente"
echo "=========================================="
echo "Nombre: ${ISO_NOMBRE}"
echo "Tamaño: ${TAMANO}"
echo "SHA256: $(cat SHA256SUMS-${FECHA})"
echo "=========================================="
