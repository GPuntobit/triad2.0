# 12 — Guardie statiche per la sorgente di S1

Type: grilling
Status: resolved

## Question

La decisione [01 — Fork architetturale del seed](01-fork-architetturale-seed.md) (Q5) ha
fissato il **meccanismo** di protezione: nessuna chirurgia nel seed per le costruzioni
*rumorose* (exit 1), **guardie statiche** sulla sorgente di S1, e **riferimento JS**
(`seed/dev/triad_core.cjs`) come autorità semantica di sviluppo. Qui si decide *quali*
regole, *dove* stanno e *come* falliscono.

Le **divergenze silenziose** (risultato sbagliato senza errore) misurate nel seed sono:

| # | Divergenza | Regola candidata sulla sorgente di S1 |
|---|---|---|
| D1 | scope **dinamico** (il callee vede i locali del chiamante) | nessun nome locale può essere *libero* in una funzione se è *locale* in un'altra (analisi di collisioni) |
| D2 | cattura delle chiusure **per valore** | nessuna variabile catturata viene riassegnata |
| D3 | escape nelle stringhe non interpretati | nessun escape (`\n`, `\t`, `\"`, `\\`) nei letterali |
| D4 | `==`/`!=` su stringhe sempre `false` | `==`/`!=` solo su `Int`/`Bool`/`Symbol`/`nothing` |
| D19 | newline dopo un operatore **prosegue** l'espressione | nessun statement iniziato dopo un operatore binario |
| D20 | il corpo di `while` non ha ambiente proprio | nessuna variabile **assegnata** nel corpo di `while` (solo lettura) |
| D21 | condizione `while` non-`Bool` **salta** il corpo | la condizione di `while` è un `Bool` (forma nota) |

Da decidere:

1. **Quale regola presidia quale divergenza** e con quale **precisione**: una regola
   *conservativa* (blocca più del necessario, es. ogni `==` su un operando non dimostrabilmente
   numerico) è accettabile, o serve **precisione** (analisi dei tipi)? Il costo statico
   cresce con la precisione.
2. **Dove stanno le guardie**: il lint esistente `tools/site-gen/lint.mjs` (che oggi «blocca
   le costrutti che il seed non può eseguire»), il runner JS (che ha già un parser
   Triad), o un **controllore dedicato** alla sorgente S1 (`selfhost/*.td` + i generatori in
   `tools/site-gen/`)? Un controllore dedicato ha un contratto proprio (exit code, elenco
   delle violazioni) e un posto nella CI.
3. **Il fallback**: la regola «*silenziosa + non presidabile ⇒ chirurgia nel seed*» (Q5)
   richiede un **criterio** per dichiarare una regola «non presidabile». Quale? (es.
   l'esempio sintetico della regola esiste ed è applicato a tutta la sorgente S1?)
4. **Il ruolo del riferimento JS nella CI**: oggi il job `conformance-core` esegue
   `node seed/dev/triad_core.cjs` su ogni `selfhost/*.td` (validità, non confronto). Va
   aggiunto un **confronto seed↔JS** (stesso programma, stesso stdout) come gate delle
   divergenze non presidate? E con quale granularità (S1 intero, per file, per programma di
   prova)?

Nessuna di queste scelte è un problema di meccanica del seed: sono tutte **decisioni** sul
come si presidia il sottoinsieme certificato del seed (Q6 della decisione 01).

## Riferimenti

- Decisione: [01 — Fork architetturale del seed](01-fork-architetturale-seed.md) (Q5, Q6).
- Sorgente da presidare: `selfhost/*.td` (S1), `tools/site-gen/*.td` (generatori), `examples/`.
- Lint esistente: `tools/site-gen/lint.mjs`; riferimento JS: `seed/dev/triad_core.cjs`.
- Contratto del seed: `seed/README.md` + elenco macchina-leggibile `seed/dev/certified-subset.txt`.

## Answer — 2026-11-08 (grilling, misure + implementazione)

**Sintesi.** Le guardie stanno in un **controllore dedicato** (`tools/selfhost-guard/`), che
**non duplica** il parser: riusa l'AST del riferimento JS (`seed/dev/triad_core.cjs`), che è
l'autorità semantica di sviluppo. Le regole sono **una per divergenza**, attive solo se la
divergenza è ancora presente nel **contratto del seed** (`seed/dev/certified-subset.txt`):
quando il seed viene corretto, la divergenza sparisce dal contratto e la regola si spegne
da sola. Il **gate differenziale** (seed↔JS, stesso stdout byte per byte e stesso exit code)
è il secondo presidio, per le divergenze che una regola statica **non può decidere**; se il
differenziale trova una differenza, la risposta è **una sola: chirurgia nel seed**.

### Q1 — Quale regola presidia quale divergenza, e con quale precisione

**Criterio di precisione (la domanda vera):** una regola statica decide solo ciò che si
vede **nell'AST**. Non può decidere ciò che dipende dai **tipi a runtime**. Quindi:

- **decidibile dall'AST** → regola statica, *error* (il costrutto è vietato nella sorgente
  di S1);
