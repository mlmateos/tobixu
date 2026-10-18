# Acta de Empalme — TobiXu v0.2 (2026-10-18)

Proposito: rescatar el contexto completo de la travesia v0.2 para cualquier
sesion futura (este chat u otro). Autoridad: este documento + git log +
logs del horno. Si se contradicen: el TESTIGO manda sobre la memoria.

## 1. Estado congelado
- Tag `v0.2.0` en GitHub (mlmateos/tobixu).
- ISO: ~/projects/tobixu-isos/v0.2/release/tobixu-0.2.0-amd64.iso
- SHA256: 37708130ad6782218aae64a5dc31c7253421e54f4de1ffb386da6dd257cef7bd
- Probado de extremo a extremo: live -> Calamares -> disco -> sistema
  instalado con identidad; sudo de fabrica; glifo en greeter y bloqueo;
  grid con iconos completos; Tab completa; idiomas de Calamares sin tofu.
- Canon previo: rc23 (unico en archive.org). No se toca hasta publicar v0.2.1.

## 2. Geografia
- tetris: repo ~/projects/tobixu; ISOs en ~/projects/tobixu-isos/{v0.1,v0.2};
  pruebas QEMU (qcow2 + ISO, -boot d para instalar, -boot c para arrancar).
- forja (192.168.122.169, VM libvirt): horneado live-build en ~/tobixu-iso.
- Sincronizacion estandar: limpieza de auto/chroot/bootstrap/binary.cache/
  cache + chown manuel; luego git reset --hard + clean -fdx + pull.

## 3. Linaje de scripts (REGLA: nunca sobreescribir; copiar y versionar)
- hornear-v0.2.sh: antiguo (v4.x). NO USAR.
- v02c: base limpia post-crisis. v02d: +grub-pc-bin. v02e/v02f: +paridad
  live-* y porton remove-list 9/9. v02g/v02h: +sudo defaultGroups, glifo en
  logos, apps GNOME, -snapshot. v02i: +glifo total (png+svg) y trigger
  firstboot (hook 0402). v02j: +fuentes Noto, bash-completion, wordmark
  dedup <- BASE DE v0.2.0. v02k: +rio (ver §5), comprometido, horno fallo.

## 4. Heridas cerradas (testigo -> cura)
1. Calamares mudo en Wayland -> cadena probada rc23: calamares-install-debian
   (fstab-trick + xhost + pkexec sobre XWayland) + qt6-wayland en lista.
2. unpackfs sin unsquashfs -> squashfs-tools.
3. Conflicto grub-pc vs grub-efi-amd64 -> solo grub-efi-amd64 (paridad rc23).
4. grub-install --target=i386-pc rc=1 -> grub-pc-bin (modulos BIOS).
5. remove-list de Calamares rc=100 (nombres unknown con --apt-indices false)
   -> live-boot-doc, live-config-doc, live-tools, live-task-localisation,
   live-task-recommended + porton 9/9 en PUERTA.
6. Usuario instalado sin sudo -> sed idempotente de defaultGroups en
   /etc/calamares/modules/users.conf (PUERTA).
7. Remolino en greeter/bloqueo -> glifo sobre debian-logos (png y svg
   embebido) + trigger firstboot escribe AccountsService de uid>=1000.
8. Glifo duplicado -> wordmark: png transparentes 1x1 + svg con texto TobiXu.
9. Tofu en idiomas -> fonts-noto-core + fonts-noto-cjk.
10. Tab sin completar -> bash-completion.
11. Iconos ausentes en grid -> gnome-weather/clocks/maps/calendar/connections/
    software (snapshot NO existe en sid: excluido con testigo).
Heridas de proceso: muertes silenciosas -> FALLO TESTIGO con rc en cada etapa;
sudo+nohup muerto -> horno SOLO via systemd-run; scripts sin version -> linaje.

## 5. El rio (v0.2.1) — estado exacto y siguiente paso
- v02k comprometido: tobixu-apt-repo-config entra a PAQUETES_V02 (N_ID y
  N_PAQ ajustados a 5); trigger firstboot con seccion RIO: respalda
  /etc/apt/sources.list a .tobixu-pre-river, escribe debian.sources deb822
  (Suites: sid, Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg),
  marcador /etc/tobixu-river-done; portones de rio en PUERTA (keyring tobixu,
  tobixu.list, keyring debian, marcador en trigger).
- Horno v02k FALLO en CAPA2: "debhelper compat level specified both in
  debian/compat and in debian/control" -> el paquete tobixu-apt-repo-config
  (epoca F92, nunca construido por CAPA2 hasta hoy) trae ambos.
- CURA DE UNA LINEA (verificar antes):
    cat packages/tobixu-apt-repo-config/debian/compat
    grep debhelper-compat packages/tobixu-apt-repo-config/debian/control
    rm packages/tobixu-apt-repo-config/debian/compat
- Luego: horno v02k; testigos: identidad 5/5, rio presente, PUERTA ABIERTA,
  BAUTIZO COMPLETO. Instalacion nueva; en el instalado:
    ls /etc/apt/sources.list.d/   (debian.sources + tobixu.list)
    ls /etc/apt/sources.list*     (legado como .tobixu-pre-river)
    sudo apt update               (sid + mlmateos.github.io, SIN Signed-By)
    apt-cache madison tobixu-gnome-look
- Tag v0.2.1 + release/ + SHA. Entonces: Acta final, pagina web, archive.org.

## 6. Doctrinas
- F93: jubilar testigos curados. F96: mostrar antes de tocar; aditivo.
- F97: busca quien lo embarca resuelto (rc23, calamares-settings-debian).
- F98: el pegado es transporte; la autoridad es el hash de Git y el testigo.
- Nuevas: versionar scripts de horno (copiar, no sobreescribir); cada clase
  de error nueva estrena porton; horno solo systemd-run; CAPA2 que falla
  temprano es un porton trabajando; "no hay paso sin huarache" (md5
  tetris<->forja antes de hornear).

## 7. Procedimientos estandar
- Forensia de ISO: sudo losetup -D; mount -o loop,ro ISO /mnt/iso-forense;
  mount -o loop,ro .../filesystem.squashfs /mnt/sq-forense; greps; umount ambos.
- Horno: sudo systemd-run --unit=horno-v02X --working-directory=/home/manuel/
  tobixu-iso /home/manuel/tobixu-iso/tools/hornear-v02X.sh
  Vigilancia: while [ "$(ssh forja 'systemctl is-active horno-v02X')" =
  "active" ]; do sleep 60; done; tail del log build-v02X-*.log.
- Prueba de instalacion: qemu-img create -f qcow2 disco.qcow2 30G;
  qemu-system-x86_64 -m 4G -smp 4 -hda disco.qcow2 -cdrom ISO -boot d
  -enable-kvm -display gtk; instalar; apagar; -boot c sin cdrom.
- UEFI (OVMF): pendiente, no bloqueante.

## 8. Abiertos no bloqueantes
- Live conserva sources.list legado (trixie, aviso cosmetico): NO tocar
  (el orden de copiado de includes.chroot esta medido: despues de
  install-packages; tocarlo arriesga lo probado).
- Hostname: lo define el usuario en Calamares (correcto asi).
- "Install Syst..." en el instalado: se queda, con nuestro glifo (reparacion).
- Capturas de vitrina (5): guardarlas en docs/capturas-v0.2/ al reanudar.

## 9. Si reanudas en un chat nuevo
1. cat docs/ActaEmpalme-v0.2.md  2. git log --oneline -5  3. continuar por
§5 en orden estricto. Ninguna cura sin testigo previo. El rio espera paciente.
