# Standard Triad — specifica del linguaggio (versione 0.2.0, bozza)

**Stato del documento:** bozza normativa. Definisce il linguaggio Triad — lessico,
grammatica, tipi, semantica, modello di esecuzione, errori, contratti, effetti, logica,
introspezione e interfaccia a riga di comando — **indipendentemente da qualsiasi
implementazione**.

**Normatività:** le sezioni §1–§14 e §16 sono normative. Il §15 e l'Appendice A sono
informativi. Un'implementazione è **conforme** se soddisfa i requisiti del §16 e passa la
suite di conformità in `conformance/`.

**Triad in breve.** Triad è un linguaggio a sé, con sintassi a blocchi e tipi dichiarati,
multiple dispatch, programmazione logica integrata (`fact`, `rule`, `solve`), codice come
dato (albero uniforme, quote, macro) e, come parte del linguaggio e non di una libreria:
errori come dati, contratti, budget, tracce ed effetti dichiarati.

**Estensione dei file:** `.triad` è l'estensione canonica; `.td` è accettata come alias
storico. L'estensione si può omettere sulla riga di comando.

```triad
struct Point
    x::Float
    y::Float
end

function dist(a::Point, b::Point)::Float
    requires a.x != b.x || a.y != b.y
    sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

fact parent(:alice, :bob)
fact parent(:bob, :dave)

rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

macro unless(c, body)
    :(if !$c; $body; end)
end

result = solve grandparent(:alice, ?who) limit 5     # [{who = :dave}]
```

`solve` restituisce un valore normale, cioè una lista di soluzioni. Si può passare a una
funzione, filtrare, indicizzare (`result[1].who`) o usare per il dispatch, senza stampare
niente.

**Implementazione di riferimento (transitoria, informativa):** `triad.jl` e `syntax.jl`,
oggi scritti in Julia per il bootstrap; non fanno parte della definizione del linguaggio e
verranno sostituiti dall'implementazione self-hosted (vedi `BOOTSTRAP.md`). La specifica
eseguibile è `conformance/`.

---

## 1. Lessico

| elemento | forma | esempi |
|---|---|---|
| identificatore | lettera o `_`, poi lettere, cifre, `_`; `!` finale ammesso se non seguito da `=` | `x`, `push!`, `età` |
| variabile logica | `?` **attaccato** a un nome | `?x`, `?who` |
| variabile anonima | `?_`: ogni occorrenza è una variabile nuova | `parent(?x, ?_)` |
| simbolo | `:` seguito da un nome o da un operatore, se non è attaccato a un valore precedente (`:-` resta il `:-` delle regole) | `:alice`, `:+`, `:<=` |
| numeri | `Int` (`42`, `1_000`) e `Float` (`3.14`, `1e-9`) | |
| stringhe | `"..."` con escape `\n \t \" \\ \$` e interpolazione `$x`, `$(espr)` | `"x = $x"` |
| commenti | `#` fino a fine riga; `#= ... =#` su più righe | |
| separatori | a capo oppure `;` | |
| macro | `@nome(...)` | `@unless(c, e)` |

**Parole chiave:** `function struct macro end if elseif else for in while let begin return
break continue fact rule solve quote try catch with requires ensures true false nothing isa is`.
Sono contestuali (dopo `solve`) `limit depth steps trace`.

**Regole sui due punti** (il problema classico di `:`):
- `1:n` e `xs[2:end]`: un `:` attaccato a un valore e senza spazi è un range;
- `f(:a)`, `x = :a`: un `:` non preceduto da un valore e seguito da un nome è un simbolo;
- `:( ... )`: è codice quotato;
- `c ? a : b`: un `:` circondato da spazi è il separatore del ternario.

Anche `?` ha due usi: `?x` (attaccato) è una variabile logica, mentre `? ` con uno spazio dopo
è il ternario.

Gli **a capo** chiudono un'istruzione, tranne dentro `( )`, `[ ]` e `:( )`, e tranne
subito dopo un operatore binario o una virgola di `rule`.