- **non decidibile** (dipende dai tipi) → **nessuna** regola statica aggressiva: il presidio
  è il gate differenziale.una regola «conservativa» che blocca più del necessario non è
  accettabile quando non è *fondata*: sarebbe una regola che vieta codice corretto senza
  eliminare il rischio (l'esempio: vietare ogni `==` su un operando non dimostrabilmente
  numerico bloccherebbe `get(e, 0) == n`, che è il cuore del front-end).

La tabella completa (misurata, non dedotta — vedi «Misure» sotto):

| # | classe | regola | id | decisione |
|---|---|---|---|---|
| D1 | silenziosa | un **globale** letto in una funzione non deve essere **locale** in un'altra funzione (con l'eccezione del frame più esterno: il livello di file non è ombreggiabile) | `G-D01` | statica |
| D2 | silenziosa | un nome **catturato** da una chiusura (letto dentro, legato fuori) non deve essere riassegnato fuori | `G-D02` | statica |
| D3 | silenziosa | nessun backslash in un letterale | `G-D03` | statica |
| D4 | silenziosa | `==`/`!=` con un operando **dimostrabilmente** stringa (letterale o concatenazione con letterale) | `G-D04` | statica (parziale: il resto è differenziale) |
| D5 | rumorosa | `continue` vietato | `G-D05` | statica |
| D6 | rumorosa | `-=`/`*=` vietati | `G-D06` | statica |
| D7 | rumorosa | `while` solo in posizione di statement | `G-D07` | statica |
| D8 | rumorosa | `if` solo in posizione di statement | `G-D08` | statica |
| D9 | rumorosa | l'ultima espressione di un corpo di funzione (o del programma) non può essere una chiamata — **eccetto `println`** | `G-D09` | statica |
| D10 | rumorosa | `return` vietato | `G-D10` | statica |
| D11 | rumorosa | blocco-lambda `function (x) … end` vietato | `G-D11` | statica |
| D12 | rumorosa | `let` con un solo binding | `G-D12` | statica |
| D13 | rumorosa | `xs[i]` vietato (usare `get(xs, i)`, 0-based) | `G-D13` | statica |
| D14 | rumorosa | `typeof`, `Int()`, `Symbol()` vietati | `G-D14` | statica |
| D15 | silenziosa | `string(x)` per `Bool`/`Symbol`/`Nothing`: il seed stampa `1` invece di `true` | — | **non decidibile** ⇒ differenziale |
| D16 | rumorosa | i primitivi §8 la cui disponibilità è dichiarata **assente** dal contratto sono vietati | `G-D16` | statica (contrattuale) |
| D17 | rumorosa | i simboli operatore (`:+`) vietati | `G-D17` | statica |
| D18 | rumorosa | la chiamata **a livello di file** che precede la definizione è vietata (le dichiarazioni di file sono eseguite in ordine) | `G-D18` | statica |
| D19 | silenziosa | nessuna riga che finisca con un operatore binario (il seed continua l'espressione; `SPEC-CORE.md` §2 fa del newline un separatore) | `G-D19` | statica |
| D20 | silenziosa | un nome **creato** in un corpo di `if`/`while` non deve essere letto fuori (nel seed il corpo non ha ambiente proprio) | `G-D20` | statica |
| D21 | silenziosa | la condizione di `while` deve essere **dimostrabilmente** Bool (confronto, letterale booleano, combinazione) | `G-D21` | statica |
| D22 | rumorosa | identificatore che **inizia** con una keyword (`if`/`let`/`while`/`function`) o keyword dentro un **corpo di blocco** | `G-D22` | statica |

Regole d'**envelope** (non sono divergenze: sono i limiti dell'arena, `seed/dev/certified-subset.txt`):
`G-E01` sorgente ≤ buffer sorgente, `G-E02` ≤ 4 parametri per funzione, `G-E03` ≤ 64
elementi per letterale di lista.

**Correzioni alla tabella iniziale del ticket** (misurate, non dedotte):

- **D9**: `println` **è** ammesso in posizione finale (il seed lo tratta come uno statement);
  ogni altro builtin e ogni funzione utente no. La regola iniziale («chiamata in posizione
  finale») era troppo larga e avrebbe bloccato i generatori del sito.
