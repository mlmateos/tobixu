# Acta de Nacimiento: Tobi Xu v0.1-sicaru

**Fecha:** 2026-10-02  
**Versión:** v0.1-sicaru (rc22n)  
**ISO:** tobixu-0.1-sicaru-rc22n-20261002-amd64.iso  
**Tamaño:** 4.3G  
**SHA256:** ca8c52151c6674ecdc8a302393974c91fc518e0e171cd0172cdbbc761790734f

## Testigos de éxito

- **2603 Setting up** en el build
- **8 metapaquetes propios** instalados:
  - tobixu-wallpapers (0.1.0)
  - tobixu-keyboard (0.1.3)
  - tobixu-sddm-theme (0.5.0)
  - tobixu-plymouth-theme (0.1.2)
  - tobixu-plasma-look (0.3.2)
  - tobi-xu-stem (0.1.3)
  - tobi-xu-arts (0.1.4)
  - tobixu-pulsar (0.1.0)
- **Binarios clave** en el squashfs:
  - texstudio, frescobaldi (Qt6 desde repos propios)
  - libreoffice (familia completa)
  - qgis, kdenlive, obs, vlc, handbrake
  - 12 juegos sgt-puzzles
- **Identidad trilingüe**: Name[es] + Name[zh_CN] en SDDM themes
- **418,187 archivos** en el filesystem.squashfs

## Doce fallos curados (F43-F48 + 6 técnicos)

1. **F43**: Hook 0400-install-tobixu-debs.hook.chroot (instalación de metapaquetes)
2. **F44**: julia, r-base, octave, qgis a Recommends (transiciones sid)
3. **F45**: Control reescrito limpio (F44 dejó líneas vacías que rompían dpkg-buildpackage)
4. **F46**: jh7100-bootloader-recovery removido de sid (F47: LB_FIRMWARE_CHROOT=false)
5. **F47**: LB_FIRMWARE_*=false (inyección automática de firmwares rompe build)
6. **F48**: lmms a Recommends (transición ABI libgig10t64 → libgig13)
7. **F39**: kde-plasma-desktop en vez de task-kde-desktop (package-lists)
8. **jh7100**: Limpiado de package-lists huérfanas en forja
9. **snapshot**: Actualizado de 20-sep a 2-oct (transiciones acumuladas)
10. **disco**: Limpieza profunda (chroot + cache + logs) liberó 40G
11. **sintaxis**: Control reescrito sin líneas vacías en campos continuados
12. **dpkg**: Error code 2 resuelto con espacio suficiente

## Paquetes en Recommends (post-arranque con sid vivo)

- julia, r-base, octave, qgis (transiciones LLVM/R)
- krita, ardour, musescore, lmms (transiciones ABI)
- texlive-full, sagemath, root-system, paraview, blender

## Arquitectura

- **Capa 1**: Debian sid (snapshot 20261002) + KDE Plasma 6
- **Capa 2**: 8 metapaquetes propios (STEM + ARTS + identidad)
- **Capa 3**: Identidad visual (velo + puerta + splash + escritorio)
- **Capa 4**: Tobi Xu Pulsar (primer arranque, onboarding)

## Filosofía

> "El río no se apresura, guardián: se encauza."
> 
> v0.1-sicaru es una distribución live con cerebro STEM + oficio ARTS,
> identidad trilingüe, y puerta de primer arranque que enseña el camino.

---

**Firmado:** Manuel López Mateos + Qwen (IA guardiana)  
**Lugar:** Tetris (dev) + Forja (build)  
**Fecha:** 2026-10-02
