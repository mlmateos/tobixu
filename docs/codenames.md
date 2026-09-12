# Tobi Xu v0.1 — Codenames sicaru

Museo en tetris: `~/tobixu-isos/v0.1/`

| Slot | Build | Archivo | SHA256 (prefijo) |
|---|---:|---|---|
| A | rc1 | tobixu-0.1-sicaru-20260911-rc1-amd64.iso | 807d77d6 |
| B | rc2 | tobixu-0.1-sicaru-20260911-rc2-amd64.iso | 837c680f |
| C | rc3 | tobixu-0.1-sicaru-20260911-amd64-rc3.iso | 489fb284 |
| D | v3 canónica | tobixu-0.1-sicaru-20260911-amd64.iso | f498aefa |

Nota de nomenclatura: rc1/rc2 usan `-rcN-amd64.iso`; rc3 y canónica usan
`-amd64-rc3.iso` / `-amd64.iso`. Asimetría heredada de los renombres del
11-sep: se documenta, no se renombra (rompería las actas).

## Configuración congelada en v3

- Idioma default (live e instalador): `en_US.UTF-8`, teclado `us`
- Formatos métricos/regionales: `es_MX.UTF-8` vía `/etc/environment` (9 `LC_*`)
- Zona horaria: `America/Mexico_City`; unidad `tobixu-tz.service` corrige
  `/etc/localtime` después de live-config (bug 13)
- Reloj Plasma: 24 h + segundos, heredado desde
  `/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc` (trofeo)
- `openssh-server`: nunca en la ISO; solo al vuelo para pruebas
