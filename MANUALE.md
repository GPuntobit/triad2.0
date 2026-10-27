# Manuale di Triad 2.0

> Il manuale completo del linguaggio: lessico, valori, controllo di flusso, funzioni, dispatch,
> logica, codice come dato, errori, contratti, budget, tracce, effetti, esercizi e riferimento.

Triad Ã¨ un linguaggio di programmazione autonomo: sintassi a blocchi e tipi dichiarati, multiple
dispatch, programmazione logica integrata e codice come dato, in una sola sintassi. La sua
definizione Ã¨ una specifica normativa indipendente da qualsiasi implementazione
([`SPEC.md`](SPEC.md), standard `0.2.0`), accompagnata da una specifica eseguibile
([`SPEC-CORE.md`](SPEC-CORE.md)) e da una suite di conformitÃ  con golden verificabili
([`conformance/`](conformance/README.md)).

Questo manuale insegna il linguaggio per come Ã¨ definito dallo standard. Non Ã¨ un riassunto della
specifica: Ã¨ un percorso di studio, con spiegazioni, esempi ed esercizi.

---

## Come leggere questo manuale

### A chi Ã¨ indirizzato

Sai programmare, in qualunque linguaggio: sai cosa sono una variabile, una funzione, un ciclo, una
ricorsione. Questo manuale non spiega la programmazione in generale, spiega **Triad**.

### Due profili, una sola lingua

Lo standard definisce due profili di conformitÃ , ed Ã¨ utile saperli distinguere prima di cominciare:

| profilo | che cosa contiene | dove Ã¨ definito |
|---|---|---|
| **Triad-Core** | valori, funzioni, chiusure, controllo di flusso, liste, stringhe, I/O | [`SPEC-CORE.md`](SPEC-CORE.md) |
| **Triad-Full** | tutto: tipi dichiarati, dispatch, logica, macro, contratti, budget, tracce, effetti | [`SPEC.md`](SPEC.md) |

Triad-Core Ã¨ un **sottoinsieme** di Triad-Full: ogni programma Core Ã¨ anche un programma Full
valido e deve comportarsi allo stesso modo. Il manuale presenta i due profili **sullo stesso piano**,
per costruzione logica: ogni capitolo introduce un costrutto e dice in quale profilo esiste. Non
perchÃ© Full sia "piÃ¹ avanti", ma perchÃ© sono due facce della stessa specifica.

Dove la differenza conta, trovi due marcatori:

- **[Core]** â€” il costrutto esiste nel sottoinsieme di bootstrap;
- **[Full]** â€” il costrutto esiste solo nello standard completo.

### Convenzioni di notazione

| notazione | significa |
|---|---|
| `monospace` | codice Triad o un valore letterale |
| **Output:** | l'output esatto prodotto dal programma |
| **[Core]** / **[Full]** | il profilo in cui il costrutto esiste |
| `SPEC Â§n` | la sezione normativa corrispondente |

I blocchi di codice sono marcati con il loro livello di eseguibilitÃ :

| fence | significa |
|---|---|
| ```` ```triad ```` | programma **eseguibile oggi** con l'interprete di riferimento |
| ```` ```triad-full ```` | programma **specifica dello standard**: definito e normativo, ma non ancora eseguibile dal runtime corrente |

### Come eseguire gli esempi

Gli esempi marcati `triad` si eseguono con l'interprete di riferimento JavaScript:

```sh
node seed/dev/triad_core.cjs programma.triad
```

Il programma riceve gli argomenti in `ARGS` (lista di stringhe, senza il nome del programma) e lo
shebang `#!` in prima riga viene ignorato dal parser.

```triad
#!/usr/bin/env triad
# saluto.triad
println("ciao, " * "Triad")
println(6 * 7)
```

```sh
node seed/dev/triad_core.cjs saluto.triad uno due
```

**Output:**

```text
ciao, Triad
42
```

### Indice

**Parte I â€” Il linguaggio**

