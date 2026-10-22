# Prompt per JEV — analisi errori progetto Triad 2.0

## Contesto

Triad 2.0 è un linguaggio di programmazione autonomo con sintassi ispirata a Julia, programmazione logica in stile Prolog e codice come dato in stile Lisp. L'implementazione di riferimento (transitoria, stage0) è scritta in Julia: `triad.jl` (kernel/interprete, ~2045 righe) + `syntax.jl` (lessico e parser Pratt, ~859 righe).

## Obiettivo della task

JEV deve ispezionare **tutti i file creati** nel progetto e rispondere:
1. **Cosa si sbaglia?** — quali errori, bug, incongruenze, parti mancanti o incomplete ci sono?
2. **Quanti errori ci sono?** — conta precisa per categoria (sintassi, runtime, semantica, specifica, conformità, tooling, documentazione).
3. **Dove si trovano?** — file, riga, funzione/costrutto coinvolto.
4. **Qual è la gravità?** — bloccante, da correggere, miglioria, da documentare.

## File da ispezionare (elenco completo)

### Implementazione di riferimento (stage0 Julia)
- `triad.jl` — kernel, interprete, REPL, CLI, builtin, SLD, contratti, budget, tracce, effetti
- `syntax.jl` — lessico (lexer) e parser Pratt, albero uniforme `Node`

### Test e conformità
- `test/runtests.jl` — 243 test, tutti verdi (243/243)
- `test/oracles/oracle_tests.jl` — confronto opzionale con interpreti esterni (SWI-Prolog, SBCL)
- `conformance/run.jl` — runner di conformità
- `conformance/cases/*/` — 12 casi Triad-Full (program.td, expected.out, expected.code, args.txt opzionale)
- `conformance/core/cases/*/` — 29 casi Triad-Core condivisi con Full

### Benchmark AI (strumento di sviluppo)
- `ai/SYSTEM_PROMPT.md` — prompt di sistema per LLM
- `ai/verify.jl` — esegue solution.triad e confronta con i golden
- `ai/tasks/01_somma/` ... `ai/tasks/05_chiusure/` — task Triad-Core con expected.out (no expected.code, no solution.triad ancora)

### Specifiche e documentazione
- `SPEC.md` — standard normativo v0.2.0 (590 righe, §1-§16 + Appendice A)
- `SPEC-CORE.md` — profilo Triad-Core normativo
- `STATUS.md` — stato avanzamento e roadmap (round 27)
- `BOOTSTRAP.md` — piano di indipendenza da linguaggi ospiti (S0→S4)
- `CHANGELOG.md` — storia delle modifiche normative
- `TUTORIAL.md` — tutorial d'uso
- `README.md` — panoramica progetto

### Handoff agenti
- `HANDOFF-KILO.md` — lane e stato Kilo (questo agente)
- `HANDOFF-QODER.md`, `HANDOFF-QWEN.md`, `HANDOFF-HERMES.md`, `HANDOFF-CODEX.md` — lane altri agenti

### Tooling editor
- `editors/vscode/` — grammatica VS Code
- `editors/vim/` — grammatica Vim/Neovim
- `editors/linguist/languages.yml` — voce Linguist GitHub

### Esempi e seed
- `examples/*.td`, `examples/*.triad` — programmi di esempio
- `seed/windows-x86_64/seed.hex` — seed S0 PE Windows (8704 byte)
- `seed/linux-x86_64/seed.hex` — seed S0 ELF Linux E0
- `seed/dev/gen_seed.js`, `gen_seed_linux.js` — generatori del seed (sola manutenzione)

### Legacy
- `legacy/triad_sexpr_v1.jl` — vecchio kernel S-expression (storico)

### CI
- `.github/workflows/ci.yml` — conformance Full/Core su Ubuntu e Windows, casi seed Windows, hash check

### File di probe (debug, da ignorare per la produzione)
- `_probe.jl`, `_probe2.jl`, `_probe3.jl`, `_qc.jl`, `_smoke.jl` — gitignored, script usa-e-getta

