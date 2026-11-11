> Copia di [`SPEC-CORE.md`](https://github.com/GPuntobit/triad2.0/blob/main/SPEC-CORE.md) — torna a [Documenti](Documenti) · [Home](Home)

# Triad-Core — sottoinsieme di bootstrap (standard 0.2.0)

**Stato:** normativo, parte dello standard Triad 0.2.0 (profilo §16.1 di `SPEC.md`).
Definisce il sottoinsieme di Triad che il seed in codice macchina (S0) deve saper eseguire e
in cui è scritta l'implementazione completa self-hosted (S1). Ogni programma Triad-Core,
**esclusi i primitivi di bootstrap** del §8, è anche un programma Triad valido e deve
comportarsi allo stesso modo in un'implementazione Triad-Full.

## 1. Scopo e criteri

Triad-Core è scelto per due proprietà:

1. **implementabile in codice macchina scritto a mano** (il seed S0): poche forme, pochi tipi,
   nessuna macro, nessuna risoluzione logica, nessun dispatch;
2. **sufficientemente espressivo** per scrivere in Triad-Core l'interprete di tutto Triad
   (S1): valori dinamici, liste, stringhe, chiusure e ricorsione, più i primitivi di I/O e di
   accesso ai caratteri necessari a leggere/analizzare il sorgente Triad.

Regola: tutto ciò che in Triad-Full è zucchero sintattico o comodità (Prolog, macro, `quote`,
struct, dispatch, contratti, budget, tracce, effetti, destrutturazione, `for`, `try`) **non**
fa parte di Core: S1 lo implementa in Core e lo espone ai programmi Full.

## 2. Lessico

Incluso:

| elemento | forma |
|---|---|
| identificatore | lettera o `_`, poi lettere/cifre/`_`; `!` finale ammesso |
| intero | `42`, `1_000` (segno gestito dall'operatore unario) |
| booleano | `true`, `false` |
| nothing | `nothing` |
| stringa | `"..."` con escape `\n \t \" \\`; **nessuna** interpolazione `$` |
| simbolo | `:` + nome o operatore (`:alice`, `:+`) |
| commento | `#` fino a fine riga; `#= ... =#` |
| separatore | a capo o `;` |
| operatori | `+ - * % ^ == != < <= > >= && \|\| ! = += -= *= -> ?:` |

Esclusi: i letterali `Float`, le variabili logiche `?x`, i caratteri (Triad non ne ha), le
macro `@nome`, lo shebang viene comunque ignorato dal seed.

## 3. Tipi e valori

| tipo | valori |
|---|---|
| `Int` | interi con segno a 64 bit, aritmetica con wrap (complemento a due) |
| `Bool` | `true`, `false` |
| `String` | sequenza di byte UTF-8 immutabile |
| `Symbol` | `:nome`; due simboli sono uguali se hanno lo stesso nome |
| `List` | lista eterogenea mutabile, indici da 1 |
| `Function` | funzione nominata, lambda o chiusura |
| `Nothing` | `nothing` |

Non ci sono `Float`, struct utente, `Term`, `Solution`, `Err` come valori del linguaggio:
S1 rappresenta questi concetti con i tipi Core (es. una struct come lista taggata, un errore
come lista `[Err, kind, msg]`). `readfile`/`strbyte`/`strsub` (§8) sono primitivi di bootstrap,
non tipi.

## 4. Sintassi

```ebnf
program  = { sep } { stmt sep { sep } } ;
stmt     = funcdef | "return" [ expr ] | "break" | "continue" | expr ;
funcdef  = "function" NAME "(" [ NAME { "," NAME } ] ")" block "end"
         | NAME "(" [ NAME { "," NAME } ] ")" "=" expr ;
expr     = assegnamento ;
assegnamento = NAME ( "=" | "+=" | "-=" | "*=" ) expr | ternario ;
ternario = or_expr [ "?" expr ":" expr ] ;
or_expr  = and_expr { "||" and_expr } ;
and_expr = cmp_expr { "&&" cmp_expr } ;
cmp_expr = sum_expr { ( "==" | "!=" | "<" | "<=" | ">" | ">=" ) sum_expr } ;
sum_expr = mul_expr { ( "+" | "-" ) mul_expr } ;
mul_expr = pow_expr { ( "*" | "%" ) pow_expr } ;
pow_expr = unary { "^" unary } ;                    (* destra *)
unary    = ( "-" | "!" ) unary | postfix ;
postfix  = primary { "(" args ")" | "[" expr "]" } ;
primary  = INT | STRING | SYMBOL | "true" | "false" | "nothing" | NAME
         | "(" expr ")"
         | "[" [ expr { "," expr } ] "]"
         | "(" NAME { "," NAME } ")" "->" expr
         | "if" expr block { "elseif" expr block } [ "else" block ] "end"
         | "while" expr block "end"
         | "let" [ NAME "=" expr { "," NAME "=" expr } ] block "end"
         | "begin" block "end"
         | "function" "(" [ NAME { "," NAME } ] ")" block "end" ;
block    = { stmt sep { sep } } ;                   (* fino a end/else/elseif *)
```

`elseif` è incluso; `for`, `elif`, destrutturazione, `try`, `with`, `solve`, `quote`,
`struct`, `macro` non lo sono.

## 5. Semantica

- Tutto è un'espressione; un blocco vale il valore dell'ultima istruzione (`nothing` se vuota).
- **Scope lessicale:** `function`, lambda, `let` e `while` introducono ambienti; un nome è
  visibile nell'ambiente in cui è legato e in quelli interni. Dentro una funzione
  l'assegnamento lega nel frame locale (o in una chiusura interna); al top level i cicli
  aggiornano i globali.
- **Chiusure:** una lambda cattura l'ambiente in cui è creata; le variabili catturate sono
  condivise (mutazioni visibili).
- **Ricorsione:** le funzioni nominate sono visibili nel proprio corpo (ricorsione diretta).
- **Condizioni:** solo `Bool`; niente truthiness. `&&`/`||` cortocircuitano.
- **Uguaglianza:** numeri, stringhe e simboli per valore; liste elemento per elemento;
  funzioni per identità.
- **Indici:** da 1; fuori range è un errore di esecuzione (§9).
- **Aritmetica:** `+ - * % ^` su `Int` con wrap a 64 bit; `%` è resto con segno del dividendo
  (come `rem` in Julia). `/` non esiste in Core (S1 implementa la divisione razionale di
  Triad-Full).
- **Valori di ritorno:** `return e` termina la funzione; senza espressione restituisce
  `nothing`.
- **`break`/`continue`** agiscono sul `while` più interno.
- **Formattazione di `println`/`print`:** concatenano gli argomenti senza separatori;
  `Int` decimale, `Bool` `true`/`false`, `String` così com'è, `Symbol` senza `:` a livello
  top-level, `List` come `[a, b]` con i simboli come `:a`, `Nothing` come `nothing`.

## 6. Espressioni e istruzioni incluse

- assegnamento semplice e `+= -= *=` (il lato sinistro è valutato una volta sola);
- `if`/`elseif`/`else`, `while`, `let`, `begin`, ternario;
- `function` nominata, forma breve `f(x) = e`, lambda `x -> e`, `function (x) … end`;
- chiamata, indicizzazione di lista, `return`, `break`, `continue`;
- commenti e separatori.

## 7. Primitive del linguaggio (visibili anche a Triad-Full)

| categoria | primitive |
|---|---|
| aritmetica | `+ - * % ^`, unario `-` |
| confronto | `== != < <= > >=` |
| logica | `&& \|\| !` |
| liste | `length`, `push!`, indicizzazione `xs[i]`, `[a, b]` |
| stringhe | `*` (concatenazione), `length` |
| conversioni | `Int("42")`, `string(x)`, `Symbol("nome")` |
| I/O | `print`, `println` |
| introspezione | `typeof` (nome del tipo come `Symbol`) |

Anche `ARGS` è disponibile come lista di stringhe (gli argomenti dello script). Non ci sono
`map`, `filter`, `reduce`, `sum`, `sort`, `div`, `mod`: S1 li implementa in Core.

## 8. Primitivi di bootstrap (solo per l'implementazione self-hosted)

Questi servono a S1 per leggere e analizzare il sorgente Triad; **non** fanno parte del
linguaggio Triad-Full e non compaiono in `SPEC.md` §13:

| primitiva | semantica |
|---|---|
| `readfile(path)` | restituisce il contenuto del file come `String`; errore di esecuzione se non leggibile |
| `strlen(s)` | numero di byte della stringa |
| `strbyte(s, i)` | byte (`Int`, 0–255) alla posizione 1-based |
| `strsub(s, a, b)` | sottostringa dai byte `a` a `b` inclusi (1-based) |
| `exit(n)` | termina il processo con codice `n` |

Il seed deve comunque fornire `readfile` per caricare S1 stesso; `strlen`/`strbyte`/`strsub`
sono richiesti solo quando S1 deve analizzare sorgente.

## 9. Errori

Core non ha `try`/`catch` né valori `Err`: un errore di esecuzione (variabile non definita,
tipo sbagliato, indice fuori range, divisione per zero, file non leggibile) **termina il
processo con exit code 1** e un messaggio diagnostico su stderr. S1, scritta in Core, usa
valori espliciti (liste `[Err, kind, msg]`) per propagare gli errori dei programmi Full senza
affidarsi a eccezioni del seed.

## 10. Interfaccia a riga di comando

Triad-Core usa la stessa interfaccia dello §14 di `SPEC.md`, limitatamente a:

```
triad FILE [ARG...]     # esegue FILE come script, ARGS = [ARG...]
triad -                 # legge lo script da stdin
```

Exit: `0` successo, `1` errore, `2` uso non valido. Il REPL non fa parte di Core: lo fornisce
S1 per Triad-Full.

## 11. Conformità

- I casi in `conformance/core/cases/` usano **solo** il sottoinsieme dei §2–§7 (quindi girano
  sia su Triad-Core sia su Triad-Full) e sono normative per entrambi i profili.
- I primitivi del §8 sono verificati dai test del seed (non possono girare su Triad-Full).
- Un'implementazione Core è conforme se passa `conformance/core/` e produce l'output atteso
  byte per byte con gli stessi exit code.

## 12. Note per l'implementazione in codice macchina (informative)

- Rappresentazione consigliata: word taggata a 64 bit; `Int` immediato, gli altri valori
  puntatori a oggetti con header (tipo, dimensione).
- Ambienti: catena di frame con associazione nome→valore; oppure liste di associazioni.
- Liste: vettore dinamico con capacità; stringhe: (puntatore, lunghezza) immutabili.
- Allocatore: arena a bump; niente GC nella prima versione (i programmi di bootstrap sono
  brevi), poi mark-sweep.
- Funzioni: oggetto con puntatore all'AST e ambiente catturato; valutazione ricorsiva con
  stack esplicito per non dipendere dallo stack di sistema.
- Il seed S0 deve implementare il **lexer** e il **parser** di Core, non quelli di Full: è S1
  a implementare il parser completo.
