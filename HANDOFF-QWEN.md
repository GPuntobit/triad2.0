# HANDOFF per Qwen — triad2.0

Da Hermes (lavoro parallelo, 2026-10-20). Stato condiviso fra le sessioni attive.
Non riscrivere ciò che è già fatto e verificato; **dichiara il tuo lane** al §6 prima di
toccare codice, così non ci pestiamo i piedi. File gemello di `HANDOFF-HERMES.md` (direttiva §7).

> **REGOLA D'ORO — mai cancellare codice:** non eliminare righe di codice; **commentale** e
> basta, con marcatore `[QWEN]` + motivo, così resta sempre traccia di cosa c'era.

## 0. Panoramica sessioni e lane (chi fa cosa ORA)

- **Qoder** — lato **Julia**: `triad.jl`, `syntax.jl`, `test/*`, `SPEC.md`, `TUTORIAL.md`.
  Suite **191/191 verde**; lane occupato.
- **Hermes** — lane **`triad-vm/` (Rust, VM S-expression)**: occupato, non toccare senza avviso.
- **Qwen** (tu) — lane **DA DICHIARARE** (§6). Sotto ci sono candidati liberi.
- **Codex** — lane DA DICHIARARE (`HANDOFF-CODEX.md`).
- **Kilo** — lane DA DICHIARARE (`HANDOFF-KILO.md`).

> ⚠️ Qwen, Codex e Kilo devono **dividersi i compiti**: confrontatevi nei rispettivi §6 prima
> di iniziare, per non prendere tutti lo stesso bug/lane.

## 1. Stato già fatto e verificato (NON duplicare)

- **Julia** (Qoder): 6 bug corretti — round-trip range `1:n`, `unparse` totale (`:destructure`/
  `:dfor`), `xs[end]=v`, escape sconosciuti, commenti `#=` annidati, lambda con parametri tipati.
- **triad-vm** (Hermes): `map`/`filter`/`reduce` a livello evaluator + fix init `reduce`;
  `(methods nome)`; dispatch per **specificità** (`select_method` + jolly `Any`). Build pulito,
  4 esempi verdi.

## 2. Regola trasversale (dal main user) — importante

**Non cancellare codice → commentalo** con marcatore `[QWEN]` + motivo, e firma nel registro
`HANDOFF-HERMES.md` §7.1. Esempi:
- Julia: `# [QWEN] rimosso X perché Y` oppure block `#= ... =#`.
- Rust/C: `/* [QWEN] sostituito da Z — motivo */`.

## 3. Candidati liberi (scegli un lane e segnalalo)

**Lato Julia** (Qoder ha già chiuso i 6 sopra; restano aperti, non ancora assegnati):
1. `not(g)` builtin mancante (`!g` esiste).
2. `let a = b = 1` (precedenza `parse_let`, `syntax.jl:785-798`).
3. corpo `rule` con virgola a inizio riga (`syntax.jl:452-465`).
4. `+=` valuta il `lhs` due volte (desugaring `syntax.jl:512`).
5. `renamevars` non scende nei `Rec` (`triad.jl:363-369`).
6. `{ }` tokenizzati ma non parsati (`syntax.jl:23`).
7. `'c'` caratteri non esistente.
8. Aree senza test: `--tree`, `-i`, comandi REPL `:tree`/`:reset`/`:help`.

**Lato triad-vm (Rust)** — se vuoi un lane pulito e isolato (ma è di Hermes: avvisa prima):
- SLD **non iterativo**: `prolog.rs` (solve/solve_conj) va in stack overflow su ricorsione
  a sinistra → convertirlo in worklist/iterativo.
- **Zero test** Rust: servirebbe una harness (`#[test]` o `cargo test`) sugli esempi.
- `triad-vm` non legge `.td` (allineamento SPEC §15).

**Analisi REA dei bundle** (nessuno l'ha presa): i tre CLI (`julia`/`swipl`/`sbcl`) sono stub
launcher; il peso è nei core/DLL accanto (`sbcl.core`, `libjulia-internal.dll`, `libswipl.dll`).
Confermare il layout PE con `inspect_*` target-free (NON `execute_rizin_command` su Windows:
fallisce sempre con `ERR_REA_WINDOWS_NATIVE`).

## 4. Ambienti / path utili

| cosa | path |
|---|---|
| Julia | `C:\Users\xbos\AppData\Local\Programs\Julia-1.13.1\bin\julia.exe` (`1.13.1`) |
| SWI-Prolog | `C:\Program Files\swipl\bin\swipl.exe` (`10.1.18`) |
| triad-vm | `cd triad-vm; cargo build; ./target/debug/triad run examples/<f>.triad` |
| Suite Julia | `julia --startup-file=no test/runtests.jl` |

## 5. Come coordinarsi

- Compila il §6 (lane, fatto, in corso, ack §7) e aggiorna `HANDOFF-HERMES.md` §7.2.
- Prima di toccare un file non tuo, controlla imtime / scrivi qui: `git` non ha ancora commit.

## 6. Note di Qwen (compila tu)

- lane: (da dichiarare — candidati liberi al §3: not(g), let a=b=1, rule virgola a inizio riga, += doppio eval, renamevars/Rec, {} , 'c', aree senza test)
- fatto:
- in corso:
- ack §7: [ ]
