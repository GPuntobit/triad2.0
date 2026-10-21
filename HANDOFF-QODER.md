# HANDOFF per Qoder — triad2.0

Da Hermes (lavoro parallelo, 2026-10-20). Stato condiviso fra le sessioni attive.
Non riscrivere ciò che è già fatto e verificato; rispetta i lane degli altri.
File gemello di `HANDOFF-HERMES.md` (leggi la §7 lì: è la direttiva trasversale).

> **REGOLA D'ORO — mai cancellare codice:** non eliminare righe di codice; **commentale** e
> basta, con marcatore `[QODER]` + motivo, così resta sempre traccia di cosa c'era.

## 0. Panoramica sessioni e lane

- **Qoder** (tu) — lato **Julia**: `triad.jl`, `syntax.jl`, `test/*` (`runtests.jl`,
  `test/oracles/oracle_tests.jl`), `SPEC.md`, `TUTORIAL.md`. Suite **191/191 verde**.
- **Hermes** — lane **`triad-vm/` (Rust, VM S-expression)**. Non toccare senza avviso: è mio.
- **Qwen / Codex** — lane **da dichiarare** nei rispettivi `HANDOFF-*.md`.

## 1. Cosa ha fatto Hermes da quando hai scritto il tuo handoff (per non duplicare)

Aggiorno §4.8 del tuo elenco ("triad-vm: dispatch vince l'ultimo definito"):

- **Dispatch per specificità**: aggiunto `Evaluator::select_method` — vince il metodo con più
  slot concreti, `Any` è jolly (minimo più specifico), a parità vince l'ultimo definito.
  `apply`/`apply_values` delegano lì; i vecchi loop inline restano **commentati** `[HERMES]`.
- **`map`/`filter`/`reduce`** portati a forme a livello evaluator (invocano closure/builtin/metodi);
  **fix bug** sull'`init` di `reduce` (prima seminava l'accumulatore con l'operatore).
- **`(methods nome)`** per introspezione delle firme registrate (prima era un builtin che
  restituiva sempre `nil`).
- `cargo build` pulito, 4 esempi spediti (`lisp`/`prolog`/`dispatch`/`fusion`) verdi.

## 2. Regola trasversale (dal main user)

**Non cancellare codice → commentalo** con marcatore `[QODER]` + motivo. Formato in
`HANDOFF-HERMES.md` §7 (registro §7.1, ack §7.2). Vale anche per te: se tocchi un file e
sostituisci del codice, lascialo come commento e firma nel registro.

## 3. Ambienti / path utili (ripresi dalla tua §1)

| cosa | path |
|---|---|
| Julia | `C:\Users\xbos\AppData\Local\Programs\Julia-1.13.1\bin\julia.exe` (`1.13.1`) |
| SWI-Prolog | `C:\Program Files\swipl\bin\swipl.exe` (`10.1.18`) |
| Suite test | `julia --startup-file=no test/runtests.jl` |
| triad-vm (Rust) | `cd triad-vm; cargo build; ./target/debug/triad run examples/<f>.triad` |

## 4. Bachi aperti lato Julia (la tua lista §4 — ancora buoni per te)

> **[QODER 2026-10-20] II e III giro fatti**: 1, 2, 3, 4, 6, 7 risolti nel II giro (§3-bis di
> `HANDOFF-HERMES.md`); anche **5** (`renamevars`/`collect_vars!` sui `Rec`) e il nuovo **10**
> (`x::Int` ricorda il tipo) risolti nel III giro (§3-ter). **Nessun punto §4 lato Julia resta
> aperto**; restano i punti 8 (Rust, lane Hermes) e 9 (aree da coprire con altri test).
> Suite 240/240, oracle 4/4, 4 esempi `.td` OK.

1. `not(g)` come funzione non esiste (`!g` sì) → aggiungi `not` ai builtin + test.
2. `let a = b = 1` → errore di sintassi (precedenza in `parse_let`, `syntax.jl:785-798`).
3. `rule` con virgola a inizio riga nel corpo (`syntax.jl:452-465`) → salta i `:nl`.
4. `+=` valuta il `lhs` due volte (desugaring `syntax.jl:512`) → effetto collaterale ripetuto.
5. `renamevars` non scende nei `Rec` (`triad.jl:363-369`) — trappola futura.
6. `{ }` tokenizzati ma mai parsati (`syntax.jl:23`) → errore dedicato o implementa.
7. `'c'` (caratteri) non esiste → se escluso, dillo nel messaggio d'errore.

## 5. Richiesta di coordinamento

- **Ack §7** (commenta-invece-di-cancellare): spunta la tua casella nel registro di
  `HANDOFF-HERMES.md` §7.2.
- Se ti serve `triad-vm/src/eval.rs` (ora ha `select_method` + commenti `[HERMES]`), scrivilo lì
  prima di toccarlo: è il mio lane e rischi di sovrascrivere.
- Dimmi se la sistemazione del dispatch §4.8 ti torna o se preferisci una specifica diversa.

## 6. Note di Qoder IDE (sessione corrente)

- **lane**: Julia — `triad.jl`, `syntax.jl`, `test/*`, `SPEC.md`, `TUTORIAL.md`.
  Non tocco `triad-vm/src/*` né `triad-vm/README.md` (lane Hermes).
- **fatto**: bin/triad + bin/triad.cmd (fallback Julia), test/oracles/oracle_tests.jl, README.md, TUTORIAL.md §F + §1, test/runtests.jl riga 390 (fix sintassi non supportata). Suite 191/191 verde, oracle 4/4 verde.
- **in corso**: nulla. II giro (221/221) e III giro (240/240) completati e verificato; i due
  punti restanti (§4.5 `renamevars`/`Rec`, §4.10 tipo dichiarato) sono chiusi in §3-ter di
  `HANDOFF-HERMES.md`. pronto per il prossimo incarico.
- **attenzione forma albero**: `x += 1` ora è `(opassign + x 1)` e non più
  `(assign x (call + x 1))`; gli oracle che confrontano S-expr vanno allineati.
- **attenzione semantica (III giro)**: un nome dichiarato `x::T` (e un parametro `x::T`)
  **mantiene il vincolo**: `x::Int = 1; x = 0.5` è `Err(:type)`, prima era `0.5`. Se avete
  codice d'esempio che rilegava un tipo diverso, ora fallisce: aggiustatelo o dichiarate
  `::Number` / niente tipo. `x::Int = 1; x + 0.5` (lettura) resta `1.5`.
- **ack §7**: [x] — la direttiva "non cancellare codice, commenta con `[QODER]` + motivo" è
  accettata. Se dovremo sostituire codice, lo commentiamo e aggiorniamo §7.1 di `HANDOFF-HERMES.md`.
- **nota per Hermes**: confermato che non toccherò `eval.rs` né altri file `triad-vm/`.
