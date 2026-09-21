# Tobi Xu

🇲🇽 Español | 🇧 English | 🇳 中文（简体）

Distro STEAM basada en Debian — ciencia, tecnología, ingeniería, artes y matemáticas.
A STEAM distro based on Debian — science, technology, engineering, arts and mathematics.
基于 Debian 的 STEAM 发行版——科学、技术、工程、艺术与数学。

---

## 🇲 Español

### Etimología

- **Tobi Xu**: del diidxazá (zapoteco del Istmo), "Uno Temblor".
- **El glifo se llama Tobi Xu**: el punto estilizado es el número (tobi, uno); el signo posado sobre el punto es el temblor de tierra (xu en diidxazá del Istmo; xoo en zapoteco del Valle de Oaxaca). El escudo no representa el nombre: lo escribe, con la notación de puntos y barras más antigua de Mesoamérica.
- **sicaru**: "bello, bonito", tomada de las palabras consecutivas de un poema de Pancho Nácar. Nombre de la release v0.1.
- **Guchaachi'**: "iguana" en diidxazá. Tobi Guchaachi' ("Uno la Iguana"; 鬣蜥托比 en chino) es la mascota del proyecto.

### Filosofía

- Base Debian sid (rolling), con paqueteo propio publicado en el repo firmado del proyecto.
- Kernel propio: 7.2.4 entra en rc5 (paso 12 de la hoja de ruta).
- Escritorio Plasma Wayland con tema selva/jacaranda/órbita-noche; todo configurable por el usuario.
- Doctrina de trabajo v2 (desde rc4): el repo es la fuente de verdad; la Forja hornea; Tetris jala, sella y prueba.

### Identidad visual

Sistema de tres voces (detalle y paletas en docs/brand/BRAND.md):

| Voz | Rol |
|---|---|
| Glifo Tobi Xu | Escudo e identidad: preside |
| Guchaachi' (Tobi Guchaachi') | Mascota: acompaña |
| Iguana-TeX (TeX→PDF/MD) | Sello del proyecto hermano (editor) |

Regla de oro: el escudo preside, la mascota acompaña; jamás al revés.

### Instalación

1. **Descargar la ISO** (`tobixu-0.1-sicaru-<fecha>-amd64.iso`) y su `SHA256SUMS` desde las Releases del repo.
2. **Verificar la descarga:** `sha256sum -c SHA256SUMS`.
3. **Crear un USB booteable** con la ISO (método recomendado):
   - Desde Linux: `sudo dd if=tobixu-*.iso of=/dev/sdX bs=4M status=progress && sync` (sdX = el USB completo, sin número de partición).
   - Desde cualquier sistema: Balena Etcher, Ventoy o GNOME Disks.
4. **Arrancar desde el USB** y elegir "Tobi Xu sicaru": entrarás a la sesión live de Plasma sin tocar el disco.
5. **Instalar como sistema principal:** abrir "Install Tobi Xu" (Calamares) y seguir el asistente. Al reiniciar sin el USB, arranca tu sistema instalado.

### Vigilancias de sid (sección viva)

- Ventana Qt 6.10 → 6.11 (sep 2026): kwin-wayland pinea qt6-base-private-abi=6.10.2 y sid queda roto para el stack KDE. Los builds de rc4 se congelaron en snapshot.debian.org 20260913 (el mundo validado del coredump) hasta que la transición sane. No hacer dist-upgrade durante la ventana.
- sid jubiló /var/log/lastlog: el aviso de sshd en cada login es ruido inofensivo.

### Distribución

- GitHub (este repo): fuente de verdad.
- Gitee: espejo en trámite (el bind telefónico de Gitee es +86-only); este README zh vive entretanto en GitHub.
- Para usuarios en China: se sugieren mirrors TUNA/USTC de Debian tras la instalación.

---

## 🇬 English

### Etymology

- **Tobi Xu**: from diidxazá (Isthmus Zapotec), "One Tremor".
- **The glyph is named Tobi Xu**: the stylized dot is the numeral (tobi, one); the sign resting upon the dot is the earth-tremor (xu in Isthmus Zapotec; xoo in Valley Zapotec). The escutcheon does not depict the name — it writes it, in Mesoamerica's oldest dot-and-bar notation.
- **sicaru**: "beautiful, pretty", taken from consecutive words of a poem by Pancho Nácar. Name of the v0.1 release.
- **Guchaachi'**: "iguana" in diidxazá. Tobi Guchaachi' ("One the Iguana"; 鬣蜥托比 in Chinese) is the project mascot.

### Philosophy

- Debian sid (rolling) base, with first-party packages published to the project's signed repo.
- Own kernel: 7.2.4 lands in rc5 (roadmap step 12).
- Plasma Wayland desktop with selva/jacaranda/órbita-noche theme; everything user-configurable.
- Work doctrine v2 (since rc4): the repo is the source of truth; the Forja bakes; Tetris pulls, seals and tests.

### Visual identity

Three-voice system (details and palettes in docs/brand/BRAND.md):

| Voice | Role |
|---|---|
| Tobi Xu glyph | Escutcheon and identity: presides |
| Guchaachi' (Tobi Guchaachi') | Mascot: accompanies |
| Iguana-TeX (TeX→PDF/MD) | Seal of the sister project (editor) |

Golden rule: the escutcheon presides, the mascot accompanies; never the reverse.

### Installation

