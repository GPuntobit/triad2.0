# 07 — Installazione e launcher: il contratto zero-install

Type: grilling
Status: open
Blocked by: 06

## Question

Con la catena nativa pronta, quale diventa il contratto d'uso su Linux?

- **Decodifica del seed**: con i fatti di [06 — Ricerca: strumenti garantiti per la
  decodifica di `seed.hex`](06-ricerca-decoder.md) si sceglie la via che resta (es. solo
  `od` POSIX) e se il binario decodificato si committa o si rigenera all'installazione.
- **`bin/triad`**: lo stub sotto soglia (oggi 4 KB) non viene più eseguito silenziosamente
  né aggirato con fallback automatico — errore chiaro; il fallback JS resta solo
  **esplicito** (flag dedicata). Da decidere: nome della flag e messaggio d'errore.
- **Installazione**: cosa garantiamo esattamente nella promessa «clone → `./install.sh`
  → `triad programma.td`» — PATH/symlink, smoke test, comportamento senza `--prefix`.

Cross-ref: il gate CI di [04 — Parità: suite di riferimento, CI e politica delle
divergenze](04-parita-suite-ci.md) definisce cosa il launcher deve poter far girare.

## Comments
