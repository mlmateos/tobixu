# 📜 Acta Maestra / Master Act / 主纪要

> Documento vivo que consolida catorce días de selva, veintiuna horneadas, once familias de cicatrices y un horno que cruza sobre cristal. Cualquier chat, colaborador o yo futuro hereda aquí el contexto completo del proyecto.
>
> Living document consolidating fourteen days of jungle, twenty-one bakes, eleven families of scars, and an oven that crosses on crystal. Any chat, collaborator, or future self inherits here the full context of the project.
>
> 活文档，汇聚十四日丛林、二十一次烘焙、十一道伤疤族群，以及一座踏晶而渡的炉火。任何新会话、协作者或未来的自我，皆从此处继承项目的完整语境。

---

## Metadata / Metadatos / 元数据

| Campo / Field / 字段 | Valor / Value / 值 |
|---|---|
| **Última actualización** / Last updated / 最后更新 | 2026-09-23 |
| **Versión ISO** / ISO version / ISO 版本 | 0.1 "Sicaru" (`tobixu-0.1-sicaru-20260923-amd64.iso`) |
| **Snapshot base** / Base snapshot / 基础快照 | `20260920T000000Z` (congelado con acta / frozen with acta / 以纪事冻结) |
| **Horno** / Oven / 炉火 | `hornear.sh` v7.2 — commit `abb2b2e` (caja negra F9 / F9 black box / F9 黑匣) |
| **Host de horneado** / Bake …1) |
| **VM de horneado** / Bake VM / 烘焙虚拟机 | `forja` (80G virtuales, writethrough, unmap) |
| **Repo firmado** / Signed repo / 签名仓库 | `https://mlmateos.github.io/tobixu/apt sid main` |
| **Estado del smoke** / Smoke status / 烟雾状态 | ✅ 11/11 puntos verdes (live + instalado) |
| **Familias cerradas** / Closed families / 已结族群 | F1 – F11 (con testigos / with witnesses / 有证人) |
| **Próxima tarea fría** / Next cold task / 下一个冷任务 | Renombrar disco-rc42.qcow2 a disco-rc45-smoke.qcow2 (con acta) | `tobi-xu-core 0.1.2` (ver apéndice / see appendix / 见附录) |

---

## 🇲🇽 Español

### Contexto

**TobiXu 0.1 "Sicaru"** es una distro STEAM (*STEM & Arts*, no Valve Steam) para científicos técnicos, ingenieros, matemáticos y artistas. Base Debian sid, escritorio Plasma Wayland, repo firmado propio, ISO horneada con `live-build`. Infraestructura:

- **`tetris`**: host físico, laptop del autor, con NVMe sano (`nvme0n1`, 1.8T) y dos SATA auxiliares (`sda` para backups, `sdb` BarraCuda SMR para almacenamiento frío).
- **`forja`**: VM KVM/libvirt donde se hornea la ISO. Vive en el NVMe del host (`~/vms/debiantesting.qcow2`, 80G virtuales, cache `writethrough`, discard `unmap`).
- **`hornear.sh`**: script maestro en `~/projects/tobixu/tools/hornear.sh` (tetris). **Forja no se edita: forja recibe** copias con nombre y apellido (`~/hornear-rc4.sh`).
- **MacBook Air del autor**: destino final del smoke test de once puntos.

### Doctrinas selladas

1. **El repo es la fuente de verdad**. Forja hornea, Tetris jala y sella. Ningún cambio vive solo en la VM.
2. **Forja no se edita: forja recibe**. Toda modificación al horno se injerta en el máster (`hornear.sh` en tetris), se sintaxea, se traspasa y se commitea.
3. **Snapshot congelado con acta**. El snapshot base se congela (hoy `20260920T000000Z`); no se persiguen point-releases del kernel en cada horneada. El kernel sube en el primer `full-upgrade` del sistema instalado.
4. **Una variable por día**. Cuando algo falla, se cambia una sola cosa y se vuelve a hornear. Mezclar variables el día del cruce produce diagnósticos imposibles.
5. **El instalado es un río; la ISO es una foto**. El sistema instalado se actualiza solo vía `apt full-upgrade` (sid vivo + repo firmado). La ISO se re-hornea para nuevas máquinas, nunca para updates.
6. **Las absoluciones solo valen para el disco que se midió**. Un `smartctl -H` PASSED no absuelve ningún otro disco del host.
7. **Los ladrillos de horno viven en NVMe, nunca en SMR**. El techo de tejas magnéticas (SMR) no soporta escrituras aleatorias sostenidas; pausa bajo carga. F9 se cerró por eso.
8. **Un horno que cae dos veces al mismo río tiene un mapa**. No se rebooteará jamás sin capturar primero la traza del kernel.
9. **La caja negra es innegociable**. Todo horno debe llevar dentro un watchdog que capture testigos automáticos si algún proceso cae en estado `D`.
10. **La muralla de la despensa vive en el primer arranque, no en el horno**. Calamares reescribe `sources.list` y locales al instalar (F11). La defensa es un trigger post-install, no un hook de build.
11. **Cuando dos autoridades se contradicen, se opera con la que no miente** (`dpkg` sobre apt, el kernel sobre systemd, el check de qcow2 sobre el df).
12. **El `mtime` es metadato, no testigo**. Los bautizos de ISO se firman por contenido (`sha256sum`), no por fecha de archivo.

### Familias de cicatrices (F1 – F11)

Cada familia es un patrón de fallo con cura conocida y testigo grabado.