- **D18**: il seed **risolve** i riferimenti in avanti *fra funzioni* (`a` chiama `b`
  definita dopo: exit 0, misurato); quello che rifiuta è la chiamata **a livello di file**
  che precede la definizione (exit 1, misurato — è il probe `bad_riferimento_avanti.td`).
- **D20**: il problema non è il `while` ma i **corpi di blocco in generale**: il seed non
  crea un ambiente per `if` e `while` (misurato: `let` e `begin` lo fanno, `if`/`while` no),
  quindi un nome creato dentro resta visibile fuori. La regola iniziale (solo `while`) era
  troppo stretta; la nuova (if/while) è misurata.
- **D22**: le keyword cieche contano **solo dentro un corpo di blocco** (a livello di programma
  il seed non le conta: misurato, i generatori del sito hanno letterali con `if`/`let`/
  `while`/`function` e girano sul seed). E il caso peggiore è un identificatore che
  **inizia** con una keyword: viene scambiato per il costrutto (misurato: `ifx = 1` →
  exit 1).

### Q2 — Dove stanno le guardie

**Un controllore dedicato**: `tools/selfhost-guard/` (CLI `guard.mjs`), con un contratto
proprio (exit 1 se ci sono errori, elenco `ERR/WARN file:line [G-Dxx] messaggio`), un posto
nella CI (job `conformance-core`) e un self-test (`test.mjs`, un fixture per regola).

Motivi della scelta, misurati:

- **non il lint di `tools/site-gen/`**: quel lint presidia un altro contratto (il
  *sottoinsieme portabile per il browser*: niente primitivi bootstrap, niente escape,
  niente `if` nei letterali). Le regole nuove (scope, catture, corpo dei blocchi, envelope
  del seed) sono *del seed*, non del browser. Il lint esistente resta dov'è e continua a
  fare il suo lavoro;
- **non un parser nuovo**: il guard riusa l'AST del riferimento JS (`seed/dev/triad_core.cjs`
  espone `tokenize` e `Parser`). Un secondo parser sarebbe un secondo linguaggio da
  mantenere — e la regola operativa 1 (la specifica è normativa) vuole che l'unico
  modello del linguaggio sia quello della specifica;
- **un solo contratto, due pezzi**: `seed/dev/certified-subset.txt` (i *fatti* del seed:
  envelope, primitivi §8 disponibili, divergenze presenti) e `seed/dev/certified-corpus.txt`
  (i *programmi* che il seed deve eseguire). Il guard e il differenziale li consumano
  entrambi.

**Corpus certificato e file fuori contratto.** Il corpus certificato oggi è
`selfhost/source.td`, `selfhost/main.td` e i quattro generatori attivi di `tools/site-gen/`
(che `build.mjs` esegue già sul seed confrontando l'output dei due runtime). Gli altri
`.td` (prototipi storici in `selfhost/`, la prima versione del generatore) sono **fuori
contratto**: restano validi (la CI li esegue sul riferimento JS) ma le loro violazioni sono
**avvisi**, non errori — e non sono silenziate: il guard li elenca tutti. Aggiungere un file
al manifesto è un atto deliberato.

### Q3 — Il fallback: il criterio di «non presidabile»

**Criterio** (operazionale, non retorico): una divergenza è *presidiata* se e solo se

1. la sua violazione è **decidibile dall'AST** (nessun tipo a runtime), **e**
2. esiste una **regola** che la presidia, **e**
3. la regola ha un **fixture sintetico** che la fa scattare (`tools/selfhost-guard/fixtures/`),
   applicato a **tutto** il corpus certificato (il self-test verifica anche che *ogni*
   divergenza del contratto sia presidiata: una divergenza senza regola è un buco).

Se (1) fallisce — la violazione dipende dai tipi a runtime — la divergenza **non è
presidiabile staticamente** (unica oggi: **D15**, `string(x)`): il presidio è il **gate
differenziale**, e se il differenziale rileva una differenza la risposta è **chirurgia nel
seed** (è il gate di esecuzione: se il seed mente, mente tutto). Non esiste una terza via:
«scrivere la regola più aggressiva» non elimina il rischio, vieta solo codice corretto.

### Q4 — Il ruolo del riferimento JS nella CI

**Il riferimento JS diventa l'oracle differenziale**: nel job `conformance-core` (che ha
Node) un nuovo passo esegue ogni programma del corpus certificato **sia sul seed ELF sia
sul riferimento JS** e confronta **stdout byte per byte** e **exit code**
(`tools/selfhost-guard/differential.mjs`). Granularità: **per programma** (l'unità del
corpo certificato è il file).

