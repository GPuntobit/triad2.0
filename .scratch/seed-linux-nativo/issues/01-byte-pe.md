# 01 — Politica dei byte del PE nella rifattorizzazione

Type: grilling
Status: resolved

## Question

N16 (`TASK.md`) rifattorizza `gen_seed.js` isolando le chiamate di sistema in `os_*`, con
acceptance «il PE rigenerato deve restare byte-identico a quello versionato; se così non
fosse: nuovo hash in CI e diff tracciata». Quale politica rendiamo vincolante?

- (a) **Byte-identico obbligatorio**: il PE versionato non cambia in questa fase; ogni
  diff nei byte blocca la rifattorizzazione. Vincolo forte sull'architettura del codegen.
- (b) **Byte-identico come regola, con eccezione tracciata**: se il refactoring rende il
  dump inevitabilmente diverso (stessa semantica, disposizione diversa), si accetta un
  nuovo `seed.hex` con nuovo hash in CI e diff documentata.

La risposta vincola [02 — Architettura del codegen per due piattaforme](02-architettura-codegen.md):
la scelta fra generatore unico e doppio emettitore pesa diversamente a seconda di
quanto è stretto questo vincolo.

## Answer

**Decisione 2026-11-04 (sessione wayfinder): politica (a) — byte-identico obbligatorio,
vincolante.** Confermata esplicitamente dal maintainer insieme ai dettagli operativi
(Q1–Q4 del round di grilling). Il maintainer si riserva di ripensarci «in futuro»:
ogni revisione ridefinisce questa risoluzione, non la sospende.

- **Politica (Q1):** (a) byte-identico obbligatorio, con scope preciso: N16 è «solo
  struttura», e `cmp` sui byte è l'unico test che lo prova davvero (la conformance non
  vede i cambi di layout). L'isolamento `os_*` resta possibile, ma a livello di
  *generatore* (funzioni JS che emettono le sequenze syscall inline come oggi), non a
  livello di codice macchina (sottoroutine `call`). Se (a) risultasse impossibile, il
  cambio di layout è una decisione architetturale da portare a
  [02 — Architettura del codegen per due piattaforme](02-architettura-codegen.md), non
  un incidente della sessione di rifattorizzazione. Precedente motivante: il drift
  silenzioso di 1705 byte del commit CodeQL `649709a` (vedi N01 in `TASK.md`).
- **Artefatti e contratti (Q2):** il vincolo copre tutti e tre gli artefatti del PE:
  `seed/windows-x86_64/seed.hex` (canonico, hash in CI) e `seed.exe`/`seed_decoded.exe`,
  che devono restarne la decodifica esatta. Due contratti distinti e entrambi
  vincolanti: **riproducibilità del dump** (`gen_seed.js` rigenera esattamente i byte
  versionati) e **immutabilità del PE** (i byte versionati non cambiano durante il
  lavoro strutturale). L'ELF di `seed/linux-x86_64/` è fuori: i suoi byte devono
  cambiare nei passi pianificati (stub E0 → interprete), è cambiamento pianificato, non
  drift.
- **Procedura su diff (Q3):** bug finché non provato il contrario: stop, diff, causa
  (come in N01, dove era un bug del generatore). Solo un diff che *dimostri*
  l'impossibilità dell'isolamento byte-preservante escalationa a
  [02 — Architettura del codegen per due piattaforme](02-architettura-codegen.md), che
  deve esplicitare il cambio di layout: nuovo hash in CI + diff documentata +
  conformance verde. L'eccezione non si concede mai silenziosamente nella sessione che
  fa la rifattorizzazione.
- **Durata (Q4):** il vincolo vale per tutto il lavoro strutturale (N16 e pulizie
  future), fino al ciclo deliberato N03/N04/N05 (rebuild PE/ELF + hash CI): i
  cambiamenti semantici deliberati applicano la procedura dell'eccezione tracciata,
  non la rendono superflua. Windows resta piattaforma di prima classe col PE invariato.
- **Dominio:** due nuove voci in `GLOSSARY.md` — «Immutabilità del PE» e
  «Riproducibilità del dump» — distinte da «Parità byte-a-byte» (equivalenza di stdout
  fra i due seed).
- **Effetti:** l'acceptance morbida di N16 in `TASK.md` («se così non fosse: nuovo hash
  in CI e diff tracciata qui») è superata e allineata a questa decisione; la risposta
  vincola [02 — Architettura del codegen per due piattaforme](02-architettura-codegen.md)
  (padrone delle eccezioni) e, a valle, il contratto `os_*`.

## Comments