| # | Familia | Causa raíz | Cura | Testigo |
|---|---|---|---|---|
| F1 | Contabilidad rota | `rm -rf` a mano sobre `.build`, cache, stamps | `lb clean --all` al inicio del script | Log con `LB EXIT: 0` |
| F2 | Dueños equivocados | Archivos creados como root que bloquean el usuario | `chown` correcto post-bootstrap | `ls -l` en verde |
| F3 | Montajes colgados | `/proc`, `/sys`, `/dev` montados al abortar | `lb clean --purge` al inicio | Ningún `mountpoint` activo |
| F4 | Espejo inestable | Snapshot poco propagado con descargas que fallan | Snapshot probado; bump de snapshot solo con acta | `apt-get` sin `Failed to fetch` |
| F5 | Relojes mentirosos | `mtime` de archivos que disparan rebuilds falsos | Bautizo por contenido, no por edad | `sha256sum -c` en verde |
| F6 | Hook que se come el chroot | `.chroot` corriendo con el chroot vivo | Puerta entre etapas: purga + triple testigo + renombrado en quietud | `ii=0 any=0 sesiones=0` |
| F7 | Colibríes fósiles (LXQt) | Recomendaciones de `apt` que re-sembraban LXQt | Pin negativo en `preferences.chroot` + jubilación en `010-desktop.list.chroot` | `dpkg -l \| grep -cE "pcmanfm\|qterminal\|lxqt\|obconf"` = 0 |
| F8 | Puerta sin nombre | Instalador llamado "Install Debian" | Hook en `.binary` que renombra `desktop-file` de Calamares | Icono "Install Tobi Xu" en escritorio |
| F9 | Asesino silencioso | qcow2 sobre SATA SMR con cache writeback + refcounts agrietados | Mudanza del ladrillo a NVMe + cache writethrough + discard unmap + caja negra | `qemu-img check` limpio + sin `D` en build |
| F10 | Branding vecino | Menú de arranque, wallpaper live, greeter, Konqi que dicen "Debian" | Tarea fría: `includes.binary`, wallpaper default, greeter selva, reemplazo de Konqi | Capturas de cada punto |
| F11 | Despensa reescrita | Calamares pisa `sources.list` y locales al instalar | Trigger de primer arranque en `tobi-xu-core 0.1.2` | `apt policy` sin trixie + tríada intacta post-boot |

### Decisiones de diseño intencionales

- **Tríada de locales**: `LANG=en_US.UTF-8` (lingua franca técnica), `LC_TIME=en_DK.UTF-8` (24h, DD/MM/YYYY), `LC_MEASUREMENT=es_MX.UTF-8` (métrico). No es mezcla rota: es arquitectura. Cada capa tapa un hueco de `en_US` (que niega métrico y 24h). Se defiende vía trigger post-install.
- **Keyboard inglés con teclas modificadas**: decisión del autor; documentar en `docs/keyboard.md` cuando se provean los detalles.
- **Snapshot congelado**: se cambia solo con acta, tras propagación verificada (2–3 días desde publicación).
- **Pin negativo LXQt**: prioridad `-1` sobre toda la familia LXQt en `preferences.chroot`. Cinturón permanente.
- **Union filesystem**: `overlay` por ahora. Si F9 vuelve tras la mudanza a NVMe, se cambiará a `LB_UNION_FILESYSTEM='none'` con acta.
- **Sudoers mínimo en forja**: solo `hornear-*.sh` corre con `sudo -n`. Ningún otro comando privilegiado en la VM.
- **Aduana de cinco frentes** previa a toda horneada: suelo, pedido, snapshot, union, ladrillo (con `qemu-img check`).

### Tareas frías post-release 0

Ordenadas por prioridad. Todas se hacen **en frío**, con la VM apagada y con acta.

1. **Trigger `tobi-xu-core 0.1.2`**: script idempotente en `/usr/lib/tobixu/first-boot.sh` + unidad systemd oneshot. Misiones: restaurar tríada de locales, limpiar sources trixie, renombrar puerta del instalado. (Ver apéndice abajo.)
2. **Bump de snapshot**: cuando `20260923+` esté bien propagado, con acta. Verificar que kernel y Plasma sigan en el snapshot.
3. **Firmado GPG del bautizo**: hook `hooks/live/9999-sign.binary` que haga `gpg --detach-sign` sobre `SHA256SUMS`.
4. **Geometría de 80G de forja**: swap a swapfile, borrar `vda2`/`vda5`, `growpart`, `resize2fs`.
5. **Branding F10**: menú de arranque TobiXu, wallpaper default órbita, greeter con caja selva, reemplazo de Konqi por Guchaachi'.
6. **Autostart de la puerta**: que "Install Tobi Xu" se abra al entrar al live. Decisión de producto.
7. **Jubilación del espécimen F9**: `debiantesting-f9-corrupta.qcow2` a borrado, tras smoke en verde.
8. **Repo STEAM**: paqueteo de herramientas STEM & Arts en `tobi-xu-steam`, con aduana nueva por su closure enorme.

### Inventario de infraestructura

| Componente | Estado | Notas |
|---|---|---|
| `tetris` host | NVMe sano (SMART PASSED), kernel 7.2.6-1 | Dos reboots con VM viva agrietaron el qcow2 viejo |
| `forja` VM | 80G virtuales, 16G reales, NVMe | Cache writethrough, discard unmap |
| `sdb` BarraCuda SMR (`ST4000DM004-2U9104`) | Sano para almacenamiento frío | **No sirve para horno**: pausas bajo escrituras aleatorias |
| `hornear.sh` v7.2 | Injertado con caja negra F9 | Commit `abb2b2e` |
| Snapshot base | `20260920T000000Z` | Propagado, sin fallos de descarga |
| Repo firmado TobiXu | `https://mlmateos.github.io/tobixu/apt sid main` | Keyring en `/etc/apt/keyrings/tobixu.gpg` |

### Epitafio de F9

> *"El asesino silencioso no vivía en nuestro código, ni en Debian, ni en el ladrillo: vivía en el techo de tejas del host, esperando la tormenta de escrituras. Nombre y apellido: Seagate BarraCuda SMR, modelo ST4000DM004-2U9104. Enterrado con acta en `/media/manuel/debiantesting-f9-corrupta.qcow2`."*

---

## 🇬🇧 English

### Context

**TobiXu 0.1 "Sicaru"** is a STEAM (*STEM & Arts*, not Valve Steam) distro for technical scientists, engineers, mathematicians, and artists. Debian sid base, Plasma Wayland desktop, own signed repo, ISO baked with `live-build`. Infrastructure:

