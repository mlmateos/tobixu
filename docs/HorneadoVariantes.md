# Horneado de variantes de escritorio (receta canónica)

La base de TobiXu (río firmado, trigger de primer arranque, glifo, sudo de
fábrica, fuentes Noto, Calamares probado) es agnóstica del escritorio.
Hornear una variante es cambiar dato, no cimiento.

## Insumos

- `tools/hornear-v02m.sh` — horno canónico (GNOME, canon v0.2.1).
- `config/package-lists/010-base.list.chroot` — lista base agnóstica.
- Repo APT firmado: https://mlmateos.github.io/tobixu-apt-repo
  (llave AD896D6B738B45D9, InRelease con Suite: stable, índices con rutas pool/).

## Receta (ejemplo: XFCE)

1. Copiar el horno y renombrar su identidad:
       cp tools/hornear-v02m.sh tools/hornear-xfce-v01.sh
       sed -i 's/hornear-v02m/hornear-xfce-v01/g' tools/hornear-xfce-v01.sh
2. Cambiar el metapaquete de escritorio:
       PAQUETES_V02="tobixu-wallpapers tobixu-keyboard tobixu-desktop-xfce"
   y en la lista base: gnome-core/gdm3 → xfce4 + lightdm (puerta elegida).
3. Hornear en forja (systemd-run; PUERTA, portones y caja negra F9 intactos):
       ssh -t forja 'sudo systemd-run --unit=horno-xfce-v01 \
         --working-directory=/home/manuel/tobixu-iso \
         /home/manuel/tobixu-iso/tools/hornear-xfce-v01.sh'
4. Testigos obligatorios antes del bautizo:
   - Arranque live en UEFI y en BIOS (grub-pc-bin presente).
   - Instalación Calamares en qcow2 virgen.
   - Primer arranque: el trigger canta (cache de íconos, glifo visible).
   - `sudo apt update` sin warnings de firma ni de Suite.
   - Sin tofu: fonts-noto-core presente; bash-completion vivo.
5. Bautizo y publicación:
       tobixu-xfce-rolling-AAAAMMDD-amd64.iso (+ .sha256)
       en ~/projects/tobixu-isos/xfce/release/
       ia upload tobixu-xfce ...   (identifier = nombre de familia)
6. Vitrina: en tobixu-web, actualizar i18n/*.yaml en LOS TRES idiomas
   (size, download_url, sha_*, quitar coming_soon), `python3 build.py`, push.

## Heridas conocidas y su prevención (ya en la base)

| Herida (saga v0.2) | Prevención |
|---|---|
| grub-pc-bin ausente (BIOS) | incluido en lista base |
| Tofu por fuentes | fonts-noto-core en base |
| bash-completion ausente | en base |
| Cache de íconos stale | trigger de primer arranque |
| Firma/Suite del repo | Suite: stable + llave correcta en keyring |
| Índices con rutas rotas | apt-ftparchive packages pool/ (conf en el repo) |

## Regla de oro

Ninguna variante se publica sin: hash en la web, identifier propio en
archive.org y acta de horneado en docs/. El río no se desborda: se encauza.

