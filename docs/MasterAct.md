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

### 2026-09-26 — F19, el rostro recuperado y la doctrina del laboratorio

- **F19 "El plasmashell que era compositor"**: en Wayland, `killall plasmashell` mata la sesion; las sesiones zombis que no sueltan el compositor se curan con reboot (testigo: 8 filas en `loginctl list-sessions`).
- **Nota de entorno**: en QEMU sin GL, la sesion X11 de Plasma 6 entra en crash-loop (`glSwapInterval is unsupported`); se aisla con usuario nuevo, nunca con X11.
- **F10-frente-1 curado por congelacion**: inyectar `Image=` suelto crashea plasmashell; el metodo correcto es configurar en el rio y congelar el appletsrc validado al skel (commit a1a1f5b). Doctrina nueva: *el rio es el laboratorio; el skel es la fabrica*.
- **F10-frente-3 parcial**: avatar glifo TobiXu en logout/greeter via `~/.face.icon` + AccountsService; pendiente injertarlo al skel y la geometria del glifo en Main.qml.
- rc6 vive como VM de trabajo `tobixurc6` (bridge libvirt, SSH por IP).

### 2026-09-26 — F19, the recovered face and the laboratory doctrine

- **F19 "The plasmashell that was the compositor"**: on Wayland, `killall plasmashell` kills the session; zombie sessions are cured with a reboot (witness: 8 rows in `loginctl list-sessions`).
- **Environment note**: on QEMU without GL, Plasma 6's X11 session crash-loops (`glSwapInterval is unsupported`); isolate with a new user, never with X11.
- **F10-front-1 cured by freezing**: loose `Image=` injection crashes plasmashell; the correct method is configuring in the river and freezing the validated appletsrc into the skel (commit a1a1f5b). New doctrine: *the river is the laboratory; the skel is the factory*.
- **F10-front-3 partial**: TobiXu glyph avatar on logout/greeter via `~/.face.icon` + AccountsService; pending: inject into skel and fix glyph geometry in Main.qml.
- rc6 lives as work VM `tobixurc6` (libvirt bridge, SSH by IP).

### 2026-09-26 — F19、恢复的面容与实验室准则

- **F19「即合成器的 plasmashell」**：Wayland 下 `killall plasmashell` 杀死会话；僵尸会话以 reboot 治愈（证人：`loginctl list-sessions` 八行）。
- **环境注记**：无 GL 的 QEMU 中 Plasma 6 的 X11 会话崩溃循环（`glSwapInterval is unsupported`）；以新用户隔离，绝不用 X11。
- **F10 fronts-1 以冻结治愈**：游离 `Image=` 注入使 plasmashell 崩溃；正确方法是在河中配置并将验证后的 appletsrc 冻结入 skel（commit a1a1f5b）。新准则：*河是实验室；skel 是工厂*。
- **F10 fronts-3 部分**：登出/greeter 的 TobiXu 字形头像经 `~/.face.icon` + AccountsService；待办：注入 skel 并修正 Main.qml 字形几何。
- rc6 以工作 VM `tobixurc6` 存活（libvirt 桥接，SSH 用 IP）。

### 2026-09-26 (tarde) — rc9 recipiente definitivo; F20–F23

- **F20 "El reset de primer arranque"**: Plasma reescribe el containment de escritorio al reasociarlo a la actividad nueva; un skel no puede congelar el wallpaper del escritorio (el panel trofeo si sobrevive). Cura: autostart de un solo uso con `plasma-apply-wallpaperimage`.
- **F21 "El rsync desde el directorio equivocado"**: rsync ejecutado desde `~` en vez de `~/projects/tobixu` no transfiere nada; verificar `pwd` antes.
- **F22 "El autostart en el directorio de menu"**: `.desktop` de autostart en `~/.local/share/applications/` es invisible para la sesion; los autostarts viven en `~/.config/autostart/`. Cura: `git mv` al directorio correcto (commit fd0f90d).
- **F23 "El autostart que se borraba en el directorio equivocado"**: el script autodestruia la ruta vieja; idempotencia por marcador sigue funcionando. Cura rediseñada: sin autodestruccion; idempotencia por marcador (el .desktop residual es un no-op de 1 ms).
- **rc9 = recipiente definitivo**: trofeo + glifo + orbita-noche de fabrica en el primer login sin intervencion (testigos: marcador 17:57:50, `Image=` correcto, escritorio con orbita-noche). SHA256 `16986eed…`.
- Pendientes de arte para v0.2: Konqi (frente-2), branding de Calamares (frente-4), geometria del glifo en el greeter (frente-3b).

### 2026-09-26 (afternoon) — rc9 definitive vessel; F20–F23

- **F20 "The first-boot reset"**: Plasma rewrites the desktop containment when reassociating it to the new activity; a skel cannot freeze the desktop wallpaper (the trophy panel does survive). Cure: one-shot autostart with `plasma-apply-wallpaperimage`.
- **F21 "The rsync from the wrong directory"**: rsync run from `~` instead of `~/projects/tobixu` transfers nothing; check `pwd` first.
- **F22 "The autostart in the menu directory"**: an autostart `.desktop` in `~/.local/share/applications/` is invisible to the session; autostarts live in `~/.config/autostart/`. Cure: `git mv` to the right directory (commit fd0f90d).
- **F23 "The autostart that deleted itself in the wrong directory"**: the script removed the old path; marker-based idempotency still works. Cure redesigned: no self-deletion; marker-based idempotency (the residual .desktop is a 1 ms no-op).
- **rc9 = definitive vessel**: trophy + glyph + orbita-noche from factory on first login with no intervention (witnesses: marker 17:57:50, correct `Image=`, desktop with orbita-noche). SHA256 `16986eed…`.
- Art pending for v0.2: Konqi (front-2), Calamares branding (front-4), glyph geometry in greeter (front-3b).

### 2026-09-26（下午）— rc9 决定版容器；F20–F23

- **F20「首启重置」**：Plasma 在重新关联新活动时重写桌面 containment；skel 无法冻结桌面壁纸（奖杯面板则存活）。疗法：以 `plasma-apply-wallpaperimage` 的一次性 autostart。
- **F21「错误目录的 rsync」**：在 `~` 而非 `~/projects/tobixu` 运行的 rsync 不传输任何内容；先检查 `pwd`。
- **F22「菜单目录中的 autostart」**：位于 `~/.local/share/applications/` 的 autostart `.desktop` 对会话不可见；autostart 住在 `~/.config/autostart/`。疗法：`git mv` 至正确目录（commit fd0f90d）。
- **F23「在错误目录自删的 autostart」**：脚本删除旧路径；基于标记的幂等仍然有效。疗法重新设计：不自删；基于标记的幂等（残留 .desktop 为 1 毫秒 no-op）。
- **rc9 = 决定版容器**：首启无需干预即出厂自带奖杯 + 字形 + órbita-noche（证人：标记 17:57:50、正确的 `Image=`、桌面显示 órbita-noche）。SHA256 `16986eed…`。
- v0.2 待办艺术：Konqi（front-2）、Calamares 品牌（front-4）、greeter 字形几何（front-3b）。