- **`tetris`**: physical host, author's laptop, with a healthy NVMe (`nvme0n1`, 1.8T) and two auxiliary SATA drives (`sda` for backups, `sdb` BarraCuda SMR for cold storage).
- **`forja`**: KVM/libvirt VM where the ISO is baked. Lives on the host's NVMe (`~/vms/debiantesting.qcow2`, 80G virtual, cache `writethrough`, discard `unmap`).
- **`hornear.sh`**: master script at `~/projects/tobixu/tools/hornear.sh` (tetris). **Forja is never edited: forja receives** named copies (`~/hornear-rc4.sh`).
- **Author's MacBook Air**: final destination of the eleven-point smoke test.

### Sealed doctrines

1. **The repo is the source of truth**. Forja bakes, Tetris pulls and seals. No change ever lives only on the VM.
2. **Forja is never edited: forja receives**. Every oven change is grafted onto the master (`hornear.sh` on tetris), syntax-checked, transferred, and committed.
3. **Frozen snapshot with acta**. The base snapshot is frozen (today `20260920T000000Z`); kernel point-releases are not chased on every bake. The kernel upgrades on the first `full-upgrade` of the installed system.
4. **One variable per day**. When something fails, change one thing and rebake. Mixing variables on crossing day makes diagnosis impossible.
5. **The installed system is a river; the ISO is a photo**. The installed system self-updates via `apt full-upgrade` (sid live + signed repo). The ISO is rebaked for new machines, never for updates.
6. **Acquittals only apply to the disk that was measured**. A `smartctl -H` PASSED does not acquit any other host disk.
7. **Oven bricks live on NVMe, never on SMR**. Shingled magnetic recording (SMR) does not tolerate sustained random writes; it stalls under load. F9 was closed for this reason.
8. **An oven that falls twice into the same river has a map**. Never reboot without first capturing the kernel trace.
9. **The black box is non-negotiable**. Every oven must carry inside a watchdog that captures automatic witnesses if any process falls into `D` state.
10. **The pantry wall lives at first boot, not at bake time**. Calamares rewrites `sources.list` and locales on install (F11). The defense is a post-install trigger, not a build hook.
11. **When two authorities contradict, operate on the one that doesn't lie** (`dpkg` over apt, the kernel over systemd, qcow2 check over df).
12. **`mtime` is metadata, not witness**. ISO baptisms are signed by content (`sha256sum`), never by file date.

### Scar families (F1 – F11)

Each family is a failure pattern with a known cure and a recorded witness.

| # | Family | Root cause | Cure | Witness |
|---|---|---|---|---|
| F1 | Broken accounting | Manual `rm -rf` on `.build`, cache, stamps | `lb clean --all` at script start | Log with `LB EXIT: 0` |
| F2 | Wrong owners | Root-created files blocking the user | Correct `chown` post-bootstrap | `ls -l` in green |
| F3 | Dangling mounts | `/proc`, `/sys`, `/dev` mounted on abort | `lb clean --purge` at start | No active `mountpoint` |
| F4 | Unstable mirror | Under-propagated snapshot with failing fetches | Proven snapshot; snapshot bump only with acta | `apt-get` with no `Failed to fetch` |
| F5 | Lying clocks | File `mtime` triggering spurious rebuilds | Baptism by content, not by age | `sha256sum -c` in green |
| F6 | Hook that eats the chroot | `.chroot` running with a live chroot | Door between stages: purge + triple witness + rename in quiet | `ii=0 any=0 sessions=0` |
| F7 | Fossil hummingbirds (LXQt) | `apt` recommendations re-seeding LXQt | Negative pin in `preferences.chroot` + retirement in `010-desktop.list.chroot` | `dpkg -l \| grep -cE "pcmanfm\|qterminal\|lxqt\|obconf"` = 0 |
| F8 | Nameless door | Installer called "Install Debian" | Hook in `.binary` renaming Calamares' `desktop-file` | "Install Tobi Xu" icon on desktop |
| F9 | Silent killer | qcow2 on SATA SMR with writeback cache + cracked refcounts | Brick migration to NVMe + writethrough cache + unmap discard + black box | `qemu-img check` clean + no `D` in build |
| F10 | Neighbor branding | Boot menu, live wallpaper, greeter, Konqi saying "Debian" | Cold task: `includes.binary`, default wallpaper, selva greeter, Konqi replacement | Screenshots of each point |
| F11 | Rewritten pantry | Calamares stomps `sources.list` and locales on install | First-boot trigger in `tobi-xu-core 0.1.2` | `apt policy` trixie-free + triad intact post-boot |

### Intentional design decisions

- **Locale triad**: `LANG=en_US.UTF-8` (technical lingua franca), `LC_TIME=en_DK.UTF-8` (24h, DD/MM/YYYY), `LC_MEASUREMENT=es_MX.UTF-8` (metric). Not a broken mix: architecture. Each layer covers a gap in `en_US` (which denies metric and 24h). Defended via post-install trigger.
- **English keyboard with modified keys**: author's choice; to be documented in `docs/keyboard.md` when details are provided.
- **Frozen snapshot**: changed only with acta, after verified propagation (2–3 days from publication).
- **Negative LXQt pin**: priority `-1` on the whole LXQt family in `preferences.chroot`. Permanent belt.
- **Union filesystem**: `overlay` for now. If F9 returns after the NVMe migration, switch to `LB_UNION_FILESYSTEM='none'` with acta.
- **Minimal sudoers on forja**: only `hornear-*.sh` runs with `sudo -n`. No other privileged command on the VM.
- **Five-front customs** before every bake: floor, order, snapshot, union, brick (with `qemu-img check`).

### Cold tasks post-release 0

Ordered by priority. All done **cold**, with the VM off and with acta.

1. **`tobi-xu-core 0.1.2` trigger**: idempotent script at `/usr/lib/tobixu/first-boot.sh` + systemd oneshot unit. Missions: restore locale triad, clean trixie sources, rename installer door. (See appendix below.)
2. **Snapshot bump**: when `20260923+` is well propagated, with acta. Verify kernel and Plasma still present in the snapshot.
3. **Baptism GPG signing**: `hooks/live/9999-sign.binary` hook running `gpg --detach-sign` on `SHA256SUMS`.
4. **80G geometry for forja**: swap to swapfile, remove `vda2`/`vda5`, `growpart`, `resize2fs`.
5. **F10 branding**: TobiXu boot menu, órbita default wallpaper, selva greeter box, Konqi replacement with Guchaachi'.
6. **Door autostart**: "Install Tobi Xu" opens on entering the live session. Product decision.
7. **F11 specimen retirement**: `debiantesting-f9-corrupta.qcow2` to be deleted, after green smoke.
8. **STEAM repo**: packaging of STEM & Arts tools in `tobi-xu-steam`, with new customs for its large closure.