1. [Lessico](#cap-1) Â· 2. [Valori e tipi](#cap-2) Â· 3. [Variabili e assegnamento](#cap-3) Â·
4. [Operatori e precedenza](#cap-4) Â· 5. [Controllo di flusso](#cap-5) Â·
6. [Funzioni](#cap-6) Â· 7. [Tipi e multiple dispatch](#cap-7) Â·
8. [Lambda, chiusure e scope](#cap-8) Â· 9. [Liste](#cap-9) Â·
10. [Stringhe, simboli e conversioni](#cap-10) Â· 11. [Errori come dati](#cap-11) Â·
12. [Contratti](#cap-12) Â· 13. [Budget](#cap-13) Â· 14. [Tracce](#cap-14) Â·
15. [Effetti dichiarati](#cap-15) Â· 16. [Logica](#cap-16) Â·
17. [Codice come dato](#cap-17) Â· 18. [Macro](#cap-18) Â·
19. [Builtin](#cap-19) Â· 20. [Riga di comando e REPL](#cap-20) Â·
21. [Primitivi di bootstrap](#cap-21) Â· 22. [Stile e pattern idiomatici](#cap-22)

**Parte II â€” Esercizi** Â· [23. Esercizi guidati](#cap-23) Â· [24. Esercizi su Triad-Full](#cap-24)

**Parte III â€” Riferimento** Â· [25. Grammatica](#cap-25) Â· [26. Schede rapide](#cap-26) Â·
[27. Tabella degli errori](#cap-27) Â· [28. Glossario](#cap-28) Â·
[29. Cosa gira oggi](#cap-29)

**Appendici** Â· [A. Influenze dichiarate](#app-a) Â· [B. Dove guardare](#app-b)

---

<a id="parte-1"></a>

# Parte I â€” Il linguaggio

<a id="cap-1"></a>

## 1. Lessico

### 1.1 Identificatori

Un identificatore comincia con una lettera o `_`, seguito da lettere, cifre o `_`. Un `!` finale Ã¨
ammesso se non Ã¨ seguito da `=`. **[Core]**

```triad
x = 1
somma_2 = 2
_ = 3
nome_valido = 4
```

`push!`, `sort!` e simili sono nomi legittimi: la convenzione del `!` finale Ã¨ per le funzioni che
mutano il loro argomento (cap. 9).

In Triad-Full gli identificatori ammettono anche lettere non ASCII. **[Full]**

```triad-full
etÃ  = 42
```

### 1.2 Numeri

Gli interi si scrivono con cifre decimali; `_` funziona come separatore. Il segno Ã¨ un operatore
unario, non parte del letterale. **[Core]**

```triad
println(42)
println(1_000_000)
println(-5)
```

**Output:**

```text
42
1000000
-5
```

`Float` esiste solo in Triad-Full. **[Full]**

```triad-full
println(3.14)
println(1e-9)
```

### 1.3 Stringhe

Una stringa Ã¨ una sequenza di byte UTF-8 **immutabile**, tra apici doppi. Gli escape sono `\n`,
`\t`, `\"`, `\\`. **[Core]**

```triad
println("ciao\n")
println("tab:\t|")
println("virgolette: \"")
println("backslash: \\")
```

**Output:**

```text
ciao

tab:	|
virgolette: "
backslash: \
```

In Core **non esiste l'interpolazione**: `"x = $x"` stampa letteralmente `x = $x`. In Full esiste, e
si scrive `$x` per un'espressione semplice e `$(espr)` per una complessa. **[Full]**

```triad-full
x = 42
println("x = $x")
println("x + 1 = $(x + 1)")
```

### 1.4 Simboli

Un simbolo Ã¨ `:` seguito da un nome o da un operatore: `:alice`, `:+`. Due simboli sono uguali se
hanno lo stesso nome. In Triad-Full il simbolo Ã¨ anche l'atomo della logica (cap. 16). **[Core]**

```triad
println(:alice)
println(:+)
println(:ok == Symbol("ok"))
```

**Output:**

```text
alice
+
true
```

### 1.5 Commenti

`#` commenta fino a fine riga. `#= â€¦ =#` commenta su piÃ¹ righe; in Triad-Full i commenti annidati
sono ammessi. **[Core]**

```triad
#= commento
   su piÃ¹ righe =#
x = 1_000   # commento di riga
println(x)
```

**Output:**

```text
1000
```

### 1.6 Separatori e fine-riga

Un'istruzione termina con un a capo o con `;`. Gli a capo **chiudono** un'istruzione, tranne dentro
`( )`, `[ ]` e `:( )`, e tranne subito dopo un operatore binario o una virgola di `rule`.

```triad
println(1); println(2)
```

Una conseguenza pratica: **in Triad-Core ogni a capo chiude l'istruzione**. La grammatica di Core
non ha una regola di continuazione di riga: un'espressione spezzata su piÃ¹ righe non Ã¨ un
programma valido. Scrivi **una istruzione per riga** e usa `;` per separare due istruzioni.

```triad
totale = 1 + 2 + 3
println(totale);
println("seconda istruzione")
```

**Output:**

```text
6
seconda istruzione
```

> **In Triad-Full** la regola Ã¨ piÃ¹ permissiva: `SPEC Â§1` stabilisce che un a capo **non** chiude
> l'istruzione dentro `( )`, `[ ]` e `:( )`, nÃ© subito dopo un operatore binario. L'interprete di
> riferimento attuale non implementa ancora questa eccezione, quindi anche in Full la forma
> sicura resta una istruzione per riga.

### 1.7 La regola dei due punti e del punto interrogativo

`:` ha tre significati e `?` ne ha due. La specifica li chiama esplicitamente Â«il problema classico
di `:`Â» â€” Ã¨ il primo punto in cui Triad si discosta dalla sintassi che conosci.

| scrittura | significato |
|---|---|
| `1:n`, `xs[2:end]` | `:` attaccato a un valore e senza spazi â†’ **range** |
| `f(:a)`, `x = :a` | `:` non preceduto da un valore e seguito da un nome â†’ **simbolo** |
| `:( â€¦ )` | â†’ **codice quotato** |
| `c ? a : b` | `:` circondato da spazi â†’ **separatore del ternario** |

| scrittura | significato |
|---|---|
| `?x` | `?` attaccato â†’ **variabile logica** |
| `? ` | `?` con spazio dopo â†’ **ternario** |

Da qui la regola pratica: quando `:` Ã¨ ambiguo, **metti o togli gli spazi**. `xs[2:end]` Ã¨ un range;
`c ? a : b` Ã¨ un ternario perchÃ© i due spazi lo circondano.

### 1.8 Parole chiave

Lo standard definisce **29 parole chiave**:

```
function struct macro end if elseif else for in while let begin return
break continue fact rule solve quote try catch with requires ensures
true false nothing isa is
```

E **4 parole contestuali**, valide solo dopo `solve`:

```
limit depth steps trace
```

`true`, `false` e `nothing` sono valori, non parole strutturali.

### 1.9 Identificatori avanzati e convenzioni

In Triad-Core gli identificatori sono limitati all'ASCII: lettere, cifre e `_`. In Triad-Full si
ammettono anche lettere non ASCII (accentate, greche, cirilliche): `etÃ `, `Ï€`, `Î”x` sono nomi
validi. **[Full]**

```triad-full
etÃ  = 42
Ï€ = 3.14159
Î”x = 0.001
println(etÃ  + Ï€)
```

La convenzione del `!` finale (`push!`, `sort!`) indica funzioni che **mutano** il loro argomento.
La convenzione del `?` finale (`valido?`, `vuoto?`) indica predicati che restituiscono un `Bool`.
Entrambe sono solo convenzioni: il parser le accetta come parte del nome. **[Core]**

```triad
function push!(xs, v)
    # muta xs e lo restituisce
    xs
end

function vuoto?(xs)
    length(xs) == 0
end
```

Gli identificatori che coincidono con una parola chiave non sono ammessi: `function`, `end`,
`if` non possono essere usati come nomi di variabile o funzione. **[Core]**

### 1.10 Escape e stringhe avanzate

Oltre agli escape base (`\n`, `\t`, `\"`, `\\`), Triad-Full aggiunge `\r`, `\0`, `\u{â€¦}` per
code point Unicode e `\x{â€¦}` per byte esadecimali. **[Full]**

```triad-full
println("a\r\nb")          # ritorno a capo CRLF
println("unicode: \u{1F600}")  # emoji
println("hex: \x{41}")     # 'A'
```

Una stringa puÃ² contenere qualsiasi byte UTF-8 valido; un byte non valido produce un errore di
parsing. Le stringhe sono **immutabili**: ogni operazione di concatenazione crea una nuova
stringa. **[Core]**

```triad
a = "ciao"
b = a * " mondo"
println(a)        # "ciao" â€” inalterato
println(b)        # "ciao mondo"
```

**Output:**

```text
ciao
ciao mondo
```

### 1.11 Esercizi sul lessico

1. Scrivi un programma che stampi il tuo nome e la tua etÃ  su due righe, usando `\n` e
   concatenazione di stringhe.
2. Definisci un identificatore con `_` iniziale e uno con `!` finale; stampali.
3. Prova a scrivere `x = 1_000_000` e verifica che l'output sia `1000000`.
4. (Full) Scrivi una stringa con interpolazione `$x` e `$(x + 1)`.
5. (Full) Definisci il simbodo `:ok` e confrontalo con `Symbol("ok")`.

---

<a id="cap-2"></a>

## 2. Valori e tipi

### 2.1 I tipi

| tipo | valori | `typeof(v)` |
|---|---|---|
| `Int` | interi con segno a 64 bit, aritmetica con wrap | `Int` |
| `Float` | numeri in virgola mobile **[Full]** | `Float` |
| `Bool` | `true`, `false` | `Bool` |
| `String` | sequenza di byte UTF-8 immutabile | `String` |
| `Symbol` | `:nome` | `Symbol` |
| `List` | lista eterogenea mutabile, indici da 1 | `List` |
| `Function` | funzione nominata, lambda, builtin | `Function` |
| `Nothing` | `nothing` | `Nothing` |
| `Expr` | codice quotato **[Full]** | `Expr` |
| `Term`, `LVar` | termini e variabili logiche **[Full]** | â€” |
| `Solution` | `{who = :dave}` **[Full]** | â€” |
| `Err` | errore come dato **[Full]** | â€” |
| `Type` | i tipi stessi sono valori **[Full]** | â€” |
| struct utente | `Point(3.0, 4.0)` **[Full]** | `Point` |

Il set dei tipi Core Ã¨ **chiuso e piccolo**: `Int`, `Bool`, `String`, `Symbol`, `List`, `Function`,
`Nothing`. In Core non esistono `Float`, `Term`, `Solution`, `Err` come valori del linguaggio: un
errore Ã¨ una lista taggata `[Err, kind, msg]` (cap. 11) e una struct Ã¨ `[Point, x, y]`.

`typeof` restituisce il **nome del tipo come simbolo**.

```triad
xs = [1, :a, "s"]
println(typeof(1), " ", typeof("s"), " ", typeof(:a), " ", typeof(xs))
println(typeof(nothing), " ", typeof(true), " ", typeof(x -> x))
```

**Output:**

```text
Int String Symbol List
Nothing Bool Function
```

### 2.2 Gerarchia dei tipi

`Int <: Number`, `Float <: Number`, e ogni tipo Ã¨ sottotipo di `Any`. `Any` Ã¨ il supertipo usato
nelle firme quando un parametro accetta qualunque cosa. **[Full]**

```triad-full
function accetta_qualsiasi(x::Any)
    "qualunque cosa: " * string(x)
end
```

### 2.3 Struct

Una `struct` Ã¨ un record immutabile con campi tipizzati e costruttore posizionale. Il
costruttore controlla i campi; un `Int` passato a un campo `Float` viene convertito, un valore non
convertibile produce `Err(:type)`. **[Full]**

```triad-full
struct Point
    x::Float
    y::Float
end

p = Point(3, 4)
println(p.x, " ", p.y)
println(typeof(p) == Point)
println(p isa Point)
```

**Output (golden Full):**

```text
3.0 4.0
true
true
```

In Core lo stesso concetto si rappresenta con una **lista taggata**: `[Point, x, y]`, con il simbolo
del tipo in prima posizione. Ãˆ cosÃ¬ che gli interpreti di `selfhost/` rappresentano le struct Full.

```triad
punto(x, y) = [:Point, x, y]
px(p) = p[2]
py(p) = p[3]
println(punto(1, 2), " ", px(punto(1, 2)))
```

**Output:**

```text
[:Point, 1, 2] 1
```

### 2.4 Conversioni

`Int(x)`, `Float(x)`, `String(x)`, `Symbol(x)`. Il nome del tipo usato come funzione converte; il
nome di una struct usato come funzione **costruisce**. **[Full]**

```triad-full
println(Int("42") + 1)
println(Float(3))
println(Symbol("ciao"))
println(String(42))
```

`Int(s)` e `Symbol(s)` esistono anche in Core, ma solo per stringhe e simboli. **[Core]**

```triad
println(Int("41") + 1)
println(Symbol("bob"))
```

**Output:**

```text
42
bob
```

### 2.5 Asserzione di tipo

`e::T` restituisce `e` se Ã¨ di tipo `T`, altrimenti produce `Err(:type)`. **[Full]**

```triad-full
x = 3
println(x::Int)
println(iserr(x::String))
```

### 2.6 Il vincolo del dichiarato

`x::T = e` â€” e un parametro `x::T` â€” **fissa** il tipo di quel nome nell'ambiente in cui nasce. Gli
assegnamenti successivi sono controllati e convertiti contro `T`. Una nuova dichiarazione
`x::U = â€¦` sostituisce il vincolo; un nome non dichiarato con tipo resta libero; una rilegatura in
un ambiente interno (`let x = 2.5`) non eredita il vincolo esterno. **[Full]**

```triad-full
x::Int = 5
x = 6            # bene
x = 5.5          # Err(:type)

y::Float = 1.0
y = 2            # 2.0: conversione Int -> Float

s = "a"
s = 3            # bene: s non Ã¨ dichiarato con un tipo
```

### 2.7 Le condizioni accettano solo `Bool`

Non esiste il concetto di "truthiness". `if 1` Ã¨ un errore, non `true`. Questo vale per `if`,
`while`, `&&`, `||`, `!`, il ternario e i filtri delle comprehension. **[Core]**

```triad
println(1 < 2 && 2 < 3)
x = 3
println(x > 2 ? "grande" : "piccolo")
```

**Output:**

```text
true
grande
```

### 2.8 Come stampa un valore

`print` e `println` concatenano gli argomenti **senza separatori**; `println` aggiunge un a capo.

| valore | come viene stampato |
|---|---|
| `Int` | decimale |
| `Bool` | `true` / `false` |
| `String` | cosÃ¬ com'Ã¨ |
| `Nothing` | `nothing` |
| `Symbol` | **senza** `:` se passato direttamente, **con** `:` dentro una lista |
| `List` | `[a, b]`; le stringhe dentro non hanno virgolette |
| `Function` | `#lambda(x)` |

```triad
xs = [1, :a, "s", true, nothing, [2, 3]]
println(xs)
println(:alice)
print("senza ", "a capo")
println()
```

**Output:**

```text
[1, :a, s, true, nothing, [2, 3]]
alice
senza a capo
```

L'uguaglianza confronta numeri, stringhe e simboli **per valore**, le liste **elemento per
elemento** (anche annidate), le funzioni **per identitÃ **. **[Core]**

```triad
println([1, [2, [3]]] == [1, [2, [3]]])
println("ab" == "a" * "b", " ", :a == :a, " ", 1 == 2)
```

**Output:**

```text
true
true true false
```

---

<a id="cap-3"></a>

## 3. Variabili e assegnamento

`nome = espr` lega o aggiorna un nome. L'assegnamento **Ã¨ un'espressione** e vale il valore
assegnato. `+=`, `-=`, `*=` aggiornano una variabile esistente e valutano il lato sinistro una
volta sola. Usare un nome mai assegnato Ã¨ un errore di esecuzione. **[Core]**

```triad
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

**Output:**

```text
43 50 186
24
```

Non esistono dichiarazioni: le variabili sono dinamiche. Le regole di **visibilitÃ ** si vedono nel
capitolo 8.

---

<a id="cap-4"></a>

## 4. Operatori e precedenza

Il parser Ã¨ un **Pratt** con dodici livelli. Dalla precedenza piÃ¹ bassa alla piÃ¹ alta:

| livello | operatori | associativitÃ  |
|---|---|---|
| 1 | `=` `+=` `-=` `*=` | destra |
| 2 | `x -> e`, `(a, b) -> e`, `c ? a : b` | destra |
| 3 | `\|\|` | sinistra, cortocircuito |
| 4 | `&&` | sinistra, cortocircuito |
| 5 | `==` `!=` `<` `<=` `>` `>=` `in` `isa` `is` | sinistra |
| 6 | `a:b` | range, senza spazi |
| 7 | `+` `-` | sinistra |
| 8 | `*` `/` `%` | sinistra |
| 9 | `-x` `!x` `+x` `$x` | prefissi |
| 10 | `^` | **destra** |
| 11 | `e::T` | asserzione di tipo |
| 12 | `f(args)` `xs[i]` `a.campo` | postfissi, senza spazio prima di `(` e `[` |

I livelli 6, 8 (la divisione), 9 (`$x`), 11 (`::`) e alcuni operatori di confronto esistono solo in
Triad-Full.

### 4.1 Aritmetica intera

- `+ - * ^` su `Int` con **wrap a 64 bit** (complemento a due);
- `%` Ã¨ il **resto con il segno del dividendo**, come `rem` di Julia: `-7 % 3 == -1`;
- `^` con esponente negativo Ã¨ un errore; `%` per zero Ã¨ un errore;
- **`/` non esiste in Core**: la divisione Ã¨ di Triad-Full.

```triad
println(2 + 3 * 4, " ", (2 + 3) * 4, " ", 2 ^ 3 ^ 2)
println(7 % 3, " ", -7 % 3, " ", 10 % 4)
println(9223372036854775807 + 1)
```

**Output:**

```text
14 20 512
1 -1 2
-9223372036854775808
```

Nota `2 ^ 3 ^ 2 == 512`: l'esponente Ã¨ associativo a destra, come in matematica.

### 4.2 Logica e confronti

`&&` e `||` cortocircuitano. I confronti **non** si concatenano: `1 < 2 < 3` Ã¨ un errore (si
confronta `Bool < Int`); scrivi `1 < 2 && 2 < 3`. **[Core]**

```triad
println(!false, " ", true && false, " ", false || true)
println(1 < 2 && 2 < 3)
```

**Output:**

```text
true false true
true
```

---

<a id="cap-5"></a>

## 5. Controllo di flusso

In Triad **tutto Ã¨ un'espressione**: `if`, `while`, `let`, `begin` hanno un valore, quello
dell'ultima istruzione eseguita (`nothing` se non ce n'Ã¨).

### 5.1 `if` / `elseif` / `else` **[Core]**

```triad
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

**Output:**

```text
negativo zero positivo
si
```

Il ternario `c ? a : b` Ã¨ la forma breve di `if` e ha la stessa precedenza del `->`. **[Core]**

### 5.2 `while`, `break`, `continue` **[Core]**

`break` e `continue` agiscono sul ciclo **piÃ¹ interno**.

```triad
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

**Output:**

```text
25
fine
```

In Core **non esiste `for`**: si itera con un contatore e `while`. In Full `for` esiste (cap. 5.6).

### 5.3 `let` e `begin` **[Core]**

`let` introduce un nuovo scope con legami locali; `begin â€¦ end` raggruppa istruzioni **senza**
creare legami nuovi.

```triad
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

**Output:**

```text
20
10
1
42
```

### 5.4 `for` e i range **[Full]**

`for` itera su una lista, un range o un risultato di `solve`. `a:b` produce il range da `a` a `b`
inclusi.

```triad-full
s = 0
for i in 1:10
    s += i
end
println(s)

xs = [1, 2, 3]
println(xs[end])
println(xs[2:end])
```

**Output (golden Full):**

```text
55
3
[2, 3]
```

`end` dentro un indicatore Ã¨ l'ultimo elemento. La destrutturazione nel `for` Ã¨ trattata nel
capitolo 24.

### 5.5 Le comprehension **[Full]**

La comprehension `[e for x in xs]` costruisce una lista; con `if` aggiunge un filtro.

```triad-full
println([x^2 for x in 1:4])
println([x^2 for x in 1:4 if x > 2])
```

**Output (golden Full):**

```text
[1, 4, 9, 16]
[9, 16]
```

### 5.6 `try` / `catch` **[Full]**

In Full l'errore Ã¨ un **valore**, quindi `try` ha due forme: con `catch` il ramo gestito produce il
valore dell'espressione; senza `catch`, l'errore **diventa** il valore dell'espressione.

```triad-full
e = try div(1, 0) end
println(iserr(e), " ", e.kind)

r = try div(1, 0) catch err; 0 end
println(r)
```

**Output (golden Full):**

```text
true domain
0
```

---

<a id="cap-6"></a>

## 6. Funzioni

### 6.1 Tre forme di definizione **[Core]**

```triad
# forma breve: il corpo Ã¨ un'espressione
quadrato(x) = x * x

# forma blocco: il valore Ã¨ quello dell'ultima espressione
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

**Output:**

```text
16 8 42
```

### 6.2 `return`, ricorsione, aritÃ 

`return e` esce subito dalla funzione; `return` da solo restituisce `nothing`. Una funzione nominata
Ã¨ visibile nel proprio corpo, quindi la ricorsione diretta funziona. Il numero di argomenti deve
coincidere con i parametri. **[Core]**

```triad
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

**Output:**

```text
grande piccola
3628800 610 6
```

### 6.3 Funzioni di ordine superiore

Le funzioni sono valori di prima classe: si passano, si restituiscono, si compongono. In Core
`map`, `filter` e `reduce` **non esistono**: si scrivono a mano (cap. 22.1). In Full sono builtin.
**[Core]**

```triad
function applica_tutti(f, xs)
    out = []
    i = 1
    while i <= length(xs)
        push!(out, f(xs[i]))
        i += 1
    end
    out
end
println(applica_tutti(x -> x * x, [1, 2, 3]))
```

**Output:**

```text
[1, 4, 9]
```

In Full, `reduce(+, xs)` e `map(sq, xs)` funzionano perchÃ© anche gli **operatori sono funzioni**.

### 6.4 L'annotazione di effetto `!io`

Una funzione che stampa deve dichiarare `!io` nella firma. Core **accetta l'annotazione e la
ignora**: scriverla rende il codice giÃ  pronto per Full. **[Core]**

```triad
function mostra() !io
    println("hello from block")
    20 + 22
end
println(mostra())
```

**Output:**

```text
hello from block
42
```

---

<a id="cap-7"></a>

## 7. Tipi e multiple dispatch

Una funzione generica Ã¨ un insieme di metodi. Ridefinire la stessa firma sostituisce il metodo
precedente. Tra i metodi applicabili (stessa aritÃ , ogni argomento sottotipo del parametro) vince
il **piÃ¹ specifico**. **[Full]**

```triad-full
area(n::Number) = :number
area(n::Int) = :int

println(area(1))
println(area(1.5))
```

**Output (golden Full):**

```text
int
number
```

Un metodo A Ã¨ piÃ¹ specifico di B se ogni suo parametro Ã¨ sottotipo del corrispondente parametro di B
e le firme differiscono.

- Se nessun metodo Ã¨ applicabile: `Err(:method)`.
- Se piÃ¹ metodi sono massimali: `Err(:ambiguous)`.
- Se il nome Ã¨ anche un builtin (per esempio `+` sui numeri), si usa il builtin.

Gli operatori si estendono come funzioni, ridefinendoli:

```triad-full
struct Point
    x::Float
    y::Float
end

function +(a::Point, b::Point)
    Point(a.x + b.x, a.y + b.y)
end

p = Point(1, 2) + Point(3, 4)
println(p.x, " ", p.y)
```

**Output (golden Full):**

```text
4.0 6.0
```

### 7.1 Il tipo di ritorno

`::R` Ã¨ controllato all'uscita, con la conversione `Int -> Float`. Se il valore non Ã¨ conforme:
`Err(:type)`. **[Full]**

```triad-full
function metÃ (n::Number)::Float
    n / 2
end
println(metÃ (3))
```

**Output (golden Full):**

```text
1.5
```

### 7.2 Funzioni locali

Una `function` definita dentro un'altra funzione Ã¨ una **chiusura locale**, senza dispatch. **[Full]**

```triad-full
function esterno(x)
    function interno(y)
        y * 2
    end
    interno(x) + 1
end
println(esterno(5))
```

---

<a id="cap-8"></a>

## 8. Lambda, chiusure e scope

### 8.1 Lambda **[Core]**

```triad
doppio = x -> x * 2
somma = (a, b) -> a + b
applica = f -> f(3)
println(doppio(5), " ", somma(1, 2), " ", applica(x -> x * x))
```

**Output:**

```text
10 3 9
```

Una lambda con corpo a piÃ¹ istruzioni si scrive con `begin â€¦ end` o con `function (â€¦) â€¦ end`. Le
lambda senza parametri (`() -> â€¦`) **non** sono supportate: usa `function () â€¦ end`.

### 8.2 Chiusure

Una lambda cattura l'ambiente in cui Ã¨ creata. Secondo `SPEC-CORE Â§5` le variabili catturate sono
**condivise**: le mutazioni sono visibili. **[Core]**

```triad
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

**Output:**

```text
15 105
15
```

> **Attenzione.** Il seed Windows cattura **per valore** e copre solo l'ultimo legame del frame: un
> accumulatore come `contatore` puÃ² non funzionare sul seed. L'interprete JS e la specifica usano il
> modello condiviso.

### 8.3 Le regole di scope

1. `function`, lambda, `let`, `while`, `for` e le comprehension introducono **ambienti**; un nome Ã¨
   visibile nell'ambiente in cui Ã¨ legato e in quelli interni (scope lessicale), mai in quelli
   esterni.
2. **Dentro una funzione nominata** l'assegnamento lega nel frame locale: una funzione **non
   modifica i globali**.
3. **Dentro una lambda** l'assegnamento a un nome giÃ  legato fuori aggiorna quel legame.
4. **Al top level** i cicli possono aggiornare i globali.
5. `let x = â€¦` crea un nuovo `x`: assegnare `x` dentro il `let` non tocca l'`x` esterno.

```triad
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

**Output:**

```text
2 1
0
```

Per far uscire un risultato da una funzione, restituiscilo â€” oppure usa una lista, che Ã¨ mutabile.

---

<a id="cap-9"></a>

## 9. Liste

Una lista Ã¨ eterogenea, annidabile e **mutabile**. Gli indici partono da **1**. **[Core]**

```triad
xs = [1, 2, 3]
println(xs[1], " ", length(xs))
push!(xs, 4)
xs[1] += 100
println(xs)
alias = xs
push!(alias, 5)
println(xs)
```

**Output:**

```text
1 3
[101, 2, 3, 4]
[101, 2, 3, 4, 5]
```

`push!` **muta** la lista e la restituisce. Le liste sono riferimenti: due nomi possono indicare la
stessa lista, come si vede sopra.

La somma degli elementi con un ciclo esplicito:

```triad
xs = [101, 2, 3, 4, 5]
tot = 0
i = 1
while i <= length(xs)
    tot += xs[i]
    i += 1
end
println(tot)
```

**Output:**

```text
115
```

In Full esistono anche `reverse`, `sort`, `sum`, `first`, `last`, `rest`, `pop!`, `append!`, `vcat`,
`collect` e l'operatore `x in xs`.

---

<a id="cap-10"></a>

## 10. Stringhe, simboli e conversioni

| operazione | significato |
|---|---|
| `a * b` | concatenazione di stringhe |
| `length(s)` | numero di **byte** UTF-8 (`length("Ã©") == 2`) |
| `string(x)` | rappresentazione testuale di qualsiasi valore (`string(:a) == "a"`, `string([1, 2]) == "[1, 2]"`) |
| `Int(s)` | da stringa a intero (`Int("42") == 42`); da `Bool`: `0`/`1` |
| `Symbol(s)` | da stringa a simbolo (`Symbol("ciao") == :ciao`) |
| `typeof(x)` | tipo come simbolo |

```triad
nome = "Triad"
saluto = "ciao " * nome
println(saluto, " (", length(saluto), " byte)")
println("risposta: " * string(40 + 2))
println(Int("41") + 1, " ", Symbol("bob"), " ", string(true))
```

**Output:**

```text
ciao Triad (10 byte)
risposta: 42
42 bob true
```

Per accedere ai singoli byte di una stringa servono i primitivi di bootstrap (cap. 21).

---

<a id="cap-11"></a>

## 11. Errori come dati

Questa Ã¨ una delle idee portanti di Triad: **l'errore Ã¨ un valore**, non un'eccezione che
 interrompe il programma.

### 11.1 La forma `Err`

Un errore Ã¨ un valore `Err` con tre campi:

- `kind::Symbol` â€” la categoria, su cui si puÃ² fare dispatch;
- `msg::String` â€” il messaggio;
- `data` â€” un valore qualsiasi, spesso un record `Info(...)` con i dettagli.

**[Full]**

```triad-full
e = err(:mio, "ops", 42)
println(e.kind, " ", e.msg)
println(iserr(e))
```

### 11.2 Produrre e propagare

| costrutto | effetto |
|---|---|
| `err(:kind, "msg"[, data])` | costruisce un `Err` **senza** sollevarlo |
| `throw(e)`, `error("msg")` | solleva (`error` produce `Err(:error, â€¦)`) |
| `try b catch e h end` | se `b` solleva, `e` Ã¨ legato all'`Err` e si valuta `h` |
| `try b end` | **l'errore diventa il valore** dell'espressione |
| `iserr(x)` | controlla se `x` Ã¨ un `Err` |

Tutti i fallimenti del linguaggio â€” divisione intera per zero, `sqrt(-1.0)`, indici fuori range,
nessun metodo applicabile â€” arrivano come `Err` e **mai** come fallimenti fatali. **[Full]**

```triad-full
e = try div(1, 0) end
println(e.kind)
println(iserr(e))

r = try div(10, 2) catch err; 0 end
println(r)
```

**Output (golden Full):**

```text
domain
true
5
```

### 11.3 Le categorie di errore

| kind | quando |
|---|---|
| `:syntax` | errore di parse; `data` contiene `line`, `col` e `incomplete` |
| `:undef` | nome, funzione, macro o predicato non definito |
| `:type` | tipo sbagliato (campi, ritorno, `::`, condizioni non `Bool`) |
| `:method` | nessun metodo applicabile; `data.types` contiene i tipi degli argomenti |
| `:ambiguous` | piÃ¹ metodi ugualmente specifici |
| `:field`, `:bounds`, `:domain` | campo inesistente, indice fuori range, errore matematico |
| `:instantiation` | variabile logica non legata dove serve un valore |
| `:contract` | `requires`/`ensures` violata (cap. 12) |
| `:budget` | passi esauriti (cap. 13) |
| `:effect` | effetto non dichiarato (cap. 15) |
| `:host` | qualsiasi altro errore dell'interprete |

Un errore non gestito al top level interrompe il programma: il messaggio riporta la riga
dell'istruzione (`riga 12: â€¦`) e il codice di uscita Ã¨ `1`.

### 11.4 In Core: errori come liste taggate

Core non ha `try`/`catch` nÃ© il tipo `Err`: un errore **termina il processo** con exit code `1` e un
messaggio diagnostico su stderr. Ma il pattern "errore come dato" si puÃ² giÃ  scrivere, ed Ã¨
esattamente cosÃ¬ che S1 implementerÃ  Full. La convenzione Ã¨ `[:Err, kind, msg]`. **[Core]**

```triad
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

**Output:**

```text
errore domain: divisione per zero
3
```

Nota che `&&` cortocircuita: `v[1]` viene valutato solo se `v` Ã¨ una lista di 3 elementi.

---

<a id="cap-12"></a>

## 12. Contratti

Un contratto Ã¨ una precondizione (`requires`) o una postcondizione (`ensures`) dichiarata nel corpo
di una funzione. **[Full]**

```triad-full
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end
```

- `requires c` viene controllata **nel punto in cui compare**: per convenzione all'inizio del corpo.
- `ensures c` viene registrata e controllata all'uscita della funzione, con `result` legato al
  valore restituito, **dopo** il controllo del tipo di ritorno.
- Una violazione produce
  `Err(:contract, "requires violata in safe_div: b != 0", Info(fn, clause, cond[, result]))`.
  `cond` contiene il **codice** della condizione: Ã¨ un dato, si puÃ² ispezionare.
- Le condizioni sono **pure**: un effetto dentro un contratto dÃ  `Err(:effect)`.
- Al top level `requires c` funziona come un'asserzione.
- `ensures` fuori da una `function` Ã¨ un `Err(:syntax)`.

```triad-full
println(safe_div(6, 3))

e = try safe_div(1, 0) end
println(e.kind)
println(e.data.clause)
println(e.data.fn)
```

**Output (golden Full):**

```text
2.0
contract
requires
safe_div
```

---

<a id="cap-13"></a>

## 13. Budget

Un **budget** limita quanti passi il programma puÃ² consumare. Un passo Ã¨ una chiamata, un'iterazione
di ciclo o un passo di risoluzione. Quando il budget si esaurisce, **il valore del `with` Ã¨
`Err(:budget)`**: il programma non si blocca e non viene interrotto. **[Full]**

```triad-full
r = with budget(steps = 10_000)
    while true end
end
println(r.kind)
```

**Output (golden Full):**

```text
budget
```

I budget si annidano e vale il piÃ¹ stretto. Un `with` converte in valore **solo** l'esaurimento del
proprio budget, mentre quello di un budget esterno continua a propagarsi. `solve â€¦ steps N` Ã¨ il
budget specifico di una query.

Il motore logico usa uno stack esplicito: la ricorsione infinita, anche sinistra, finisce in
`Err(:budget)` e **non** in uno stack overflow.

---

<a id="cap-14"></a>

## 14. Tracce

La traccia di un calcolo Ã¨ un **valore**, non output stampato. **[Full]**

```triad-full
fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)

t = with trace
    fib(3)
end
println(t.result)
println(length(t.trace))
```

**Output (golden Full):**

```text
2
10
```

`fib(3)` effettua 5 chiamate (`fib(3)`, `fib(2)`, `fib(1)`, `fib(0)`, `fib(1)`): la traccia registra
**due eventi per ogni chiamata**, `:call` e `:exit`, quindi 10 eventi. Per `fib(5)` sono 15 chiamate
e 30 eventi â€” Ã¨ il valore atteso dal caso di conformance `garanzie_core`.

`with trace â€¦ end` restituisce `Traced(result, trace)` con gli eventi `:call` e `:exit` di ogni
funzione generica chiamata nel corpo. `solve â€¦ trace` restituisce `Traced(result, trace)` dove
`result` Ã¨ la lista delle soluzioni e gli eventi sono le porte del modello a scatole di Byrd
(`call`, `exit`, `redo`, `fail`) piÃ¹ `depth`, quando un ramo viene tagliato da `depth`.

Gli eventi sono record: si filtrano e si contano come ogni altro valore.

### Glossario degli eventi di traccia (porte di Byrd)

Quando si usa `solve â€¦ trace`, ogni passo della ricerca produce un evento che registra **a che
riferimento** (quale goal, quale clausola, quali variabili logiche) si sta lavorando. Le quattro
porte del modello a scatole di Byrd sono:

| porta | quando si verifica | significato |
|---|---|---|
| `:call` | si entra in un goal | inizio della valutazione della clausola candidata |
| `:exit` | unificazione **riuscita** | il goal Ã¨ dimostrato: Ã¨ il "success" della ricerca |
| `:redo` | backtracking | si torna indietro per cercare un'altra soluzione |
| `:fail` | nessuna clausola applicabile | il goal **fallisce**: nessuna soluzione per quel ramo |

Note importanti:

- **"success" e "fail" non sono esiti generici**: sono le porte `:exit` e `:fail` della traccia,
  riferite al goal/clausola in corso. Il fallimento di un goal non Ã¨ un'eccezione: si manifesta
  come **lista di soluzioni vuota** nel `result` di `Traced(result, trace)`.
- **`depth`** appare come evento aggiuntivo quando un ramo viene tagliato dal limite di profonditÃ 
  (`solve â€¦ depth N`), segnalando che la ricerca Ã¨ stata interrotta prima di un `:exit`/`:fail`.
- Gli eventi sono **record ordinari**: si filtrano (`[e for e in t.trace if e.port == :fail]`),
  si contano (`length`), si ispezionano (`e.args`, `e.depth`) come ogni altro valore Triad.
- Il riferimento di ogni evento Ã¨ il **goal corrente e le variabili logiche** (`?x`, `?y`, â€¦)
  coinvolte in quel passo: leggendo la traccia si ricostruisce *quale* alternativa Ã¨ stata
  provata e *perchÃ©* Ã¨ fallita.

```triad-full
# Conta i fallimenti di una ricerca
t = solve path(:a, :c) trace
fails = [e for e in t.trace if e.port == :fail]
println(length(fails))
```

```triad-full
fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)
t = with trace
    fib(3)
end
println([e.args for e in t.trace if e.port == :call])
```

**Output (golden Full):**

```text
[[3], [2], [1], [0], [1]]
```

---

<a id="cap-15"></a>

## 15. Effetti dichiarati

Le funzioni sono **pure per default**. Gli effetti si dichiarano nella firma, dopo i parametri. **[Full]**

```triad-full
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

Il controllo Ã¨ **dinamico**. Una funzione viene eseguita solo con gli effetti che dichiara, e solo
se il chiamante li permette. Se una funzione pura chiama `println`, o chiama una funzione `!io`, si
ottiene `Err(:effect)`; `data` contiene `fn`, `caller` e `missing`.

- Il top level permette tutti gli effetti.
- Le lambda ereditano gli effetti del contesto in cui vengono eseguite.
- Macro e contratti sono puri.
- Leggere la knowledge base (`solve`, chiamare un predicato) Ã¨ puro.
- La mutazione locale di dati (`push!` su una lista, assegnamento a variabili locali) **non** Ã¨ un
  effetto: modifica solo valori raggiungibili dall'ambiente locale.

```triad-full
function rumorosa()
    println("faccio rumore")
end

function tranquilla()
    rumorosa()
end

e = try tranquilla() end
println(e.kind)
```

**Output (golden Full):**

```text
effect
```

---

<a id="cap-16"></a>

## 16. Logica

Triad integra la programmazione logica **nella sintassi a blocchi**: i fatti e le regole sono
costrutti di primo livello, non un embedded language. **[Full]**

### 16.1 Fatti, regole, termini

```triad-full
fact parent(:tom, :bob)
fact parent(:bob, :jim)

rule ancestor(?a, ?d) :- parent(?a, ?d)
rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)
```

Dentro un termine:

- `:atomo` Ã¨ un simbolo; `?x` Ã¨ una variabile logica; numeri, stringhe e liste sono se stessi;
- `f(t1, t2)` Ã¨ un termine composto. Anche `?x + 1` Ã¨ un termine (`+(?x, 1)`) e **non viene
  valutato**;
- un **nome nudo** Ã¨ un valore dell'ambiente corrente, letto al momento in cui viene eseguito `fact`,
  `rule` o `solve`: `chi = :bob; solve parent(chi, ?c)`;
- `$(espr)` inserisce esplicitamente un valore calcolato: `fact eta(:bob, $(2026 - 1975))`;
- `[a, b]` e `[?h | ?t]` sono liste e pattern su liste;
- il nome di una struct con argomenti, come `Point(?x, ?y)`, unifica con le istanze di quella struct.

Le variabili di una clausola vengono **rinominate a ogni uso** (standardizzazione a parte).
L'unificazione fa l'**occurs-check**: `solve ?x = f(?x)` non ha soluzioni.

### 16.2 I goal

| goal | significato |
|---|---|
| `p(tâ€¦)` | predicato della knowledge base, risolto con SLD e backtracking, clausole in ordine |
| `g1 && g2`, `(g1, g2)` | congiunzione; nelle `rule` anche con `,` |
| `g1 \|\| g2` | disgiunzione |
| `!g`, `not(g)` | negazione per fallimento |
| `not(b)` *fuori* da un goal | Ã¨ una funzione: nega un `Bool` (`not(true) == false`) |
| `a = b` | unificazione |
| `?y is espr` | valuta `espr` (le variabili devono essere legate) e unifica con `?y` |
| `a < b`, `==`, `!=`, `<=`, `>`, `>=` | confronto tra valori, valutati |
| `f(tâ€¦)` con `f` funzione Triad | chiama la funzione con gli argomenti valutati; deve restituire `Bool` |
| `true`, `false` | successo, fallimento |

Un predicato senza clausole con quell'aritÃ , che non sia nemmeno una funzione, dÃ 
`Err(:undef, "predicato sconosciuto: p/2")`. Una variabile non legata dentro un'espressione dÃ 
`Err(:instantiation)`.

### 16.3 `solve` Ã¨ un valore

`solve` **restituisce una lista** di `Solution`. Non stampa nulla: Ã¨ un valore come un altro.

```triad-full
fact parent(:alice, :bob)
fact parent(:alice, :carol)
fact parent(:bob, :dave)

rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

sols = solve grandparent(:alice, ?who) limit 5
println(sols)
println(sols[1].who)
println(length(sols))
```

**Output (golden Full):**

```text
[{who = :dave}]
dave
1
```

Ogni soluzione lega le variabili della query **non anonime**, nell'ordine in cui compaiono. Le
variabili rimaste libere restano `?x#n`. `vars(sol)` restituisce i nomi legati.

Opzioni di `solve`:

- `limit n` â€” al massimo `n` soluzioni;
- `depth d` â€” i rami piÃ¹ profondi di `d` vengono tagliati (falliscono);
- `steps s` â€” al massimo `s` passi di risoluzione, altrimenti `Err(:budget)`; il default Ã¨
  `1 000 000`;
- `trace` â€” vedi cap. 14.

### 16.4 Un predicato usato come funzione

Chiamare un predicato dove ci si aspetta un valore restituisce un `Bool`: dice se il goal Ã¨
dimostrabile.

```triad-full
if grandparent(:alice, :dave)
    println("alice Ã¨ nonna di dave")
end
```

### 16.5 Esempi

Percorso con costo:

```triad-full
fact edge(:a, :b, 2)
fact edge(:b, :c, 3)
rule path(?x, ?y, ?c) :- edge(?x, ?y, ?c)
rule path(?x, ?y, ?c) :- edge(?x, ?z, ?c1), path(?z, ?y, ?c2), ?c is ?c1 + ?c2
println((solve path(:a, :c, ?costo))[1].costo)
```

**Output (golden Full):**

```text
5
```

Append in stile Prolog:

```triad-full
rule app([], ?l, ?l)
rule app([?h | ?t], ?l, [?h | ?r]) :- app(?t, ?l, ?r)
println((solve app([1, 2], [3], ?r))[1].r)
println(length(solve app(?a, ?b, [1, 2, 3])))
```

**Output (golden Full):**

```text
[1, 2, 3]
4
```

Negazione per fallimento:

```triad-full
fact parent(:tom, :bob)
persone = [:tom, :bob]
foglie = filter(p -> !parent(p, ?_), persone)
println(foglie)
```

**Output (golden Full):**

```text
[:bob]
```

---

<a id="cap-17"></a>

## 17. Codice come dato

Il parser produce **un solo tipo di nodo**, `Node(head, args)`. Ãˆ lo stesso albero che il kernel
esegue, che `:( â€¦ )` restituisce come valore e che `triad --tree` stampa come S-expression.
**[Full]**

| sintassi | nodo |
|---|---|
| `f(a, b)`, `a + b` | `(call f a b)`, `(call + a b)` |
| `a && b`, `a \|\| b` | `(and a b)`, `(or a b)` |
| `x = e` | `(assign x e)` |
| `:alice` | `(sym alice)` |
| `a.x`, `xs[i]` | `(dot a x)`, `(index xs i)` |
| `[a, b]`, `[h \| t]` | `(list a b)`, `(cons (list h) t)` |
| `[e for x in xs if c]` | `(comprehension e x xs c)` |
| `x -> e` | `(lambda (tuple x) e)` |
| `x::T` | `(typed x T)` |
| `"a $x"` | `(string "a " x)` |
| `if c a else b end`, `c ? a : b` | `(if c (block a) (block b))` |
| `while`, `for`, `let`, `begin` | `(while c body)`, `(for x iter body)`, `(let (tuple â€¦) body)`, `(block â€¦)` |
| `function f(a::T)::R !io â€¦ end` | `(function f (tuple (typed a T)) R (tuple io) body)` |
| `struct P; x::Float; end` | `(struct P (tuple (typed x Float)))` |
| `macro m(a) â€¦ end`, `@m(e)` | `(macro m (tuple a) body)`, `(macrocall m e)` |
| `:(e)`, `quote â€¦ end`, `$e` | `(quasi e)`, `(quasi (block â€¦))`, `(unquote e)` |
| `fact t`, `rule h :- g1, g2` | `(fact t)`, `(rule h g1 g2)` |
| `solve g limit 5 trace` | `(solve g (tuple (assign limit 5) (assign trace true)))` |
| `try b catch e h end` | `(try b e h)` |
| `with budget(steps = N), trace â€¦ end` | `(with (tuple (call budget (assign steps N)) trace) body)` |

### 17.1 Quote, unquote, eval

```triad-full
c = :(a.x + f(b, 2))
println(c.head)
println(sexpr(c))

n = 7
quadrato = :($n * $n)
println(eval(quadrato))
```

**Output (golden Full):**

```text
call
(call + (dot a x) (call f b 2))
49
```

Dentro un quote, `$x` e `$(e)` inseriscono il **valore** di un'espressione: se Ã¨ codice viene
innestato, se Ã¨ un numero o una lista diventa una costante, se Ã¨ un Symbol diventa un identificatore.
`eval(c)` esegue codice **nello scope globale**. Gli altri builtin del gruppo "codice" sono `parse`,
`unparse`, `sexpr`, `Expr` e `gensym`.

---

<a id="cap-18"></a>

## 18. Macro

Una macro riceve gli argomenti **come codice**, non valutati, e restituisce codice, che viene poi
eseguito al posto della chiamata `@nome(...)` nello scope del chiamante. **[Full]**

```triad-full
macro unless(c, body)
    :(if !$c; $body; end)
end

macro swap(a, b)
    t = gensym(:tmp)
    quote
        $t = $a
        $a = $b
        $b = $t
    end
end

x = 1
y = 2
@swap(x, y)
println(x, " ", y)
```

**Output (golden Full):**

```text
2 1
```

L'espansione Ã¨ **pura** (Â§15) e **non Ã¨ igienica**: per i nomi temporanei si usa `gensym()`.

### 18.1 Codice che genera codice

```triad-full
function poly(coeffs)
    acc = :(0)
    i = 0
    for c in coeffs
        acc = :($acc + $c * x ^ $i)
        i += 1
    end
    acc
end

p = poly([1, 2, 3])
x = 2
println(eval(p))
```

**Output (golden Full):**

```text
17
```

---

<a id="cap-19"></a>

## 19. Builtin

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

**Il sottoinsieme di Core** Ã¨ piÃ¹ piccolo: `+ - * % ^`, i confronti, `&& || !`, `length`, `push!`,
l'indicizzazione `xs[i]`, `*` sulle stringhe, `Int`, `string`, `Symbol`, `print`, `println`, `typeof`
(`SPEC-CORE Â§7`). In Core `map`, `filter`, `reduce`, `sum`, `sort`, `div` e `mod` **non esistono**:
si scrivono a mano (cap. 22.1).

---

<a id="cap-20"></a>

## 20. Riga di comando e REPL

L'interfaccia di `triad` Ã¨ normativa (`SPEC Â§14`):

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

- L'estensione `.triad`/`.td` si puÃ² omettere; lo shebang `#!` Ã¨ ignorato.
- Il programma vede gli argomenti in `ARGS`, lista di stringhe, senza il nome del programma.
- Codici di uscita: `0` successo, `1` errore non gestito (su stderr), `2` uso non valido.

### 20.1 Il REPL

Il REPL Ã¨ in stile Prolog:

```
triad> 1 + 2
3
triad> ?- ancestor(:tom, ?d)
?d = :bob ;
?d = :liz.
triad> parent(:jim, ?x)
false.
```

- I blocchi restano aperti finchÃ© non sono chiusi da `end`.
- `?- goal` (il `.` finale Ã¨ facoltativo) esegue una query con le opzioni di `solve`: `limit`,
  `depth`, `steps`, `trace`.
- Un'istruzione che Ã¨ un goal su un predicato della knowledge base Ã¨ trattata come query.
- Dopo ogni soluzione: `;`, `n` o spazio per la successiva, `a` per tutte le rimanenti, invio o `.`
  per fermarsi. `false.` significa nessun'altra soluzione.
- Comandi: `:load FILEâ€¦` (`:l`), `:reload` (`:r`), `:listing [nome]` (`:ls`), `:tree CODICE`,
  `:reset`, `:help` (`:h`), `:quit` (`:q`, `halt`, Ctrl-D).
- Ctrl-C interrompe il calcolo in corso; un errore non gestito Ã¨ stampato e il REPL continua.

---

<a id="cap-21"></a>

## 21. Primitivi di bootstrap

Cinque primitive servono a S1 per leggere e analizzare il sorgente Triad. **Non fanno parte di
Triad-Full** (`SPEC-CORE Â§8`): usale solo nel codice di bootstrap.

| primitiva | semantica |
|---|---|
| `readfile(path)` | contenuto del file come `String`; errore se non leggibile |
| `strlen(s)` | numero di byte |
| `strbyte(s, i)` | byte (`Int` 0â€“255) alla posizione `i`, da 1 |
| `strsub(s, a, b)` | sottostringa dai byte `a` a `b` inclusi, da 1 |
| `exit(n)` | termina il processo con codice `n` |

```triad
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

**Output:**

```text
3
abc
```

Un programma puÃ² leggere se stesso con `readfile(ARGS[1])`: Ã¨ il primo passo di un interprete
self-hosted.

---

<a id="cap-22"></a>

## 22. Stile e pattern idiomatici

### 22.1 Funzioni di ordine superiore scritte in Core

In Core non esistono `map`/`filter`/`reduce`: si scrivono una volta, con `while` e lambda, e poi si
usano ovunque.

```triad
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

**Output:**

```text
[1, 4, 9, 16, 25, 36]
[2, 4, 6]
21
```

### 22.2 Record come liste taggate

In Core non c'Ã¨ `struct`: un record Ã¨ una lista con un simbolo come tag in prima posizione.

```triad
punto(x, y) = [:Punto, x, y]
px(p) = p[2]
py(p) = p[3]
somma_punti(a, b) = punto(px(a) + px(b), py(a) + py(b))
p = somma_punti(punto(1, 2), punto(10, 20))
println(p, " ", p[1] == :Punto)
```

**Output:**

```text
[:Punto, 11, 22] true
```

### 22.3 Ambiente come lista di associazioni

Ãˆ la struttura usata dagli interpreti in `selfhost/`: una lista piatta `[nome1, valore1, nome2,
valore2, â€¦]`.

```triad
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

**Output:**

```text
[:x, 11, :y, 20] 11 nothing
```

### 22.4 Stato mutabile condiviso

PoichÃ© una funzione nominata non puÃ² riassegnare un globale, lo stato condiviso si tiene in una
lista mutabile o in una chiusura.

```triad
stato = [0]
function tick()
    stato[1] += 1
end
tick()
tick()
println(stato[1])
```

**Output:**

```text
2
```

### 22.5 Costruire stringhe

```triad
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

**Output:**

```text
ababab
1, 2, 3
```

### 22.6 Regole di stile

- Funzioni piccole con nomi chiari; caso base esplicito in ogni ricorsione; per profonditÃ  grandi
  preferisci `while`.
- Cicli con contatori espliciti (`i = 1 â€¦ while i <= length(xs)`).
- Non usare `fact`, `rule`, `solve`, `struct` e le altre parole chiave di Full come nomi: il codice
  deve restare valido anche in Triad-Full.
- Scrivi `!io` sulle funzioni che stampano: Core lo ignora, Full lo richiede.
- Metti le parentesi quando spezzi un'espressione su piÃ¹ righe.

---

<a id="parte-2"></a>

# Parte II â€” Esercizi

Ogni esercizio ha una soluzione verificata. Prova prima, poi apri il riquadro Â«SoluzioneÂ».

<a id="cap-23"></a>

## 23. Esercizi guidati (Triad-Core)

### Esercizio 1 â€” Potenza e somme

Senza usare `^`, scrivi `potenza(b, e)` ricorsiva e `somma_fino(n)` (somma `1 + â€¦ + n`) con `while`.
Stampa `potenza(3, 13)`, `potenza(2, 10)` e `somma_fino(100)`.

<details>
<summary>Soluzione</summary>

```triad
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

**Output:**

```text
1594323 1024 5050
```

</details>

### Esercizio 2 â€” Numeri primi

Stampa la lista dei numeri primi minori di 30.

<details>
<summary>Soluzione</summary>

```triad
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

**Output:**

```text
[2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
```

</details>

### Esercizio 3 â€” Inverti una lista

Scrivi `inverti(xs)` che restituisca una nuova lista con gli elementi in ordine inverso.

<details>
<summary>Soluzione</summary>

```triad
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

**Output:**

```text
[tre, :due, 1]
```

</details>

### Esercizio 4 â€” Ordinamento per inserzione

Ordina in loco `[5, 2, 9, 1, 7]`.

<details>
<summary>Soluzione</summary>

```triad
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

**Output:**

```text
[1, 2, 5, 7, 9]
```

Il `!` finale nel nome segnala, per convenzione, una funzione che muta il suo argomento.

</details>

### Esercizio 5 â€” Contatore di parole

Conta le parole (separate da spazi) di `"il  linguaggio Triad "` usando `strbyte`.

<details>
<summary>Soluzione</summary>

```triad
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

**Output:**

```text
3
```

</details>

### Esercizio 6 â€” Un mini-tokenizer

Trasforma `"12+x*3"` in una lista di token `[tipo, testo]`, con tipi `:num`, `:id`, `:op`. Ãˆ il primo
passo di un interprete.

<details>
<summary>Soluzione</summary>

```triad
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

**Output:**

```text
[[:num, 12], [:op, +], [:id, x], [:op, *], [:num, 3]]
```

</details>

### Esercizio 7 â€” Valutare un'espressione

Usando i token dell'esercizio 6, scrivi un valutatore a discesa ricorsiva per `+` e `*` con
precedenza, dove le variabili vengono da una lista di associazioni. Suggerimento: tieni la posizione
corrente in una lista `pos = [1]`, cosÃ¬ le funzioni possono aggiornarla.

<details>
<summary>Soluzione</summary>

```triad
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

**Output:**

```text
42
26
```

</details>

### Esercizio 8 â€” Un ambiente a dizionario

Estendi l'esercizio 5 con un ambiente che supporta anche la rimozione, e scrivi `ambiente_da_elenco`
che costruisce un ambiente da coppie `[nome, valore]`. Verifica con `env_get` ed `env_set` del
capitolo 22.3.

<details>
<summary>Soluzione</summary>

```triad
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

function env_rimuovi(env, nome)
    out = []
    i = 1
    while i < length(env)
        if env[i] == nome
            i += 2
        else
            push!(out, env[i])
            push!(out, env[i + 1])
            i += 2
        end
    end
    out
end

function ambiente_da_elenco(coppie)
    env = []
    i = 1
    while i < length(coppie)
        env_set(env, coppie[i], coppie[i + 1])
        i += 2
    end
    env
end

env = ambiente_da_elenco([:x, 10, :y, 20])
println(env, " ", env_get(env, :x))
env = env_rimuovi(env, :x)
println(env, " ", env_get(env, :x))
```

**Output:**

```text
[:x, 10, :y, 20] 10
[:y, 20] nothing
```

</details>

<a id="cap-24"></a>

## 24. Esercizi su Triad-Full

Questi esercizi usano i costrutti dello standard completo. Sono definiti dalla specifica e hanno
output golden in `conformance/cases/`, ma **non sono ancora eseguibili** dal runtime corrente.

### Esercizio 9 â€” Dispatch su struct

Definisci `struct Vec2` con due campi `Float` e tre metodi di `area`: uno per `Vec2`, uno per `Number`
e uno per `Any`. Verifica che il metodo piÃ¹ specifico vinca.

<details>
<summary>Soluzione</summary>

```triad-full
struct Vec2
    x::Float
    y::Float
end

area(v::Vec2) = v.x * v.y
area(n::Number) = n * n
area(x::Any) = 0

println(area(Vec2(3, 4)))
println(area(5))
println(area("ciao"))
```

**Output (golden Full):**

```text
12.0
25
0
```

</details>

### Esercizio 10 â€” Una base di conoscenza

Scrivi fatti e regole per `parent` e `sorella`, e usa `solve` per trovare le sorelle di `:bob` e
i nipoti di `:alice`.

<details>
<summary>Soluzione</summary>

```triad-full
fact parent(:alice, :bob)
fact parent(:alice, :carol)
fact parent(:bob, :dave)
fact parent(:carol, :erin)

rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

rule sorella(?a, ?b) :- parent(?p, ?a), parent(?p, ?b), ?a != ?b

println([s.b for s in solve sorella(:bob, ?b)])
println([s.z for s in solve grandparent(:alice, ?z)])
```

**Output (golden Full):**

```text
[:carol]
[:dave, :erin]
```

</details>

### Esercizio 11 â€” Contratti in pratica

Scrivi `dividi(a, b)` con `requires b != 0` e `ensures abs(result * b - a) < 1e-9`, e usa `try` per
distinguere il caso di contratto violata dal caso di successo.

<details>
<summary>Soluzione</summary>

```triad-full
function dividi(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end

r = try dividi(1, 0) end
if iserr(r)
    println("contratto: ", r.data.clause)
else
    println("valore: ", r)
end
```

**Output (golden Full):**

```text
contratto: requires
```

</details>

### Esercizio 12 â€” Una macro che misura

Scrivi la macro `@misura(label, espr)` che valuta l'espressione e stampa etichetta e valore,
restituendo il valore.

<details>
<summary>Soluzione</summary>

```triad-full
macro misura(label, e)
    :(begin
        r = $e
        println($label, " -> ", r)
        r
    end)
end

totale = @misura("somma", 1 + 2 + 3)
println(totale)
```

**Output (golden Full):**

```text
somma -> 6
6
```

</details>

---

<a id="parte-3"></a>

# Parte III â€” Riferimento

<a id="cap-25"></a>

## 25. Grammatica

### 25.1 Triad-Core (EBNF normativa)

```
program  = { sep } { stmt sep { sep } } ;
sep      = NEWLINE | ";" ;
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

### 25.2 Triad-Full (EBNF normativa)

```
program    = { sep } { stmt sep { sep } } ;
sep        = NEWLINE | ";" ;
block      = { sep } { stmt sep { sep } } ;

stmt       = funcdef | structdef | macrodef | fact | rule
           | "requires" expr | "ensures" expr
           | "return" [ expr ] | "break" | "continue"
           | "(" NAME { "," NAME } ")" "=" expr
           | expr ;

funcdef    = "function" fname "(" [ params ] ")" [ "::" TYPE ] [ "!" EFFECT { "," EFFECT } ]
             block "end"
           | NAME "(" [ params ] ")" "=" expr ;
fname      = NAME | "+" | "-" | "*" | "/" | "%" | "^" | "==" | "<" | "<=" | ">" | ">=" ;
params     = param { "," param } ;
param      = NAME [ "::" TYPE ] | "(" NAME { "," NAME } ")" ;
structdef  = "struct" NAME sep { NAME [ "::" TYPE ] sep } "end" ;
macrodef   = "macro" NAME "(" [ NAME { "," NAME } ] ")" block "end" ;

fact       = "fact" term ;
rule       = "rule" term [ ":-" goal { "," goal } ] ;

expr       = (* Pratt: precedenze dalla piÃ¹ bassa alla piÃ¹ alta *)
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
           | "for" "(" NAME { "," NAME } ")" "in" expr block "end"
           | "let" [ NAME "=" expr { "," NAME "=" expr } ] block "end"
           | "begin" block "end"
           | "try" block [ "catch" [ NAME ] block ] "end"
           | "with" modifier { "," modifier } block "end"
           | "solve" goal { "limit" expr | "depth" expr | "steps" expr | "trace" }
           | "function" "(" params ")" block "end" ;
modifier   = "budget" "(" "steps" "=" expr ")" | "trace" ;
```

---

<a id="cap-26"></a>

## 26. Schede rapide

### 26.1 Valori

| vuoi | scrivi |
|---|---|
| un intero | `42`, `1_000` |
| un float **[Full]** | `3.14`, `1e-9` |
| un booleano | `true`, `false` |
| il vuoto | `nothing` |
| una stringa | `"testo"` |
| un simbolo | `:alice` |
| una lista | `[1, 2, 3]` |
| una lambda | `x -> x + 1` |
| una funzione | `function (x) x end` |
| un record Core | `[:Punto, 1, 2]` |
| una struct **[Full]** | `Point(3, 4)` |
| codice come dato **[Full]** | `:(a + b)`, `quote â€¦ end` |

### 26.2 Controllo di flusso

| vuoi | scrivi |
|---|---|
| una condizione | `if c â€¦ elseif d â€¦ else â€¦ end` |
| una condizione breve | `c ? a : b` |
| un ciclo | `while c â€¦ end` **[Core]** Â· `for x in xs â€¦ end` **[Full]** |
| uscire dal ciclo | `break` |
| saltare al passo dopo | `continue` |
| uscire dalla funzione | `return e` |
| uno scope nuovo | `let x = 1 â€¦ end` |
| un blocco senza scope | `begin â€¦ end` |
| una lista costruita **[Full]** | `[x * x for x in xs]` |
| catturare un errore **[Full]** | `try b catch e h end` |

### 26.3 Funzioni

| vuoi | scrivi |
|---|---|
| una funzione | `f(x) = x + 1` |
| un corpo multi-istruzione | `function f(x) â€¦ end` |
| un tipo di ritorno **[Full]** | `function f(x)::Float â€¦ end` |
| un effetto **[Full]** | `function f(x) !io â€¦ end` |
| un predicato in un goal **[Full]** | `function evena(n) n % 2 == 0 end` |
| una precondizione **[Full]** | `requires cond` |
| una postcondizione **[Full]** | `ensures cond` |

---

<a id="cap-27"></a>

## 27. Tabella degli errori

### 27.1 In Core

Core non ha `try`/`catch` nÃ© valori `Err`: un errore **termina il processo** con exit code `1` e un
messaggio diagnostico su stderr. Quello giÃ  stampato su stdout resta.

| messaggio | causa |
|---|---|
| `parse error: unexpected token â€¦` / `parse error: expected â€¦` | sintassi non Core (`1.5`, `/`, `() -> â€¦`, `end` mancante) |
| `error: undefined variable NOME` | nome mai assegnato, o funzione chiamata prima di essere definita |
| `error: not a function` | si chiama un valore che non Ã¨ una funzione (`x = 5; x(1)`) |
| `error: arity mismatch` | numero di argomenti diverso dai parametri |
| `error: index out of range` | `xs[i]` con `i < 1` o `i > length(xs)` |
| `error: + type error` (e simili) | operandi di tipo sbagliato (`1 + "a"`) |
| `error: if cond` / `while cond` / `ternary cond` / `&& expects bool` | condizione non `Bool` |
| `error: div by zero` / `negative exponent` | `x % 0`, `2 ^ -1` |
| `error: unknown function NOME` | builtin riservato usato in modo non supportato |
| `cannot read file: â€¦` | file inesistente o non leggibile |
| `usage: triad FILE [ARG...]` (exit 2) | nessun file passato |

### 27.2 In Triad-Full

Gli stessi fallimenti arrivano come `Err` con un `kind` (cap. 11.3), invece di terminare il
processo. Un errore non gestito al top level stampa `riga N: â€¦` e esce con codice `1`.

---

<a id="cap-28"></a>

## 28. Glossario

| termine | significato |
|---|---|
| **Albero uniforme** | l'unico tipo di nodo prodotto dal parser, `Node(head, args)`; Ã¨ anche ciÃ² che il kernel esegue |
| **Ambiente** | l'insieme dei legami di nomi a valori visibile in un punto del programma |
| **Backtracking** | il motore logico torna sui legami e prova la clausola successiva |
| **Budget** | limite di passi eseguibili; esaurito produce `Err(:budget)` |
| **Clausola** | un `fact` o una `rule` della knowledge base |
| **Chiusura** | funzione che cattura l'ambiente in cui Ã¨ stata creata |
| **Dispatch** | scelta del metodo in base ai **tipi** degli argomenti |
| **Effetto** | capacitÃ  dichiarata di una funzione: `io`, `state` |
| **Err** | l'errore come dato: `kind`, `msg`, `data` |
| **Goal** | una domanda alla knowledge base: predicato, congiunzione, disgiunzione, unificazione |
| **Knowledge base** | l'insieme dei fatti e delle regole |
| **Macro** | una funzione che riceve e restituisce codice |
| **Occurs-check** | la regola che impedisce a `?x` di unificarsi con un termine che contiene `?x` |
| **Precedenza** | l'ordine in cui gli operatori vengono valutati (12 livelli) |
| **Profilo** | un sottoinsieme normativo dello standard: Core o Full |
| **Scope lessicale** | un nome Ã¨ visibile dove Ã¨ stato legato e all'interno, mai all'esterno |
| **Soluzione** | una `Solution`: i legami prodotti da un goal risolto |
| **Standardizzazione a parte** | le variabili di una clausola vengono rinominate a ogni uso |
| **Unificazione** | l'uguaglianza logica: due termini si rendono identici legando le variabili |
| **Valori di prima classe** | funzioni e operatori usabili come qualsiasi altro valore |

---

<a id="cap-29"></a>

## 29. Cosa gira oggi

Questa sezione non fa parte del linguaggio: Ã¨ lo stato dell'implementazione,useful per orientarsi
prima di scrivere codice.

| profilo | stato |
|---|---|
| **Triad-Core** | **eseguibile**: interprete di riferimento JavaScript `seed/dev/triad_core.cjs` (37/37 casi Core) e, in parte, il seed Windows `seed/windows-x86_64/seed.exe` |
| **Triad-Full** | **non eseguibile**: struct, dispatch, logica, macro, contratti, budget, tracce, effetti, destrutturazione, `for`, `try`, `Float` sono specifica; nella conformance Full passa solo `errore` |

Differenze note fra i due runtime Core:

| funzionalitÃ  | interprete JS | seed Windows |
|---|---|---|
| `return`, `break`, `continue` | sÃ¬ | non elencati nel README del seed |
| lambda | piÃ¹ parametri | **un solo parametro** |
| chiusure | condivise | **per valore**, solo l'ultimo legame del frame |
| `string(x)` | tutti i tipi | solo `Int` e `String` |
| liste | eterogenee, `xs[i]`, `length`, `push!` | solo interi; costruzione, stampa, `push!` |
| `get(xs, i)` | non esiste | helper **non standard**, indici **da 0** |
| `ARGS`, primitivi di bootstrap | sÃ¬ | non elencati nel README del seed |
| messaggi di errore | su stderr | solo exit code |

Regola pratica: **scrivi codice che rispetta `SPEC-CORE` e verificalo con l'interprete JS**; se deve
girare anche sul seed, restringiti alle funzionalitÃ  elencate nella colonna di destra e verificalo
su Windows.

Due limiti noti che il lettore deve conoscere prima di scrivere codice:

- **ogni a capo chiude l'istruzione**, anche dentro `( )`, `[ ]` e negli argomenti di una chiamata.
  L'eccezione prevista da `SPEC Â§1` per Triad-Full (a capo dentro le parentesi, o subito dopo un
  operatore binario) non Ã¨ implementata nell'interprete di riferimento. Scrivere una istruzione
  per riga;
- **il seed Windows non implementa l'indicizzazione standard `xs[i]`**: lÃ¬ c'Ã¨ l'helper non
  standard `get(xs, i)`, con indici **da 0**.

---

<a id="app-a"></a>

# Appendice A â€” Influenze dichiarate

Triad nasce da idee di Julia, Prolog e Lisp, ma **non Ã¨ un dialetto di nessuno dei tre**: la
definizione del linguaggio Ã¨ la specifica.

| da | idea ripresa |
|---|---|
| Julia | blocchi `function â€¦ end`, `struct`, tipi con `::`, multiple dispatch, operatori-funzione, `if`/`for`/`while`/`let` |
| Prolog | `fact`/`rule` come costrutti, unificazione con occurs-check, backtracking, `solve`, variabili logiche `?x` |
| Lisp | codice come dato, albero uniforme, `:( â€¦ )`/`quote` con `$`, macro |

**Propri di Triad**, non presi in prestito: errori come dati, contratti, budget, tracce ed effetti
dichiarati come parte del linguaggio, e l'integrazione dei tre modelli in una sintassi a blocchi.

---

<a id="app-b"></a>

# Appendice B â€” Dove guardare

| vuoi | leggi |
|---|---|
| la definizione normativa completa | [`SPEC.md`](SPEC.md) |
| il sottoinsieme di bootstrap | [`SPEC-CORE.md`](SPEC-CORE.md) |
| il percorso di studio per capitoli e il codice del progetto | [`TUTORIAL.md`](TUTORIAL.md) |
| gli esempi completi con output | `examples/` |
| il contratto eseguibile, con i golden | [`conformance/`](conformance/README.md) |
| lo stato del bootstrap | [`STATUS.md`](STATUS.md) Â· [`BOOTSTRAP.md`](BOOTSTRAP.md) |
| il piano di lavoro | [`plan.md`](plan.md) Â· [`TASK.md`](TASK.md) |
| gli strumenti per gli editor | [`editors/`](editors/README.md) |
| la licenza | [`LICENSE`](LICENSE) â€” MIT |

---

*Manuale scritto per lo standard Triad `0.2.0`. Le sezioni normative sono in [`SPEC.md`](SPEC.md) e
[`SPEC-CORE.md`](SPEC-CORE.md); in caso di divergenza, la specifica prevail.*