## 2. Sintassi (EBNF)

```ebnf
program    = { sep } { stmt sep { sep } } ;
sep        = NEWLINE | ";" ;
block      = { sep } { stmt sep { sep } } ;          (* fino alla parola chiave di chiusura *)

stmt       = funcdef | structdef | macrodef | fact | rule
           | "requires" expr | "ensures" expr
           | "return" [ expr ] | "break" | "continue"
           | "(" NAME { "," NAME } ")" "=" expr        (* destrutturazione *)
           | expr ;                                   (* include l'assegnamento *)

funcdef    = "function" fname "(" [ params ] ")" [ "::" TYPE ] [ "!" EFFECT { "," EFFECT } ]
             block "end"
           | NAME "(" [ params ] ")" "=" expr ;       (* forma breve: sq(x) = x * x *)
fname      = NAME | "+" | "-" | "*" | "/" | "%" | "^" | "==" | "<" | "<=" | ">" | ">=" ;
params     = param { "," param } ;
param      = NAME [ "::" TYPE ] | "(" NAME { "," NAME } ")" ;
structdef  = "struct" NAME sep { NAME [ "::" TYPE ] sep } "end" ;
macrodef   = "macro" NAME "(" [ NAME { "," NAME } ] ")" block "end" ;

fact       = "fact" term ;
rule       = "rule" term [ ":-" goal { "," goal } ] ;
             (* la virgola può stare anche a inizio riga, quando il corpo va a capo *)

expr       = (* Pratt: precedenze dalla più bassa alla più alta *)
  1  a = b   a += b   a -= b   a *= b                 (destra)
  2  x -> e   (a, b) -> e   c ? a : b                 (destra)
  3  ||
  4  &&
  5  ==  !=  <  <=  >  >=  in  isa  is
  6  a:b                                               (range, senza spazi)
  7  +  -
  8  *  /  %
  9  -x  !x  +x  $x                                    (unari)
 10  ^                                                 (destra)
 11  e::T                                              (asserzione di tipo)
 12  f(args)  xs[i]  a.campo                           (postfissi, senza spazio prima di ( e [)

primary    = NUMBER | STRING | SYMBOL | LVAR | NAME | "true" | "false" | "nothing"
           | "(" expr ")" | "(" expr "," ... ")"       (* tupla: parametri di lambda *)
           | "[" [ expr { "," expr } [ "|" expr ] ] "]"
           | "[" expr "for" NAME "in" expr [ "if" expr ] "]"
           | ":(" expr ")" | "quote" block "end"
           | "@" NAME "(" args ")"
           | "if" expr block { "elseif" expr block } [ "else" block ] "end"
           | "while" expr block "end"
           | "for" NAME "in" expr block "end"
           | "for" "(" NAME { "," NAME } ")" "in" expr block "end"   (* destrutturazione *)
           | "let" [ NAME "=" expr { "," NAME "=" expr } ] block "end"
           | "begin" block "end"
           | "try" block [ "catch" [ NAME ] block ] "end"
           | "with" modifier { "," modifier } block "end"
           | "solve" goal { "limit" expr | "depth" expr | "steps" expr | "trace" }
           | "function" "(" params ")" block "end" ;   (* anonima *)
modifier   = "budget" "(" "steps" "=" expr ")" | "trace" ;
```

Tutto è un'espressione con un valore: `if`, `let`, `try`, `with`, `solve` e i blocchi
restituiscono il valore dell'ultima istruzione eseguita (`nothing` se non ce n'è).

## 3. L'albero uniforme

Il parser produce un solo tipo di nodo, `Node(head, args)`. È lo stesso albero che il kernel
esegue, che `:( ... )` restituisce come valore e che `--tree` stampa come S-expression:

```
$ julia triad.jl --tree examples/assaggio.td
(rule (call grandparent ?x ?z) (call parent ?x ?y) (call parent ?y ?z))
(assign result (solve (call grandparent (sym alice) ?who) (tuple (assign limit 5))))
```