### Infrastructure inventory

| Component | Status | Notes |
|---|---|---|
| `tetris` host | Healthy NVMe (SMART PASSED), kernel 7.2.6-1 | Two reboots with live VM cracked the old qcow2 |
| `forja` VM | 80G virtual, 16G real, NVMe | Cache writethrough, discard unmap |
| `sdb` BarraCuda SMR (`ST4000DM004-2U9104`) | Healthy for cold storage | **Not fit for oven**: stalls under random writes |
| `hornear.sh` v7.2 | Grafted with F9 black box | Commit `abb2b2e` |
| Base snapshot | `20260920T000000Z` | Propagated, no fetch failures |
| Signed TobiXu repo | `https://mlmateos.github.io/tobixu/apt sid main` | Keyring at `/etc/apt/keyrings/tobixu.gpg` |

### F9 epitaph

> *"The silent killer did not live in our code, nor in Debian, nor in the brick: it lived in the host's shingled roof, waiting for the write storm. Name and surname: Seagate BarraCuda SMR, model ST4000DM004-2U9104. Buried with acta in `/media/manuel/debiantesting-f9-corrupta.qcow2`."*

---

## 🇨🇳 中文

### 项目背景

**TobiXu 0.1 "Sicaru"** 是面向技术科学家、工程师、数学家和艺术家的 STEAM (*STEM & Arts*，非 Valve Steam) 发行版。基于 Debian sid，Plasma Wayland 桌面，自有签名仓库，使用 `live-build` 烘焙 ISO。基础设施：

- **`tetris`**：物理主机，作者的笔记本，含健康 NVMe（`nvme0n1`，1.8T）和两块辅助 SATA（`sda` 备份用，`sdb` BarraCuda SMR 作冷存储）。
- **`forja`**：烘焙 ISO 的 KVM/libvirt 虚拟机。驻于主机 NVMe 之上（`~/vms/debiantesting.qcow2`，虚拟 80G，cache `writethrough`，discard `unmap`）。
- **`hornear.sh`**：位于 `~/projects/tobixu/tools/hornear.sh`（tetris）的主脚本。**Forja 永不直接编辑：Forja 只接收**带名副本（`~/hornear-rc4.sh`）。
- **作者的 MacBook Air**：十一点烟雾测试的最终目的地。

### 已封印的准则

1. **仓库即真相之源**。Forja 烘焙，Tetris 拉取与封印。任何变更都不得只驻留于虚拟机。
2. **Forja 永不直接编辑：Forja 只接收**。任何对炉火的修改都必须嫁接到母本（tetris 上的 `hornear.sh`）、语法检查、转移并提交。
3. **带纪事的冻结快照**。基础快照冻结（当前为 `20260920T000000Z`）；不在每次烘焙中追踪内核小版本。内核在已安装系统的第一次 `full-upgrade` 时升级。
4. **一日一变量**。故障时只改一处、重新烘焙。渡河之日混合变量将令诊断不可能。
5. **已装系统为河，ISO 为照**。已装系统通过 `apt full-upgrade` 自我更新（sid 活跃 + 签名仓库）。ISO 只为新机重焙，从不为更新重焙。
6. **无罪仅对所测之盘成立**。一次 `smartctl -H` PASSED 不能为主机其它磁盘洗脱嫌疑。
7. **炉砖只居 NVMe，永不 SMR**。叠瓦式磁记录（SMR）无法承受持续随机写入，会在负载下停顿。F9 因此结案。
8. **一炉两次坠入同河，必有地图**。不得在未捕获内核踪迹前重启。
9. **黑匣不可妥协**。每座炉火必须内置守护，一旦进程陷入 `D` 态即自动捕获证人。
10. **粮仓之墙立于首次启动，不在烘焙时**。Calamares 会在安装时重写 `sources.list` 与区域设置（F11）。防线是安装后触发器，而非构建钩子。
11. **两权相悖时，取不说谎者**（`dpkg` 优先于 apt，内核优先于 systemd，qcow2 检查优先于 df）。
12. **`mtime` 是元数据，不是证人**。ISO 洗礼以内容（`sha256sum`）为凭，不以文件日期为凭。

### 伤疤族群（F1 – F11）

每一族群都是一个故障模式，附已知疗法与录下的证人。

| # | 族群 | 根因 | 疗法 | 证人 |
|---|---|---|---|---|
| F1 | 账本崩坏 | 手动 `rm -rf` `.build`、缓存、戳记 | 脚本起始处 `lb clean --all` | 日志含 `LB EXIT: 0` |
| F2 | 属主错位 | root 所创文件阻塞用户 | bootstrap 后正确 `chown` | `ls -l` 绿色 |
| F3 | 悬挂挂载 | 中止时 `/proc`、`/sys`、`/dev` 已挂载 | 起始处 `lb clean --purge` | 无活动 `mountpoint` |
| F4 | 镜像不稳 | 未传播快照导致 fetch 失败 | 已验证快照；仅在纪事中升级快照 | `apt-get` 无 `Failed to fetch` |
| F5 | 谎言之钟 | 文件 `mtime` 引发虚假重筑 | 依内容洗礼，不依年龄 | `sha256sum -c` 绿色 |
| F6 | 吞 chroot 的钩子 | `.chroot` 在活跃 chroot 上运行 | 阶段间门：静默中清场 + 三重证人 + 更名 | `ii=0 any=0 sessions=0` |
| F7 | 化石蜂鸟（LXQt） | `apt` 推荐重新播撒 LXQt | `preferences.chroot` 负优先级 + `010-desktop.list.chroot` 中退役 | `dpkg -l \| grep -cE "pcmanfm\|qterminal\|lxqt\|obconf"` = 0 |
| F8 | 无名之门 | 安装器名 "Install Debian" | `.binary` 钩子重命名 Calamares 的 `desktop-file` | 桌面图标 "Install Tobi Xu" |
| F9 | 沉默杀手 | SATA SMR 上 qcow2 + writeback 缓存 + 破损 refcount | 砖迁 NVMe + writethrough 缓存 + unmap discard + 黑匣 | `qemu-img check` 清洁 + 构建无 `D` |
| F10 | 邻居品牌 | 启动菜单、live 壁纸、greeter、Konqi 仍言 "Debian" | 冷任务：`includes.binary`、默认壁纸、丛林 greeter、Konqi 替换 | 各点截图 |
| F11 | 被重写粮仓 | Calamares 安装时践踏 `sources.list` 与 locale | `tobi-xu-core 0.1.2` 首次启动触发器 | `apt policy` 无 trixie + 三件套完整 |

