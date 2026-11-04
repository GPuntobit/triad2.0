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

## Not yet specified

- **IDE / tooling di sviluppo per Triad**: diagnostica, run da editor, LSP minimo su
  `editors/`. Secondario e non bloccante (`TASK.md` N19, risposta Q2 → b): si cristallizza
  quando la catena nativa è chiara, poi diventa ticket.
- **`triad-cli` senza Node**: il confine zero-install copre oggi l'**esecuzione** dei
  programmi (risposta Q4); la CLI senza Node si specifica quando il percorso di esecuzione
  è chiuso.

## Out of scope

- **Architetture diverse da x86-64** (aarch64/Termux incluso): un secondo seed scritto a
  mano per un'altra ISA sarebbe un nuovo sforzo con destinazione propria (risposta Q3),
  non un passo di questa mappa.
- **La catena S2–S4** (compilatore nativo e self-hosting): resta la mappa di
  `BOOTSTRAP.md`; questa mappa si ferma alla toolchain Linux nativa.
- **Rimozione completa di JavaScript dal progetto** (generatori del seed, runner di
  conformance/probe, riferimento JS `triad_core.cjs`, tooling `ai/`): strumenti di sviluppo
  tollerati dalla regola operativa 2, fuori dalla catena S0→S4; eliminarli è conseguenza
  del self-hosting S2–S4, non un passo di questa mappa. L'**esecuzione** dei programmi
  Triad è già JS-free col seed nativo (percorso zero-install); la sola foglia in scope è
  la CLI senza Node (vedi «Not yet specified»).