| sintassi | nodo |
|---|---|
| `f(a, b)`, `a + b` | `(call f a b)`, `(call + a b)`: gli operatori sono chiamate |
| `a && b`, `a \|\| b` | `(and a b)`, `(or a b)`: cortocircuito |
| `x = e` | `(assign x e)` |
| `:alice` | `(sym alice)`; un nome nudo `x` è il Symbol `x` (riferimento a variabile) |
| `?x` | la variabile logica stessa (foglia) |
| `a.x`, `xs[i]` | `(dot a x)`, `(index xs i)` |
| `[a, b]`, `[h \| t]` | `(list a b)`, `(cons (list h) t)` |
| `[e for x in xs if c]` | `(comprehension e x xs c)` |
| `x -> e` | `(lambda (tuple x) e)` |
| `x::T` | `(typed x T)` |
| `"a $x"` | `(string "a " x)` |
| `if c a else b end`, `c ? a : b` | `(if c (block a) (block b))` |
| `while`, `for`, `let`, `begin` | `(while c body)`, `(for x iter body)`, `(let (tuple binds…) body)`, `(block …)` |
| `function f(a::T)::R !io ... end` | `(function f (tuple (typed a T)) R (tuple io) body)` |
| `struct P; x::Float; end` | `(struct P (tuple (typed x Float)))` |
| `macro m(a) ... end`, `@m(e)` | `(macro m (tuple a) body)`, `(macrocall m e)` |
| `:(e)`, `quote … end`, `$e` | `(quasi e)`, `(quasi (block …))`, `(unquote e)` |
| `fact t`, `rule h :- g1, g2` | `(fact t)`, `(rule h g1 g2)` |
| `solve g limit 5 trace` | `(solve g (tuple (assign limit 5) (assign trace true)))` |
| `try b catch e h end` | `(try b e h)` |
| `with budget(steps = N), trace … end` | `(with (tuple (call budget (assign steps N)) trace) body)` |
| `requires c`, `ensures c`, `return e` | `(requires c)`, `(ensures c)`, `(return e)` |

Il codice quotato è un valore di tipo `Expr`: `c.head` e `c.args` lo ispezionano,
`Expr(:call, :f, 1)` lo costruisce, `eval(c)` lo esegue, `parse(s)` e `unparse(c)` convertono
tra testo e albero, `sexpr(c)` ne dà la vista a S-expression.

## 4. Valori e tipi