### 有意的架构决定

- **区域三件套**：`LANG=en_US.UTF-8`（技术通用语）、`LC_TIME=en_DK.UTF-8`（24 时制、DD/MM/YYYY）、`LC_MEASUREMENT=es_MX.UTF-8`（公制）。非破损拼凑：是架构。每层覆盖 `en_US` 的一处缺口（它拒绝公制与 24 时制）。由安装后触发器守护。
- **英式键盘配改键**：作者之选；待细节提供后记录于 `docs/keyboard.md`。
- **冻结快照**：仅在验证传播后（发布后 2–3 日）以纪事改之。
- **LXQt 负优先级**：`preferences.chroot` 中整个 LXQt 族优先级 `-1`。永久腰带。
- **联合文件系统**：目前为 `overlay`。若迁 NVMe 后 F9 再临，则以纪事改为 `LB_UNION_FILESYSTEM='none'`。
- **Forja 最小 sudoers**：仅 `hornear-*.sh` 以 `sudo -n` 运行。虚拟机上无其它特权命令。
- **五关验前**：每次烘焙前必经——地基、订单、快照、联合、砖（含 `qemu-img check`）。

### 0 版发布后的冷任务

按优先级排序。全部在**冷态**下进行：虚拟机关闭并附纪事。

1. **`tobi-xu-core 0.1.2` 触发器**：位于 `/usr/lib/tobixu/first-boot.sh` 的幂等脚本 + systemd oneshot 单元。任务：恢复区域三件套、清理 trixie 源、更名安装器之门。（见下方附录。）
2. **快照升级**：待 `20260923+` 充分传播后，以纪事行之。验证内核与 Plasma 仍在新快照中。
3. **洗礼 GPG 签名**：`hooks/live/9999-sign.binary` 钩子对 `SHA256SUMS` 执行 `gpg --detach-sign`。
4. **Forja 的 80G 几何**：swap 转为 swapfile，移除 `vda2`/`vda5`，`growpart`、`resize2fs`。
5. **F10 品牌**：TobiXu 启动菜单、órbita 默认壁纸、丛林 greeter 框、Konqi 替换为 Guchaachi'。
6. **门之自启**："Install Tobi Xu" 在 live 会话启动时自动打开。产品决定。
7. **F9 标本退役**：绿色烟雾测试后，删除 `debiantesting-f9-corrupta.qcow2`。
8. **STEAM 仓库**：在 `tobi-xu-steam` 中打包 STEM & Arts 工具，并为大闭包设新关验。

### 基础设施清单

| 组件 | 状态 | 备注 |
|---|---|---|
| `tetris` 主机 | NVMe 健康（SMART PASSED），内核 7.2.6-1 | 虚拟机运行时两次重启撕裂了旧 qcow2 |
| `forja` 虚拟机 | 虚拟 80G，实际 16G，NVMe | cache writethrough，discard unmap |
| `sdb` BarraCuda SMR (`ST4000DM004-2U9104`) | 冷存储健康 | **不适合作炉**：随机写入下停顿 |
| `hornear.sh` v7.2 | 嫁接 F9 黑匣 | 提交 `abb2b2e` |
| 基础快照 | `20260920T000000Z` | 已传播，无 fetch 失败 |
| 签名 TobiXu 仓库 | `https://mlmateos.github.io/tobixu/apt sid main` | 密钥环位于 `/etc/apt/keyrings/tobixu.gpg` |

### F9 墓志铭

> *沉默的杀手不住在我们的代码里，不住在 Debian 里，也不住在砖里：它住在主机的叠瓦屋顶之下，等候写入的风暴。姓名与姓氏：Seagate BarraCuda SMR，型号 ST4000DM004-2U9104。以纪事葬于 `/media/manuel/debiantesting-f9-corrupta.qcow2`。*

---

* * *

## 📅 Bitácora de sesiones / Session log / 会话日志

### 2026-09-25 — Camino A sellado, doctrina 13, F12

