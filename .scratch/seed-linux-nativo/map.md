# Mappa wayfinder — Seed Linux nativo senza Wine

Label: `wayfinder:map`
Ticket figli: [`issues/`](issues/) — uno per file, `NN-<slug>.md`; il **frontier** sono i
file aperti, non bloccati (`Blocked by:` vuoto o tutto `resolved`) e non claimati: il
numero più basso vince.
Tracciata il 2026-11-03, come prosecuzione della decisione maintainer «Task principale:
seed Linux nativo senza Wine» (`TASK.md`).

## Destination

Da un checkout pulito su Linux x86-64: `./install.sh` → `bin/triad programma.td` esegue
programmi Triad-Core con **zero dipendenze esterne** (niente Wine, niente Node per
l'esecuzione), tramite il seed ELF64 statico (senza libc né dynamic linker) con stdout
**byte-identico** al PE. Windows resta piattaforma di prima classe col PE invariato:
nessuna delle due piattaforme emula l'altra. `SPEC-CORE.md` non cambia di una virgola.

## Notes

- **Dominio**: seed/interprete Triad-Core in codice macchina (`seed/dev/gen_seed.js`,
  `seed/dev/gen_seed_linux.js`, `seed/windows-x86_64/`, `seed/linux-x86_64/`), toolchain
  (`install.sh`, `bin/triad`, `cli/`), CI (`.github/workflows/ci.yml`), verifiche
  (`conformance/`, `tests/probes/`).
- **Normativo**: `SPEC-CORE.md` (regola operativa 1: nessuna semantica inventata),
  `BOOTSTRAP.md` §4 (routine `os_*`), §5 (riga «Linux x86-64 (ELF)»), §6 (M7 = parità +
  porta Linux), §9 (rischio «Seed too tied to Windows»); vincolo Triad-Core ⊂ Triad-Full
  (regola 4); JS reference fuori dalla catena S0→S4 (regola 2); output deterministico
  byte-exatto (regola 5).
- **Skill da consultare**: `grilling` + `domain-modeling` per i ticket `grilling`;
  `prototype` per i ticket `prototype`; `research` per i ticket `research`.
- **Preferenze stabili**: i ticket di questa mappa sono *decisioni*, non slice di
  costruzione — le slice N15–N18 restano il piano d'esecuzione in `TASK.md` e vanno
  referenziate, mai duplicate. La porta Linux precede N03 e le sotto-task meccaniche
  (decisione maintainer 2026-11-03). L'ELF deve comportarsi come il PE, limiti noti
  compresi.
- **Glossario**: `GLOSSARY.md` alla radice; quando un termine si cristallizza in un
  ticket, si aggiorna lì subito.

## Decisions so far

<!-- indice: una riga per ticket chiuso — gisting della risposta + link al ticket, il
     dettaglio vive solo nel ticket -->

- [01 — Politica dei byte del PE nella rifattorizzazione](issues/01-byte-pe.md):
  politica **(a) vincolante** — immutabilità del PE + riproducibilità del dump per tutto
  il lavoro strutturale; ogni diff nei byte è un bug, e un cambio di layout deliberato va
  deciso in _Architettura del codegen per due piattaforme_; eccezioni solo per cambi
  semantici deliberati (ciclo N03–N05) con hash CI + diff tracciati.
- [02 — Architettura del codegen per due piattaforme](issues/02-architettura-codegen.md):
  architettura **(a)** — un generatore, *core del codegen* condiviso + due *backend di
  piattaforma* (PE/ELF); `os_*` è il confine completo con emissioni inline (mai
  sottoroutine); memory map interna identica sulle due piattaforme; entry unico
  `gen_seed.js <windows|linux|all>`; nessuna eccezione di layout del PE concessa.
- [03 — Contratto delle routine `os_*`](issues/03-contratto-os-star.md):
  contratto **firmato (Q1–Q6)** — forma a *piazzamenti ordinati* (byte-identico su PE
  per costruzione, nessuna eccezione di layout); lista `os_arg`/`os_open`/`os_read`
  (legge tutto e chiude)/`os_write`/`os_exit`/`os_alloc` (una chiamata, arena bump
  `0x40000` senza GC); stato `r14` base, `r12` stdout (solo PE), `rbx` file, `r13`
  conteggio; errori exit 1/2 identici, **PE muto**, stderr solo sull'ELF fuori
  parità; ELF usa `openat` (N15). Spike su branch `prototype/os-star-contract`.
- [04 — Parità: suite di riferimento, CI e politica delle divergenze](issues/04-parita-suite-ci.md):
  gate = `conformance/core` (39 casi, senza più lo skip `liste`) + probe `ok_*`/`test_*` +
  golden `selfhost/source.expected.out` + esiti `bad_*` (exit code + stdout vuoto, niente
  testi d'errore); confronto su **golden condivisi**, verifica **solo su Linux nativo**
  (gambe Windows della CI rimosse: `seed-windows` + matrice `site-gen`); lato PE garantito
  da hash `seed.hex` + golden congelati; anti-drift `gen_seed.js && cmp` in CI; ordine di
  verità SPEC-CORE.md > PE (nei golden) > ELF, conflitto → CI rossa + ticket, golden
  rigenerati solo da SPEC-CORE.md nei cambi deliberati.
- [05 — Ricerca: come altri seed scritti a mano isolano il confine OS](issues/05-ricerca-confine-os.md):
  dai 2 servizi BIOS di sectorlisp/sectorforth/hex0 alle 2 routine-per-classe di Collapse
  OS, fino alle 6 + sportello generico di jonesforth: il confine resta piccolo, heap sempre
  gestito in linguaggio (o `brk` una tantum), errori per codice/flag mai per stringa.
  Nessuna divergenza con _Architettura del codegen_ e _Contratto `os_*`_; innovazione
  consapevole: `os_read` «leggi tutto e chiudi». Findings su branch `research/05-confine-os`.
- [06 — Ricerca: strumenti garantiti per la decodifica di `seed.hex`](issues/06-ricerca-decoder.md):
  `od` è POSIX ma solo *dumper* (non decodifica); `xxd`/`python3` **non** garantiti
  (non POSIX, assenti da BusyBox/minimal system); pavimento zero-install = `printf`
  POSIX con escape ottali `"\ddd"` (decoder sh puro, byte-esatto, ~0,1 s); `awk` solo
  con `LC_ALL=C` (`%c` non byte-sicuro in locale multibyte); `chmod`/`ln`/`mkdir`/
  `command -v` tutti POSIX. Bug confermato: ramo `od`/`awk` di `install.sh` chiama
  comunque `python3_decode`. Findings in
  [`research/06-decoder.md`](research/06-decoder.md); sblocca 07 e 08.
- [07 — Installazione e launcher: il contratto zero-install](issues/07-installazione-launcher.md):
  contratto firmato (Q1–Q11) — decoder sh-puro `printf` **unico** (niente `xxd`/`python3`/
  ramo `od`); binario decodificato resta committato e `install.sh` ridecodifica sempre
  (no-op deterministica = anti-drift via `cmp`); launcher installato = **wrapper a
  percorso assoluto** (niente symlink, `readlink` fuori contratto, `--no-symlink` rimossa
  col suo bug latente); fallback JS solo esplicito con **`--jsref`**, stub → errore exit 1,
  soglia 4 KB transitoria fino a N18 (poi soglia + flag + ramo JS escono da `bin/triad`);
  smoke test byte-exatto su `test_simple.td` + golden sidecar, mismatch → installazione
  fallisce; fuori Linux x86-64 parziale + avviso; zero-install = **sola esecuzione** (la
  CLI Node resta fino a 09), catena garantita solo `./install.sh` → `triad`. Sblocca 09.
- [08 — Harness di verifica senza Node (shell POSIX)](issues/08-harness-verifica-senza-node.md):
  contratto firmato (Q1–Q11) — entry point POSIX `conformance/run.sh [--update]` +
  `tests/probes/run_probes.sh` + `verify.sh`, oracle su **golden sidecar committati**
  (`<file>.expected.out` + `.expected.code`, generati una tantum dal **PE** poi congelati),
  confronto byte-exatto `cmp` senza normalizzazione, `bad_*` = exit ≠ 0 + stdout vuoto,
  report `diff -u`, runtime = seed repo + `TRIAD_SEED` senza fallback JS né `install.sh`,
  transizione **un colpo solo** (`run.mjs`/`run_probes.mjs`/`run.test.mjs` escono, CI
  ripuntata).
- [09 — CLI e toolchain senza Node](issues/09-cli-toolchain-senza-node.md):
  CLI sh **completa** `bin/triad-cli` (sostituzione 1:1) a **pura delega** — `run` →
  `bin/triad`, `test conformance|probes|all` → harness, `status` info ambiente; interfaccia
  **imposta a 08**: `conformance/run.sh` + `tests/probes/run_probes.sh` + `verify.sh` root,
  cwd-indipendenti, exit 0 = gate verde; dev CLI `cli/triad-cli.mjs` resta col nome attuale
  ma solo `seed`/`ai`/`ext` (`build standalone` rimosso, fallback JS lecito nei soli strumenti
  dev); ramo `bin/triad-native` fuori dal launcher (exec-sempre-il-seed); `install.sh`
  installa entrambi i wrapper, niente avvisi Node nel percorso utente; `.cmd` Windows
  invariati.

## Open (dopo la destinazione)

- [11 — Ternario con simbolo: il seed prende il `:` del simbolo come separatore](issues/11-ternario-simbolo-seed.md):
  difetto **misurato** del seed (non conforme a `SPEC.md` §1): il ternario col ramo *then*
  simbolico viene rifiutato (exit 1) quando la condizione è falsa; il riferimento JS è
  corretto. Divergenza `D23 = noisy` nel contratto del seed + guardia statica `G-D23`
  (vietata nei sorgenti di S1); caso di conformance `ternario_simbolo` congelato con il
  golden del riferimento JS e **2° gap noto** del gate (escluso in modo rumoroso). Il fix
  del codice macchina è rinviato a una sessione separata (ciclo di rebuild dei dump).

## Not yet specified

## Out of scope

- **Architetture diverse da x86-64** (aarch64/Termux incluso): un secondo seed scritto a
  mano per un'altra ISA sarebbe un nuovo sforzo con destinazione propria (risposta Q3),
  non un passo di questa mappa.
- **La catena S2–S4** (compilatore nativo e self-hosting): resta la mappa di
  `BOOTSTRAP.md`; questa mappa si ferma alla toolchain Linux nativa.
- **Esperienza di sviluppo / IDE** (diagnostica, run da editor, LSP minimo su `editors/`):
  oltre la destinazione zero-dep — il frontier si ferma alla destinazione
  ([10 — Esperienza di sviluppo / IDE: scope e forma](issues/10-esperienza-sviluppo-ide.md),
  chiusa fuori scope, 2026-11-05). Resta `TASK.md` N19 («se deciso») per uno sforzo futuro
  con destinazione propria.
- **Rimozione completa di JavaScript dal progetto** (generatori del seed, runner di
  conformance/probe, riferimento JS `triad_core.cjs`, tooling `ai/`): strumenti di sviluppo
  tollerati dalla regola operativa 2, fuori dalla catena S0→S4; eliminarli del tutto è
  conseguenza del self-hosting S2–S4. L'**esecuzione** dei programmi Triad è già JS-free
  col seed nativo (percorso zero-install); di questa mappa restano solo due foglie, entrate
  in scope per decisione _Parità: suite di riferimento, CI e politica delle divergenze_:
  l'harness di verifica senza Node ([08](issues/08-harness-verifica-senza-node.md)) e la
  CLI senza Node ([09](issues/09-cli-toolchain-senza-node.md)).