| tipo | valori |
|---|---|
| `Int`, `Float` (sottotipi di `Number`) | `42`, `3.5` |
| `Bool` | `true`, `false` |
| `String` | `"testo"` |
| `Symbol` | `:alice` (è anche l'atomo della logica) |
| `Nothing` | `nothing` |
| `List` | `[1, :a, "x"]`: lista eterogenea, indici da 1 |
| `Function` | lambda, funzioni generiche, builtin |
| `Expr` | codice quotato |
| `Term`, `LVar` | termini e variabili logiche (`f(?x)`, `?x`) |
| `Solution` | `{who = :dave}`: `s.who`, `s[:who]`, `vars(s)` |
| `Err` | errore come dato (§8) |
| `Type` | i tipi stessi sono valori: `typeof(3) == Int` |
| struct utente | `Point(3.0, 4.0)` |

- **Gerarchia:** `Int <: Number`, `Float <: Number`, e ogni tipo è sottotipo di `Any`.
- **Struct:** sono immutabili e il costruttore è posizionale (`Point(3, 4)`). Il costruttore
  controlla i campi tipati; un `Int` passato a un campo `Float` viene convertito in `Float`.
  Un valore di tipo non convertibile produce `Err(:type)`.
- **Conversioni:** `Int(x)`, `Float(x)`, `String(x)`, `Symbol(x)`. Il nome del tipo usato come
  funzione converte; il nome di una struct usato come funzione costruisce.
- **Asserzione:** `e::T` restituisce `e` se è di tipo `T`, altrimenti produce `Err(:type)`.
- **Vincolo del dichiarato:** `x::T = e` (e un parametro `x::T`) *fissa* il tipo di quel nome
  nell'ambiente dove nasce: gli assegnamenti successivi sono controllati e
  convertiti contro `T` (`y::Float = 1.0; y = 2` → `2.0`; `x::Int = 1; x = 0.5` → `Err(:type)`).
  Una nuova dichiarazione `x::U = ...` sullo stesso nome sostituisce il vincolo, un nome non
  dichiarato con tipo resta libero (`s = "a"; s = 3` va bene), e una rilegatura in un ambiente
  interno (`let x = 2.5`) non eredita il vincolo dell'esterno.
- **Condizioni:** `if`, `while`, `&&`, `||`, `!` e i filtri accettano solo `Bool`. Non esiste
  un concetto di "truthy", e una condizione non booleana dà `Err(:type)`.
- **`print` e `show`:** `println(:a)` stampa `a`; dentro una lista o in un `repr` il simbolo
  si stampa come `:a`.

## 5. Funzioni e multiple dispatch

```julia
area(n::Number) = :number
area(n::Int)    = :int            # più specifico: vince per gli Int
area(p::Point)  = :point
function +(a::Point, b::Point)    # gli operatori si estendono come funzioni
    Point(a.x + b.x, a.y + b.y)
end
```

- Una funzione generica è un insieme di metodi. Ridefinire la stessa firma sostituisce il
  metodo precedente.
- **Selezione del metodo:** tra i metodi applicabili (stessa arità, ogni argomento sottotipo
  del parametro) vince il più specifico. Un metodo A è più specifico di B se ogni suo
  parametro è sottotipo del corrispondente parametro di B e le firme differiscono.
  - Se nessun metodo è applicabile si ottiene `Err(:method)`. Se il nome è anche un builtin,
    per esempio `+` sui numeri, si usa il builtin.
  - Più metodi massimali danno `Err(:ambiguous)`.
- **Tipo di ritorno:** `::R` è controllato all'uscita, con la conversione Int→Float. Se il
  valore non è conforme si ottiene `Err(:type)`.
- **Valori di prima classe:** funzioni e operatori sono valori (`reduce(+, xs)`,
  `map(sq, xs)`), le lambda (`x -> x + 1`) sono chiusure.
- **Funzioni locali:** una `function` definita dentro un'altra funzione è una chiusura locale,
  senza dispatch.
- **Scope lessicale:** ogni `function`, lambda, `let`, `for`, `while` e comprehension
  introduce un ambiente. Un nome è visibile nell'ambiente in cui è legato e in quelli
  interni, non in quelli esterni. Dentro una funzione, un assegnamento lega il nome
  nell'ambiente locale (o in una chiusura interna), mai nei globali; al top level i cicli
  possono aggiornare i globali.
- **`return`, `break`, `continue`:** `return e` termina la funzione restituendo il valore di
  `e` (`nothing` senza espressione); `break` esce dal `for`/`while` più interno; `continue`
  salta al passo successivo del ciclo più interno.

## 6. Logica

### 6.1 Fatti, regole, termini

```julia
fact parent(:tom, :bob)
rule ancestor(?a, ?d) :- parent(?a, ?d)
rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)
```

Dentro un termine:
- `:atomo` è un simbolo; `?x` è una variabile logica; numeri, stringhe e liste sono se stessi.
- `f(t1, t2)` è un termine composto. Anche `?x + 1` è un termine (`+(?x, 1)`) e non viene
  valutato.
- **un nome nudo è un valore dell'ambiente corrente**, letto al momento in cui viene eseguito
  `fact`, `rule` o `solve`: `chi = :bob; solve parent(chi, ?c)`.
- `$(espr)` inserisce esplicitamente un valore calcolato: `fact eta(:bob, $(2026 - 1975))`.
- `[a, b]` e `[?h | ?t]` sono liste e pattern su liste.
- Il nome di una struct con argomenti, come `Point(?x, ?y)`, unifica con le istanze di quella
  struct (pattern matching).

Le variabili di una clausola vengono rinominate a ogni uso (standardizzazione a parte).
L'unificazione fa l'**occurs-check**: `solve ?x = f(?x)` non ha soluzioni.

### 6.2 Goal

| goal | significato |
|---|---|
| `p(t…)` | predicato della knowledge base, risolto con SLD e backtracking, clausole in ordine |
| `g1 && g2`, `(g1, g2)` | congiunzione; nelle `rule` anche con `,` |
| `g1 \|\| g2` | disgiunzione |
| `!g`, `not(g)` | negazione per fallimento |
| `not(b)` | *fuori* da un goal `not/1` è una funzione: nega un `Bool` (`not(true) == false`) |
| `a = b` | unificazione |
| `?y is espr` | valuta `espr` (le variabili devono essere legate) e unifica con `?y` |
| `a < b`, `==`, `!=`, `<=`, `>`, `>=` | confronto tra valori, valutati |
| `f(t…)` con `f` funzione Triad | chiama la funzione con gli argomenti valutati; deve restituire `Bool` |
| `true`, `false` | successo, fallimento |

Un predicato senza clausole con quell'arità, che non sia nemmeno una funzione, dà
`Err(:undef, "predicato sconosciuto: p/2")`. Una variabile non legata dentro un'espressione dà
`Err(:instantiation)`.

### 6.3 `solve` è un valore

```julia
sols = solve ancestor(:tom, ?d) limit 10 depth 50 steps 100_000
[s.d for s in sols]                 # comprehension sulle soluzioni
```

- `solve g` restituisce una lista (`List`) di `Solution`. Ogni soluzione lega le variabili
  della query **non anonime**, nell'ordine in cui compaiono. Le variabili rimaste libere
  restano `?x#n`.
- Opzioni:
  - `limit n`: al massimo `n` soluzioni;
  - `depth d`: i rami più profondi di `d` vengono tagliati (cioè falliscono);
  - `steps s`: al massimo `s` passi di risoluzione, altrimenti `Err(:budget)`; il default è
    1 000 000;
  - `trace`: si veda §11.
- **Predicato in un'espressione:** chiamare un predicato dove ci si aspetta un valore
  restituisce `Bool`, cioè dice se il goal è dimostrabile:
  `if grandparent(:alice, :dave) … end`, `filter(p -> !parent(p, ?_), persone)`.
- Il motore è iterativo, con uno stack esplicito e uno store dei legami con trail. Non usa la
  ricorsione dell'implementazione, quindi la ricorsione infinita, anche sinistra, finisce in
  `Err(:budget)` e non in uno stack overflow.

## 7. Macro e codice come dato

```julia
macro swap(a, b)
    t = gensym(:tmp)
    quote
        $t = $a
        $a = $b
        $b = $t
    end
end
@swap(x, y)
```

- `:(e)` e `quote … end` restituiscono codice (`Expr`). Dentro, `$x` e `$(e)` inseriscono il
  **valore** di un'espressione: se è codice viene innestato, se è un numero, una lista o altro
  diventa una costante, se è un Symbol diventa un identificatore.
- Una macro riceve gli argomenti **come codice**, non valutati, e restituisce codice, che viene
  poi eseguito al posto della chiamata `@nome(...)` nello scope del chiamante.
- L'espansione è pura (§12) e non è igienica: per i nomi temporanei si usa `gensym()`.
- `eval(c)` esegue codice nello scope globale.

## 8. Errori come dati

Un errore è un valore `Err` con tre campi:
- `kind::Symbol`: la categoria, su cui si può fare dispatch;
- `msg::String`;
- `data`: un valore qualsiasi, spesso un record `Info(...)` con i dettagli.

| costrutto | effetto |
|---|---|
| `err(:kind, "msg"[, data])` | costruisce un `Err` senza sollevarlo |
| `throw(e)`, `error("msg")` | solleva (`error` produce `Err(:error, …)`) |
| `try b catch e h end` | se `b` solleva, `e` è legato all'`Err` e si valuta `h` |
| `try b end` | **l'errore diventa il valore** dell'espressione |
| `iserr(x)` | controlla se `x` è un `Err` |

Tutti i fallimenti del linguaggio e dell'implementazione (divisione intera per zero,
`sqrt(-1.0)`, indici fuori range…), arrivano come `Err` e mai come fallimenti fatali:

| kind | quando |
|---|---|
| `:syntax` | errore di parse; `data` contiene `line`, `col` e `incomplete` (usato dal REPL) |
| `:undef` | nome, funzione, macro o predicato non definito |
| `:type` | tipo sbagliato (campi, ritorno, `::`, condizioni non `Bool`) |
| `:method` | nessun metodo applicabile; `data.types` contiene i tipi degli argomenti |
| `:ambiguous` | più metodi ugualmente specifici |
| `:field`, `:bounds`, `:domain` | campo inesistente, indice fuori range, errore matematico |
| `:instantiation` | variabile logica non legata dove serve un valore |
| `:contract` | `requires`/`ensures` violata (§9) |
| `:budget` | passi esauriti (§10) |
| `:effect` | effetto non dichiarato (§12) |
| `:host` | qualsiasi altro errore dell'interprete |

Un errore non gestito al top level interrompe il programma. Il messaggio riporta la riga
dell'istruzione (`riga 12: …`) e il codice di uscita è 1.

## 9. Contratti

```julia
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end
```

- `requires c` viene controllata nel punto in cui compare: per convenzione all'inizio del
  corpo.
- `ensures c` viene registrata e controllata all'uscita della funzione, con `result` legato al
  valore restituito, dopo il controllo del tipo di ritorno.
