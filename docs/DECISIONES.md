# DECISIONES — TobiXu
Registro numerado y fechado. Complementa las doctrinas F92–F97 de MasterAct.md.

- D1 (2026-11-13): El Project vive en GitHub bajo mlmateos. No se crea cuenta nueva
  ni organización ahora. Los chats alimentan el repo + tablero.
- D2 (2026-11-13): Un solo repo tobixu con base/ + editions/<dm>/. La identidad vive
  una sola vez en base/; cada edición sólo aporta su delta.
- D3 (2026-11-13): forja es desechable (sólo hornea). tetris es la fuente de verdad
  y commitea. Las ISOs se jalan a ~/tobixu-isos. El respaldo es el repo, no la VM.
- D4 (2026-11-13, decidida): Exportar rc6-canonica como archivo aparte
  (qemu-img convert -l 7-v0.1-rc6-canonica) a ~/tobixu-archive/ y luego aplanar la
  forja con qemu-img convert (descarta los 9 snapshots internos). VM apagada.
  Original intacta hasta verificar el arranque de la imagen aplanada.
- D5 (2026-11-13): La identidad se cura de raíz con paquete tobixu-identity + hooks
  en base/ (F94/F95), no con parches en caliente.
