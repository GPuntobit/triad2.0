# Sorgenti degli esempi

Sorgenti completi di [`examples/`](https://github.com/GPuntobit/triad2.0/tree/main/examples) (Triad-Full, non ancora eseguibili: i loro output sono nel [Catalogo conformance Full](Catalogo-conformance-Full)) e dei task del benchmark AI in [`ai/tasks/`](https://github.com/GPuntobit/triad2.0/tree/main/ai/tasks) (Triad-Core, eseguibili).

## Indice

- [`examples/assaggio.td`](#examplesassaggiotd)
- [`examples/benvenuto.triad`](#examplesbenvenutotriad)
- [`examples/famiglia.td`](#examplesfamigliatd)
- [`examples/garanzie.td`](#examplesgaranzietd)
- [`examples/hello_shebang.td`](#exampleshello_shebangtd)
- [`examples/macro.td`](#examplesmacrotd)
- [`examples/tour.td`](#examplestourtd)
- [`ai/tasks/01_somma`](#aitasks01_somma)
- [`ai/tasks/02_fattoriale`](#aitasks02_fattoriale)
- [`ai/tasks/03_fibonacci`](#aitasks03_fibonacci)
- [`ai/tasks/04_stringhe`](#aitasks04_stringhe)
- [`ai/tasks/05_chiusure`](#aitasks05_chiusure)

# Esempi Triad-Full (`examples/`)

## examples/assaggio.td

```julia
# assaggio.td — i tre linguaggi in poche righe

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

result = solve grandparent(:alice, ?who) limit 5

# `solve` restituisce un valore normale: una lista di soluzioni
println("nipoti di alice: ", result)
println("primo: ", result[1].who)
println("quanti: ", length(result))

p = Point(0, 0)
q = Point(3, 4)
println("dist(p, q) = ", dist(p, q))

# il contratto violato è un errore come dato
e = try dist(p, p) end
println("dist(p, p) -> ", e)
println("tipo: ", e.kind)

@unless(length(result) == 0, println("almeno un nipote"))

# un predicato chiamato come funzione: vero se dimostrabile
println("alice è nonna di dave? ", grandparent(:alice, :dave))
```

## examples/benvenuto.triad

```julia
#!/usr/bin/env triad
# benvenuto.triad — file col nome canonico dell'estensione (.triad).
# Esegui con:  triad examples/benvenuto.triad  (oppure ./benvenuto.triad)

println("Triad, standard ", 0.2)

fact saluta(:mondo)
println((solve saluta(?x))[1].x)
```

## examples/famiglia.td

```julia
# famiglia.td — Prolog dentro Triad: fatti, regole, ricorsione, liste

fact parent(:tom, :bob)
fact parent(:tom, :liz)
fact parent(:bob, :ann)
fact parent(:bob, :pat)
fact parent(:pat, :jim)
fact female(:liz)
fact female(:ann)
fact female(:pat)

rule mother(?m, ?c) :- parent(?m, ?c), female(?m)
rule sibling(?a, ?b) :- parent(?p, ?a), parent(?p, ?b), ?a != ?b
rule ancestor(?a, ?d) :- parent(?a, ?d)
rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)

# solve restituisce una lista: si filtra e si trasforma con il resto del linguaggio
discendenti = [s.d for s in solve ancestor(:tom, ?d)]
println("discendenti di tom: ", discendenti)
println("fratelli di ann: ", [s.b for s in solve sibling(:ann, ?b)])
println("madri: ", [string(s.m, " -> ", s.c) for s in solve mother(?m, ?c)])

# negazione per fallimento: chi non ha figli?
persone = [:tom, :bob, :liz, :ann, :pat, :jim]
foglie = filter(p -> !parent(p, ?_), persone)
println("senza figli: ", foglie)

# aritmetica nei goal con `is`, e una funzione Triad usata come goal
fact born(:tom, 1950)
fact born(:bob, 1975)
fact born(:pat, 2001)
rule age(?p, ?a) :- born(?p, ?y), ?a is 2026 - ?y
over50(a::Int) = a > 50
println("over 50: ", [s.p for s in solve age(?p, ?a) && over50(?a)])

# liste in stile Prolog: [testa | coda]
rule app([], ?l, ?l)
rule app([?h | ?t], ?l, [?h | ?r]) :- app(?t, ?l, ?r)
println("modi di spezzare [1, 2, 3]:")
for s in solve app(?a, ?b, [1, 2, 3])
    println("  ", s.a, " ++ ", s.b)
end

# un identificatore nudo in un termine è un valore dell'host
chi = :bob
println("figli di ", chi, ": ", [s.c for s in solve parent(chi, ?c)])
```

## examples/garanzie.td

```julia
# garanzie.td — errori come dati, contratti, budget, tracce, effetti

# --- contratti: requires / ensures fanno parte della funzione ---
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end

println(safe_div(10, 4))
e = try safe_div(1, 0) end            # try senza catch: l'errore diventa il valore
println("violazione: ", e.kind, " — ", e.msg)
println("clausola: ", e.data.clause, ", funzione: ", e.data.fn)

# --- errori come dati: si ispezionano, si passano, si fa dispatch ---
describe(e::Err) = string("errore ", e.kind, ": ", e.msg)
describe(x::Any) = string("valore ", x)

risultati = [try div(10, d) end for d in [2, 0, 5]]
for r in risultati
    println(describe(r))
end

function parse_eta(s::String)
    n = try Int(s) end
    if iserr(n)
        return err(:input, "età non valida", s)
    end
    requires n >= 0
    n
end
println(describe(parse_eta("42")))
println(describe(parse_eta("quaranta")))

try
    throw(err(:mio, "qualcosa non va", [1, 2, 3]))
catch e
    println("catturato ", e.kind, " con dati ", e.data)
end

# --- budget: un calcolo limitato finisce con un Err, non si blocca ---
r = with budget(steps = 10_000)
    i = 0
    while true
        i += 1
    end
end
println("ciclo infinito -> ", r.kind)

rule loop(?x) :- loop(?x)
println("solve infinito -> ", (try solve loop(1) steps 2000 end).kind)

# --- tracce: la storia di un calcolo è un valore ---
fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)
t = with trace
    fib(3)
end
println("fib(3) = ", t.result, " in ", length(t.trace), " eventi")
println("chiamate: ", [e.args for e in t.trace if e.port == :call])

fact edge(:a, :b)
fact edge(:b, :c)
rule path(?x, ?y) :- edge(?x, ?y)
rule path(?x, ?y) :- edge(?x, ?z), path(?z, ?y)
t = solve path(:a, :c) trace
for e in t.trace
    println("  ", e.port, " ", e.goal, " @", e.depth)
end

# --- effetti: pure per default, !io / !state dichiarati ---
function saluta(nome::String) !io
    println("ciao, ", nome)
end
saluta("Triad")

function quadrato(x::Number)
    x * x                              # pura: niente println qui
end
function rumorosa(x::Number)
    println(x)                         # vietato: non dichiara !io
end
println("effetto non dichiarato -> ", (try rumorosa(1) end).msg)

function impara(x) !state
    fact visto($x)
end
impara(:gatto)
println("imparato: ", [s.v for s in solve visto(?v)])
```

## examples/hello_shebang.td

```julia
#!/usr/bin/env triad
# =====================================================================
#  hello_shebang.td — esempio di file .td eseguibile direttamente
#
#  Rendi eseguibile e lancia:
#    chmod +x hello_shebang.td
#    ./hello_shebang.td Alice Bob
#
#  Oppure con il launcher:
#    triad hello_shebang.td Alice Bob
#
#  La prima riga (shebang) viene rimossa automaticamente dal runtime.
# =====================================================================

function saluta(nome::String) !io
    println("Ciao, ", nome, "! Benvenuto in Triad.")
end

# Mostra gli argomenti passati dalla riga di comando
println("=== File .td eseguibile ===")
println("ARGS = ", ARGS)

if isempty(ARGS)
    println("Uso: ./hello_shebang.td nome1 [nome2 ...]")
    println("Provo con un esempio:")
    saluta("mondo")
else
    for nome in ARGS
        saluta(String(nome))
    end
end

# Dimostra che la logica funziona anche nei file shebang
fact parent(:alice, :bob)
fact parent(:bob, :charlie)
rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

println()
println("Query logica: grandparent(:alice, ?who)")
result = solve grandparent(:alice, ?who)
println("Risultato: ", result)
```

## examples/macro.td

```julia
# macro.td — il codice è dato (Lisp), con la faccia di Julia

# un pezzo di codice è un valore: un albero con head e args
c = :(a.x + f(b, 2))
println("codice:  ", c)
println("head:    ", c.head)
println("args:    ", c.args)
println("sexpr:   ", sexpr(c))

# $ inserisce valori nel codice; eval lo esegue
n = 7
quadrato = :($n * $n)
println(quadrato, " = ", eval(quadrato))

# parse/unparse: testo <-> albero
t = parse("if x > 0; :pos; else; :neg; end")
println("parse:   ", sexpr(t))
println("unparse: ", unparse(t))

# macro: ricevono codice, restituiscono codice
macro unless(c, body)
    :(if !$c; $body; end)
end

macro swap(a, b)
    tmp = gensym(:tmp)            # nome fresco: niente catture accidentali
    quote
        $tmp = $a
        $a = $b
        $b = $tmp
    end
end

macro time_it(label, e)
    :(begin
        r = $e
        println($label, " -> ", r)
        r
    end)
end

x = 1
y = 2
@swap(x, y)
println("dopo @swap: x = ", x, ", y = ", y)
@unless(x < y, println("x non è minore di y"))
@time_it("somma", reduce(+, 1:100))

# costruire codice con un programma: un polinomio come albero
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
println("polinomio: ", p)
x = 2
println("p(2) = ", eval(p))
```

## examples/tour.td

```julia
# tour.td — un giro guidato di Triad 2.0.
# Scritto leggendo TUTORIAL.md: tocca i tre paradigmi (Julia ∪ Prolog ∪ Lisp)
# e le caratteristiche del linguaggio (errori come dati, contratti, budget,
# tracce, effetti, destrutturazione).
#
# Esegui:  julia --startup-file=no triad.jl examples/tour.td

# =====================================================================
# 1. Julia: struct, tipi, operatori-funzione, multiple dispatch
# =====================================================================
struct Punto
    x::Float
    y::Float
end

function +(a::Punto, b::Punto)
    Punto(a.x + b.x, a.y + b.y)
end

function norma(p::Punto)::Float
    sqrt(p.x^2 + p.y^2)
end

p = Punto(3, 4)          # Int → Float nella costruzione
q = Punto(1, 2)
r = p + q
println("|p| = ", norma(p))
println("p + q = (", r.x, ", ", r.y, ")")

area(n::Int) = :intero
area(n::Number) = :numero
println("dispatch: area(1) = ", area(1), ", area(1.5) = ", area(1.5))

# =====================================================================
# 2. Contratti: requires / ensures sono parte della funzione
# =====================================================================
function dividi(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end

println("dividi(7, 2) = ", dividi(7, 2))
e = try dividi(1, 0) end
println("contratto violato -> ", e.kind, " (clausola ", e.data.clause, ")")

# =====================================================================
# 3. Errori come dati: try ... end, iserr, dispatch su Err
# =====================================================================
describe(e::Err) = string("errore ", e.kind)
describe(x::Any) = string("valore ", x)

for r in [try div(10, d) end for d in [5, 0]]
    println("  ", describe(r))
end

e = try (a, b) = [1] end
println("destrutturazione con arità sbagliata -> ", e.kind)

# =====================================================================
# 4. Prolog: fatti, regole, ricorsione, `is`, negazione per fallimento
# =====================================================================
fact volo(:roma, :milano, 60)
fact volo(:milano, :parigi, 90)
fact volo(:parigi, :londra, 80)
fact volo(:roma, :parigi, 180)

rule rotta(?a, ?b, ?c) :- volo(?a, ?b, ?c)
rule rotta(?a, ?b, ?c) :- volo(?a, ?x, ?c1), rotta(?x, ?b, ?c2), ?c is ?c1 + ?c2

println("rotte da roma (limit 6):")
for s in solve rotta(:roma, ?b, ?c) limit 6
    println("  ", s.b, " a ", s.c, " minuti")
end
println("roma -> londra costa ", (solve rotta(:roma, :londra, ?c))[1].c, " minuti")

citta = [:roma, :milano, :parigi, :londra]
terminali = filter(c -> !volo(c, ?_, ?_), citta)
println("senza voli in partenza: ", terminali)

# =====================================================================
# 5. Destrutturazione: assegnamento multiplo e for su coppie
# =====================================================================
(x, y) = [10, 32]
println("x + y = ", x + y)

totale = 0
for (c, v) in [[:alfa, 1], [:beta, 2], [:gamma, 3]]
    println("  ", c, " -> ", v)
    totale += v
end
println("totale = ", totale)

# =====================================================================
# 6. Lisp: macro e codice come dato
# =====================================================================
macro unless(c, body)
    :(if !$c; $body; end)
end

@unless(2 > 3, println("macro: 2 non è maggiore di 3"))

function poly(coeffs)
    acc = :(0)
    i = 0
    for c in coeffs
        acc = :($acc + $c * x ^ $i)
        i += 1
    end
    acc
end
espressione = poly([1, 2, 3])
x = 2
println("polinomio p(2) = ", eval(espressione))

# =====================================================================
# 7. Budget e tracce: sono valori, non blocchi
# =====================================================================
r = with budget(steps = 2000)
    i = 0
    while true
        i += 1
    end
end
println("budget esaurito -> ", r.kind)

fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)
t = with trace
    fib(5)
end
println("fib(5) = ", t.result, " (", length(t.trace), " eventi tracciati)")

# =====================================================================
# 8. Effetti dichiarati: pure per default, !io / !state espliciti
# =====================================================================
function saluta(nome::String) !io
    println("ciao, ", nome, "!")
end
saluta("Triad")

function muta(x::Number)
    println(x)
end
println("effetto non dichiarato -> ", (try muta(1) end).kind)

function impara(x) !state
    fact visto($x)
end
impara(:gatto)
println("imparato: ", [s.v for s in solve visto(?v)])
```

# Task del benchmark AI (`ai/tasks/`)

Verifica: `node cli/triad-cli.mjs ai verify` (vedi [Parte IV §40](Parte-IV-Codice-del-progetto#cap-40)).

## ai/tasks/01_somma

**Richiesta (`task.md`):**

> # Task 01 — somma e precedenza
>
> Scrivi un programma Triad che stampi il risultato di:
>
> ```
> 2 + 3 * 4
> ```
>
> Output atteso: una sola riga con il numero, poi newline. Non stampare altro.

**Soluzione di riferimento (`solution.triad`):**

```julia
println(2 + 3 * 4)
```

**Output atteso:**

```text
14
```

## ai/tasks/02_fattoriale

**Richiesta (`task.md`):**

> # Task 02 — fattoriale
>
> Scrivi un programma Triad che definisca una funzione ricorsiva `fattoriale(n)`
> e stampi `fattoriale(5)`.
>
> Output atteso: una sola riga con il risultato, poi newline.

**Soluzione di riferimento (`solution.triad`):**

```julia
fattoriale(n) = n < 2 ? 1 : n * fattoriale(n - 1)
println(fattoriale(5))
```

**Output atteso:**

```text
120
```

## ai/tasks/03_fibonacci

**Richiesta (`task.md`):**

> # Task 03 — Fibonacci
>
> Scrivi un programma Triad che definisca una funzione ricorsiva `fib(n)` e stampi
> `fib(10)`.
>
> Output atteso: una sola riga con il risultato, poi newline.

**Soluzione di riferimento (`solution.triad`):**

```julia
fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)
println(fib(10))
```

**Output atteso:**

```text
55
```

## ai/tasks/04_stringhe

**Richiesta (`task.md`):**

> # Task 04 — stringhe
>
> Scrivi un programma Triad che:
>
> 1. assegni a `nome` la stringa `"Triad"`;
> 2. stampi la concatenazione di `"ciao "` e `nome`;
> 3. stampi la lunghezza di `nome`.
>
> Output atteso: due righe, la prima `ciao Triad`, la seconda `5`.

**Soluzione di riferimento (`solution.triad`):**

```julia
nome = "Triad"
println("ciao " * nome)
println(length(nome))
```

**Output atteso:**

```text
ciao Triad
5
```

## ai/tasks/05_chiusure

**Richiesta (`task.md`):**

> # Task 05 — chiusure
>
> Scrivi un programma Triad che:
>
> 1. definisca una funzione `crea(n)` che restituisce una lambda `x -> x + n`;
> 2. chiami `crea(10)` e assegni il risultato a `f`;
> 3. stampi `f(5)`.
>
> Output atteso: una sola riga con il risultato, poi newline.

**Soluzione di riferimento (`solution.triad`):**

```julia
crea(n) = x -> x + n
f = crea(10)
println(f(5))
```

**Output atteso:**

```text
15
```
