# Tobi Xu

Distro STEM & Arts basada en Debian, con énfasis en producción científica, tecnológica, ingeniería y artística.

## Filosofía

- **Forja construye, Tetris jala y prueba** (doctrina de trabajo)
- **Repo receta, Forja hornea, Tetris prueba** (doctrina v2 para rc4+)
- Todo configurable por le usuarie
- Código y documentación bilingües (español/inglés)

---
## 🔍 Vigilancias de sid (corolario de D1)

Tobi Xu v0.1 `sicaru` construye sobre **Debian sid** (pool + fuentes). Esto nos da Qt 6.10, Plasma 6.7 y kernel reciente, pero exige vigilancia activa de transiciones que pueden romper la ISO. Las familias críticas son:

### Paquetes con dependencias de versión exacta
- **openssh**: `openssh-server` exige `openssh-client` de la misma versión exacta. Un upgrade asimétrico rompe la instalación. Verificar con `apt-cache policy openssh-{server,client}` antes de cada build.
- **systemd/logind**: transiciones de systemd pueden dejar coredumps de `systemd-logind` en `/var/lib/systemd/coredump/`. Monitorear con `coredumpctl list` post-instalación.

### Stack gráfico Qt6/Plasma6
- **qt6-base / qt6-wayland**: cambios en `libQt6WaylandClient` pueden romper el compositor `kwin_wayland` en VMs sin GL completo. El tema Kvantum/TobiXu-Selva está fuera del skel por esta razón (Bug #23); se ofrece como opt-in vía metapaquete `tobixu-look` en v0.2.
- **plasma-workspace / plasma-desktop**: cambios en `startplasma-wayland` pueden afectar el ciclo de login. El drop-in `[Autologin] Session=plasma.desktop` previene caídas a LXQt por orden alfabético (Bug #20).
- **sddm**: la sección `[Theme]` (no `[General]`) es donde se declara `Current=tobixu` (Bug #19). Cualquier upstream que cambie el parser de `sddm.conf` requiere revalidación.

### Mesa ↔ Kernel
- El kernel 7.2.4 (paso 12) define el piso DRM/KMS. Cambios en `mesa` o `linux-image-amd64` pueden desacoplar el stack gráfico. Validar con `glxinfo | grep "OpenGL version"` post-instalación.

### Herramientas de build
- **live-build**: cambios en hooks de `live-config` pueden pisar `/etc/environment` o `/etc/timezone`. La estrategia v4 es embarcar configuración crítica como archivos estáticos en `includes.chroot/`, no inyectarla vía hooks (Bug #29).
- **calamares**: el instalador hereda `/etc/apt/sources.list` del chroot. Si no existe, genera uno genérico que puede apuntar a la suite estable (Bug #28). Por eso sembramos `sources.list` explícito con sid.

### Upstreams de temas
- **Papirus-Dark**: cambios en la estructura de íconos pueden romper la referencia en `kdeglobals` (`[Icons] Theme=Papirus-Dark`). Monitorear releases de papirus-icon-theme.
- **Kvantum**: el tema TobiXu-Selva usa SVGs propios; cambios en el parser de Kvantum pueden requerir ajustes en `TobiXu-Selva.svg`.

### Política de mitigación
Antes de cada build de release candidate:
1. `apt update && apt list --upgradable` en el chroot de prueba
2. Revisar changelogs de las familias críticas
3. Smoke test completo en VM virgen (`disco-rc4.qcow2`)
4. Archivar coredumps si aparecen: `coredumpctl info <PID>`

El repo propio (`https://mlmateos.github.io/tobixu/apt sid main`) es la fuente de verdad para kernel, metapaquetes STEAM (paso 13+), y temas TobiXu. Cualquier override de sid se documenta aquí.

---

## 🔍 Sid Watchlist (D1 Corollary)

Tobi Xu v0.1 `sicaru` builds on **Debian sid** (pool + sources). This gives us Qt 6.10, Plasma 6.7, and recent kernels, but requires active monitoring of transitions that can break the ISO. Critical families are:

### Packages with Exact Version Dependencies
- **openssh**: `openssh-server` requires `openssh-client` of the exact same version. Asymmetric upgrades break installation. Verify with `apt-cache policy openssh-{server,client}` before each build.
- **systemd/logind**: systemd transitions can leave `systemd-logind` coredumps in `/var/lib/systemd/coredump/`. Monitor with `coredumpctl list` post-installation.

### Qt6/Plasma6 Graphics Stack
- **qt6-base / qt6-wayland**: changes in `libQt6WaylandClient` can break the `kwin_wayland` compositor in VMs without full GL. The Kvantum/TobiXu-Selva theme is kept out of skel for this reason (Bug #23); offered as opt-in via `tobixu-look` metapackage in v0.2.
- **plasma-workspace / plasma-desktop**: changes in `startplasma-wayland` can affect the login cycle. The `[Autologin] Session=plasma.desktop` drop-in prevents falls to LXQt by alphabetical order (Bug #20).
- **sddm**: the `[Theme]` section (not `[General]`) is where `Current=tobixu` is declared (Bug #19). Any upstream change to the `sddm.conf` parser requires revalidation.

### Mesa ↔ Kernel
- Kernel 7.2.4 (step 12) defines the DRM/KMS floor. Changes in `mesa` or `linux-image-amd64` can decouple the graphics stack. Validate with `glxinfo | grep "OpenGL version"` post-installation.

### Build Tools
- **live-build**: changes in `live-config` hooks can overwrite `/etc/environment` or `/etc/timezone`. The v4 strategy is to ship critical configuration as static files in `includes.chroot/`, not inject via hooks (Bug #29).
- **calamares**: the installer inherits `/etc/apt/sources.list` from the chroot. If it doesn't exist, it generates a generic one that may point to stable suite (Bug #28). That's why we seed an explicit `sources.list` with sid.

### Theme Upstreams
- **Papirus-Dark**: changes in icon structure can break the reference in `kdeglobals` (`[Icons] Theme=Papirus-Dark`). Monitor papirus-icon-theme releases.
- **Kvantum**: the TobiXu-Selva theme uses custom SVGs; changes in Kvantum's parser may require adjustments to `TobiXu-Selva.svg`.

### Mitigation Policy
Before each release candidate build:
1. `apt update && apt list --upgradable` in test chroot
2. Review changelogs of critical families
3. Complete smoke test on virgin VM (`disco-rc4.qcow2`)
4. Archive coredumps if they appear: `coredumpctl info <PID>`

The custom repo (`https://mlmateos.github.io/tobixu/apt sid main`) is the source of truth for kernel, STEAM metapackages (step 13+), and TobiXu themes. Any sid override is documented here.
