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

### 12. Teclados xkb: validación y reconocimiento multi-desktop
El que modifica un layout valida con `tobixu-keyboard-check` (xkbcli, la misma
autoridad que Mutter/KWin usan en Wayland). El reconocimiento ocurre al compilar
el keymap: sesión nueva en Wayland, arranque de X en X11 (con purga de
`/var/lib/xkb/*.xkm`). Recarga inmediata: `setxkbmap` en X11;
`tobixu-keyboard-apply` toca `input-sources` en GNOME-Wayland; en KDE-Wayland,
logout-login. Los visores (gkbd-keyboard-display en GNOME, applet de Plasma,
xkbprint como universal) leen los mismos datos xkb: si el dato es válido,
el visor funciona. (Deuda v0.3 cerrada: teclados multi-desktop)
### 13. Rolling release real: repo apt firmado
Los metapaquetes propios (tobixu-gnome-look, tobixu-plasma-look, tobixu-wallpapers,
tobixu-keyboard, tobixu-sddm-theme, tobixu-plymouth-theme, tobixu-pulsar, tobi-xu-arts,
tobi-xu-stem) se publican en `https://mlmateos.github.io/tobixu-apt-repo` firmado
con GPG (clave `2AF282649069E8636BBE1A0DAD896D6B738B45D9`, UID `TobiXu APT Signing Key <apt@tobixu.org>`).

La ISO incluye:
- `/etc/apt/sources.list.d/tobixu.list` apuntando al repo
- `/etc/apt/keyrings/tobixu-apt-key.gpg` con la clave pública

Resultado: `apt update && apt upgrade` actualiza TODO (Debian + TobiXu), sin
reinstalar nunca. (Deuda v0.3 cerrada)

**Uso post-instalación:**

~~~bash
apt update && apt upgrade
apt install tobixu-gnome-look   # instala GNOME con identidad TobiXu
apt install tobixu-plasma-look  # instala Plasma con identidad TobiXu
~~~

**Publicar nueva versión (flujo del mantenedor):**

~~~bash
cd ~/projects/tobixu-apt-repo

# 1. Construir los .deb nuevos desde el repo principal
cd ~/projects/tobixu/packages
for pkg in tobixu-gnome-look tobixu-plasma-look tobixu-wallpapers tobixu-keyboard \
           tobixu-sddm-theme tobixu-plymouth-theme tobixu-pulsar tobi-xu-arts tobi-xu-stem; do
    [ -d "$pkg" ] && { cd "$pkg"; dpkg-buildpackage -us -uc -b 2>&1 | tail -1; cd ..; }
done

# 2. Copiar .deb nuevos al pool
cp ~/projects/tobixu/packages/tobixu-*.deb ~/projects/tobixu-apt-repo/pool/
cp ~/projects/tobixu/packages/tobi-xu-*.deb ~/projects/tobixu-apt-repo/pool/

# 3. Regenerar índices
cd ~/projects/tobixu-apt-repo/pool
apt-ftparchive packages . > ../dists/stable/main/binary-amd64/Packages
cd ..
gzip -kf dists/stable/main/binary-amd64/Packages

# 4. Regenerar y re-firmar Release
cd dists/stable
cat > Release <<'REL'
Origin: TobiXu
Label: TobiXu
Suite: stable
Codename: stable
Version: 0.1
Architectures: amd64 all
Components: main
Description: TobiXu rolling release repository
REL
apt-ftparchive release . >> Release
cd ../..

# 5. Firmar
FPR=$(gpg --list-keys --with-colons apt@tobixu.org | awk -F: '/^fpr:/ {print $10; exit}')
gpg --clearsign --default-key "$FPR" -o dists/stable/InRelease dists/stable/Release
gpg --detach-sign --default-key "$FPR" -o dists/stable/Release.gpg dists/stable/Release

# 6. Publicar
git add -A
git commit -m "repo: actualizar metapaquetes a vX.Y"
git push
~~~

**Verificar que los usuarios ven la nueva versión:**

~~~bash
curl -s https://mlmateos.github.io/tobixu-apt-repo/dists/stable/main/binary-amd64/Packages | \
  grep -A1 "^Package: tobixu-gnome-look$" | head -3
~~~

**Notas doctrinales:**
- La clave GPG no tiene passphrase (`%no-protection`) para permitir firmado automatizado.
  Esto es aceptable porque: (a) la clave vive solo en tetris (máquina del mantenedor),
  (b) si se pierde, se revoca y se emite una nueva (los usuarios hacen `apt update`
  con la nueva clave), (c) el repo es público y no requiere autenticación de usuarios.
- La clave no expira (`Expire-Date: 0`). Para una versión v0.1 establecida, considerar
  clave con expiración de 2 años y subclave rotativa.
- Si un metapaquete nuevo se añade al repo principal, también debe publicarse aquí
  para que `apt install` funcione post-instalación.