## Risultato della verifica attuale (tutto verde)

```
test/runtests.jl:        243/243 PASS
conformance Full:        12/12 PASS
conformance Core:        29/29 PASS
```

Non ci sono **errori funzionali** rilevati dai test. Tuttavia esistono **elementi incompleti, mancanti o da migliorare** documentati nei file del progetto.

## Elementi già noti da ispezionare (candidati errori/mancanze)

Questi sono elencati in `HANDOFF-KILO.md` §3 (lato Julia, non assegnati):

1. `not(g)` builtin mancante (`!g` esiste) — `triad.jl` builtin
2. `let a = b = 1` — precedenza `parse_let`, `syntax.jl` righe 785-798 (già fixato per Qoder?)
3. corpo `rule` con virgola a inizio riga — `syntax.jl` righe 452-465 (già fixato?)
4. `+=` valuta il `lhs` due volte — desugaring `syntax.jl` riga 512 (già fixato?)
5. `renamevars` non scende nei `Rec` — `triad.jl` righe 363-369
6. `{ }` tokenizzati ma non parsati — `syntax.jl` riga 23
7. `'c'` caratteri non esistente — `syntax.jl` riga 204
8. Aree senza test: `--tree`, `-i`, comandi REPL `:tree`/`:reset`/`:help`

Altre mancanze da `STATUS.md`:
- `stringhe` (`string()`) — non stabile, implementazione tentata e ritirata
- `liste` — non implementate (nel seed S0)
- `valori` — parziale (simboli/nothing ok, liste e stringhe complete mancano)
- `controllo` (`elseif`) — manca `elseif` nel seed S0 (ma c'è in stage0)
- S1 (Triad in Triad-Core) — non iniziato
- S2–S3 (compilatore nativo, self-hosting) — non iniziati

Altre mancanze da `SPEC.md` §15 (informativo, non implementate nel riferimento):
- argomenti con nome (salvo `budget(steps = …)`)
- struct mutabili, tipi astratti utente, tipi parametrici
- macro senza parentesi, quote annidate a più livelli, cut

## Domande a cui JEV deve rispondere

1. Tra gli elementi elencati sopra, quali sono già risolti (test verdi lo confermano) e quali sono ancora aperti?
2. Quali errori reali (non solo mancanze) emergono leggendo il codice di `triad.jl` e `syntax.jl`? Cerca:
   - variabili non usate, codice morto
   - casi edge non gestiti nel lexer/parser
   - incongruenze tra SPEC.md e implementazione
   - errori di gestione ambienti/scope/chiusure
   - errori di unificazione (occurs-check, trail, undo)
   - errori di gestione effetti, contratti, budget, tracce
   - errori di CLI/REPL
3. Quanti errori per categoria? Fornisci una tabella.
4. Quali file vanno modificati e con quale priorità?

## Output atteso da JEV

Un rapporto strutturato in markdown con:
- Riepilogo esecutivo (totale errori, per gravità)
- Elenco errori per categoria con file:riga e descrizione
- Confronto tra ciò che SPEC.md promette e ciò che l'implementazione fa
- Elementi già risolti vs elementi ancora aperti
- Priorità di intervento e file da modificare

## Come eseguire la verifica

```powershell
# Test suite
julia --startup-file=no test/runtests.jl

# Conformità Full
julia --startup-file=no conformance/run.jl

# Conformità Core
julia --startup-file=no conformance/run.jl --cases conformance/core/cases

# Verifica AI task (nessuna solution.triad ancora: tutte SKIP)
julia --startup-file=no ai/verify.jl
```

Tutti i comandi vanno lanciati dalla root del progetto: `C:\Users\xbos\Documents\progetti\triad2.0`

---

**Nota:** questa analisi è di tipo white-box (lettura codice). Non modificare nulla a meno che non venga richiesto esplicitamente. L'obiettivo è capire cosa c'è, cosa manca e cosa è rotto, non riscrivere.