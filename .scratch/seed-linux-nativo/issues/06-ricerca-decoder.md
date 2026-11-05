# 06 — Ricerca: strumenti garantiti per la decodifica di `seed.hex`

Type: research
Status: resolved

## Question

Fatti che una decisione attende: quali strumenti di decodifica hex-dump sono garantiti su
un sistema Linux minimale — `od` (è davvero POSIX?), `xxd` (vim-common), `python3` — e
quindi cosa `install.sh` può assumere senza violare la promessa zero-install (solo shell
POSIX + repo). Fatto già accertato in sede di charting, da verificare/estendere:
`install.sh` oggi decodifica solo con `xxd` o `python3`, e il ramo `od`/`awk` è incompleto
(richiama comunque `python3_decode`).

Include anche: disponibilità e comportamento di `chmod`, `ln`, `mkdir`, `command -v` su
shell POSIX strette (dash/ash). Serve a [07 — Installazione e launcher: il contratto
zero-install](07-installazione-launcher.md).

## Answer

Findings completi con fonti primarie in
[`../research/06-decoder.md`](../research/06-decoder.md). Sintesi:

- **`od` è POSIX** (`-A n`, `-t x1` validi) ma è solo un *dumper* (binario→hex): la
  specifica non prevede inversione, quindi **non può decodificare** `seed.hex`.
- **`xxd` non è garantito**: non POSIX, assente da BusyBox, pacchetto separato in
  Debian (Source: vim) e Alpine. Funziona col formato di `seed.hex` (round-trip
  byte-identico verificato) ma è solo un gradino opzionale della catena.
- **`python3` non è garantito**: non POSIX, assente dai minimal system.
- **Pavimento garantito**: `printf` POSIX con escape ottali `"\ddd"` — la specifica
  dice «written as a byte»; decoder sh puro provato byte-esatto, ~0,1 s per l'intero
  `seed.hex` del PE. `awk` è seconda scelta (`%c` non byte-sicuro in locale multibyte:
  gawk UTF-8 → `c3 bf` per 0xff; richiede `LC_ALL=C`).
- **`chmod`, `ln -s`, `mkdir -p`, `command -v`**: tutti utility POSIX, ok su dash/ash
  (BusyBox li fornisce come applet/builtin).
- **Bug confermato** in `install.sh`: il ramo `od`/`awk` chiama comunque
  `python3_decode`; catena coerente proposta: `xxd` → `python3` → sh puro `printf`.
  La decisione sulla catena spetta a 07.

## Comments