- Una violazione produce `Err(:contract, "requires violata in safe_div: b != 0", Info(fn, clause, cond[, result]))`.
  `cond` contiene il codice della condizione: è un dato, si può ispezionare.
- Le condizioni sono **pure**: un effetto dentro un contratto dà `Err(:effect)`.
- Al top level `requires c` funziona come un'asserzione.

## 10. Budget

```julia
r = with budget(steps = 10_000)
    calcolo_che_potrebbe_non_finire()
end
iserr(r) && r.kind == :budget
```

- Un **passo** è una chiamata, un'iterazione di un ciclo o un passo di risoluzione.
- `with budget(steps = N) … end` limita i passi del corpo. Se il budget si esaurisce,
  **il valore del `with` è `Err(:budget)`**: il programma non si blocca e non viene
  interrotto.
- I budget si annidano: vale il più stretto. Un `with` converte in valore solo l'esaurimento
  del **proprio** budget, mentre quello di un budget esterno continua a propagarsi.
- `solve … steps N` è il budget specifico di una query.

## 11. Tracce

La traccia di un calcolo è un **valore**, non output stampato:

```julia
t = with trace
    fib(3)
end
t.result                         # 2
t.trace                          # [Event(port = :call, fn = :fib, args = [3], depth = 0), …]

t = solve path(:a, :c) trace
t.trace                          # Event(port = :call | :redo | :exit | :fail | :depth, goal, depth)
```

- `with trace … end` restituisce `Traced(result, trace)` con gli eventi `:call` e `:exit` di
  ogni funzione generica chiamata nel corpo.
- `solve … trace` restituisce `Traced(result, trace)`, dove `result` è la lista delle
  soluzioni e gli eventi sono le porte del modello a scatole di Byrd (`call`, `exit`, `redo`,
  `fail`) più `depth`, quando un ramo viene tagliato da `depth`.
- Gli eventi sono record: si filtrano e si contano come ogni altro valore
  (`[e.args for e in t.trace if e.port == :call]`).

