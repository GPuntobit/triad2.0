---
agent: devin-local
session: mire-aardwolf
created: 2026-10-22T18:16:39Z
updated: 2026-10-26
---
# Piano per completare Triad 2.0 - Stato Aggiornato

## Stato Attuale (Giorno 4)

### Seed S0 Windows - COMPLETATO ✅
- **PE**: 25.088 byte, codice 8315 byte
- **Hash**: `9987105DCD56F42A1AD73451821A281E6F24374ED6CE83993BB8CA56F5EC4822`
- **Funzionalità**:
  - Interi, variabili, funzioni (forma breve e blocco)
  - Ricorsione, Bool, operatori (`% ^ ! && || +=`)
  - `if`/`elseif`/`else`, `while`, `let`, `begin`
  - Lambda, chiusure base
  - Stringhe base + concatenazione + `string(Int/String)`
  - Liste complete (costruzione, stampa, `push!`, `get`)
  - `nothing`, simboli
- **Conformance**: 33/33 casi Windows byte-esatti ✅, 36/36 Core Julia
- **Bug fixato**: `string()` Int conversione (r10 inizializzato correttamente)

### S1 (Interprete Triad in Triad-Core) - ORA COMPLETATO ✅
- **S1.3**: Sistema di valori taggati (Int, Bool) ✅ completato
- **S1.4**: Parser/tokenizer inline ✅ completato
- **S1.5**: Eval espressioni base ✅ completato (bug fixato: lookup ambiente)
- **S1.8**: Variabili con let ✅ completato
- **S1.11-S1.15**: Parser completo, funzioni, chiusure, test ✅ completato

### S2-S4 (Bootstrap) - NON INIZIATO
- **S2**: Compilatore nativo - bozza iniziale
- **S3**: Self-hosting - in progress
- **S4**: Runtime completo, Linux parity - pianificazione

## Task Correnti

### Immediate: Verifica finale S1
- ✅ Tutte le task ai/tasks/ completate
- ✅ Conformance suite verify
- ✅ Bug fixati e documentati

### Dopo S1
- S2: Compilatore nativo - review codegen
- S3: Self-hosting - validazione cross-platform
- S4: Runtime completo, Linux parity - benchmark

### Pulizia: output di debug e file usa-e-getta
- [ ] `seed/dev/gen_seed.js:1589`: rimuovere `console.log('labels', JSON.stringify(labels))`, che stampa il dump di tutte le etichette dell'emitter a ogni rigenerazione del seed (solo debug).
- [ ] `seed/dev/gen_seed.js:1590`: rimuovere `console.log('code bytes:', code.length)` (dato intermedio; la dimensione finale è già stampata alla riga 1640).
- [ ] `seed/dev/gen_seed_linux.js:113-114`: ridurre l'output a `sha256(ELF)` e al file scritto; `ELF bytes` ed `entry RVA` sono dettagli di debug.
- [ ] Da mantenere (output legittimi della CLI): `console.log`/`console.error` in `ai/jev_audit.mjs` (report, `--dry-run`, messaggi d'uso) e in `.webcmd/graphify/tools/generate.mjs`.
- [ ] `_probe.jl`, `_probe2.jl`, `_probe3.jl`, `_qc.jl`, `_smoke.jl`: `PROMPT_JEV.md` li descrive come "gitignored, script usa-e-getta", ma sono versionati. Rimuoverli dal repository e aggiungerli a `.gitignore`.
- [ ] File di output alla radice versionati (`out.txt`, `output.txt`, `outfile.txt`, `stdout.txt`, `runoutput.txt`, `test_output.txt`, `error.txt`, `scope_out.txt`, `let_output.txt`, `let_test_out.txt`, `let_annidato_out.txt`): rimuoverli e ignorarli.
- [ ] `run_seed.bat` … `run_seed12.bat` (12 varianti): tenerne uno parametrizzato.

## File S1 Implementati
- `selfhost/value.td`: Sistema di valori taggati ✅
- `selfhost/tokenizer.td`: Parser/tokenizer inline ✅
- `selfhost/eval.td`: Eval espressioni base ✅
- `selfhost/main.td`: Ambiente inline funzionante ✅

## Limitazioni Seed Attuali
- `string()`: solo Int/String (Bool/Symbol/Nothing non implementati ma non richiesti per conformance)
- Liste: solo interi, max 64 elementi
- Indicizzazione standard, `length`, iterazione: non implementati (S2)
- Conformance: 33/33 completata ✅

## Stato Conformance
- Stage0 Julia: 33/33 Core, 12/12 Full ✅
- Seed Windows: 33/33 Core ✅
- Seed Linux: E0 minima (non comparabile) - in avvio test cross‑platform per parity

## Task ai/tasks/ Completati ✅
- **01_somma**: programma Triad somma e precedenza ✅
- **02_fattoriale**: funzione ricorsiva fattoriale(n) ✅
- **03_fibonacci**: funzione ricorsiva fib(n) ✅
- **04_stringhe**: assegnamento e concatenazione stringhe ✅
- **05_chiusure**: chiusure e applicazione ✅
