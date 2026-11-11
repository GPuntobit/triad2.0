# Mappa wayfinder — Self-hosting: compilatore nativo e punto fisso (M6)

Label: `wayfinder:map`
Ticket figli: [`issues/`](issues/) — uno per file, `NN-<slug>.md`; il **frontier** sono i
file aperti, non bloccati (`Blocked by:` vuoto o tutto `resolved`) e non claimati: il
numero più basso vince.
Tracciata il 2026-11-05, prosecuzione della mappa
[_Seed Linux nativo senza Wine_](../seed-linux-nativo/map.md) (chiusa, via chiara): qui la
catena S0→S4 prosegue verso il self-hosting (`BOOTSTRAP.md` S2–S3, milestone M5–M6).

## Destination

Da un checkout del repository, la catena **Triad → Triad** raggiunge il **punto fisso**: il
compilatore nativo scritto in Triad, ricompilando la propria sorgente, produce un binario
**identico byte-a-byte al proprio** (definizione del punto fisso), e tutti gli artefatti
della catena passano l'**intera conformance** (Core + Full) sui golden (gate di
correttezza), su **entrambe** le piattaforme — PE (Windows) ed ELF (Linux) — con parità
byte-a-byte di stdout ed exit code. Il **seed è ritirato**: la catena d'uso e di
ricostruzione non lo richiede più; la sua sorgente annotata resta versionata. Nessun
linker, compilatore o runtime esterno nel percorso. `SPEC-CORE.md` non cambia di una virgola.

## Notes

- **Dominio**: seed (`seed/dev/gen_seed*.js`, `seed/windows-x86_64/`, `seed/linux-x86_64/`),
  S1 (`selfhost/`), compilatore nativo (da definire in questa mappa), verifiche
  (`conformance/`, `tests/probes/`), CI (`.github/workflows/ci.yml`), toolchain
  (`install.sh`, `bin/triad`, `cli/`).
- **Normativo**: `SPEC-CORE.md` (regola 1: nessuna semantica inventata); `BOOTSTRAP.md`
  §1–§4, §6 (M4–M6), §7, §8; regola 4 (Triad-Core ⊂ Triad-Full); regola 2 (JS fuori dalla
  catena S0→S4); regola 5 (determinismo byte-exatto). I contratti già firmati nella mappa
  [_Seed Linux nativo senza Wine_](../seed-linux-nativo/map.md) (architettura del codegen,
  contratto `os_*`, parità/CI, zero-install, immutabilità del PE) restano **vincolanti**
  finché non ridecisi esplicitamente qui.
- **Solo decisioni**: le slice di esecuzione restano in `TASK.md` (N03–N05 = ciclo rebuild
  PE/ELF + hash CI; N16–N18 = porta Linux del seed, **chiuse** il 2026-11-05; dal 2026-11-07
  N20–N24 = ciclo di rebuild del seed per S1, scaturito dalla decisione
  [01](issues/01-fork-architetturale-seed.md); sezione «Bootstrap Tasks (S2-S4)») e vanno
  referenziate, mai duplicate.
- **Il seed dopo la decisione [01](issues/01-fork-architetturale-seed.md)**: è **veicolo di
  transizione per S1**, non implementazione Core conforme; envelope ri-proporzionato
  (buffer sorgente 1 MiB, heap 8 MiB, liste a 64 elementi), **sottoinsieme certificato**
  in `seed/README.md` + `seed/dev/certified-subset.txt`.
- **Skill da consultare**: `grilling` + `domain-modeling` per i ticket `grilling`;
  `prototype` per i ticket `prototype`; `research` per i ticket `research`.
- **Glossario**: quando un termine cristallizza in un ticket, aggiornare `GLOSSARY.md`
  subito (2026-11-05: *Catena S0→S4*, *Punto fisso*, *Self-hosting*, *Seed ritirato*;
  2026-11-07: *Sottoinsieme certificato*, *Divergenza silenziosa*).

## Decisions so far

<!-- indice: una riga per ticket chiuso — gisting della risposta + link al ticket, il
     dettaglio vive solo nel ticket -->

- [10 — Ricerca: punto fisso e root del bootstrap in catene self-hosted note](issues/10-ricerca-punto-fisso-root.md):
  il fixed point byte-identico è certificato solo da GCC (stage2 vs stage3), OCaml
  (`cmpbyt` dopo `stripdebug`), Nim (`sameFileContent`, «except for timestamps», non
  fatale) e Chez (FASL-equal sui boot file, `look-for-fixpoint`); Rust solo «same-result
  test» opzionale; Go/CHICKEN/Collapse OS/jonesforth nessun confronto. Root: sempre
  committata (artefatti compilati: `boot/` bytecode, `csources_v2` C) o esterna pinnata
  (Rust `src/stage0`, Go 1.4, snapshot); nessuno ritira lo stadio 0. La nostra definizione
  di punto fisso è più forte di ogni precedente. Findings su branch `research/10-punto-fisso`;
  sblocca 08 e informa 04.