## 12. Effetti

Le funzioni sono **pure per default**. Gli effetti si dichiarano nella firma:

```julia
function saluta(nome::String) !io
    println("ciao, ", nome)
end
function impara(x) !state
    fact visto($x)
end
```

| effetto | operazioni |
|---|---|
| `io` | `println`, `print` |
| `state` | `fact`/`rule` eseguiti dentro una funzione (modificano la knowledge base) |

- **Controllo dinamico.** Una funzione viene eseguita solo con gli effetti che dichiara, e solo
  se il chiamante li permette. Se una funzione pura chiama `println`, o chiama una funzione
  `!io`, si ottiene `Err(:effect)`. `data` contiene `fn`, `caller` e `missing`.
- Il top level permette tutti gli effetti.
- Le lambda ereditano gli effetti del contesto in cui vengono eseguite.
- Macro e contratti sono puri.
- Leggere la knowledge base (`solve`, chiamare un predicato) è puro.
- La mutazione locale di dati (`push!` su una lista, assegnamento a variabili locali) non è un
  effetto: modifica solo valori raggiungibili dall'ambiente locale.

## 13. Builtin

| ambito | funzioni |
|---|---|
| aritmetica e confronto | `+ - * / ^ % == != < <= > >= !`, `abs sqrt floor ceil round exp log sin cos div mod min max`; `*` concatena le stringhe |
| liste | `length isempty first last rest reverse sort sum push! pop! append! vcat collect`, `a:b`, `x in xs` |
| ordine superiore | `map filter reduce any all count` |
| stringhe e output | `string repr println print` |
| tipi | `typeof`, `isa`, `Int Float String Symbol` |
| errori | `err iserr throw error` |
| codice | `eval parse unparse sexpr Expr gensym` |
| logica | `vars(sol)` |

## 14. Interfaccia a riga di comando

Un'implementazione conforme espone un comando `triad` con questa interfaccia. La forma è
normativa; sono ammesse opzioni aggiuntive, purché compatibili.

```
triad                            # REPL
triad FILE [ARG...]              # esegue FILE; ARGS == [ARG...]
triad -l FILE                    # carica FILE e apre il REPL
triad -i FILE                    # esegue FILE e poi apre il REPL
triad -e CODE                    # esegue CODE
triad -E CODE                    # esegue CODE e stampa il valore
triad --tree FILE                # stampa l'albero uniforme come S-expression
triad -q                         # REPL senza banner
triad -h, --help
triad -v, --version
triad -                          # legge lo script da stdin
```

- Le azioni si eseguono nell'ordine dato; poi lo script.
- L'estensione `.triad` (canonica) o `.td` (storica) si può omettere.
- Un file `.triad`/`.td` può avere shebang `#!/usr/bin/env triad`; la prima riga `#!...` è
  ignorata prima del parsing.
- Il programma vede gli argomenti in `ARGS`, lista di stringhe, senza il nome del programma.
- Codici di uscita: `0` successo, `1` errore non gestito, `2` uso non valido. Un errore non
  gestito è stampato su stderr.

**REPL.** Senza script, l'implementazione apre un REPL con questo comportamento:

```
triad> ?- ancestor(:tom, ?d)
?d = :bob ;
?d = :liz.
triad> mother(?m, ?c)                # un goal su un predicato della KB è già una query
?m = :pat,
?c = :jim.
triad> parent(:jim, ?x)
false.
```

- Le righe sono codice Triad; i blocchi restano aperti finché non sono chiusi da `end`.
- `?- goal` (il `.` finale è facoltativo) esegue una query con le opzioni di `solve`:
  `limit`, `depth`, `steps`, `trace`.
- Un'istruzione che è un goal su un predicato della knowledge base è trattata come query.
- Dopo ogni soluzione: `;`, `n` o spazio per la successiva, `a` per tutte le rimanenti,
  invio o `.` per fermarsi. `false.` significa nessun'altra soluzione. Se stdin non è un
  terminale le soluzioni sono stampate tutte.