- **Forense del disco smoke** (doctrina 11): autopsia de `disco-rc42.qcow2` reveló que el archivo es nuevo (nacimiento 23-sep, primer boot 23-sep 12:11, 10 boots, sin `/var/log/calamares/`). Kernel 7.2.6→7.2.7 vía `full-upgrade`; `pcmanfm-qt`/`qterminal` ausentes confirman estrato rc4.5+. El nombre `disco-rc42.qcow2` es una reliquia mentirosa. **Tarea fría:** renombrar a `disco-rc45-smoke.qcow2` con acta (VM apagada).
- **F12 "El cordón umbilical"**: 26 hooks en `hooks/{normal,live}` eran symlinks (`git mode 120000`) apuntando a `/usr/share/live/build/hooks/...` de forja. En tetris eran rotos; `diff -rq` salía con exit 2. Cura: dereferenciar (rm + cp + chmod) y congelar en el repo. Testigo: `diff -rq` exit 0, cero líneas.
- **Triada v2 de locales**: `en_DK` jubilado (punto en reloj CLDR/Qt), `es_MX` descartado (12h en glibc), `en_GB` ganador (24h con dos puntos). Aplicada en `includes.chroot/etc/environment`, hook `0200-locales` y trigger `first-boot.sh`.
- **Doctrina 13: "Los defaults son semillas, no cadenas"**: el sistema siembra una vez; el usuario cosecha (`plasma-localerc`, `localectl`) o re-siembra. Implementación: `/etc/tobixu/defaults.conf` con interruptores `APPLY_*` y semillas `DEF_*`; re-sembrado documentado (editar conf, borrar marcador, restart del servicio).
- **tobi-xu-core 0.1.2 construido, firmado, inyectado, recibido**: `dpkg-deb --build --root-owner-group` → `reprepro includedeb sid` → push → `apt install` en smoke-rc45 → trigger corrido en caliente (sin reboot) → `/etc/locale.conf` reconciliado con la triada v2. Camino A sellado con testigo vivo en `/var/log/tobixu-first-boot.log`.
- **Observación para el libro**: Calamares no deja `/var/log/calamares/` en el sistema instalado (T1 vacío en la autopsia) — justificación para que el trigger de primer arranque sí deje acta en `/var/log/tobixu-first-boot.log`.
- **Polizones**: `tools/hornear.sh.pre-cajanegra` borrado (git ya tenía la versión en historial, duplicado es ruido); `tools/checkpoints.md` trackeado (runbook de caja negra F9).

### 2026-09-25 — Sealed Road A, Doctrine 13, F12

- **Smoke disk forensics** (doctrine 11): autopsy of `disco-rc42.qcow2` showed the file is new (birth 23-sep, first boot 23-sep 12:11, 10 boots, no `/var/log/calamares/`). Kernel 7.2.6→7.2.7 via `full-upgrade`; absence of `pcmanfm-qt`/`qterminal` confirms rc4.5+ stratum. The filename `disco-rc42.qcow2` is a lying relic. **Cold task:** rename to `disco-rc45-smoke.qcow2` with acta (VM off).
- **F12 "The umbilical cord"**: 26 hooks under `hooks/{normal,live}` were symlinks (`git mode 120000`) pointing at `/usr/share/live/build/hooks/...` on the forge. On tetris they were dangling; `diff -rq` exited with 2. Cure: dereference (rm + cp + chmod) and freeze in the repo. Witness: `diff -rq` exit 0, zero lines.
- **Locale triad v2**: `en_DK` retired (dot on clock per CLDR/Qt), `es_MX` discarded (12h in glibc), `en_GB` the winner (24h with colons). Applied to `includes.chroot/etc/environment`, hook `0200-locales`, and the `first-boot.sh` trigger.
- **Doctrine 13: "Defaults are seeds, not chains"**: the system seeds once; the user harvests (`plasma-localerc`, `localectl`) or re-seeds. Implementation: `/etc/tobixu/defaults.conf` with `APPLY_*` switches and `DEF_*` seeds; re-seeding documented (edit conf, remove marker, restart service).
- **tobi-xu-core 0.1.2 built, signed, injected, received**: `dpkg-deb --build --root-owner-group` → `reprepro includedeb sid` → push → `apt install` on smoke-rc45 → trigger ran hot (no reboot) → `/etc/locale.conf` reconciled with triad v2. Road A sealed with a living witness at `/var/log/tobixu-first-boot.log`.
- **Observation for the book**: Calamares leaves no `/var/log/calamares/` on the installed system (T1 empty on the autopsy) — justification for the first-boot trigger leaving an acta at `/var/log/tobixu-first-boot.log`.
- **Stragglers**: `tools/hornear.sh.pre-cajanegra` deleted (git already had the version in history, duplicate is noise); `tools/checkpoints.md` tracked (F9 black-box runbook).

### 2026-09-25 — A 路封印，准则 13，F12

- **烟雾盘取证**（准则 11）：对 `disco-rc42.qcow2` 的尸检显示文件是新的（诞生 9 月 23 日，首次启动 12:11，10 次引导，无 `/var/log/calamares/`）。内核 7.2.6→7.2.7 经由 `full-upgrade`；`pcmanfm-qt`/`qterminal` 缺失确认为 rc4.5+ 地层。文件名 `disco-rc42.qcow2` 是一则谎称的遗迹。**冷任务**：VM 关闭状态下以纪事更名为 `disco-rc45-smoke.qcow2`。
- **F12「脐带」**：`hooks/{normal,live}` 下 26 个钩子均为符号链接（`git mode 120000`），指向 Forja 上的 `/usr/share/live/build/hooks/...`。在 Tetris 上为悬空链接；`diff -rq` 以退出码 2 告终。疗法：解引用（rm + cp + chmod）并冻结于仓库。证人：`diff -rq` 退出码 0，零行。
- **区域三件套 v2**：`en_DK` 退役（CLDR/Qt 下时钟显点），`es_MX` 弃用（glibc 中为 12 时制），`en_GB` 胜出（24 时制带冒号）。应用于 `includes.chroot/etc/environment`、钩子 `0200-locales` 与 `first-boot.sh` 触发器。
- **准则 13：「默认即种籽，非锁链」**：系统播种一次；用户收割（`plasma-localerc`、`localectl`）或重新播种。实现：`/etc/tobixu/defaults.conf` 含 `APPLY_*` 开关与 `DEF_*` 种籽；重新播种文档化（编辑配置、删除标记、重启服务）。
- **tobi-xu-core 0.1.2 构建、签名、注入、接收**：`dpkg-deb --build --root-owner-group` → `reprepro includedeb sid` → 推送 → smoke-rc45 上 `apt install` → 触发器热启动运行（无重启）→ `/etc/locale.conf` 已与三件套 v2 和解。A 路以 `/var/log/tobixu-first-boot.log` 中的活体证人封印。
- **书中注记**：Calamares 在已安装系统上不留 `/var/log/calamares/`（尸检中 T1 为空）——此为首次启动触发器在 `/var/log/tobixu-first-boot.log` 留纪事的理由。
- **游散文件**：删除 `tools/hornear.sh.pre-cajanegra`（git 历史中已有该版本，重复即噪声）；`tools/checkpoints.md` 纳入跟踪（F9 黑匣运行簿）。

### 2026-09-25 (tarde) — rc6 canonica; cicatrices F13–F18

