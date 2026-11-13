# ROADMAP — TobiXu
Cada milestone tiene criterio de "hecho". Una sesión = un issue.

## M0 — Cimientos del proyecto  [cerrado]
Tablero + docs/ESTADO, ROADMAP, DECISIONES + protocolo.
Hecho: docs commiteados y tablero creado con los primeros issues.

## M1 — Forja sostenible [cerrado]
Receta 100% en el repo (diff forja↔tetris commiteado); limpieza guest + fstrim;
política de snapshots decidida y aplanado verificado arrancando; ~/tobixu-isos
organizado (published/ last-good/ archive/ + SHA256SUMS).
Hecho: forja ligera, arranca y hornea.

## M2 — Estructura base + ediciones
ISOs archivadas y verificadas.
base/ (identidad+estructura) + editions/plasma y editions/gnome (sólo delta);
tools/build.sh <edición> = base + delta; migración git mv en rama estructura-v2.
Hecho: plasma y gnome se hornean desde la nueva estructura y pasan checklist.

## M3 — Identidad completa
Plymouth visible (live + instalado): tema + initramfs + splash, cura en base/hooks.
Mapa del remolino: cada aparición de Debian → paquete tobixu-identity (cura permanente).
Hecho: checklist de identidad pasa en plasma y gnome, live e instalado.

## M4 — Cierre y re-release
Actas de plasma 20261005 y gnome 20261019 + checklist por ISO; re-release completo;
XFCE/LXQt como nuevos deltas.
Hecho: ISOs verificadas, con acta y SHA256, publicadas.