1. **Download the ISO** (`tobixu-0.1-sicaru-<date>-amd64.iso`) and its `SHA256SUMS` from the repo Releases.
2. **Verify the download:** `sha256sum -c SHA256SUMS`.
3. **Create a bootable USB** with the ISO (recommended method):
   - From Linux: `sudo dd if=tobixu-*.iso of=/dev/sdX bs=4M status=progress && sync` (sdX = the whole USB drive, no partition number).
   - From any system: Balena Etcher, Ventoy or GNOME Disks.
4. **Boot from the USB** and pick "Tobi Xu sicaru": you enter the Plasma live session without touching the disk.
5. **Install as your main system:** open "Install Tobi Xu" (Calamares) and follow the wizard. Reboot without the USB and your installed system starts.

### Sid watchlist (living section)

- Qt 6.10 → 6.11 window (Sep 2026): kwin-wayland pins qt6-base-private-abi=6.10.2 and sid breaks for the KDE stack. rc4 builds were frozen on snapshot.debian.org 20260913 (the coredump-validated world) until the transition heals. Do not dist-upgrade during the window.
- sid retired /var/log/lastlog: the sshd notice at login is harmless noise.

### Distribution

- GitHub (this repo): source of truth.
- Gitee: mirror pending (Gitee phone binding is +86-only); this zh README lives on GitHub meanwhile.
- For users in China: TUNA/USTC Debian mirrors suggested post-install.

---

## 🇨 中文（简体）

### 词源

- **Tobi Xu**：来自迪迪萨语（地峡萨波特克语），意为「一次震颤」。
- **徽记之名即 Tobi Xu**：风格化的圆点是数字「一」（tobi），其上的符号是大地之震（xu，地峡萨波特克语；谷地萨波特克语作 xoo）。徽记并非描绘名字，而是以中美洲最古老的点杠记数法，把名字写了出来。
- **sicaru**：意为「美丽」，取自潘乔·纳卡尔诗中的连续词句；v0.1 发布之名。
- **Guchaachi'**：迪迪萨语的「鬣蜥」。Tobi Guchaachi'（「一之鬣蜥」，中文昵称鬣蜥托比）是项目的吉祥物。

### 理念

- 基于 Debian sid（滚动），自有软件包发布于项目签名仓库。
- 自有内核：7.2.4 将于 rc5 引入（路线图第 12 步）。
- Plasma Wayland 桌面，selva/jacaranda/órbita-noche 主题；一切皆可由用户配置。
- 工作准则 v2（rc4 起）：仓库即真相之源；Forja 烘焙；Tetris 拉取、封印并测试。

### 视觉识别

三声系统（详见 docs/brand/BRAND.md）：

| 声 | 角色 |
|---|---|
| Tobi Xu 徽记 | 纹章与身份：主持 |
| Guchaachi'（Tobi Guchaachi'） | 吉祥物：陪伴 |
| Iguana-TeX（TeX→PDF/MD） | 姊妹项目（编辑器）之印 |

黄金法则：纹章主持，吉祥物陪伴；切不可颠倒。

### 安装

1. **下载 ISO**（`tobixu-0.1-sicaru-<日期>-amd64.iso`）及其 `SHA256SUMS`（见仓库 Releases）。
2. **校验下载：** `sha256sum -c SHA256SUMS`。
3. **制作可启动 U 盘**（推荐方式）：
   - Linux 下：`sudo dd if=tobixu-*.iso of=/dev/sdX bs=4M status=progress && sync`（sdX 为整块 U 盘，不带分区号）。
   - 任意系统：Balena Etcher、Ventoy 或 GNOME Disks。
4. **从 U 盘启动**并选择 "Tobi Xu sicaru"：进入 Plasma live 会话，不触碰硬盘。
5. **安装为主系统：**打开 "Install Tobi Xu"（Calamares）并按向导操作。拔掉 U 盘重启后，即进入已安装的系统。

### sid 守望（活栏目）

- Qt 6.10 → 6.11 窗口（2026 年 9 月）：kwin-wayland 钉住 qt6-base-private-abi=6.10.2，sid 的 KDE 栈因此破裂。rc4 的构建冻结于 snapshot.debian.org 20260913（经 coredump 验证的世界），直至过渡愈合。窗口期间请勿 dist-upgrade。
- 点杠与算筹：托比徐的徽记承载中美洲最古老的点杠记数法，与中华算筹同为位置记数法的远古血脉；而鬣蜥托比（Guchaachi'）是这片数字丛林的向导。

### 发行

- GitHub（本仓库）：真相之源。
- Gitee：镜像办理中（Gitee 的电话绑定仅支持 +86）；中文 README 暂居 GitHub。
- 中国用户建议：安装后改用 TUNA/USTC 等 Debian 镜像。

---

## 🤖 Acknowledgments / Reconocimientos / 致谢

**🇲🇽 Español:** Este proyecto fue desarrollado con la asistencia de Qwen, un modelo de lenguaje grande de Alibaba Group. Agradecimientos especiales a la comunidad Debian y a todos los contribuyentes de los proyectos de software libre que hacen posible Tobi Xu.

**🇬🇧 English:** This project was developed with the assistance of Qwen, a large language model by Alibaba Group. Special thanks to the Debian community and all contributors of the free software projects that make Tobi Xu possible.

**🇨🇳 中文（简体）：** 本项目在阿里巴巴集团大语言模型 Qwen 的协助下开发。特别感谢 Debian 社区以及所有为 Tobi Xu 奠定基础的自由软件项目贡献者。