### 2026-09-29 — Capa 2 sellada: rc12 y el primer paquete de fabrica

- **Capa 2 completa (camino C, capa A)**: `tobixu-wallpapers 0.1.0` se hornea en el propio `hornear.sh` (bloque CAPA2 tras `lb bootstrap`), se siembra en `includes.chroot/opt/tobixu-debs/`, y el hook `0400-install-tobixu-debs.hook.chroot` lo instala dentro del chroot y borra el directorio. Testigos en rc12 instalado: `ii tobixu-wallpapers 0.1.0`, `dpkg -S` atribuye el svg al paquete, `/opt/tobixu-debs` ausente. SHA256 rc12: `c3dcd98f…`.
- **F24 "El contenido de archivo pegado como comando"**: pegar el cuerpo de un hook suelto en la terminal ejecuto su `exit 0` y cerro la sesion. Los cuerpos de script se escriben con `cat > archivo <<'EOF'`, nunca se pegan sueltos.
- **F25 "El rsync que no puede borrar lo que el horno creo como root"**: `includes.chroot/opt/tobixu-debs/` queda propiedad de root tras el horneado; `rsync --delete` no puede hacer unlink. No bloquea (el horno limpia como root), pero se documenta: cura futura = limpiar al final del horneado o excluir la ruta del rsync.
- **F26 "El falso positivo del grep numerico"**: `grep 0400` matcheo `0400-libkf6syntaxhighlighting6` (paquete KDE) y no al hook. Usar el nombre completo (`0400-install`) en los testigos.
- **live-build no recorre `config/hooks/chroot/`**: los hooks chroot viven en `config/hooks/normal/` (cura del 0400, commit del 28-sep).
- Pendientes: Konqi (frente-2), branding Calamares (frente-4), proximo paquete: `tobixu-sddm-theme` o `tobixu-welcome`.

### 2026-09-29 — Layer 2 sealed: rc12 and the first factory package

- **Layer 2 complete (path C, layer A)**: `tobixu-wallpapers 0.1.0` is built inside `hornear.sh` (CAPA2 block after `lb bootstrap`), seeded into `includes.chroot/opt/tobixu-debs/`, and hook `0400-install-tobixu-debs.hook.chroot` installs it inside the chroot and removes the directory. Witnesses on installed rc12: `ii tobixu-wallpapers 0.1.0`, `dpkg -S` attributes the svg to the package, `/opt/tobixu-debs` absent. rc12 SHA256: `c3dcd98f…`.
- **F24 "File content pasted as command"**: pasting a hook body loose in the terminal ran its `exit 0` and closed the session. Script bodies are written with `cat > file <<'EOF'`, never pasted loose.
- **F25 "The rsync that cannot delete what the oven created as root"**: `includes.chroot/opt/tobixu-debs/` ends up root-owned after a build; `rsync --delete` cannot unlink. Non-blocking (the oven cleans as root), but documented: future cure = clean at end of build or exclude the path from rsync.
- **F26 "The numeric grep false positive"**: `grep 0400` matched `0400-libkf6syntaxhighlighting6` (a KDE package), not the hook. Use the full name (`0400-install`) in witnesses.
- **live-build does not walk `config/hooks/chroot/`**: chroot hooks live in `config/hooks/normal/` (0400 cure, 28-Sep commit).
- Pending: Konqi (front-2), Calamares branding (front-4), next package: `tobixu-sddm-theme` or `tobixu-welcome`.

### 2026-09-29 — 第二层封印：rc12 与首个出厂包

- **第二层完成（路径 C，A 层）**：`tobixu-wallpapers 0.1.0` 在 `hornear.sh` 内构建（`lb bootstrap` 后的 CAPA2 块），播种到 `includes.chroot/opt/tobixu-debs/`，hook `0400-install-tobixu-debs.hook.chroot` 在 chroot 内安装并删除该目录。rc12 安装后的证人：`ii tobixu-wallpapers 0.1.0`、`dpkg -S` 将 svg 归属于该包、`/opt/tobixu-debs` 不存在。rc12 SHA256：`c3dcd98f…`。
- **F24「把文件内容当命令粘贴」**：将 hook 正文松散粘贴到终端会执行其 `exit 0` 并关闭会话。脚本正文须用 `cat > file <<'EOF'` 书写，绝不松散粘贴。
- **F25「无法删除 horno 以 root 所建之物的 rsync」**：`includes.chroot/opt/tobixu-debs/` 在构建后归 root 所有；`rsync --delete` 无法 unlink。不阻塞（horno 以 root 清理），但已记录：未来疗法 = 构建末尾清理或从 rsync 排除该路径。
- **F26「数字 grep 的假阳性」**：`grep 0400` 匹配到 `0400-libkf6syntaxhighlighting6`（KDE 包）而非 hook。证人中使用全名（`0400-install`）。
- **live-build 不遍历 `config/hooks/chroot/`**：chroot hooks 住在 `config/hooks/normal/`（0400 的疗法，9月28日 commit）。
- 待办：Konqi（front-2）、Calamares 品牌（front-4）、下一个包：`tobixu-sddm-theme` 或 `tobixu-welcome`。

### 2026-09-29 — rc13: teclado y tecla de fabrica (Capa 2 completa)

- **rc13**: primera ISO con `tobixu-keyboard 0.1.3` (us modificado por dpkg-divert sobre xkb-data), `tobixu-wallpapers 0.1.0` y `tecla 51.0-1` de fabrica. Testigos sin intervencion: tres `ii`, diversion listada, AltGr+c→ç, RWIN→'→a→á, tecla con 4 niveles. SHA256 rc13: `4df17a64…`.
- **F27 "La tecla por keycode, no por posicion"**: la tecla de acentos era RWIN (Right Super), no MENU; dos versiones fallidas (0.1.1/0.1.2) por identificarla por posicion. Cura: precedente drix del propio archivo (RWIN = Multi_key).
- **F28 "El horno fail-fast"**: rc13a nacio muda (el source de tobixu-keyboard no existia en packages/ de la forja y el bucle CAPA2 siguio de largo). Cura: guardia `[ -d packages/$PKG ] || exit 1` (commit 6be9ec9).
- **F29 "Wayland no hereda opciones fantasma"**: el basic del us no declaraba level3(ralt_switch); en X11 una opcion global lo suplia, en Wayland nada. Cura dentro del propio layout; RWIN=Multi_key viaja en el archivo, no en kxkbrc.
- **dpkg-divert como canon**: sobrescribir un archivo de otro paquete (xkb-data) con reversa limpia en prerm.
- Pendientes v0.2: Konqi (frente-2), branding Calamares (frente-4), geometria del greeter (frente-3b); paquetes `tobixu-sddm-theme` y `tobixu-welcome`.

