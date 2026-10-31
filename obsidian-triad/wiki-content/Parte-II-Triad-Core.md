<a id="parte-2"></a>

# Parte II — Triad-Core passo per passo (eseguibile oggi)

Ogni capitolo di questa parte usa solo Triad-Core. Gli esempi con **Output:** sono stati
eseguiti con l'interprete JS; il caso di conformance indicato in fondo a ogni capitolo è il
riferimento normativo da leggere e far girare.

<a id="cap-4"></a>

## 4. Lessico

| elemento | forma | esempi |
|---|---|---|
| identificatore | lettera o `_`, poi lettere/cifre/`_`; un `!` finale è ammesso | `x`, `somma_2`, `push!` |
| intero | cifre decimali, `_` come separatore; il segno è l'operatore unario | `42`, `1_000_000`, `-5` |
| booleano | `true`, `false` | |
| nothing | `nothing` | |
| stringa | `"..."` con escape `\n \t \" \\`; **nessuna interpolazione** | `"ciao\n"` |
| simbolo | `:` seguito da un nome o da un operatore | `:alice`, `:+` |
| commento | `#` fino a fine riga; `#= ... =#` su più righe | |
| separatore | a capo oppure `;` | `println(1); println(2)` |

Operatori di Core: `+ - * % ^ == != < <= > >= && || ! = += -= *= -> ?:`.

Parole riservate usate da Core: `function end if elseif else while let begin return break
continue true false nothing`.

Non fanno parte di Core: letterali `Float` (`1.5`), variabili logiche `?x`, macro `@nome`,
interpolazione `$x`, l'operatore `/`.

```julia
#= commento
   su più righe =#
x = 1_000   # commento di riga
println(x); println("tab:\t|", " virgolette: \"", " backslash: \\")
println(:alice, " ", :+)
```

Output:

```text
1000
tab:	| virgolette: " backslash: \
alice +
```

> **Attenzione.** `"x = $x"` in Core stampa letteralmente `x = $x`: l'interpolazione è solo
> Triad-Full. In Core si concatena: `"x = " * string(x)`.
>
> I commenti `#= … =#` **non si annidano** nell'interprete JS (SPEC Full richiede l'annidamento).

Riferimento: `conformance/core/cases/aritmetica`, `simboli_base`, `stringhe_base`.

---

<a id="cap-5"></a>

## 5. Valori, tipi e stampa

| tipo | valori | `typeof(v)` |
|---|---|---|
| `Int` | interi con segno a 64 bit, aritmetica con wrap (complemento a due) | `Int` |
| `Bool` | `true`, `false` | `Bool` |
| `String` | sequenza immutabile di byte UTF-8 | `String` |
| `Symbol` | `:nome`; uguali se hanno lo stesso nome | `Symbol` |
| `List` | lista eterogenea **mutabile**, indici da 1 | `List` |
| `Function` | funzione nominata, lambda o chiusura | `Function` |
| `Nothing` | `nothing` | `Nothing` |

`typeof` restituisce il **nome del tipo come simbolo**.

### 5.1 Regole di stampa di `print`/`println`

- concatenano gli argomenti senza separatori; `println` aggiunge `\n`;
- `Int` in decimale, `Bool` come `true`/`false`, `String` così com'è, `Nothing` come `nothing`;
- un `Symbol` passato direttamente è stampato **senza** `:`; dentro una lista **con** `:`;
- una `List` è stampata come `[a, b]`; le stringhe dentro una lista sono stampate senza
  virgolette.

```julia
xs = [1, :a, "s", true, nothing, [2, 3]]
println(xs)
println(:alice)
println(typeof(1), " ", typeof("s"), " ", typeof(:a), " ", typeof(xs))
println(typeof(nothing), " ", typeof(true), " ", typeof(x -> x))
print("senza ", "a capo")
println()
```

Output:

```text
[1, :a, s, true, nothing, [2, 3]]
alice
Int String Symbol List
Nothing Bool Function
senza a capo
```

### 5.2 Uguaglianza

`==` e `!=` confrontano numeri, stringhe e simboli **per valore**, le liste **elemento per
elemento** (anche annidate), le funzioni **per identità**.