- **F13 "El sudoers con nombre y apellido"**: sudoers literal `hornear-rc4.sh` mato el lanzamiento de rc5 (`a password is required`). Cura: patron `hornear-*.sh`.
- **F14 descartada con testigos**: el "bautizo en 8 min" de rc5 era real (caches); el bautizo sin criatura se descarto al hallar la ISO renombrada. Leccion: verificar por **mtime y SHA256**, no por nombre.
- **F15 "El mensajero sin audiencia"**: `localectl` da Access denied en boot temprano (sin agente polkit). Cura (0.1.3): escritura directa de `/etc/locale.conf`.
- **F16 "La muralla que vacia la despensa"**: la mision 2 barria el sources.list trixie sin reponer sid. Cura (0.1.3): garantizar `debian.sources` (unstable) antes de expulsar.
- **F17 "El grub que pregunta a nadie"**: Discover sin terminal debconf rompio el full-upgrade (grub-pc exit 1). Cura (0.1.4, mision 4): preseed debconf con el disco raiz detectado en el primer arranque. Testigo: grub 2.14-3 actualizado sin dialogo.
- **F18 "El paste devoralineas" y el horno fantasma**: seis pastes troceados en un dia; un comando de diagnostico (`| head`) decapito un horno con SIGPIPE. Doctrina nueva: bloques cortos, y ningun diagnostico toca el horno.
- **rc5 al museo** como no canonica (acta de F15+F16); **rc6 canonica de sicaru**: ISO `tobixu-0.1-sicaru-rc6-20260925-amd64.iso` (SHA256 `17ee39e1…`), tobi-xu-core 0.1.4 de fabrica, kernel 7.2.7 por el rio tras reboot.
- Snapshot forja #7: `7-v0.1-rc6-canonica`.

### 2026-09-25 (afternoon) — rc6 canonical; scars F13–F18

- **F13 "The sudoers with a surname"**: literal `hornear-rc4.sh` in sudoers killed the rc5 launch (`a password is required`). Cure: pattern `hornear-*.sh`.
- **F14 discarded with witnesses**: rc5's "8-minute baptism" was real (caches); the baptism-without-creature was discarded upon finding the renamed ISO. Lesson: verify by **mtime and SHA256**, not by name.
- **F15 "The messenger with no audience"**: `localectl` yields Access denied at early boot (no polkit agent). Cure (0.1.3): direct write of `/etc/locale.conf`.
- **F16 "The wall that empties the pantry"**: mission 2 swept the trixie sources.list without restoring sid. Cure (0.1.3): guarantee `debian.sources` (unstable) before sweeping.
- **F17 "The grub that asks nobody"**: Discover without a debconf terminal broke the full-upgrade (grub-pc exit 1). Cure (0.1.4, mission 4): debconf preseed with the root disk detected at first boot. Witness: grub 2.14-3 upgraded with no dialog.
- **F18 "The line-eating paste" and the ghost oven**: six truncated pastes in one day; a diagnostic command (`| head`) beheaded an oven with SIGPIPE. New doctrine: short blocks, and no diagnostic touches the oven.
- **rc5 to the museum** as non-canonical (acta of F15+F16); **rc6 canonical of sicaru**: ISO `tobixu-0.1-sicaru-rc6-20260925-amd64.iso` (SHA256 `17ee39e1…`), tobi-xu-core 0.1.4 from factory, kernel 7.2.7 via the river after reboot.
- Forge snapshot #7: `7-v0.1-rc6-canonica`.

### 2026-09-25（下午）— rc6 正典；伤痕 F13–F18

- **F13「带姓氏的 sudoers」**：sudoers 中字面的 `hornear-rc4.sh` 扼杀了 rc5 的启动（`a password is required`）。疗法：模式 `hornear-*.sh`。
- **F14 以证人排除**：rc5 的「8 分钟洗礼」为真（缓存）；「无婴之洗礼」在找到已更名 ISO 后被排除。教训：以 **mtime 与 SHA256** 验证，而非名称。
- **F15「无人接见的信使」**：`localectl` 在早期启动时返回 Access denied（无 polkit 代理）。疗法（0.1.3）：直接写 `/etc/locale.conf`。
- **F16「清空食品库的城墙」**：任务 2 扫除 trixie 的 sources.list 却未补回 sid。疗法（0.1.3）：扫除前保证 `debian.sources`（unstable）。
- **F17「无人可问的 grub」**：无 debconf 终端的 Discover 破坏了 full-upgrade（grub-pc exit 1）。疗法（0.1.4，任务 4）：以首启检测到的根盘做 debconf preseed。证人：grub 2.14-3 无对话升级。
- **F18「吞行粘贴」与幽灵烤箱**：一日六次粘贴断行；一条诊断命令（`| head`）以 SIGPIPE 斩首烤箱。新准则：短块操作，诊断不得触碰烤箱。
- **rc5 入博物馆**为非正典（F15+F16 纪事）；**rc6 为 sicaru 正典**：ISO `tobixu-0.1-sicaru-rc6-20260925-amd64.iso`（SHA256 `17ee39e1…`），出厂自带 tobi-xu-core 0.1.4，重启后经河流获得内核 7.2.7。
- Forja 快照 #7：`7-v0.1-rc6-canonica`。

### 2026-09-26 — F19 y el wallpaper que rompio la sesion

- **F19 "El plasmashell que era compositor"**: en Wayland, `killall plasmashell` mata la sesion entera; y las sesiones zombis que no sueltan el compositor se curan con **reboot**, no con restart de sddm (testigo: `loginctl list-sessions` con 8 filas).
- **F10-frente-1 redisenado**: inyectar `Image=` suelto tras `wallpaperplugin=` coloca la clave en el nivel del Containment y **crashea plasmashell** (pantalla negra post-login + journal). Metodo correcto para rc7: crear la subseccion `[Containments][N][Wallpaper][org.kde.image][General]` con su `Image=`, solo en el containment con `formfactor=0`.
- **Nota de entorno**: en QEMU sin aceleracion GL, la sesion X11 de Plasma 6 entra en crash-loop (`glSwapInterval is unsupported`); el aislamiento de fallos se hace con **usuario nuevo**, nunca cambiando a X11.
- rc6 vive como VM de trabajo `tobixurc6` bajo bridge de libvirt (SSH por IP, IPv6 local).