Il differenziale non è un doppione delle guardie statiche: copre ciò che le regole non
possono vedere (D15 e le altre violazioni dipendenti dai tipi) ed è il **controllo
empirico** delle reglie stesse (se una regola lascia passare un programma divergente, il
differenziale lo vede). Il modello non è nuovo: `tools/site-gen/build.mjs` confronta già
l'output dei due runtime per i generatori.

La CI ha così tre presidî sul corpus certificato, in ordine di costo: guardie statiche
(veloce, diagnostica), differenziale (lento, empirico), e — se il differenziale finding —
**chirurgia nel seed** (che chiama il ciclo di rebuild PE/ELF + hash CI, ADR 0001).

### Misure (2026-11-08, seed ELF nativo vs riferimento JS)

| divergenza | seed | JS | differenziale la vede? | regola |
|---|---|---|---|---|
| D1 scope dinamico | `7` | `100` | sì | `G-D01` |
| D2 cattura per valore | `1` | `2` | sì | `G-D02` |
| D3 escape | `a\nb` (2 caratteri) | `a`⏎`b` | sì | `G-D03` |
| D4 `==` fra stringhe | `false` | `true` | sì | `G-D04` |
| D15 `string(true)` | `1` | `true` | sì | — (differenziale) |
| D19 newline dopo operatore | `3` | errore di parse | sì | `G-D19` |
| D20 nome creato in `if`/`while` | `5` | errore «undefined variable» | sì | `G-D20` |
| D20 nome **già legato** nel frame | identico | identico | **no** | (pending normativo N08) |
| D21 condizione `while` non-Bool | salta il corpo | errore | sì | `G-D21` |
| D9 chiamata in posizione finale | exit 1 | exit 0 | sì | `G-D09` |
| D18 riferimento in avanti fra funzioni | exit 0 | exit 0 | **no** (non è divergenza) | `G-D18` (solo file level) |

**Correzione importante**: D20 ha **due** casi. Quello del nome *nuovo* (creato nel corpo)
è una divergenza vera fra i due runtime (il differenziale la vede). Quello del nome *già
legato* in un frame esterno è **identico** nei due runtime: la divergenza è solo rispetto
alla lettera di `SPEC-CORE.md` §5 («`while` introduce un ambiente»), e la lettura stretta
di quella frase renderebbe **impossibile scrivere un ciclo** (il contatore di un loop
dovrebbe sopravvivere al body). È quindi una **decisione normativa pending** (la famiglia
N08: lessicale vs dinamico), non una guardia: il guard copre il caso decidibile e il resto
resta dichiarato.

### Esecuzione

- `seed/dev/certified-subset.txt` — il contratto del seed (fatti, macchina-leggibile).
- `seed/dev/certified-corpus.txt` — il corpus certificato.
- `tools/selfhost-guard/` — il controllore: `guard.mjs` (CLI), `rules.mjs` (le regole),
  `analysis.mjs` (ambienti), `scan.mjs` (scanner grezzo), `contract.mjs`, `differential.mjs`
  (gate seed↔JS), `test.mjs` (self-test), `fixtures/` (un fixture per regola).
- `seed/README.md` — la sezione «Contratto del seed» (la versione leggibile del contratto).
- CI (`.github/workflows/ci.yml`, job `conformance-core`): tre passi nuovi — guardie
  statiche, self-test, gate differenziale.
- `tools/selfhost-guard/README.md` — il contratto del controllore.

Il guard e il differenziale sono **strumenti di sviluppo** (Node): restano fuori dalla catena
S0→S4 (regola operativa 2), come il riferimento JS. `verify.sh` resta senza Node.

### Limiti noti

- Le regole statiche sono **sintattiche**: non provano i tipi. Una divergenza che si
  manifesta solo con valori concreti (D15) è delegata al differenziale.
- Il guard non presidia `examples/` (non sono nel corpus certificato): i programmi di
  esempio girano sul *riferimento JS* e sul seed solo se sono nel manifesto.
- Il self-test copre una regola per divergenza con un fixture sintetico: non è una
  copertura di prova del valore semantico delle regole (è un presidio di *presenza*).

## Riferimenti

- Decisione: [01 — Fork architetturale del seed](01-fork-architetturale-seed.md) (Q5, Q6).
- Contratto e presidî: `seed/dev/certified-subset.txt`, `seed/dev/certified-corpus.txt`,
  `seed/README.md`, `tools/selfhost-guard/`.
- Limiti misurati del seed: `tests/probes/README.md` (matrice dei probe).
- Successore: [02 — Architettura di S1](02-architettura-s1.md).
