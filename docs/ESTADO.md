# ESTADO — TobiXu
Actualizado: 2026-11-13 · Fuente de verdad: github.com/mlmateos/tobixu

## Publicado (canónico)
- Plasma: tobixu-plasma-rolling-20261005-amd64.iso (~4.4 GB) · SHA256 c5fa1276…bd2699
- GNOME:  tobixu-gnome-rolling-20261019-amd64.iso (~1.4 GB) · SHA256 3486ab15…bb2639d
- Web: tobixu.xyz · APT: tobixu-apt-repo · XFCE/LXQt: anunciados, no publicados.
  (SHA256 completos en tobixu.xyz y SHA256SUMS.)

## Qué funciona
Base rolling Debian Sid; Calamares; repo APT firmado; identidad visual (glifo + mascota).

## Qué está incompleto
IDENTIDAD: Plymouth no aparece; el remolino de Debian no está sustituido por el
glifo cuadrado (theme/plymouth/glyph-square.png) en todas sus apariciones.

## En decisión / bloqueado
- FORJA: vms/debiantesting.qcow2 ocupa 169 GiB (archivo 188 GiB ≈ 202.1 GB) por
  9 snapshots internos v0.1 (rc5→rc21). Guest raíz 56G, 77% usado.
  Política de snapshots PENDIENTE (export rc6-canonica opcional vs ninguno; aplanar).
- ESTRUCTURA: falta migrar a base/ + editions/<dm>/ (identidad una sola vez).

## Próximos 3 pasos
1. [Sesión 1] Tablero + docs + protocolo (esto). Cero riesgo.
2. [Sesión 2] Asegurar receta + limpieza forja + aplanado. EN PAUSA hasta confirmar.
3. [Sesión 3] Estructura base/ediciones en rama estructura-v2 (git mv + build prueba).

## Infra y flujo
forja = VM que sólo hornea (vms/debiantesting.qcow2 en tetris).
tetris = fuente de verdad: repo, commits firmados (GPG), sella y prueba.
ISOs + sha256 se jalan a ~/tobixu-isos (a organizar). tetris /home: 922 GiB libres.

## Doctrina
El repo es la fuente de verdad; la Forja hornea; Tetris jala, sella y prueba.
Cura permanente, no parche en caliente (F94/F95). Ver docs/MasterAct.md.