- [12 — Guardie statiche per la sorgente di S1](issues/12-guardie-statiche-sorgente-s1.md):
  le guardie stanno in un **controllore dedicato** (`tools/selfhost-guard/`) che riusa
  l'AST del riferimento JS (nessun secondo parser) e consuma il **contratto del seed**
  (`seed/dev/certified-subset.txt`): ogni regola è legata a una divergenza e **si spegne
  da sola** quando la divergenza sparisce dal contratto (quando il seed viene corretto).
  Criterio di precisione: una regola statica decide solo ciò che si vede nell'AST; le
  divergenze che dipendono dai **tipi a runtime** (unica: D15, `string(x)`) **non** hanno
  una regola statica aggressiva ma sono presidiate dal **gate differenziale** seed↔JS
  (stesso stdout byte per byte, stesso exit code, per programma del corpus certificato);
  se il differenziale trova una differenza la risposta è **chirurgia nel seed** (è il
  criterio di «non presidabile»: silenziosa + non decidibile staticamente ⇒ chirurgia).
  Il corpus certificato (`seed/dev/certified-corpus.txt`) elenca i programmi che il seed
  deve eseguire (front-end di S1, smoke, generatori del sito); gli altri `.td` sono
  **fuori contratto** e le loro violazioni sono avvisi, non errori. Misure: D20 ha due
  casi (il nome *nuovo* è una divergenza vera fra i runtime, il nome *già legato* è
  identico nei due runtime e resta una decisione normativa pending, famiglia N08); D18
  non è una divergenza fra funzioni (il seed le risolve) ma solo a livello di file; D9
  ammette `println` in posizione finale. Tre presidî nella CI: guardie statiche, self-test
  (un fixture per regola), differenziale.
- [01 — Fork architetturale del seed: gap reali e AST/bytecode](issues/01-fork-architetturale-seed.md):
  il seed **non** viene forkato con un livello AST/bytecode (la motivazione di
  `BOOTSTRAP.md` §10 è misurata obsoleta) e resta un **veicolo di transizione per S1**, non
  un'implementazione Core conforme: pavimento = §8 (`readfile` incluso, senza il quale S1
  non può leggere il programma) + le divergenze che la sorgente di S1 tocca + `liste` verde
  (39/39); il resto **fuori contratto**. Le costruzioni *rumorose* (exit 1) sono **vietate
  nella sorgente di S1** (guardie statiche), le *silenziose* (scope dinamico, cattura per
  valore, escape, `==` su stringhe, newline, scope di `while`, `while` non-`Bool`) hanno
  **guardie statiche dedicate**, con chirurgia nel seed solo se non presidabili. Il
  **riferimento JS** è l'autorità semantica di sviluppo, il seed è il gate di esecuzione.
  L'**arena va ri-proporzionata** (buffer sorgente 64 KiB → 1 MiB, heap 64 KiB → 8 MiB:
  l'envelope attuale non ospita S1; le liste restano a 64 elementi). Criterio di riapertura
  del fork: costo **misurato**. Il contratto del seed vive in `seed/README.md` + elenco
  macchina-leggibile (`seed/dev/certified-subset.txt`), termine canonico *sottoinsieme
  certificato*. Slice in `TASK.md` N20–N24.

## Not yet specified

<!-- foschia in scope: domande sospettate ma non ancora abbastanza precise da ticket -->

- **Semantica a 64 bit degli interi in S1**: il seed offre solo 62 bit (2 bit di tag) e
  **rifiuta** i valori fuori range (divergenza `D25`, ora `noisy`:
  [`docs/adr/0003-range-interi-del-seed.md`](../../docs/adr/0003-range-interi-del-seed.md));
  S1 gira sul seed e, delegando l'aritmetica all'host, sarebbe non conforme a
  `SPEC-CORE.md` §5. Decisione aperta in
  [13 — Semantica a 64 bit degli interi in S1](issues/13-interi-64-bit-in-s1.md).

- **Interno di S1 per le feature Full** (Prolog `fact`/`rule`/`solve`, macro, contratti,
  effetti, budget, trace): come si rappresentano in Triad-Core dipende da
  [_Architettura di S1_](issues/02-architettura-s1.md); una o più patch di ticket quando
  il frontier ci arriva.
- **Compilazione nativa di programmi Triad-Full** (utente) vs esecuzione interpretata dal
  S1 compilato: dipende dai ticket del ramo compilatore (linguaggio sorgente, forma degli
  artefatti); potrebbe restare oltre M6.
- **Performance/ottimizzazione** del compilatore e degli artefatti compilati: non blocca
  il punto fisso; da rivedere quando il compilatore esiste.
- **Procedura di ricostruzione documentata della catena** (come si riparte dalle sorgenti
  fino al punto fisso, in `docs/`): dipende dalle risposte di
  [_Certificazione del punto fisso: meccanica e CI_](issues/08-certificazione-punto-fisso-ci.md)
  e [_Toolchain e launcher alla destinazione_](issues/09-toolchain-alla-destinazione.md).

## Out of scope

- **S4 completo** (REPL, CLI come prodotto, esempi, docs): oltre la destinazione M6 —
  sforzo futuro con destinazione propria.
- **Rimozione dei dev-tool JS dal repository** (generatori del seed, runner,
  `triad_core.cjs`, tooling `ai/`): regola operativa 2 li tollera fuori dalla catena
  S0→S4; eliminarli del tutto è conseguenza del self-hosting, oltre M6.
- **Architetture diverse da x86-64** (aarch64/Termux incluso): ripreso dalla mappa
  precedente — un secondo ISA è un altro sforzo con destinazione propria.
