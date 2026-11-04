# 06 — Ricerca: strumenti garantiti per la decodifica di `seed.hex`

Type: research
Status: open

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

## Comments