### 2026-09-29 — rc13: factory keyboard and tecla (Layer 2 complete)

- **rc13**: first ISO with `tobixu-keyboard 0.1.3` (modified us via dpkg-divert over xkb-data), `tobixu-wallpapers 0.1.0` and `tecla 51.0-1` from factory. Witnesses: three `ii`, diversion listed, AltGr+c→ç, RWIN→'→a→á, tecla with 4 levels. rc13 SHA256: `4df17a64…`.
- **F27 "The key by keycode, not by position"**: the accent key was RWIN (Right Super), not MENU; two failed versions (0.1.1/0.1.2) from position-based identification. Cure: the drix precedent in the file itself (RWIN = Multi_key).
- **F28 "The fail-fast oven"**: rc13a was born mute (tobixu-keyboard source missing in forja's packages/; the CAPA2 loop skipped on). Cure: guard `[ -d packages/$PKG ] || exit 1` (commit 6be9ec9).
- **F29 "

### 2026-09-30 — Capa 3 abierta: rc14 y la puerta versionada

- **rc14**: primera ISO con `tobixu-sddm-theme 0.4.2` de fabrica (greeter con glifo a caballo sobre la tarjeta), junto a `tobixu-keyboard 0.1.3`, `tobixu-wallpapers 0.1.0` y `tecla 51.0-1`. Testigos sin intervencion: cuatro `ii`, `dpkg -S` atribuye Main.qml y el drop-in al paquete, captura del greeter con glifo completo. SHA256 rc14: `7946bc96…`.
- **F30 "Las dos copias que divergieron"**: el greeter vivia en dos lugares (`theme/sddm/` taller en espanol, `includes.chroot` contrabando en ingles). Desempate por commit mas reciente (b482f97, ingles) y fuente unica en `packages/tobixu-sddm-theme/`. Semilla trilingue: `TranslationsDirectory=` en metadata y copia espanola preservada en git (9aba956) para el frente i18n (es/en/zh).
- **F31 "La inyeccion ciega"**: el grep de geometria no incluia `id:`; la tarjeta ya tenia nombre (`loginCard`) y el sed anadio un segundo `id` → QML "Property value set multiple times" y greeter gris de respaldo. Cura: id unico y glifo anclado a `loginCard` con `z:2`. Leccion: todo grep forense de QML incluye `id:`.
- **Frente-3b cerrado**: geometria del glifo en el greeter.
- Pendientes: Plymouth (negro de arranque), `tobixu-welcome` (jubilar a Konqi, frente-2), branding Calamares (frente-4), `tobixu-plasma-look` (lockscreen + Kvantum + Papirus), i18n trilingue.

### 2026-09-30 — Layer 3 open: rc14 and the versioned door

- **rc14**: first ISO with factory `tobixu-sddm-theme 0.4.2` (greeter with glyph straddling the card), plus `tobixu-keyboard 0.1.3`, `tobixu-wallpapers 0.1.0`, `tecla 51.0-1`. Witnesses without intervention: four `ii`, `dpkg -S` attributes Main.qml and the drop-in to the package, greeter capture with full glyph. rc14 SHA256: `7946bc96…`.
- **F30 "The two copies that diverged"**: the greeter lived in two places (`theme/sddm/` workshop in Spanish, `includes.chroot` contraband in English). Tie-break by most recent commit (b482f97, English) and single source at `packages/tobixu-sddm-theme/`. Trilingual seed: `TranslationsDirectory=` in metadata and the Spanish copy preserved in git (9aba956) for the i18n front (es/en/zh).
- **F31 "The blind injection"**: the geometry grep omitted `id:`; the card already had a name (`loginCard`) and the sed added a second `id` → QML "Property value set multiple times" and fallback gray greeter. Cure: single id and glyph anchored to `loginCard` with `z:2`. Lesson: every QML forensic grep includes `id:`.
- **Front-3b closed**: greeter glyph geometry.
- Pending: Plymouth (boot black), `tobixu-welcome` (retire Konqi, front-2), Calamares branding (front-4), `tobixu-plasma-look` (lockscreen + Kvantum + Papirus), trilingual i18n.

### 2026-09-30 — 第三层开启：rc14 与版本化之门

- **rc14**：首个出厂 `tobixu-sddm-theme 0.4.2`（greeter 中徽记骑跨卡片）的 ISO，另有 `tobixu-keyboard 0.1.3`、`tobixu-wallpapers 0.1.0`、`tecla 51.0-1`。无干预证人：四个 `ii`、`dpkg -S` 将 Main.qml 与 drop-in 归属于该包、greeter 徽记完整截图。rc14 SHA256：`7946bc96…`。
- **F30「分歧的两份拷贝」**：greeter 曾住两处（`theme/sddm/` 西班牙语工坊、`includes.chroot` 英语走私）。以最近 commit（b482f97，英语）裁决，单一源归于 `packages/tobixu-sddm-theme/`。三语种子：metadata 的 `TranslationsDirectory=` 与 git 中保存的西班牙语拷贝（9aba956），供 i18n 前线（es/en/zh）。
- **F31「盲目注入」**：几何 grep 未含 `id:`；卡片本有名（`loginCard`），sed 又加第二 `id` → QML "Property value set multiple times"，greeter 退回灰色。疗法：唯一 id，徽记锚定 `loginCard` 且 `z:2`。教训：QML 取证 grep 必含 `id:`。
- **front-3b 已闭**：greeter 徽记几何。
- 待办：Plymouth（启动黑屏）、`tobixu-welcome`（Konqi 退休，front-2）、Calamares 品牌（front-4）、`tobixu-plasma-look`（锁屏 + Kvantum + Papirus）、三语 i18n。

### 2026-09-30 — rc15: el velo de fabrica (Capa 3 completa)

- **rc15**: primera ISO con `tobixu-plymouth-theme 0.1.2` de fabrica: orbita-noche y glifo dorado velan el arranque desde el initramfs. Testigos sin intervencion: cinco `ii`, `lsinitramfs` lista `tobixu-selva` en el initrd, `plymouthd.conf` con `Theme=tobixu-selva`, captura del velo en el arranque. SHA256 rc15: `f32b5223…`.
- **F33 "El metapaquete iguana que hacia de todo"**: `tobixu-iguana 0.1.0` poseia `/usr/share/plymouth/themes/tobixu/`; dpkg rechazo el overwrite. Cura: renombrar nuestro tema a `tobixu-selva` y coexistir sin Replaces; la migracion (jubilar iguana, dividir colores Konsole/CSS) queda en `tobixu-plasma-look`.
- **F34 "El fantasma del rsync sin --delete"**: el dir de build en forja conservo el `tobixu/` viejo; con `debian/install` obsoleto, el 0.1.1 reempaqueto la ruta antigua y colisiono con iguana otra vez. Cura: `rsync --delete` a dirs de build y actualizar `debian/install` en cada rename.
- **F35 "El comando que Debian 14 mato"**: `plymouth-set-default-theme` no existe en Debian 14; el guard del postinst fallo en silencio y el trigger de initramfs-tools regenero el initrd de todos modos; el tema se activa via `/etc/plymouth/plymouthd.conf`. Pendiente 0.1.3: escribir el conf directamente desde el postinst.
- **Micro-frentes nuevos**: KSplash de Plasma negro al iniciar sesion (`tobixu-plasma-look`); volcado breve de texto de consola al retirarse plymouth (cosmetico); `tobixu-grub-theme` para el hueco GRUB→initramfs.
- Estado Capa 3: puerta + velo + teclado + wallpapers + tecla de fabrica. Pendientes: `tobixu-welcome` (Konqi), branding Calamares, plasma-look, i18n trilingue, repo APT (latido rolling).

### 2026-09-30 — rc15: the factory veil (Layer 3 complete)

- **rc15**: first ISO with factory `tobixu-plymouth-theme 0.1.2`: orbita-noche and the golden glyph veil the boot from the initramfs. Witnesses without intervention: five `ii`, `lsinitramfs` lists `tobixu-selva` in the initrd, `plymouthd.conf` with `Theme=tobixu-selva`, boot capture of the veil. rc15 SHA256: `f32b5223…`.
- **F33 "The iguana metapackage that did everything"**: `tobixu-iguana 0.1.0` owned `/usr/share/plymouth/themes/tobixu/`; dpkg refused the overwrite. Cure: rename our theme to `tobixu-selva` and coexist without Replaces; migration (retire iguana, split Konsole/CSS colors) deferred to `tobixu-plasma-look`.
- **F34 "The ghost of rsync without --delete"**: forja's build dir kept the old `tobixu/`; with a stale `debian/install`, 0.1.1 repackaged the old path and collided with iguana again. Cure: `rsync --delete` to build dirs and update `debian/install` on every rename.
- **F35 "The command Debian 14 killed"**: `plymouth-set-default-theme` does not exist in Debian 14; the postinst guard failed silently and the initramfs-tools trigger regenerated the initrd anyway; the theme activates via `/etc/plymouth/plymouthd.conf`. Pending 0.1.3: write the conf directly from postinst.
- **New micro-fronts**: black Plasma KSplash at session start (`tobixu-plasma-look`); brief console text dump when plymouth quits (cosmetic); `tobixu-grub-theme` for the GRUB→initramfs gap.
- Layer 3 state: door + veil + keyboard + wallpapers + tecla from factory. Pending: `tobixu-welcome` (Konqi), Calamares branding, plasma-look, trilingual i18n, APT repo (rolling heartbeat).

### 2026-09-30 — rc15：出厂之 veil（第三层完成）

- **rc15**：首个出厂 `tobixu-plymouth-theme 0.1.2` 的 ISO：orbita-noche 与金色徽记自 initramfs 遮蔽启动。无干预证人：五个 `ii`、`lsinitramfs` 在 initrd 中列出 `tobixu-selva`、`plymouthd.conf` 为 `Theme=tobixu-selva`、启动 veil 截图。rc15 SHA256：`f32b5223…`。
- **F33「无所不包的 iguana 元包」**：`tobixu-iguana 0.1.0` 拥有 `/usr/share/plymouth/themes/tobixu/`；dpkg 拒绝覆盖。疗法：我方主题改名 `tobixu-selva` 并存，不用 Replaces；迁移（iguana 退休、拆分 Konsole/CSS 颜色）留给 `tobixu-plasma-look`。
- **F34「无 --delete 的 rsync 之幽灵」**：forja 构建目录残留旧 `tobixu/`；配合过期的 `debian/install`，0.1.1 重新打包旧路径再撞 iguana。疗法：构建目录用 `rsync --delete`，每次改名更新 `debian/install`。
- **F35「Debian 14 杀死的命令」**：`plymouth-set-default-theme` 在 Debian 14 不存在；postinst 守卫静默失败，initramfs-tools 触发器仍重建 initrd；主题经 `/etc/plymouth/plymouthd.conf` 激活。0.1.3 待办：postinst 直写 conf。
- **新微前线**：会话启动时黑色 Plasma KSplash（`tobixu-plasma-look`）；plymouth 退场时短暂控制台文本（装饰性）；GRUB→initramfs 空档的 `tobixu-grub-theme`。
- 第三层状态：门 + veil + 键盘 + 壁纸 + tecla 出厂。待办：`tobixu-welcome`（Konqi）、Calamares 品牌、plasma-look、三语 i18n、APT 仓库（rolling 心跳）。

### 2026-09-30 — rc16: jubila al monolito iguana (Capa 3 identidad)

- **rc16**: primera ISO con `tobixu-plasma-look 0.1.1` de fabrica y sin `tobixu-iguana`. Testigos: seis `ii` (wallpapers, keyboard, sddm-theme, plymouth-theme, plasma-look, tecla), ausencia total de iguana en `dpkg -l`, archivos de identidad atribuidos a plasma-look. SHA256 rc16: `XXXXX…`.
- **F33 cerrado**: el monolito artesanal (construido con `dpkg-deb --build`) es reemplazado por `tobixu-plasma-look` con `Replaces: tobixu-iguana (<< 0.2.0)`, `Breaks: tobixu-iguana (<< 0.2.0)`. El hook 0100 ya no lo pide.
- **F36 "El nombre del paquete no es el nombre del rio"**: en Debian 14 (trixie) con Plasma 6 (Qt6), el motor de estilos se llama `qt-style-kvantum`, no `kvantum`. El `Depends: kvantum` del 0.1.0 rompio el sistema; cura en 0.1.1 como `Recommends`.
- Pendiente visual 0.1.2: el kdeglobals actual dice `widgetStyle=Breeze` sin `ColorScheme=IguanaNoche`; la identidad esta instalada pero no activada. Requiere `ColorScheme=IguanaNoche` y `widgetStyle=kvantum` para que se vea.

### 2026-09-30 — rc16: the iguana monolith retired (Layer 3 identity)

- **rc16**: first ISO with factory `tobixu-plasma-look 0.1.1` and without `tobixu-iguana`. Witnesses: six `ii`, total absence of iguana in `dpkg -l`, identity files attributed to plasma-look. rc16 SHA256: `XXXXX…`.
- **F33 closed**: the artisanal monolith (built with `dpkg-deb --build`) is replaced by `tobixu-plasma-look` with `Replaces: tobixu-iguana (<< 0.2.0)`, `Breaks: tobixu-iguana (<< 0.2.0)`. Hook 0100 no longer requests it.
- **F36 "The package name is not the river's name"**: in Debian 14 (trixie) with Plasma 6 (Qt6), the style engine is called `qt-style-kvantum`, not `kvantum`. The `Depends: kvantum` of 0.1.0 broke the system; cured in 0.1.1 as `Recommends`.
- Pending visual 0.1.2: current kdeglobals says `widgetStyle=Breeze` without `ColorScheme=IguanaNoche`; identity is installed but not activated. Requires `ColorScheme=IguanaNoche` and `widgetStyle=kvantum` to be seen.

### 2026-09-30 — rc16：iguana 巨石退休（第三层身份）

- **rc16**：首个出厂 `tobixu-plasma-look 0.1.1` 且无 `tobixu-iguana` 的 ISO。证人：六个 `ii`、`dpkg -l` 中全无 iguana、身份文件归属 plasma-look。rc16 SHA256：`XXXXX…`。
- **F33 已闭**：手工巨石（`dpkg-deb --build` 构建）被 `tobixu-plasma-look` 替代，附 `Replaces: tobixu-iguana (<< 0.2.0)`、`Breaks: tobixu-iguana (<< 0.2.0)`。Hook 0100 不再请求。
- **F36「包名非河名」**：Debian 14 (trixie) + Plasma 6 (Qt6) 的样式引擎叫 `qt-style-kvantum`，非 `kvantum`。0.1.0 的 `Depends: kvantum` 破坏系统；0.1.1 改为 `Recommends`。
- 0.1.2 视觉待办：现 kdeglobals 为 `widgetStyle=Breeze` 无 `ColorScheme=IguanaNoche`；身份已装未激活。需 `ColorScheme=IguanaNoche` 与 `widgetStyle=kvantum` 才可见。

### 2026-09-30 — rc16: jubila al monolito iguana (Capa 3 identidad)

- **rc16**: primera ISO con `tobixu-plasma-look 0.1.1` de fabrica y sin `tobixu-iguana`. Testigos: seis `ii` (wallpapers, keyboard, sddm-theme, plymouth-theme, plasma-look, tecla), ausencia total de iguana en `dpkg -l`, archivos de identidad atribuidos a plasma-look. SHA256 rc16: `ba499f9fbd497c587522dc529722f8370535ad3bb47b2e6e82b7bcdfbdb2193b`.
- **F33 cerrado**: el monolito artesanal (construido con `dpkg-deb --build`) es reemplazado por `tobixu-plasma-look` con `Replaces: tobixu-iguana (<< 0.2.0)`, `Breaks: tobixu-iguana (<< 0.2.0)`. El hook 0100 ya no lo pide.
- **F36 "El nombre del paquete no es el nombre del rio"**: en Debian 14 (trixie) con Plasma 6 (Qt6), el motor de estilos se llama `qt-style-kvantum`, no `kvantum`. El `Depends: kvantum` del 0.1.0 rompio el sistema; cura en 0.1.1 como `Recommends`.
- Pendiente visual 0.1.2: el kdeglobals actual dice `widgetStyle=Breeze` sin `ColorScheme=IguanaNoche`; la identidad esta instalada pero no activada. Requiere `ColorScheme=IguanaNoche` y `widgetStyle=kvantum` para que se vea.

### 2026-09-30 — rc16: the iguana monolith retired (Layer 3 identity)

- **rc16**: first ISO with factory `tobixu-plasma-look 0.1.1` and without `tobixu-iguana`. Witnesses: six `ii`, total absence of iguana in `dpkg -l`, identity files attributed to plasma-look. rc16 SHA256: `ba499f9fbd497c587522dc529722f8370535ad3bb47b2e6e82b7bcdfbdb2193b`.
- **F33 closed**: the artisanal monolith (built with `dpkg-deb --build`) is replaced by `tobixu-plasma-look` with `Replaces: tobixu-iguana (<< 0.2.0)`, `Breaks: tobixu-iguana (<< 0.2.0)`. Hook 0100 no longer requests it.
- **F36 "The package name is not the river's name"**: in Debian 14 (trixie) with Plasma 6 (Qt6), the style engine is called `qt-style-kvantum`, not `kvantum`. The `Depends: kvantum` of 0.1.0 broke the system; cured in 0.1.1 as `Recommends`.
- Pending visual 0.1.2: current kdeglobals says `widgetStyle=Breeze` without `ColorScheme=IguanaNoche`; identity is installed but not activated. Requires `ColorScheme=IguanaNoche` and `widgetStyle=kvantum` to be seen.

### 2026-09-30 — rc16：iguana 巨石退休（第三层身份）

- **rc16**：首个出厂 `tobixu-plasma-look 0.1.1` 且无 `tobixu-iguana` 的 ISO。证人：六个 `ii`、`dpkg -l` 中全无 iguana、身份文件归属 plasma-look。rc16 SHA256：`ba499f9fbd497c587522dc529722f8370535ad3bb47b2e6e82b7bcdfbdb2193b`。
- **F33 已闭**：手工巨石（`dpkg-deb --build` 构建）被 `tobixu-plasma-look` 替代，附 `Replaces: tobixu-iguana (<< 0.2.0)`、`Breaks: tobixu-iguana (<< 0.2.0)`。Hook 0100 不再请求。
- **F36「包名非河名」**：Debian 14 (trixie) + Plasma 6 (Qt6) 的样式引擎叫 `qt-style-kvantum`，非 `kvantum`。0.1.0 的 `Depends: kvantum` 破坏系统；0.1.1 改为 `Recommends`。
- 0.1.2 视觉待办：现 kdeglobals 为 `widgetStyle=Breeze` 无 `ColorScheme=IguanaNoche`；身份已装未激活。需 `ColorScheme=IguanaNoche` 与 `widgetStyle=kvantum` 才可见。

### 2026-10-01 — rc17: identidad trilingue y contenido visible (Capa 3 cerrada)

- **rc17**: primera ISO con `tobixu-plasma-look 0.2.1` (identidad visible: ColorScheme=IguanaNoche + widgetStyle=kvantum), `tobixu-sddm-theme 0.5.0` (greeter trilingue EN/ES/ZH con selector), y `fonts-wqy-zenhei` (fuente CJK de fabrica). Testigos: siete `ii`, velo de plymouth, puerta trilingue, icono instalador con Name[zh_CN]=安装 Tobi Xu, escritorio con piel Kvantum selva. SHA256 rc17: `XXXXX…`.
- **F39 "El conffile…
- **D1「Konqi 留下」**：Welcome Center 是 Plasma 自带教程，不应披我方皮肤；仅会话 splash（KSplash）接收 orbita-noche。`tobixu-welcome` 退出地图。
- **D2「stock KSplash」**：look-and-feel 包 org.tobixu.selva.desktop 就位、metadata.json 合法、plasmarc 指向正确，但 kpackagetool6 未注册，KSplash 退回 breeze。仅改背景需 patch breeze 文件（divert 领地，风险高，收益装饰性）。v0.1：won't fix。skel 中的 plasmarc 无害（fallback = stock），留作 v0.2 种子。
- **第三层闭合**：版本化门（F30/F31）、出厂 veil（F33/F34/F35）、无巨石可见身份（F33 已闭、F36）、三语 greeter、CJK 字体、本地化安装图标。河流转向内容：元包 `tobi-xu-stem` 与 `tobi-xu-arts`。

### 2026-10-01 — rc21: Capa 3 cerrada con splash (cierre pragmatico)

- **rc21**: identidad cero clics confirmada (`LookAndFeelPackage=org.tobixu.selva.desktop` sin intervencion, marcador `~/.tobixu-wallpaper-done`, Kate/Konsole con piel selva), puerta trilingue, velo de fabrica, y sorpresa: KSplash muestra orbita+glifo al caer al splash del look-and-feel activo cuando plasmarc no trae pin `[KSplash]`. Residuo: splash del primer login es stock. SHA256 rc21: `3285d3c6161cd6ff34651ff0048581983a9c138bf4e21ed425dded002ca7e01a`.
- **F42 "La ruta relativa silenciosa"**: el Splash.qml no renderizaba invocado por el pin explicito de plasmarc (KSplashQML + Theme); cura B (quitar el pin) revelo que la ruta del look-and-feel lo renderiza bien. Semilla v0.2: investigar la ruta explicita de KSplashQML.
- **F39/F40/F41**: conffile noninteractive con debs duplicados; clave `LookAndFeel=` vs `LookAndFeelPackage`; primer arranque pisa el pin del skel (curado con autostart de un solo uso). **D1 honrado** (Konqi saluda una vez con piel selva); **D2 revertida del todo** en rc21.
- **Capa 3 cerrada**: puerta, velo, identidad, trilingue, fuente CJK, icono localizado, cero clics, splash selva. El rio pasa al contenido: `tobi-xu-stem` y `tobi-xu-arts`.

### 2026-10-01 — rc21: Layer 3 closed with splash (pragmatic closure)

- **rc21**: zero-click identity confirmed, trilingual door, factory veil, and surprise: KSplash shows orbit+glyph by falling back to the active look-and-feel splash once plasmarc carries no `[KSplash]` pin. Residue: first-login splash is stock. rc21 SHA256: `3285d3c6161cd6ff34651ff0048581983a9c138bf4e21ed425dded002ca7e01a`.
- **F42**: Splash.qml failed only via the explicit plasmarc pin path; the look-and-feel path renders it. v0.2 seed: investigate KSplashQML explicit path. **F39/F40/F41** cured as logged. **D1 honored; D2 fully reverted** in rc21.
- **Layer 3 closed**: door, veil, identity, trilingual, CJK font, localized icon, zero clicks, selva splash. The river moves to content: `tobi-xu-stem` and `tobi-xu-arts`.

### 2026-10-01 — rc21：第三层含 splash 闭合（务实收束）

- **rc21**：零点击身份确认、三语门、出厂 veil，且惊喜：plasmarc 无 `[KSplash]` pin 后 KSplash 回落到活跃 look-and-feel 的 splash，显示 orbit+glyph。残留：首登 splash 为 stock。rc21 SHA256：`3285d3c6161cd6ff34651ff0048581983a9c138bf4e21ed425dded002ca7e01a`。
- **F42**：Splash.qml 仅经 plasmarc 显式 pin 路径失败；look-and-feel 路径正常。v0.2 种子：调查 KSplashQML 显式路径。**F39/F40/F41** 已愈。**D1 已尊；D2 于 rc21 完全反转**。
- **第三层闭合**：门、veil、身份、三语、CJK 字体、本地化图标、零点击、selva splash。河流转向内容：`tobi-xu-stem` 与 `tobi-xu-arts`。

### 2026-10-02 — rc22n: v0.1-sicaru en el metal y en el aire

- **rc22n horneado con contenido completo**: 2603 paquetes; metapaquetes tobi-xu-stem 0.1.2
  y tobi-xu-arts 0.1.1; repos Qt6 firmados (texstudio, frescobaldi) con pinning 990;
  hook 0400 curado (F43); F44: julia/r-base/octave/qgis y krita/ardour/musescore a
  Recommends por transiciones de sid en el snapshot 20260920.
- **Sitio publico en el aire**: tobixu.xyz (GitHub Pages + dominio via Cloudflare); heroe
  con glifo sobre orbita-noche en ES/中文/EN; atribucion a Qwen (Alibaba Tongyi Lab);
  titular "GNU/Linux distro"; SHA256 de rc22n publicado.
- **HTTPS por el borde (F45)**: verificador DNS de GitHub atorado pese a DNS perfecto;
  tras 24 h de manos quietas, proxy Cloudflare + SSL Flexible + Always Use HTTPS →
  candado verde. Deuda v0.2: volver a topologia pura de GitHub.
- **Listo para difusion por fases**: Distrowatch → HN → Reddit/Lobsters → STEM → trilingues.

### 2026-10-02 — rc22n: v0.1-sicaru on metal and on air

- **rc22n baked with full content**: 2603 packages; metapackages tobi-xu-stem 0.1.2 and
  tobi-xu-arts 0.1.1; signed Qt6 repos (texstudio, frescobaldi) pinned at 990; hook 0400
  cured (F43); F44: julia/r-base/octave/qgis and krita/ardour/musescore moved to Recommends
  due to sid transitions in snapshot 20260920.
- **Public site on air**: tobixu.xyz (GitHub Pages + custom domain via Cloudflare); hero
  with glyph over orbita-noche in ES/中文/EN; Qwen (Alibaba Tongyi Lab) attribution;
  "GNU/Linux distro" headline; rc22n SHA256 published.
- **Edge HTTPS (F45)**: GitHub DNS verifier stuck despite perfect DNS; after 24 h of quiet
  hands, Cloudflare proxy + Flexible SSL + Always Use HTTPS → green padlock. v0.2 debt:
  return to pure GitHub topology.
- **Ready for phased outreach**: Distrowatch → HN → Reddit/Lobsters → STEM → trilingual.

### 2026-10-02 — rc22n：v0.1-sicaru 落地与上线

- **rc22n 完整内容烘焙**：2603 个软件包；元包 tobi-xu-stem 0.1.2 与 tobi-xu-arts 0.1.1；
  签名 Qt6 仓库（texstudio、frescobaldi）优先级 990；hook 0400 修复（F43）；F44：
  julia/r-base/octave/qgis 与 krita/ardour/musescore 移至 Recommends（sid 转换）。
- **公共站点上线**：tobixu.xyz（GitHub Pages + Cloudflare 自定义域名）；ES/中文/EN
  三语英雄区（轨道之夜上的字形）；Qwen（阿里巴巴通义实验室）署名；"GNU/Linux distro"
  标题；rc22n SHA256 已公布。
- **边缘 HTTPS（F45）**：GitHub DNS 校验器卡死（DNS 本身完美）；静置 24 小时后改用
  Cloudflare 代理 + Flexible SSL + 强制 HTTPS → 绿锁。v0.2 债务：回归纯 GitHub 拓扑。
- **分阶段传播就绪**：Distrowatch → HN → Reddit/Lobsters → STEM → 三语社区。



## 2026-10-03 — Candado, press kit y primera semilla de difusión

### ES

- **HTTPS por el borde (F45 cerrado):** proxy Cloudflare + SSL Flexible +
  "Always Use HTTPS"; candado verde en `https://tobixu.xyz` y redirección
  301 desde `www.tobixu.xyz` al apex. F46 anotada: doble salto
  `www→http→https`, curar en v0.2 con regla directa en Cloudflare.
- **Snapshot #15** de sicaru01 (`snap15-v01sicaru`): rc22n con contenido
  STEM+ARTS en el metal y sitio con candado en el aire.
- **Press kit mínimo** en `docs/press/`: one-pager trilingüe (ES/EN/ZH) +
  capturas canónicas de las cuatro fases del arranque (velo, puerta,
  splash, escritorio) + glifo + órbita-noche.
- **Difusión fase 1 (Distrowatch):** correo de sumisión a
  `distro@distrowatch.com` con los cuatro datos canónicos (nombre, sitio,
  descripción, ISO directa en Archive.org) + bug tracker, foro (GitHub
  Discussions activado) y press kit. Mención breve en el DistroWatch
  Weekly del 5-oct esperada; waiting list después, sin correspondencia
  (doctrina de su propia página).

### EN

- **Edge HTTPS (F45 closed):** Cloudflare proxy + Flexible SSL +
  "Always Use HTTPS"; green padlock on `https://tobixu.xyz` and 301
  redirect from `www.tobixu.xyz` to apex. F46 noted: double jump
  `www→http→https`, fix in v0.2 with direct rule in Cloudflare.
- **Snapshot #15** of sicaru01 (`snap15-v01sicaru`): rc22n with STEM+ARTS
  content on metal and padlocked site on air.
- **Minimal press kit** in `docs/press/`: trilingual one-pager (ES/EN/ZH)
  + canonical screenshots of all four boot phases (veil, door, splash,
  desktop) + glyph + orbita-noche.
- **Outreach phase 1 (Distrowatch):** submission email to
  `distro@distrowatch.com` with the four canonical pieces of info (name,
  site, description, direct ISO link on Archive.org) + bug tracker,
  forum (GitHub Discussions enabled) and press kit. Brief mention in
  DistroWatch Weekly on Oct 5 expected; waiting list afterwards, no
  correspondence (their own doctrine).

### ZH

- **边缘 HTTPS（F45 关闭）：** Cloudflare 代理 + Flexible SSL + 强制 HTTPS；
  `https://tobixu.xyz` 绿锁，`www.tobixu.xyz` 301 重定向到 apex。F46 记录：
  双跳 `www→http→https`，v0.2 中在 Cloudflare 直接修复。
- **sicaru01 快照 #15**（`snap15-v01sicaru`）：rc22n 落地且站点已加锁。
- **最小新闻资料包** 在 `docs/press/`：三语单页（ES/EN/ZH）+ 四个启动
  阶段标准截图（面纱、门、启动画面、桌面）+ 字形 + 轨道之夜。
- **传播第一阶段（Distrowatch）：** 向 `distro@distrowatch.com` 发送提交
  邮件，包含四条规范信息（名称、站点、描述、Archive.org 上的 ISO 直接链接）
  + bug 跟踪器、论坛（已启用 GitHub Discussions）与新闻资料包。预计 10-05
  在 DistroWatch Weekly 简要提及；之后进入等待名单，不通信（其自身原则）。
  
## 2026-10-05 — rc23: firmwares Wi-Fi para el metal real; primera piedra (F47–F54)

### ES

- **F47:** el helper de Calamares hacia `apt-get install grub-efi` en plena
  instalacion; la ISO sin firmwares Wi-Fi no-libres dejaba al metal real sin
  red → exit 2. Invisible en VM: virtio da Ethernet cableado sin firmware.
- **F48–F52:** tabla de verdades del grub: un sistema lleva UNA sola variante;
  `grub-efi-amd64` Conflicts `grub-efi-ia32` (F51) y `grub-pc` (F52). Doctrina
  resultante: el chroot preinstala `grub-efi-amd64` (UEFI64 instala offline);
  las maquinas BIOS obtienen `grub-pc` en plena instalacion, ahora posible
  porque la ISO trae firmwares → sesion live con red → apt alcanza forky.
- **F49:** firmwares Wi-Fi y microcodigos ausentes del snapshot 20260920;
  fuente de respaldo de forky vivo (testing) con pin 100 y secciones
  `contrib non-free-firmware non-free` en `config/archives/firmware.*`.
- **rc23:** 2607 paquetes, ~4.4 GB; subida a Archive.org (item
  `tobixu-v0.1-sicaru`); sitio con liga, SHA256 y SHA256SUMS coherentes.
- **Primera piedra real:** Huawei UEFI64 instala y corre de maravilla
  (maquina espejo de tetris; rsync de recuperacion en vivo).
- **F53 (abierta):** VM rc23test (`--network none`, OVMF) falla la
  instalacion; en diagnostico.
- **F54 (abierta):** MacBook Air 2008 instala pero se traba; sospecha de
  mixed-mode EFI32/CPU64; en diagnostico.

### EN

- **F47:** Calamares helper ran `apt-get install grub-efi` mid-install; the
  ISO without non-free Wi-Fi firmwares left real metal without network →
  exit 2. Invisible in VMs: virtio gives wired Ethernet without firmware.
- **F48–F52:** grub truth table: a system carries ONE variant only;
  `grub-efi-amd64` Conflicts `grub-efi-ia32` (F51) and `grub-pc` (F52).
  Resulting doctrine: chroot preinstalls `grub-efi-amd64` (UEFI64 installs
  offline); BIOS machines get `grub-pc` mid-install, now possible because
  the ISO ships firmwares → live session with network → apt reaches forky.
- **F49:** Wi-Fi firmwares and microcode absent from snapshot 20260920;
  fallback source from live forky (testing), pin 100, sections
  `contrib non-free-firmware non-free` in `config/archives/firmware.*`.
- **rc23:** 2607 packages, ~4.4 GB; uploaded to Archive.org (item
  `tobixu-v0.1-sicaru`); site with coherent link, SHA256 and SHA256SUMS.
- **First real stone:** Huawei UEFI64 installs and runs beautifully
  (tetris mirror machine; live rsync recovery).
- **F53 (open):** VM rc23test (`--network none`, OVMF) fails installation;
  under diagnosis.
- **F54 (open):** MacBook Air 2008 installs but stalls; mixed-mode
  EFI32/CPU64 suspected; under diagnosis.

### ZH

- **F47：** Calamares helper 在安装中期执行 `apt-get install grub-efi`；ISO 缺少
  非自由 Wi-Fi 固件 → 真实金属无网络 → 退出码 2。VM 中不可见：virtio 提供无需
  固件的有线以太网。
- **F48–F52：** grub 真值表：系统仅携带一个变体；`grub-efi-amd64` 与
  `grub-efi-ia32`（F51）及 `grub-pc`（F52）互斥。由此原则：chroot 预装
  `grub-efi-amd64`（UEFI64 离线安装）；BIOS 机器在安装中期获取 `grub-pc`，
  因 ISO 带固件而可行 → live 会话有网络 → apt 到达 forky。
- **F49：** Wi-Fi 固件与微代码不在 snapshot 20260920；在
  `config/archives/firmware.*` 添加实时 forky (testing) 备用源，pin 100，
  section `contrib non-free-firmware non-free`。
- **rc23：** 2607 个软件包，约 4.4 GB；上传至 Archive.org（item
  `tobixu-v0.1-sicaru`）；站点链接、SHA256 与 SHA256SUMS 一致。
- **第一块真实石头：** Huawei UEFI64 安装并运行良好（tetris 镜像机；rsync
  实时恢复）。
- **F53（开放）：** VM rc23test（`--network none`，OVMF）安装失败；诊断中。
- **F54（开放）：** MacBook Air 2008 安装但卡顿；疑似 EFI32/CPU64 混合模式；
  诊断中。

## 2026-10-08 — El giro GNOME: el escritorio es semilla, no cadena (F56–F59)

### ES

- **Decision de producto (usuario cero):** el mantenedor vive en GNOME; Plasma
  se siente ajeno (look & feel tipo Windows). TobiXu v0.1 gira a GNOME por
  defecto con gdm3; Plasma queda como sesion alternativa.
- **D3 candidata:** "El escritorio es semilla, no cadena: el default es un
  metapaquete; las sesiones conviven en el engranaje de GDM."
- **D4 candidata:** "La geometria del display es de la maquina, n…意字符串；mutter 只服从
  `/usr/share/X11/xkb/rules/evdev.lst`（非 `xkb.lst`）中的名称。
  `level3:ralt_switch` 不存在；正名为 `lv3:ralt_switch`。治愈后 AltGr 出 ç/€。
- **F55 gnome-initial-setup：** 以标记 `~/.config/gnome-initial-setup-done`
  解除；出厂将置于 `/etc/skel`。
- **状态：** Huawei = 已生活的 GNOME 实验室；tetris 保留工坊、门与 Plasma 之路。
  rc24 待办：`tobixu-gnome-look`、`010-desktop.list.chroot` 默认翻转、
  Calamares→gdm3、双会话烟雾、更新新闻资料包（GNOME 下：面纱 → GDM 门 →
  桌面；splash 仅 Plasma）。
- **开放：** F53（VM rc23test）、F54（MacBook 2008）、Huawei 转储在途（工厂种子）。

## 2026-10-09 (noche) — Saga F67-F77: ocho horneados muertos, una ISO viva

### ES

**rc24 nació con BAUTIZO COMPLETO tras 8 horneados muertos.** Cada muerte dejó una lección doctrinal:

- **F67 "El package-list que pedía paquetes de identidad":** `010-desktop.list.chroot` listaba `tobixu-gnome-look` y `tobixu-plasma-look` como paquetes a instalar vía apt durante la fase chroot. Pero esos paquetes viven en `/opt/tobixu-debs/` sembrados por CAPA2 y se instalan vía hook 0400, no vía apt. Apt no lo… clean --all` 无法在其中删除。疗法：脚本开始时的预清理挂载（通过 sudoers 作为 root 运行）+ `trap ... EXIT`。

**rc24 特性：**
- 默认 GNOME（gdm3 + tobixu-gnome-look 0.1.1 带 EGO 扩展：appmenu-is-back、trayIconsReloaded）
- Plasma 作为替代（SDDM + tobixu-plasma-look 0.3.2）
- Hook 0400 带 `dpkg -i --force-confold --force-confdef`
- `config/binary` 中 `LB_HDD_SIZE=8000`
- 僵尸挂载预清理 + trap EXIT
- SHA256：`ba5360a2ba8876d2a247205e112cfb1329acf7b20c4c46c1d60db8ab43bea9b5`
- 大小：6.3 GB（D3 已验证：GNOME + Plasma 共存）

**v0.2 债务：** 记录在 `docs/doctrina.md` 中。

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