```julia
println([1, [2, [3]]] == [1, [2, [3]]])
println("ab" == "a" * "b", " ", :a == :a, " ", 1 == 2)
```

Output:

```text
true
true true false
```

Riferimento: `conformance/core/cases/valori`, `nothing_base`, `confronti`.

---

<a id="cap-6"></a>

## 6. Variabili e assegnamento

- `nome = espr` lega o aggiorna un nome; l'assegnamento è un'espressione e vale il valore
  assegnato.
- `+=`, `-=`, `*=` aggiornano una variabile esistente (il lato sinistro è valutato una volta).
- Usare un nome mai assegnato è un errore di esecuzione (`undefined variable`).
- Non ci sono dichiarazioni né tipi: le variabili sono dinamiche.

```julia
x = 42
y = x + 8
x = x + 1
z = (x + y) * 2
println(x, " ", y, " ", z)
n = 10
n += 5
n -= 3
n *= 2
println(n)
```

Output:

```text
43 50 186
24
```

Le regole di **visibilità** (dentro funzioni, `let`, lambda) sono nel [capitolo 10](#cap-10).

Riferimento: `conformance/core/cases/variabili`.

---

<a id="cap-7"></a>

## 7. Operatori ed espressioni

### 7.1 Precedenza (dalla più bassa alla più alta)

| livello | operatori | associatività |
|---|---|---|
| 1 | `=` `+=` `-=` `*=` | destra |
| 2 | `c ? a : b` | destra |
| 3 | `\|\|` | sinistra, cortocircuito |
| 4 | `&&` | sinistra, cortocircuito |
| 5 | `==` `!=` `<` `<=` `>` `>=` | sinistra |
| 6 | `+` `-` | sinistra |
| 7 | `*` `%` | sinistra |
| 8 | `^` | **destra** |
| 9 | unari `-` `!` | prefissi |
| 10 | `f(args)` `xs[i]` | postfissi |

### 7.2 Aritmetica intera

- `+ - * ^` su `Int` con **wrap a 64 bit**;
- `%` è il **resto con il segno del dividendo** (come `rem` di Julia): `-7 % 3 == -1`;
- `^` con esponente negativo è un errore; `%` per zero è un errore;
- **non esiste `/`** in Core (la divisione è di Triad-Full).

```julia
println(2 + 3 * 4, " ", (2 + 3) * 4, " ", 2 ^ 3 ^ 2)
println(7 % 3, " ", -7 % 3, " ", 10 % 4)
println(9223372036854775807 + 1)
```

Output:

```text
14 20 512
1 -1 2
-9223372036854775808
```

### 7.3 Logica e condizioni

- Le condizioni (`if`, `while`, ternario, `&&`, `||`, `!`) accettano **solo `Bool`**: non c'è
  "truthiness" (`if 1` è un errore).
- `&&` e `||` cortocircuitano.
- I confronti non si concatenano: `1 < 2 < 3` è un errore (si confronta `Bool < Int`); scrivi
  `1 < 2 && 2 < 3`.

```julia
println(!false, " ", true && false, " ", false || true)
println(1 < 2 && 2 < 3)
x = 3
println(x > 2 ? "grande" : "piccolo")
```

Output:

```text
true false true
true
grande
```

Riferimento: `conformance/core/cases/aritmetica`, `operatori`, `interi`, `confronti`.

---

<a id="cap-8"></a>

## 8. Controllo di flusso

In Triad **tutto è un'espressione**: `if`, `while`, `let`, `begin` hanno un valore (quello
dell'ultima istruzione eseguita, `nothing` se nessuna).

### 8.1 `if` / `elseif` / `else`

```julia
function classifica(x)
    if x < 0
        "negativo"
    elseif x == 0
        "zero"
    else
        "positivo"
    end
end
println(classifica(-3), " ", classifica(0), " ", classifica(7))
v = if 2 > 1 :si else :no end
println(v)
```

Output:

```text
negativo zero positivo
si
```

### 8.2 `while`, `break`, `continue`

```julia
i = 0
somma_dispari = 0
while i < 10
    i += 1
    if i % 2 == 0
        continue
    end
    somma_dispari += i
end
println(somma_dispari)
while true
    break
end
println(:fine)
```

Output:

```text
25
fine
```

`break` e `continue` agiscono sul `while` più interno. Non esiste `for` in Core: si itera con un
contatore e `while`.

### 8.3 `let` e `begin`

`let` introduce un nuovo scope con legami locali; `begin … end` raggruppa istruzioni senza
creare legami nuovi.

```julia
x = 1
let x = 10
    let x = 20
        println(x)
    end
    println(x)
end
println(x)
r = begin
    a = 2
    a * 21
end
println(r)
```

Output:

```text
20
10
1
42
```

Riferimento: `conformance/core/cases/controllo`, `if_else`, `if_elseif`, `if_nested`,
`if_no_else`, `while_loop`, `let_annidato`, `begin_block`.

---

<a id="cap-9"></a>

## 9. Funzioni

### 9.1 Tre modi di definire una funzione

```julia
# forma breve: il corpo è un'espressione
quadrato(x) = x * x

# forma blocco: il valore è quello dell'ultima espressione
function calcola(n)
    m = n + 1
    m * 2
end

# funzione anonima assegnata a un nome
moltiplica = function (a, b)
    a * b
end

println(quadrato(4), " ", calcola(3), " ", moltiplica(6, 7))
```

Output:

```text
16 8 42
```

### 9.2 `return`, ricorsione, arità

- `return e` esce subito dalla funzione; `return` da solo restituisce `nothing`.
- Una funzione nominata è visibile nel proprio corpo: la ricorsione diretta funziona.
- Il numero di argomenti deve coincidere con i parametri (altrimenti `arity mismatch`).

```julia
function taglia(n)
    if n > 100
        return :grande
    end
    :piccola
end
fattoriale(n) = n < 2 ? 1 : n * fattoriale(n - 1)
fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)
mcd(a, b) = b == 0 ? a : mcd(b, a % b)
println(taglia(500), " ", taglia(5))
println(fattoriale(10), " ", fib(15), " ", mcd(48, 18))
```

Output:

```text
grande piccola
3628800 610 6
```

### 9.3 Annotazione di effetto `!io`

In Triad-Full una funzione che stampa deve dichiarare `!io` ([capitolo 28](Parte-III-Triad-Full#cap-28)). Core
accetta l'annotazione e la ignora: scriverla rende il codice già pronto per Full.

```julia
function mostra() !io
    println("hello from block")
    20 + 22
end
println(mostra())
```

Output:

```text
hello from block
42
```

Riferimento: `conformance/core/cases/funzioni`, `funzioni_semplici`, `funzioni_blocco`,
`funzioni_io`, `ricorsione`, `gcd`, `formula`.

---

<a id="cap-10"></a>

## 10. Lambda, chiusure e scope

### 10.1 Lambda

```julia
doppio = x -> x * 2
somma = (a, b) -> a + b
applica = f -> f(3)
println(doppio(5), " ", somma(1, 2), " ", applica(x -> x * x))
```

Output:

```text
10 3 9
```

Una lambda con corpo a più istruzioni si scrive con `begin … end` o con `function (…) … end`.
Le lambda senza parametri (`() -> …`) **non** sono supportate: usa `function () … end`.

### 10.2 Chiusure

Una lambda cattura l'ambiente in cui è creata. Secondo SPEC-CORE §5 le variabili catturate sono
**condivise**: le mutazioni sono visibili.

```julia
function add(n)
    x -> x + n
end
f = add(10)
g = add(100)
println(f(5), " ", g(5))

function contatore()
    v = 0
    x -> begin
        v += x
        v
    end
end
acc = contatore()
acc(5)
println(acc(10))
```

Output:

```text
15 105
15
```

> Il seed Windows cattura **per valore** e copre solo l'ultimo legame del frame: un
> accumulatore come `contatore` può non funzionare sul seed ([capitolo 15](#cap-15)).

### 10.3 Regole di scope

1. `function`, lambda, `let` e `while` introducono ambienti; un nome è visibile nell'ambiente
   in cui è legato e in quelli interni (scope lessicale).
2. **Dentro una funzione nominata** l'assegnamento lega nel frame locale: una funzione **non
   modifica i globali**.
3. **Dentro una lambda** l'assegnamento a un nome già legato fuori aggiorna quel legame (è così
   che funziona l'accumulatore sopra).
4. **Al top level** i cicli aggiornano i globali.
5. `let x = …` crea un nuovo `x`; assegnare `x` dentro il `let` non tocca l'`x` esterno.

```julia
x = 1
function f()
    x = 2
    x
end
println(f(), " ", x)
c = 0
function incrementa()
    c += 1
end
incrementa()
println(c)
```

Output:

```text
2 1
0
```

Per far "uscire" un risultato da una funzione restituiscilo, oppure usa una lista (che è
mutabile, [capitolo 11](#cap-11)).

Riferimento: `conformance/core/cases/lambda`, `closure`, `chiusure`, `chiusure_local`,
`chiusura_in_if`, `let_chiusura`, `scope`.

---

<a id="cap-11"></a>

## 11. Liste

- Letterale: `[1, 2, 3]`, `[]`, eterogenee e annidabili.
- Indici **da 1**: `xs[1]` è il primo elemento; fuori range è un errore.
- Assegnamento per indice: `xs[i] = v`, anche `xs[i] += v`.
- `length(xs)` numero di elementi; `push!(xs, v)` aggiunge in coda, **muta** la lista e la
  restituisce.
- Le liste sono riferimenti: due nomi possono indicare la stessa lista.

```julia
xs = [1, 2, 3]
println(xs[1], " ", length(xs))
push!(xs, 4)
xs[1] += 100
println(xs)
alias = xs
push!(alias, 5)
println(xs)
tot = 0
i = 1
while i <= length(xs)
    tot += xs[i]
    i += 1
end
println(tot)
```

Output:

```text
1 3
[101, 2, 3, 4]
[101, 2, 3, 4, 5]
115
```

Core non ha `map`, `filter`, `reduce`, `sum`, `sort`: si scrivono in Core (vedi
[capitolo 16](#cap-16)).

> Sul seed Windows: liste solo di interi, `push!` sì, `xs[i]` e `length(xs)` **no**; c'è invece
> l'helper non standard `get(xs, i)` con indici **da 0** ([capitolo 15](#cap-15)).

Riferimento: `conformance/core/cases/liste`, `liste_base`, `liste_push`.

---

<a id="cap-12"></a>

## 12. Stringhe, simboli e conversioni

| operazione | significato |
|---|---|
| `a * b` | concatenazione di stringhe |
| `length(s)` | numero di **byte** UTF-8 (`length("é") == 2`) |
| `string(x)` | rappresentazione testuale di qualsiasi valore (`string(:a) == "a"`, `string([1, 2]) == "[1, 2]"`) |
| `Int(s)` | da stringa a intero (`Int("42") == 42`); da Bool: `0`/`1` |
| `Symbol(s)` | da stringa a simbolo (`Symbol("ciao") == :ciao`) |
| `typeof(x)` | tipo come simbolo |

```julia
nome = "Triad"
saluto = "ciao " * nome
println(saluto, " (", length(saluto), " byte)")
println("risposta: " * string(40 + 2))
println(Int("41") + 1, " ", Symbol("bob"), " ", string(true))
println(:ok == Symbol("ok"))
```

Output:

```text
ciao Triad (10 byte)
risposta: 42
42 bob true
true
```

Per accedere ai singoli byte di una stringa servono i primitivi di bootstrap del capitolo
successivo.

Riferimento: `conformance/core/cases/stringhe`, `stringhe_concat`, `stringhe_multi`,
`simboli_base`.

---

<a id="cap-13"></a>

## 13. Primitivi di bootstrap

Servono a S1 per leggere e analizzare sorgente Triad. **Non** fanno parte di Triad-Full
(SPEC-CORE §8): usali solo nel codice di bootstrap.

| primitiva | semantica |
|---|---|
| `readfile(path)` | contenuto del file come `String`; errore se non leggibile |
| `strlen(s)` | numero di byte |
| `strbyte(s, i)` | byte (`Int` 0–255) alla posizione `i`, da 1 |
| `strsub(s, a, b)` | sottostringa dai byte `a` a `b` inclusi, da 1 |
| `exit(n)` | termina il processo con codice `n` |

Esempio: contare le cifre di una stringa e separare la prima parola.

```julia
s = "abc 123 xyz"
cifre = 0
i = 1
while i <= strlen(s)
    b = strbyte(s, i)
    if b >= 48 && b <= 57
        cifre += 1
    end
    i += 1
end
println(cifre)
fine = 1
while fine <= strlen(s) && strbyte(s, fine) != 32
    fine += 1
end
println(strsub(s, 1, fine - 1))
```

Output:

```text
3
abc
```

Un programma può leggere se stesso o un altro sorgente con `readfile(ARGS[1])`: è esattamente
il primo passo di un interprete self-hosted ([capitolo 37](Parte-IV-Codice-del-progetto#cap-37)).

---
<a id="cap-14"></a>

## 14. Errori di esecuzione

Core non ha `try`/`catch` né valori `Err` (SPEC-CORE §9): un errore **termina il processo con
exit code 1** e stampa un messaggio diagnostico su stderr. Quello che era già stato stampato su
stdout resta.

```julia
println("prima")
println(non_esiste)
println("dopo")
```

```text
stdout:  prima
stderr:  error: undefined variable non_esiste
exit:    1
```

Messaggi dell'interprete JS (stderr) e cause tipiche:

| messaggio | causa |
|---|---|
| `parse error: unexpected token …` / `parse error: expected …` | sintassi non Core (es. `1.5`, `/`, `() -> …`, `end` mancante) |
| `error: undefined variable NOME` | nome mai assegnato, o funzione chiamata prima di essere definita |
| `error: not a function` | si chiama un valore che non è una funzione (`x = 5; x(1)`) |
| `error: arity mismatch` | numero di argomenti diverso dai parametri |
| `error: index out of range` | `xs[i]` con `i < 1` o `i > length(xs)` |
| `error: + type error` (e simili per `- * % < …`) | operandi di tipo sbagliato (`1 + "a"`) |
| `error: if cond` / `while cond` / `ternary cond` / `&& expects bool` | condizione non `Bool` |
| `error: div by zero` / `negative exponent` | `x % 0`, `2 ^ -1` |
| `error: unknown function NOME` | builtin riservato usato in modo non supportato |
| `cannot read file: …` | file inesistente o non leggibile |
| `usage: triad FILE [ARG...]` (exit 2) | nessun file passato |

Il seed Windows non stampa messaggi dettagliati: esce con codice `1` (sintassi, variabile o
funzione non definita, arità, lettura) o `2` (nessun argomento).

### 14.1 Errori come valori, in Core

Per propagare errori senza terminare il processo (come farà S1 per i programmi Full) si usa
una convenzione con liste: `[:Err, kind, msg]`.

```julia
err(kind, msg) = [:Err, kind, msg]
is_err(v) = typeof(v) == :List && length(v) == 3 && v[1] == :Err
function div_intera(a, b)
    if b == 0
        return err(:domain, "divisione per zero")
    end
    q = 0
    while a >= b
        a -= b
        q += 1
    end
    q
end
r = div_intera(7, 0)
if is_err(r)
    println("errore ", r[2], ": ", r[3])
end
println(div_intera(17, 5))
```

Output:

```text
errore domain: divisione per zero
3
```

Nota: `&&` cortocircuita, quindi `v[1]` è valutato solo se `v` è una lista di 3 elementi.

---

<a id="cap-15"></a>

## 15. Interprete JS e seed Windows: differenze

Il contratto è `conformance/core/`: entrambi i runtime devono produrre gli stessi golden. Oggi
l'interprete JS li passa tutti, il seed Windows i 33 casi elencati nel job `seed-windows` della
CI. Fuori da quei casi i due runtime differiscono:

| funzionalità | interprete JS (`seed/dev/triad_core.cjs`) | seed Windows (`seed.exe`) |
|---|---|---|
| interi, Bool, operatori, confronti, ternario | ✅ | ✅ |
| `if`/`elseif`/`else`, `while`, `let`, `begin` | ✅ | ✅ |
| funzioni forma breve e blocco, ricorsione | ✅ | ✅ (max 4 parametri) |
| `return`, `break`, `continue` | ✅ | non elencati in `seed/windows-x86_64/README.md` |
| lambda | ✅ più parametri | ✅ **un solo parametro** |
| chiusure | condivise (mutazioni visibili, SPEC-CORE §5) | **per valore**, solo l'ultimo legame del frame |
| stringhe, `*`, `length(s)` | ✅ | ✅ |
| `string(x)` | ✅ tutti i tipi | solo `Int` e `String` |
| simboli, `nothing` | ✅ | ✅ |
| liste | eterogenee, `xs[i]`, `xs[i] = v`, `length`, `push!` | solo interi; costruzione, stampa e `push!` (max 64 elementi) |
| `get(xs, i)` | non esiste | helper **non standard**, indici **da 0** |
| `-=`, `*=`, `Int`, `Symbol`, `typeof` | ✅ | non elencati nel README del seed |
| `ARGS`, primitivi di bootstrap | ✅ | non elencati nel README del seed |
| stampa di una funzione | `#lambda(x)` | `fun` |
| `triad -` (stdin) | ✅ | no |
| messaggi d'errore | su stderr | solo exit code |

Regola pratica: **scrivi codice che rispetta SPEC-CORE e verificalo con l'interprete JS**; se
deve girare sul seed (come `selfhost/`), restringiti alla colonna di destra e verificalo su
Windows.

---

<a id="cap-16"></a>

## 16. Pattern idiomatici Triad-Core

### 16.1 Funzioni di ordine superiore scritte in Core

Core non ha `map`/`filter`/`reduce`: si scrivono una volta con `while` e lambda.

```julia
function mappa(f, xs)
    out = []
    i = 1
    while i <= length(xs)
        push!(out, f(xs[i]))
        i += 1
    end
    out
end
function filtra(p, xs)
    out = []
    i = 1
    while i <= length(xs)
        if p(xs[i])
            push!(out, xs[i])
        end
        i += 1
    end
    out
end
function riduci(f, acc, xs)
    i = 1
    while i <= length(xs)
        acc = f(acc, xs[i])
        i += 1
    end
    acc
end
xs = [1, 2, 3, 4, 5, 6]
println(mappa(x -> x * x, xs))
println(filtra(x -> x % 2 == 0, xs))
println(riduci((a, b) -> a + b, 0, xs))
```

Output:

```text
[1, 4, 9, 16, 25, 36]
[2, 4, 6]
21
```

### 16.2 Record come liste taggate

Core non ha `struct`: un record è una lista con un simbolo come tag nella prima posizione.

```julia
punto(x, y) = [:Punto, x, y]
px(p) = p[2]
py(p) = p[3]
somma_punti(a, b) = punto(px(a) + px(b), py(a) + py(b))
p = somma_punti(punto(1, 2), punto(10, 20))
println(p, " ", p[1] == :Punto)
```

Output:

```text
[:Punto, 11, 22] true
```

### 16.3 Ambiente come lista di associazioni

È la struttura usata dagli interpreti in `selfhost/`: una lista piatta `[nome1, valore1,
nome2, valore2, …]` (in Core puoi anche usare coppie annidate).

```julia
function env_get(env, nome)
    i = 1
    while i < length(env)
        if env[i] == nome
            return env[i + 1]
        end
        i += 2
    end
    nothing
end
function env_set(env, nome, valore)
    i = 1
    while i < length(env)
        if env[i] == nome
            env[i + 1] = valore
            return env
        end
        i += 2
    end
    push!(env, nome)
    push!(env, valore)
end
env = []
env_set(env, :x, 10)
env_set(env, :y, 20)
env_set(env, :x, 11)
println(env, " ", env_get(env, :x), " ", env_get(env, :z))
```

Output:

```text
[:x, 11, :y, 20] 11 nothing
```

### 16.4 Stato mutabile condiviso

Poiché una funzione nominata non può riassegnare un globale, lo stato condiviso si tiene in
una lista (mutabile) o in una chiusura.

```julia
stato = [0]
function tick()
    stato[1] += 1
end
tick()
tick()
println(stato[1])
```

Output:

```text
2
```

### 16.5 Costruire stringhe

```julia
function ripeti(s, n)
    out = ""
    while n > 0
        out = out * s
        n -= 1
    end
    out
end
function unisci(xs, sep)
    out = ""
    i = 1
    while i <= length(xs)
        if i > 1
            out = out * sep
        end
        out = out * string(xs[i])
        i += 1
    end
    out
end
println(ripeti("ab", 3))
println(unisci([1, 2, 3], ", "))
```

Output:

```text
ababab
1, 2, 3
```

### 16.6 Stile

- Funzioni piccole con nomi chiari (in italiano, come nel resto del repository).
- Caso base esplicito in ogni ricorsione; per profondità grandi preferisci `while`.
- Cicli con contatori espliciti (`i = 1 … while i <= length(xs)`).
- Non usare `fact`, `rule`, `solve`, `struct` e le altre parole chiave di Full come nomi:
  il codice deve restare valido anche in Triad-Full.
- Scrivi `!io` sulle funzioni che stampano: Core lo ignora, Full lo richiede.

---

<a id="cap-17"></a>

## 17. Esercizi guidati

Ogni esercizio ha una soluzione verificata (aprila solo dopo averci provato). Per controllare
la tua soluzione: salvala in un file ed eseguila con `node seed/dev/triad_core.cjs`.

### Esercizio 1 — Potenza e somme

Senza usare `^`, scrivi `potenza(b, e)` ricorsiva e `somma_fino(n)` (somma `1 + … + n`) con
`while`. Stampa `potenza(3, 13)`, `potenza(2, 10)` e `somma_fino(100)`.

<details>
<summary>Soluzione</summary>

```julia
potenza(b, e) = e == 0 ? 1 : b * potenza(b, e - 1)
function somma_fino(n)
    s = 0
    i = 1
    while i <= n
        s += i
        i += 1
    end
    s
end
println(potenza(3, 13), " ", potenza(2, 10), " ", somma_fino(100))
```

Output:

```text
1594323 1024 5050
```

</details>

### Esercizio 2 — Numeri primi

Stampa la lista dei numeri primi minori di 30.

<details>
<summary>Soluzione</summary>

```julia
function primo(n)
    if n < 2
        return false
    end
    d = 2
    while d * d <= n
        if n % d == 0
            return false
        end
        d += 1
    end
    true
end
primi = []
n = 2
while n < 30
    if primo(n)
        push!(primi, n)
    end
    n += 1
end
println(primi)
```

Output:

```text
[2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
```

</details>

### Esercizio 3 — Inverti una lista

Scrivi `inverti(xs)` che restituisce una nuova lista con gli elementi in ordine inverso.

<details>
<summary>Soluzione</summary>

```julia
function inverti(xs)
    out = []
    i = length(xs)
    while i >= 1
        push!(out, xs[i])
        i -= 1
    end
    out
end
println(inverti([1, :due, "tre"]))
```

Output:

```text
[tre, :due, 1]
```

</details>

### Esercizio 4 — Ordinamento per inserzione

Ordina in loco `[5, 2, 9, 1, 7]`.

<details>
<summary>Soluzione</summary>

```julia
function ordina!(xs)
    i = 2
    while i <= length(xs)
        k = xs[i]
        j = i - 1
        while j >= 1 && xs[j] > k
            xs[j + 1] = xs[j]
            j -= 1
        end
        xs[j + 1] = k
        i += 1
    end
    xs
end
println(ordina!([5, 2, 9, 1, 7]))
```

Output:

```text
[1, 2, 5, 7, 9]
```

Il `!` finale nel nome segnala, per convenzione, una funzione che muta il suo argomento.

</details>

### Esercizio 5 — Contatore di parole

Conta le parole (separate da spazi) di `"il  linguaggio Triad "` usando `strbyte`.

<details>
<summary>Soluzione</summary>

```julia
function conta_parole(s)
    n = 0
    dentro = false
    i = 1
    while i <= strlen(s)
        spazio = strbyte(s, i) == 32
        if !spazio && !dentro
            n += 1
        end
        dentro = !spazio
        i += 1
    end
    n
end
println(conta_parole("il  linguaggio Triad "))
```

Output:

```text
3
```

</details>

### Esercizio 6 — Un mini-tokenizer

Trasforma `"12+x*3"` in una lista di token `[tipo, testo]`, con tipi `:num`, `:id`, `:op`.
È il primo passo di un interprete (vedi `selfhost/tokenizer.td`).

<details>
<summary>Soluzione</summary>

```julia
cifra(b) = b >= 48 && b <= 57
lettera(b) = (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || b == 95
function tokenizza(s)
    toks = []
    i = 1
    while i <= strlen(s)
        b = strbyte(s, i)
        if cifra(b)
            j = i
            while j <= strlen(s) && cifra(strbyte(s, j))
                j += 1
            end
            push!(toks, [:num, strsub(s, i, j - 1)])
            i = j
        elseif lettera(b)
            j = i
            while j <= strlen(s) && (lettera(strbyte(s, j)) || cifra(strbyte(s, j)))
                j += 1
            end
            push!(toks, [:id, strsub(s, i, j - 1)])
            i = j
        else
            push!(toks, [:op, strsub(s, i, i)])
            i += 1
        end
    end
    toks
end
println(tokenizza("12+x*3"))
```

Output:

```text
[[:num, 12], [:op, +], [:id, x], [:op, *], [:num, 3]]
```

</details>

### Esercizio 7 — Valutare un'espressione

Usando i token dell'esercizio 6, scrivi un valutatore a discesa ricorsiva per `+` e `*` con
precedenza, dove le variabili vengono da una lista di associazioni. Suggerimento: tieni la
posizione corrente in una lista `pos = [1]` per poterla aggiornare dalle funzioni.

<details>
<summary>Soluzione</summary>

```julia
cifra(b) = b >= 48 && b <= 57
lettera(b) = (b >= 97 && b <= 122) || b == 95
function tokenizza(s)
    toks = []
    i = 1
    while i <= strlen(s)
        b = strbyte(s, i)
        if cifra(b)
            j = i
            while j <= strlen(s) && cifra(strbyte(s, j))
                j += 1
            end
            push!(toks, [:num, strsub(s, i, j - 1)])
            i = j
        elseif lettera(b)
            j = i
            while j <= strlen(s) && lettera(strbyte(s, j))
                j += 1
            end
            push!(toks, [:id, strsub(s, i, j - 1)])
            i = j
        else
            push!(toks, [:op, strsub(s, i, i)])
            i += 1
        end
    end
    toks
end
function cerca(env, nome)
    i = 1
    while i < length(env)
        if env[i] == nome
            return env[i + 1]
        end
        i += 2
    end
    0
end
function primario(toks, pos, env)
    t = toks[pos[1]]
    pos[1] += 1
    if t[1] == :num
        Int(t[2])
    else
        cerca(env, t[2])
    end
end
function prodotto(toks, pos, env)
    v = primario(toks, pos, env)
    while pos[1] <= length(toks) && toks[pos[1]][2] == "*"
        pos[1] += 1
        v = v * primario(toks, pos, env)
    end
    v
end
function somma(toks, pos, env)
    v = prodotto(toks, pos, env)
    while pos[1] <= length(toks) && toks[pos[1]][2] == "+"
        pos[1] += 1
        v = v + prodotto(toks, pos, env)
    end
    v
end
valuta(s, env) = somma(tokenizza(s), [1], env)
println(valuta("12+x*3", ["x", 10]))
println(valuta("2*3+4*5", []))
```

Output:

```text
42
26
```

</details>

---

← [Parte I Primi passi](Parte-I-Primi-passi) · [Home](Home) · [Parte III Triad Full](Parte-III-Triad-Full) →
