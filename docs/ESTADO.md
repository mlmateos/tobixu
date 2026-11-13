# ESTADO — TobiXu
Actualizado: 2026-11-13 (cierre de sesión) · Fuente de verdad: github.com/mlmateos/tobixu

## Publicado (canónico)
- Plasma: tobixu-plasma-rolling-20261005-amd64.iso (~4.4 GB) · SHA256 c5fa1276…bd2699
- GNOME: tobixu-gnome-rolling-20261019-amd64.iso (~1.4 GB) · SHA256 3486ab15…bb2639d
- Web: tobixu.xyz · APT: tobixu-apt-repo · XFCE/LXQt: anunciados, no publicados.

## Hecho (M0 y M1 cerrados, 2026-11-13)
- Project "TobiXu" (tablero) + docs ESTADO/ROADMAP/DECISIONES + protocolo de sesión.
- Receta rolling capturada en rama captura-forja-rolling (b99641b): config Plasma v0.2,
  hooks, paquetes, listas, glifos. NO mergeada a main a propósito (espera M2).
- Forja: export rc6-canonica → ~/tobixu-archive/rc6-canonica.qcow2 (30.2 GiB, sin snapshots).
  Aplanado vms/debiantesting.qcow2: 169 → 30.6 GiB; arranque verificado (VMM + ssh);
  raíz 22G/41%. Original conservada: vms/debiantesting-old.qcow2.
- Issues de M0/M1 cerrados; #4 (organizar ~/tobixu-isos) reubicado a M2, abierto.

## Pendiente / en decisión
- Bake de prueba desde la forja aplanada → si OK, borrar debiantesting-old.qcow2 (~169 GiB).
- M2: despiezar captura-forja-rolling en base/ + editions/plasma|gnome|xfce.
  Nota: config/ actual es variante PLASMA, no base común.
- Identidad: Plymouth no aparece → falta `splash` en LB_BOOTAPPEND_LIVE (+ theme por
  defecto + initramfs). El theme existe (tobixu-plymouth-theme / tobixu-selva).
  Mapa del remolino → paquete tobixu-identity (issues #6, #7).

## Próximos 3 pasos
1. Bake de prueba en forja aplanada; si OK, rm vms/debiantesting-old.qcow2.
2. M2: estructura base/ + editions/ desde captura-forja-rolling (rama estructura-v2, git mv).
3. Identidad: splash + Plymouth + tobixu-identity.

## Infra y flujo
forja = VM que sólo hornea (vms/debiantesting.qcow2 en tetris; libvirt/VMM; ssh forja).
tetris = fuente de verdad: repo ~/projects/tobixu, commits firmados (-S), sella y prueba.
ISOs se jalan a ~/tobixu-isos (a organizar, #4).
Regla: pegar comandos por fases; nunca un bloque que cruce de ssh a la máquina local.

## Doctrina
El repo es la fuente de verdad; la Forja hornea; Tetris jala, sella y prueba.
Cura permanente, no parche en caliente (F94/F95). Ver docs/MasterAct.md y DECISIONES.md.