### 2026-09-26 — F19 and the wallpaper that broke the session

- **F19 "The plasmashell that was the compositor"**: on Wayland, `killall plasmashell` kills the whole session; zombie sessions that won't release the compositor are cured with a **reboot**, not an sddm restart (witness: `loginctl list-sessions` with 8 rows).
- **F10-front-1 redesigned**: injecting a loose `Image=` after `wallpaperplugin=` places the key at Containment level and **crashes plasmashell** (black screen post-login + journal). Correct method for rc7: create the `[Containments][N][Wallpaper][org.kde.image][General]` subsection with its `Image=`, only in the containment with `formfactor=0`.
- **Environment note**: on QEMU without GL acceleration, Plasma 6's X11 session enters a crash-loop (`glSwapInterval is unsupported`); fault isolation is done with a **new user**, never by switching to X11.
- rc6 lives as work VM `tobixurc6` under a libvirt bridge (SSH by IP, local IPv6).

### 2026-09-26 — F19 与会破坏会话的壁纸

- **F19「即合成器的 plasmashell」**：Wayland 下 `killall plasmashell` 会杀死整个会话；不释放合成器的僵尸会话须以 **reboot** 治愈，而非重启 sddm（证人：`loginctl list-sessions` 八行）。
- **F10  fronts-1 重新设计**：在 `wallpaperplugin=` 后注入游离 `Image=` 会将键置于 Containment 层并**使 plasmashell 崩溃**（登录后黑屏 + journal）。rc7 的正确方法：仅在 `formfactor=0` 的 containment 中创建带 `Image=` 的 `[Containments][N][Wallpaper][org.kde.image][General]` 子节。
- **环境注记**：在无 GL 加速的 QEMU 中，Plasma 6 的 X11 会话陷入崩溃循环（`glSwapInterval is unsupported`）；故障隔离以**新用户**进行，绝不切换 X11。
- rc6 以工作 VM `tobixurc6` 存活于 libvirt 桥接之下（SSH 用 IP，本地 IPv6）。

---

* * *

# 📎 Apéndice / Appendix / 附录: Trigger `tobi-xu-core 0.1.2`

Diseño listo para integrar en el paquete. Dos archivos:

### 1. `/usr/lib/tobixu/first-boot.sh`

```bash
#!/bin/bash
# Trigger de primer arranque TobiXu 0.1.2
# Misiones: tríada de locales + limpieza de fuentes trixie + renombrado de puerta
# Idempotente: un marcador en /var/lib/tobixu evita re-ejecución

set -euo pipefail

MARKER="/var/lib/tobixu/.first-boot-done"
LOG="/var/log/tobixu-first-boot.log"

exec > >(tee -a "$LOG") 2>&1
echo "== $(date -Is) primer arranque TobiXu =="

# --- Misión 1: tríada de locales ---
# LANG=en_US.UTF-8 (lingua franca) + en_DK (24h, DD/MM/YYYY) + es_MX (métrico)
if command -v localectl >/dev/null 2>&1; then
    localectl set-locale \
        LANG=en_US.UTF-8 \
        LC_TIME=en_DK.UTF-8 \
        LC_MEASUREMENT=es_MX.UTF-8 \
        LC_NUMERIC=es_MX.UTF-8 \
        LC_MONETARY=es_MX.UTF-8 \
        LC_PAPER=es_MX.UTF-8 || echo "localectl: fallo parcial (no fatal)"
fi

# --- Misión 2: limpieza de fuentes trixie ---
# Calamares deja debian.sources / debian-backports.sources al instalar; los expulsamos.
SHOULD_UPDATE=0
for f in /etc/apt/sources.list /etc/apt/sources.list.d/debian.sources \
         /etc/apt/sources.list.d/debian-backports.sources \
         /etc/apt/sources.list.d/debian-backports.list \
         /etc/apt/sources.list.d/debian.list; do
    if [ -f "$f" ] && grep -q -iE "trixie|stable-security|stable-updates" "$f" 2>/dev/null; then
        if [ "$f" = "/etc/apt/sources.list" ]; then
            : > "$f"    # vaciar maestro, no borrar
        else
            rm -f "$f"
        fi
        SHOULD_UPDATE=1
        echo "expulsado: $f"
    fi
done
[ "$SHOULD_UPDATE" -eq 1 ] && apt-get update -y || true

# --- Misión 3: renombrado de puerta del instalado (si aplica) ---
# Calamares desktop-file: /usr/share/applications/calamares.desktop
# Pendiente de decidir si se aplica post-instalación; hoy es un placeholder idempotente.
if [ -f /usr/share/applications/calamares.desktop ]; then
    sed -i 's|^Name=.*Install Debian.*|Name=Install Tobi Xu|' \
           /usr/share/applications/calamares.desktop 2>/dev/null || true
fi

# --- Marcador ---
mkdir -p "$(dirname "$MARKER")"
date -Is > "$MARKER"
echo "== $(date -Is) primer arranque completado =="
```

### 2. `/lib/systemd/system/tobixu-first-boot.service`

```ini
[Unit]
Description=TobiXu first-boot trigger
ConditionPathExists=!/var/lib/tobixu/.first-boot-done
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/lib/tobixu/first-boot.sh
RemainAfterExit=no
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
```

### 3. Integración en `debian/`

En `tobi-xu-core/debian/tobi-xu-core.postinst`:

```bash
if [ "$1" = "configure" ] && [ -z "$2" ]; then
    # Primera instalación en el sistema
    systemctl enable tobixu-first-boot.service
    systemctl start  tobixu-first-boot.service
fi
```

**Comportamiento esperado**: en el primer boot tras Calamares, el servicio corre una sola vez, escribe en `/var/log/tobixu-first-boot.log`, crea el marcador, y systemd ya no lo re-dispara (la condición `ConditionPathExists=!…` lo impide). Si el trigger falla, no hay marcador y systemd reintenta en el siguiente boot.

---

