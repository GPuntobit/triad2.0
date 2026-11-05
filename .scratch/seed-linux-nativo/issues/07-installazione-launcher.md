# 07 — Installazione e launcher: il contratto zero-install

Type: grilling
Status: resolved
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

## Answer

Decisioni firmate via grilling (2 round, 2026-11-04):

- **Decodifica del seed (Q1)**: **un solo decoder sh-puro `printf`** con escape ottali
  (pavimento garantito da [06 — Ricerca: strumenti garantiti per la decodifica di
  `seed.hex`](06-ricerca-decoder.md)): `xxd`, `python3_decode` e il ramo `od`/`awk`
  escono da `install.sh`. Scartata la catena con acceleratori: a 0,1 s non compra nulla,
  mentre ogni ramo condizionale marcisce (bug del ramo `od`→`python3_decode`).
- **Binario decodificato (Q2)**: **resta committato** (simmetria col PE) e `install.sh`
  **ridecodifica sempre** da `seed.hex`: la decodifica è deterministica (Riproducibilità
  del dump), quindi la sovrascrittura è un no-op ed è anche verifica anti-drift.
  Meccanica: decode su temporaneo, `cmp` col binario committato, avviso su mismatch,
  poi installazione.
- **Launcher installato (Q4)**: **wrapper sh a percorso assoluto** (`$PREFIX/triad` fa
  `exec "$ROOT/bin/triad" "$@"`), niente symlink nel percorso installato; `readlink` è
  **fuori dal contratto** (resta solo come robustezza best-effort per symlink creati a
  mano). `--no-symlink` **rimossa** (opzione sconosciuta → errore d'uso exit 2): il bug
  latente della copia (`TRIAD_HOME` = `$PREFIX/..`, launcher rotto) sparisce per
  costruzione.
- **Fallback JS (Q3)**: solo esplicito, flag **`--jsref`**. Seed stub/parziale → errore
  chiaro su stderr («il seed nativo è ancora uno stub: non esegue programmi; usa
  `--jsref` per l'interprete JS di riferimento (richiede Node)») + **exit 1**; exit 2
  resta per gli errori d'uso. Rilevamento stub = soglia di dimensione < 4 KB,
  **transitoria**.
- **Dismissione a N18 (Q9)**: soglia 4 KB, flag `--jsref` e ramo JS **escono da
  `bin/triad`** alla consegna di N18 (acceptance aggiornata in `TASK.md`); il JS di
  riferimento resta solo nel tooling di sviluppo (`seed/dev/`, harness), mai nel launcher
  utente.
- **Smoke test (Q5, Q10)**: `$PREFIX/triad tests/probes/test_simple.td` confrontato
  **byte-exatto** col golden sidecar `test_simple.expected.out` (`test\n`, convenzione
  già delle probe) via `cmp` (POSIX); mismatch → **`install.sh` exit non-zero**. La
  stringa stub «Triad seed Linux OK» esce dal contratto.
- **Piattaforme (Q6)**: fuori Linux x86-64 installazione **parziale** (launcher + PATH),
  decodifica e smoke test saltate con avviso esplicito, exit 0.
- **Perimetro zero-install (Q7, Q8)**: la promessa copre la **sola esecuzione** via seed
  nativo lungo la catena `./install.sh` → `triad programma.td`; `triad-cli` (Node) resta
  installato con avviso Node esplicitamente fuori promessa, fino a
  [09 — CLI e toolchain senza Node](09-cli-toolchain-senza-node.md). Il checkout nudo
  senza `install.sh` resta comodità documentata (README), non garantita.

Aggiornamenti: `TASK.md` (acceptance N18: dismissione della logica di stub e smoke test
che fallisce l'installazione), `GLOSSARY.md` (termine *Launcher*). Nessun ADR: scelte
tutte reversibili a basso costo.

## Comments
