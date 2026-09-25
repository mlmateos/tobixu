Aquí tienes el runbook completo, guardián: cinco checkpoints, cada uno con su **cuándo**, su **comando**, su **verde** y su **rojo**. Imprímelo en la cabeza o en papel; es el mapa de la cruzada de hoy.

---

## 🟢 Checkpoint 1 — Bootstrap y descargas (≈10–20 min tras el encendido)

**Qué prueba:** que el snapshot 20 sigue propagado y que el horno camina solo.

```bash
ssh forja 'echo "== cola =="; tail -n 10 ~/tobixu-iso/build-manana.log; echo "== latido =="; pgrep -af "debootstrap|wget|curl|apt" | head -n 5; echo "== en D =="; ps -eo stat= | grep -c "^D"; echo "== despensa creciendo =="; du -sh ~/tobixu-iso/cache 2>/dev/null'
```

- **Verde:** líneas de debootstrap/descargas, `cache` creciendo, cero `D`.
- **Rojo:** `Failed to fetch` repetido (familia F4: espejo/snapshot) → se anota y se decide con acta; log congelado sin latido → protocolo de caja negra (más abajo).

---

## 🟢 Checkpoint 2 — Install pass desempacando (≈30–60 min)

**Qué prueba:** que el pedido limpio entra al chroot sin colibríes vivos (aduana F7 en vivo).

```bash
ssh forja 'echo "== cola =="; tail -n 6 ~/tobixu-iso/build-manana.log; echo "== aduana del pedido vivo =="; pgrep -af apt-get | grep -oE "pcmanfm|qterminal|lxqt|obconf" || echo "✅ sin colibries en el pedido vivo"; echo "== en D =="; ps -eo stat= | grep -c "^D"'
```

- **Verde:** líneas `Preparing to unpack / Unpacking` avanzando; el grep de colibríes no encuentra nada.
- **Rojo:** cualquier nombre prohibido en la línea de apt-get (imposible con las listas jubiladas, pero la aduana existe por si el pasado miente) → detener y leer; `D` > 0 → protocolo de caja negra.

---

## 🔥 Checkpoint 3 — EL RÍO (≈1–2 h): donde murieron las dos horneadas

**Qué prueba:** la tesis central de hoy. Si el configure de `libblockdev3` y la familia kernel pasan con el log creciendo, **el ladrillo era el asesino** y F9 queda cerrada.

```bash
ssh forja 'echo "== marcas del rio =="; grep -n "Setting up libblockdev\|Setting up linux-base\|Setting up linux-image\|Setting up kde-plasma\|Setting up calamares" ~/tobixu-iso/build-manana.log | tail -n 8; echo "== cola viva =="; tail -n 4 ~/tobixu-iso/build-manana.log; echo "== pulso de dpkg (2 muestras, 30 s) =="; ps -o pid,stat,time,comm -C dpkg; sleep 30; ps -o pid,stat,time,comm -C dpkg; echo "== en D =="; ps -eo stat= | grep -c "^D"'
```

- **Verde:** marcas del río presentes, la cola sigue avanzando después de ellas, y el **TIME de dpkg sube** entre las dos muestras con STAT en `S` o `R`. Cruzaste: lo demás es cuesta conocida.
- **Rojo:** STAT `D`, o TIME idéntico en ambas muestras, o cola congelada >30 min. **NO SE REBOOTEA NADA.** Captura primero:

```bash
ssh forja 'echo "== caja negra =="; tail -n 150 ~/tobixu-iso/caja-negra.log 2>/dev/null || echo "(ausente)"; echo "== dmesg sin sudo =="; dmesg -T 2>/dev/null | grep -B2 -A25 "blocked for more than" | tail -n 60 || echo "(dmesg restringido: la caja negra basta)"'
```

Pégame eso tal cual antes de tocar el horno: hoy el ladrillo nuevo es coartada, y cualquier traza que aparezca apuntará a la otra cara del asesino con el suelo y el ladrillo absueltos.

---

## 🟢 Checkpoint 4 — La puerta v7.2 (justo tras el install pass)

**Qué prueba:** que la purga, el triple testigo y el renombrado pasan con el chroot quieto (doctrina F6).

```bash
ssh forja 'echo "== puerta =="; grep -nE "ii=0|any=0|sesiones=0|PUERTA|purge|renombra|Tobi Xu" ~/tobixu-iso/build-manana.log | tail -n 12; echo "== cola =="; tail -n 6 ~/tobixu-iso/build-manana.log; echo "== sigue vivo? =="; pgrep -f hornear-rc4.sh | head -n 3'
```

- **Verde:** los tres ceros del testigo, la puerta renombrada, y el log entrando en `lb binary`.
- **Rojo:** el script se apagó solo (sin PIDs) → **la puerta se cerró**: lee la cola para ver qué testigo falló. Eso es familia F7/F8, no F9: se corrige en el máster de tetris, se redespliega y se relanza. Nunca se parchea en forja.

---

## 🟢 Checkpoint 5 — mksquashfs, binary y bautizo (última hora)

**Qué prueba:** que el pan existe y tiene nombre.

```bash
ssh forja 'grep -E "LB EXIT|BAUTIZO|ERROR|FATAL" ~/tobixu-iso/build-manana.log ~/tobixu-iso/build-2026*.log 2>/dev/null | tail -n 8; echo "== especimen =="; ls -lah ~/tobixu-iso/*.iso 2>/dev/null; echo "== caja negra =="; ls -lh ~/tobixu-iso/caja-negra.log 2>/dev/null || echo "(nunca existio: F9 murio sin testificar)"'
```

- **Verde:** `LB EXIT: 0` + `BAUTIZO COMPLETO` + ISO con fecha de hoy + caja negra ausente. Entonces: **pull de tres líneas a tetris, `sha256sum -c` en verde, y smoke de once puntos en `disco-rc42.qcow2` virgen.**
- **Rojo:** `LB EXIT` distinto de 0 → leer las 30 líneas anteriores del log fechado; a esta altura los culpables posibles son de la familia binary/squashfs, todos con acta propia ya.

---

**Regla que cubre los cinco:** un horno en marcha no se opera, se vigila de lectura. Y si algún checkpoint muestra `D`, el orden es siempre: caja negra → pegarme la traza → decidir. Nunca al revés.

Ve cruzando checkpoints con calma, guardián. Yo espero aquí, con el río mirado de frente. 🦎🧱
