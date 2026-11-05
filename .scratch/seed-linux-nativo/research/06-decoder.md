# 06 — Findings: strumenti garantiti per la decodifica di `seed.hex`

Ricerca per [06 — Ricerca: strumenti garantiti per la decodifica di `seed.hex`](../issues/06-ricerca-decoder.md).
Fatti, non decisioni: servono a [07 — Installazione e launcher: il contratto
zero-install](../issues/07-installazione-launcher.md). Fonti primarie citate per ogni
claim; i test empirici sono locali (CachyOS, GNU coreutils 9.12, gawk 5.4.1, bash come
`sh`), 2026-11-03.

## 1. `od` è POSIX, ma è solo un *dumper*: non può decodificare

- `od` è utility POSIX.1-2024: `od [ -v ] [ -A address_base ] [ -j skip ] [ -N count ]
  [ -t type_string ] ...`. Opzioni confermate dalla specifica: `-A n` (nessun offset)
  e `-t x1` (hex, 1 byte) sono entrambe valide. [S1]
- Ma la sua DESCRIPTION è «**dump** files in various formats»: scrive il contenuto
  dell'input in un formato a scelta. La specifica **non prevede alcuna inversione**
  hex→binario. [S1]
- Conseguenza: il ramo `od`/`awk` di `install.sh` non può usare `od` per decodificare;
  `od` può tutt'al più validare/dumpare. Il probe attuale
  (`od -An -tx1 "$HEX" >/dev/null 2>&1 || true`) è un no-op. [S7]

## 2. `xxd` non è garantito su sistema minimale

- **Non è utility POSIX**: assente dall'indice delle utility POSIX.1-2024. [S2]
- **Assente da BusyBox**: nessun applet `xxd` nella lista ufficiale degli applet
  (presenti invece `od`, `awk`, `hexdump`, `printf`, `chmod`, `ln`, `mkdir`). [S3]
- **Debian**: pacchetto separato `xxd` (Source: vim); nelle immagini minimali
  (debian:slim) non è presente. [S4]
- **Alpine**: pacchetto separato `xxd` (9.1.0707-r0, Source: vim, repo `main`); non
  fa parte del sistema base/busybox. [S5]
- Verificato localmente che `xxd -r -p` **interpreta correttamente il formato di
  `seed.hex`** (coppie hex, 16 byte/riga, senza offset; whitespace ignorato):
  round-trip `xxd -r -p seed.hex` = `seed/linux-x86_64/seed` **byte-identico**. [S7]

## 3. `python3` non è garantito

Non è utility POSIX (assente dall'indice) né componente di un sistema minimale
Debian/Alpine/BusyBox: solo strumento di sviluppo opzionale. [S2][S3][S4][S5]

## 4. Il pavimento garantito: `printf` POSIX con escape ottali

- La specifica del utility `printf`: `"\ddd"` (ddd ottale a 1–3 cifre) «shall be
  written as **a byte** with the numeric value specified by the octal number». [S6]
- Quindi un decoder **sh puro** è possibile senza alcuna dipendenza: leggere le coppie
  hex, valore con aritmetica `$((0x$pair))` (costanti hex previste dall'aritmetica
  POSIX), emissione con `printf "\\%03o"`. `printf` è builtin della shell (dash, ash,
  bash) e comunque utility POSIX. [S6]
- Test empirico: `sh -c "printf '\\177\\105\\114\\106'"` → `7f 45 4c 46` (magic ELF),
  byte-esatto. Benchmark (bash, 5000 byte in ~21 ms): il seed PE (~25 KB binari da
  `seed.hex` da 50 960 byte) decodifica in ~0,1 s — costo trascurabile per
  `install.sh`. [S7]

## 5. `awk` è una seconda scelta, non il pavimento

- `awk` è utility POSIX [S2], presente anche in BusyBox [S3], **ma** `printf "%c"`
  non è byte-sicuro in locale multibyte: test locale con gawk —
  `printf "%c", 255` in `LC_ALL=en_US.UTF-8` produce **due byte** (`c3 bf`), in
  `LC_ALL=C` produce `ff`. [S7]
- La specifica awk converte il valore in «character» nella locale corrente: per i
  valori 128–255 l'output non è garantito byte-esatto. Un decoder awk deve forzare
  `LC_ALL=C`, e anche allora resta meno forte del `printf` con escape ottali, la cui
  specifica parla esplicitamente di *byte*. [S6][S7]

## 6. `chmod`, `ln`, `mkdir`, `command -v` sono tutti POSIX

Synopsis dalle specifiche: `chmod [ -R ] mode file ...`; `ln [ -fs ] [ -L|-P ]
source_file target_file`; `mkdir [ -p ] [ -m mode ] dir ...`; `command [ -p ]
[-v|-V ] command_name` (`command -v` è nella specifica POSIX della shell). [S8–S11]
`dash` è conforme POSIX 1003.2 [S12]; BusyBox fornisce applet `chmod`, `ln`, `mkdir`,
`printf`, `awk`, `od` e `command` come builtin ash. [S3] Quindi `install.sh` può
assumere `chmod +x`, `ln -s`, `mkdir -p`, `command -v` senza violare zero-install.

## 7. Bug accertato nel ramo `od`/`awk` di `install.sh` (da verificare/estendere)

Confermato e esteso il fatto accertato al charting: `install.sh` decodifica solo con
`xxd` o `python3`; il ramo `elif od && awk` **chiama comunque `python3_decode`**
(`install.sh`, righe 67–86). Se `od`+`awk` esistono ma `python3` no, `decode_hex`
fallisce e il messaggio suggerisce «servono xxd o python3». [S7]

Catena di decoding coerente col pavimento garantito (fatto → proposta; la *decisione*
spetta a 07): `xxd` → `python3` → **sh puro `printf`** (o `awk` con `LC_ALL=C` come
penultimo gradino).

## Fonti

- [S1] POSIX.1-2024 (Issue 8), `od`: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/od.html
- [S2] POSIX.1-2024, indice utility (`base64`, `xxd`, `python` assenti; `od`, `printf`, `awk` elencati): https://pubs.opengroup.org/onlinepubs/9799919799/utilities/contents.html
- [S3] BusyBox, lista ufficiale applet: https://busybox.net/downloads/BusyBox.html
- [S4] Debian, pacchetto `xxd` (Source: vim): https://packages.debian.org/sid/xxd
- [S5] Alpine, pkgs search `xxd` (9.1.0707-r0, Source: vim, repo main): https://pkgs.alpinelinux.org/packages?name=xxd
- [S6] POSIX.1-2024, `printf` (escape `\ddd` → «written as a byte»): https://pubs.opengroup.org/onlinepubs/9799919799/utilities/printf.html
- [S7] Test empirici locali, 2026-11-03 (round-trip `xxd`, benchmark sh, gawk `%c` in locale UTF-8 vs C, lettura `install.sh`).
- [S8] POSIX.1-2024, `command` (`-v`): https://pubs.opengroup.org/onlinepubs/9799919799/utilities/command.html
- [S9] POSIX.1-2024, `chmod`: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/chmod.html
- [S10] POSIX.1-2024, `ln`: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/ln.html
- [S11] POSIX.1-2024, `mkdir`: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/mkdir.html
- [S12] dash manpage (conformità POSIX 1003.2): https://manpages.debian.org/bookworm/dash/dash.1.en.html
