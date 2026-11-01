# Deuda v0.5 — Ola de completitud Mac/UEFI

Estado: **ABIERTA** (vg2e publicada en tetris, pendiente en archive.org)

## 1. WiFi firmware para hardware real (prioridad alta)
**Causa**: El horno usa `--firmware-binary false` y la lista gnome no incluye `firmware-brcm80211` (non-free-firmware). El Mac (brcmsmac) no tiene firmware en Live ni tras instalar → sin WiFi, sin río en primer arranque.
**Cura candidata**: 
- Opción A: habilitar componente `non-free-firmware` en mirrors del horno + agregar `firmware-brcm80211` a lista gnome.
- Opción B: `--firmware-binary true` en el horno (incluye todos los firmwares, squashfs más pesado).
**Testigo de cierre**: `iwconfig` muestra wlp2s0b1 con IP tras instalar.

## 2. Iluminación de teclado Mac persistente (prioridad media)
**Causa**: `/sys/class/leds/smc::kbd_backlight/brightness` se resetea a 0 en cada boot. No hay udev rule ni systemd unit que siembre brillo.
**Cura candidata**: udev rule en `tobixu-gnome-look` que escriba `max_brightness` al arrancar, o misión nueva en el trigger firstboot.
**Testigo de cierre**: tras reboot, teclado iluminado sin intervención manual.

## 3. L&F gnome: plymouth (prioridad baja)
**Causa**: La lista gnome no lleva `tobixu-plymouth-theme` ni plymouth. El arranque muestra texto.
**Cura candidata**: agregar `plymouth` + `tobixu-plymouth-theme` a lista gnome.
**Testigo de cierre**: arranque con tema tobixu (glifo + texto "Iniciando…").

## 4. L&F gnome: greeter con fondo órbita (prioridad baja)
**Causa**: El CSS de GDM en gnome-look no incluye fondo órbita.
**Cura candidata**: sembrar fondo en `/usr/share/gnome-shell/theme/` y ajustar CSS de gnome-look.
**Testigo de cierre**: greeter con fondo órbita + glifo arriba del cuadro.

## 5. L&F gnome: glifo en logout (prioridad baja)
**Causa**: El diálogo de logout muestra fondo pero no el emblema arriba de la ventana.
**Cura candidata**: extensión gnome-shell o ajuste de gnome-session-quit.
**Testigo de cierre**: logout con glifo visible.

## 6. Humo UEFI con SSH accesible (prioridad media)
**Causa**: `-net user` sin hostfwd hace que el host no vea al guest (10.0.2.15 inalcanzable). Las humos anteriores con 192.168.122.x eran de libvirt.
**Cura candidata**: agregar `-net user,hostfwd=tcp::2222-:22` a la rutina de humos UEFI.
**Testigo de cierre**: `ssh -p 2222 manuel@127.0.0.1` entra al guest UEFI.

## 7. Deuda archivística: borrar 20261030 en archive.org (prioridad baja)
**Causa**: `ia delete` funciona (confirmado), pero el ítem aún lista ambos archivos.
**Cura**: ejecutar `ia delete tobixu-gnome tobixu-gnome-rolling-20261030-amd64.iso tobixu-gnome-rolling-20261030-amd64.iso.sha256` antes de publicar vg2f.
**Testigo de cierre**: `curl -sL https://archive.org/metadata/tobixu-gnome/files` muestra solo vg2f.