- Comandi: `:load FILE...` (`:l`), `:reload` (`:r`, `make`), `:listing [nome|nome/arità]`
  (`:ls`), `:tree CODICE`, `:reset`, `:help` (`:h`), `:quit` (`:q`, `halt`, Ctrl-D).
- Ctrl-C interrompe il calcolo in corso; un errore non gestito è stampato e il REPL continua.

La suite di conformità copre la parte non interattiva dell'interfaccia (script, argomenti,
exit code); il REPL è coperto dai test dell'implementazione.

## 15. Stato dell'implementazione di riferimento (informativo)

Questa sezione non è normativa.

- L'implementazione di riferimento attuale (`triad.jl`, `syntax.jl`) è scritta in Julia ed è
  transitoria: serve al bootstrap e sarà sostituita dall'implementazione self-hosted
  (`BOOTSTRAP.md`).
- Non ancora implementati nel riferimento: argomenti con nome (salvo `budget(steps = …)`),
  struct mutabili, tipi astratti utente, tipi parametrici, macro senza parentesi, quote
  annidate a più livelli, cut.
- Il controllo degli effetti è dinamico; è previsto un controllo statico.
- Il vecchio kernel a S-expression è conservato in `legacy/triad_sexpr_v1.jl`.

## 16. Conformità e versionamento

### 16.1 Profili di conformità

- **Triad-Core** — sottoinsieme richiesto per eseguire il bootstrap e le implementazioni
  self-hosted: valori, funzioni e chiusure, controllo di flusso, liste, stringhe, I/O e
  primitive di bootstrap. È definito in modo normativo in `SPEC-CORE.md`; i casi condivisi
  con Triad-Full sono in `conformance/core/`.
- **Triad-Full** — tutto il linguaggio descritto in questo documento, inclusi logica (§6),
  macro (§7), contratti (§9), budget (§10), tracce (§11), effetti (§12).

### 16.2 Verifica

Un'implementazione è conforme a un profilo se:

1. passa i casi di `conformance/`, producendo per ognuno esattamente `expected.out` ed
   `expected.code` (formato in `conformance/README.md`);
2. implementa l'interfaccia a riga di comando del §14 per la parte coperta dalla suite;
3. per Triad-Full passa tutti i casi; per Triad-Core, il sottoinsieme dichiarato.

La suite di conformità è parte dello standard: i suoi golden sono normativi e versionati
insieme alla specifica. Un'implementazione non può dichiararsi conforme senza eseguirla.

### 16.3 Versionamento

- La versione dello standard è `MAJOR.MINOR.PATCH` (`0.2.0` attuale, in `VERSION`).
- `MAJOR` cambia per modifiche incompatibili; `MINOR` per estensioni compatibili e
  chiarimenti; `PATCH` per correzioni non normative o di implementazione.
- Ogni modifica normativa aggiorna `CHANGELOG.md`, `VERSION` e, se cambia il comportamento,
  i golden della conformità.

## Appendice A — Influenze dichiarate (informativo)

Triad nasce da idee di **Julia**, **Prolog** e **Lisp**, ma non è un dialetto di nessuno dei
tre: la definizione del linguaggio è questa specifica. Le somiglianze sono note informative.

| da | idea ripresa |
|---|---|
| Julia | blocchi `function ... end`, tipi `::`, `struct`, multiple dispatch, operatori-funzione, `if`/`for`/`while`/`let` |
| Prolog | `fact`/`rule` come costrutti, unificazione con occurs-check, backtracking, `solve`, variabili `?x` |
| Lisp | codice come dato, albero uniforme, `:( ... )`/`quote` con `$`, macro |

Propri di Triad, non presi in prestito: errori come dati, contratti, budget, tracce ed
effetti dichiarati come parte del linguaggio, e l'integrazione dei tre modelli in un'unica
sintassi a blocchi.
