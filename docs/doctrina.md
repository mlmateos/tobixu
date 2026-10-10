# Doctrina TobiXu — Reglas selladas (v0.1)

Este documento registra las reglas que el horno respeta tras la saga F67-F77.
No romper estas reglas; si una regla ya no sirve, archivarla aquí con fecha y razón.

---

## Reglas del horno (no negociar)

### 1. El repo es la fuente de verdad
Forja recibe, no custodia. Todo archivo que el horno necesita vive en el repo
(`tools/hornear.sh`, `config/*`, `packages/*/debian/*`). Forja es un esclavo
que obedece al repo vía rsync. (F75)

### 2. Changelog: entrada reciente arriba
En Debian, la entrada más reciente del `debian/changelog` va primero (arriba
del archivo); `dpkg-buildpackage` lee la primera entrada para determinar la
versión. Usar `cat >` para reescribir, o `dch` (de `devscripts`) que mantiene
el orden automáticamente. Nunca `cat >>` al final. (F64)

### 3. Hook sin stdin: `--force-confold --force-confdef`
Todo `dpkg -i` en hooks debe llevar `--force-confold --force-confdef` para
evitar prompts interactivos que mueren con EOF. El horno corre con `</dev/null`.
(F73)

### 4. Glob: `ls -t | head -1` para capturar solo la versión viva
El bucle CAPA2 usa `cp "$(ls -t packages/${PKG}_*.deb | head -1)"` para copiar
solo la versión más reciente (por mtime). El glob `*.deb` capturaba versiones
viejas y causaba conflictos de sobreescritura. (F71)

### 5. No tuberías remoto→ejecutable
Nunca `wget ... | gpg` o `curl ... | sh`. Primero descargar a archivo (`/tmp/`),
luego transformar, luego borrar el tmp. La higiene de tuberías esquiva
heurísticas ClickFix y es más robusta ante fallos de red. (F68 v2, F69)

### 6. Pre-clean de montajes zombi + trap EXIT
El script de horno desmonta restos de hornos muertos al inicio (corre como root
vía sudoers) y tiene `trap ... EXIT` para desmontar al morir. Evita el chroot
read-only heredado. (F77)

### 7. `LB_HDD_SIZE=8000` en `config/binary`
Para ISOs grandes (>5 GB), `LB_HDD_SIZE='auto'` calcula mal el tamaño del medio.
Forzar 8000 MB en `config/binary` línea 68. (F74)

### 8. `pkill -f` con corchetes
Para no suicidarse al coincidir con la línea de comandos del invocador, usar
patrón con corchetes `"[h]ornear-rc24.sh"`. (F76)

### 9. Testigos después de cada ejecución
grep, ls, sha256sum, dpkg sobre apt. Nunca confiar en output implícito.
Siempre verificar con autoridad que no miente.

---


---

## Deudas v0.2 — Estado al 2026-10-10

### ✅ Cerradas

1. **Keys Qt6 como archivos estáticos (F68 v3):** las keys ya no se descargan de GitHub durante el build; viven en `config/includes.chroot/etc/apt/keyrings/` como archivos estáticos del repo. El horno no depende de internet para artefactos propios.

2. **`locales` declarado en package-lists (F70 declarativo):** `locales` ahora está en `005-herramientas.list.chroot` junto a wget/curl/certs/gnupg. El hook 0200 ya no necesita instalarlo reactivamente.

3. **kdeglobals con dueño único:** vive en `packages/tobixu-plasma-look/skel/.config/kdeglobals` (semilla modular), no en `includes.chroot`. El hook 0400 con `--force-confold --force-confdef` resuelve cualquier conflicto de conffile futuro.

4. **Hook 0400 con mejor logging:** el fallback `apt-get install -f` ya funcionaba; ahora el hook lista explícitamente los paquetes a instalar y los paquetes en estado roto si el fallback falla. Diagnóstico rápido sin forense profundo.

### 🔄 Pendientes (v0.3)

Ninguna deuda crítica. La estructura es 100% sólida para agregar/quitar paquetes de forma rutinaria.



## Registro de cambios

- **2026-10-09:** Doctrina inicial sellada tras saga F67-F77 (8 horneados muertos,
  una ISO viva). Nueve reglas, cuatro deudas v0.2.

### 10. Archive.org: testigos durante el derive
`ia list` miente durante `derive.php`; los testigos que no mienten son
`curl -sI` (302→200 + content-length) y `ia metadata` (files[] con sha1).
(F78)

### 11. Archive.org: metadata de items existentes
`ia upload --metadata` solo crea; para modificar un item existente se usa
`ia metadata <item> --modify="campo:valor"`. (F79)

### 12. Teclados xkb: validación y reconocimiento multi-desktop
El que modifica un layout valida con `tobixu-keyboard-check` (xkbcli, la misma
autoridad que Mutter/KWin usan en Wayland). El reconocimiento ocurre al compilar
el keymap: sesión nueva en Wayland, arranque de X en X11 (con purga de
`/var/lib/xkb/*.xkm`). Recarga inmediata: `setxkbmap` en X11;
`tobixu-keyboard-apply` toca `input-sources` en GNOME-Wayland; en KDE-Wayland,
logout-login. Los visores (gkbd-keyboard-display en GNOME, applet de Plasma,
xkbprint como universal) leen los mismos datos xkb: si el dato es válido,
el visor funciona. (Deuda v0.3 cerrada: teclados multi-desktop)
