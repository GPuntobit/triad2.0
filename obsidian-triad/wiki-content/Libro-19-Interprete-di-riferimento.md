# Capitolo 19 — L'interprete di riferimento

`seed/dev/triad_core.cjs` è un interprete completo di Triad-Core in circa mille righe di
JavaScript, senza dipendenze. È lo strumento con cui la CI verifica la conformità su Linux, ed è
anche il modo più diretto per capire la semantica di Core leggendo codice. Questo capitolo ne
segue il percorso, dal testo all'output.

## 19.1 La pipeline

```
sorgente ──tokenize()──▶ token ──Parser──▶ albero {kind: …} ──evalStmt / evalExpr──▶ output
```

## 19.2 I valori

In cima al file ci sono i costruttori dei valori, oggetti con un campo `t` (il tipo) e un campo
`v` (il contenuto): `I` per gli interi (rappresentati come `BigInt` e riportati a 64 bit dalla
funzione `wrap`, che realizza il wrap del capitolo 6), `B`, `S`, `Y` per booleani, stringhe e
simboli, `L` per le liste, `F` per le funzioni (parametri, corpo, ambiente catturato) e la
costante `NOTHING`. I builtin sono oggetti `{t: 'builtin', name}`.

## 19.3 Il tokenizer

`tokenize(src)` scorre il testo e produce token come `SEP` (a capo o `;`), `NUM`, `STR`, `SYM`,
`IDENT`, `OP`, le parentesi, `COMMA`, `QMARK`, `COLON` e infine `EOF`. Commenti e spazi spariscono
qui. Le regole lessicali del capitolo 4 sono, letteralmente, i rami di questa funzione: per
esempio, un `:` seguito da una lettera produce un `SYM`, altrimenti un `COLON`.

## 19.4 Il parser

La classe `Parser` è una discesa ricorsiva, la stessa tecnica del capitolo 13 su scala più
grande. `parseProgram` legge istruzioni fino a `EOF`; `parseStmt` riconosce `return`, `break`,
`continue` e le definizioni di funzione; `parseExpr` scende attraverso `parseAssign`, il
ternario, `||`, `&&`, i confronti, somma, prodotto, potenza, unari e postfissi, fino a
`parsePrimary`. `parseBlock(terminatori)` legge il corpo di un blocco fino a `end`, `else` o
`elseif`. Ogni livello produce nodi con un campo `kind`: `num`, `str`, `sym`, `var`, `list`,
`lambda`, `assign`, `indexassign`, `binary`, `unary`, `ternary`, `call`, `index`, `if`, `while`,
`let`, `begin`, `funcdef`, `return`, `break`, `continue`.

## 19.5 Ambienti e scope

`makeFrame(parent, owner, isLambda)` crea un ambiente con una `Map` di legami e un puntatore al
genitore; `lookup` risale la catena. La funzione più interessante è `writeVar`, che realizza le
regole di scope del capitolo 9: cerca un legame appartenente alla stessa funzione
("proprietario") e lo aggiorna; se si trova in una lambda e il nome esiste più fuori, aggiorna
quello; altrimenti crea un legame locale. Leggere `writeVar` è il modo più rapido per capire
perché una funzione nominata non modifica i globali mentre una lambda sì.

## 19.6 La valutazione

`evalStmt` ed `evalExpr` (con gli aiutanti `evalExprBinary`, `evalExprRest`, `evalExprBlocks`)
percorrono l'albero. `return`, `break` e `continue` sono realizzati come eccezioni JavaScript
(`ReturnSignal`, `BreakSignal`, `ContinueSignal`) catturate dalla chiamata di funzione o dal
`while`. Una chiamata crea un nuovo ambiente figlio di quello **catturato** dalla funzione (non di
quello del chiamante): è qui che lo scope lessicale e le chiusure prendono forma.

I builtin sono elencati in `BUILTIN_NAMES` e implementati in `callBuiltin`; la stampa usa
`printValue`, la conversione in stringa `stringOf`. `main()` legge il file (o lo standard input
con `-`), lega `ARGS`, esegue e traduce gli errori in messaggi e codici di uscita.

## 19.7 Estenderlo

Per sperimentare un nuovo builtin bastano due modifiche: aggiungere il nome a `BUILTIN_NAMES` e
un ramo in `callBuiltin`, costruendo il risultato con gli helper (`I`, `B`, `S`, …). Per una nuova
forma sintattica: un token in `tokenize` se serve, un livello o un caso nel `Parser`, il nuovo
`kind` nella valutazione. In entrambi i casi la regola è la stessa: l'interprete deve restare
fedele a `SPEC-CORE.md`, quindi una modifica al linguaggio passa prima dallo standard e da un
caso di conformità.

## Riepilogo

- Pipeline: `tokenize` → `Parser` → `evalStmt`/`evalExpr`.
- Valori `{t, v}`; interi `BigInt` con wrap a 64 bit.
- `writeVar` realizza le regole di scope; i segnali JS realizzano `return`/`break`/`continue`.
- Le estensioni seguono lo standard, non lo precedono.
<!-- nav -->

---

← [Capitolo 18 — Anatomia del progetto e contratto di conformità](Libro-18-Anatomia-e-conformance) · [Sommario](Home) · [Capitolo 20 — Il seed in codice macchina](Libro-20-Seed) →
