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

## Deudas v0.2 (cerrar cuando haya tiempo)

### 1. Keys Qt6 se descargan de GitHub durante el build (F68)
El hook 0050 hace `wget ... | gpg` cada vez que horneas. Si GitHub cae o la red
del horno falla, el build muere. **Cura v0.2:** meter las keys como archivo
estático en `config/includes.chroot/etc/apt/keyrings/`.

### 2. `/etc/skel/.config/kdeglobals` tiene dos dueños (F73)
Lo siembra `includes.chroot` como archivo estático Y lo trae `tobixu-plasma-look`
como conffile. El hook 0400 con `--force-confold` resuelve el conflicto, pero
es síntoma de deuda: **un archivo, un dueño**. **Cura v0.2:** decidir si vive
en includes.chroot (semilla universal) o en el metapaquete (semilla modular),
y quitarlo del otro.

### 3. `locales` se instala vía hook reactivo, no declarado (F70)
El hook 0200 hace `apt-get install locales` si no está. Funciona, pero es magia.
**Cura v0.2:** añadir `locales` a `005-herramientas.list.chroot` junto a
wget/curl/certs/gnupg, y dejar que dpkg lo declare como dependencia explícita.

### 4. El hook 0400 usa `dpkg -i` sin resolver dependencias (F67)
Si un metapaquete propio pide una dependencia que no está en el package-lists,
dpkg falla y el fallback `apt-get install -f` intenta resolver. Funciona, pero
es frágil. **Cura v0.2:** si los metapaquetes crecen en complejidad, considerar
meterlos también en el package-lists (pero entonces volvemos al problema de F67:
hay que coordinar que no se pidan dos veces).

---

## Estructura sólida (agregar/quitar paquetes ya es trivial)

**Para paquetes del repo firmado de Debian** (firefox, vlc, neovim, etc.):
- Añadir el nombre al `010-desktop.list.chroot` (o al package-list que corresponda)
- Commit + push + rsync a forja + hornear
- **Fin.**

**Para paquetes propios TobiXu** (metapaquetes modulares):
- Añadir el paquete al bucle `for PKG in ...` en `tools/hornear.sh`
- Crear `packages/nombre-del-paquete/` con su `debian/`
- Bump del `debian/changelog` (entrada reciente arriba, F64 honrada)
- Commit + push + hornear
- **Fin.**

**Para cambios de semilla** (wallpapers, teclados, temas):
- Editar el metapaquete correspondiente (`tobixu-wallpapers`, `tobixu-keyboard`, etc.)
- Bump del changelog
- Hornear
- **Fin.**

**Para hooks del chroot:**
- Crear/editar `config/hooks/normal/NNNN-nombre.hook.chroot`
- Commit + push + hornear
- El script se auto-sana (trap EXIT, pre-clean de montajes zombi)

---

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
