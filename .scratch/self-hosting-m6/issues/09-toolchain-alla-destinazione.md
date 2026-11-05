# 09 — Toolchain e launcher alla destinazione

Type: grilling
Status: open
Blocked by: 04, 05

## Question

Il contratto zero-install firmato nella mappa _Seed Linux nativo senza Wine_ dice:
`install.sh` decodifica il seed, `bin/triad programma.td` lo esegue, wrapper a percorso
assoluto, fallback JS solo esplicito (`--jsref`). Alla destinazione M6 il seed è
**ritirato** — la catena d'uso non lo richiede più. Cosa diventa quel contratto?

- `bin/triad` esegue il **S1 compilato** (interprete nativo) invece del seed? E il launcher
  installato resta un wrapper a percorso assoluto?
- `install.sh` cosa installa, se non decodifica più il seed — artefatti committati li
  copia, artefatti ricostruiti li costruisce?
- il seed resta la root di ricostruzione della catena: in quale forma documentata?

Dipende dalla forma degli artefatti e dal linguaggio del compilatore; la risposta chiude
con un aggiornamento del contratto zero-install.

## Riferimenti

- Preliminari: [04 — Linguaggio sorgente del compilatore S2](04-linguaggio-sorgente-s2.md), [05 — Forma degli artefatti compilati](05-forma-artefatti.md).
- Contratto da aggiornare: [07 — Installazione e launcher: il contratto zero-install](../../seed-linux-nativo/issues/07-installazione-launcher.md).
- Collegato: [08 — Certificazione del punto fisso: meccanica e CI](08-certificazione-punto-fisso-ci.md).
