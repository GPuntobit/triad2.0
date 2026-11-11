# Catalogo conformance Triad-Full

Tutti i casi di [`conformance/cases/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/cases) (profilo Triad-Full). I golden sono stati prodotti dalla vecchia implementazione Julia e sono **congelati**: sono il contratto per la futura implementazione Full (S1). Oggi l'interprete JS esegue solo Triad-Core, quindi passa solo il caso `errore`. Spiegazione dei costrutti: [Parte III](Parte-III-Triad-Full).

| caso | stato oggi |
|---|---|
| [`assaggio`](#assaggio) | golden congelato, non ancora eseguibile |
| [`destruttura`](#destruttura) | golden congelato, non ancora eseguibile |
| [`dispatch`](#dispatch) | golden congelato, non ancora eseguibile |
| [`errore`](#errore) | ✅ passa |
| [`famiglia`](#famiglia) | golden congelato, non ancora eseguibile |
| [`garanzie_core`](#garanzie_core) | golden congelato, non ancora eseguibile |
| [`hello_shebang`](#hello_shebang) | golden congelato, non ancora eseguibile |
| [`macro`](#macro) | golden congelato, non ancora eseguibile |
| [`macro_eval`](#macro_eval) | golden congelato, non ancora eseguibile |
| [`prolog`](#prolog) | golden congelato, non ancora eseguibile |
| [`tour`](#tour) | golden congelato, non ancora eseguibile |
| [`valori`](#valori) | golden congelato, non ancora eseguibile |

## assaggio

Sorgente: [`conformance/cases/assaggio/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/cases/assaggio)

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

Output atteso (`expected.out`):

```text
nipoti di alice: [{who = :dave}]
primo: dave
quanti: 1
dist(p, q) = 5.0
dist(p, p) -> Err(:contract, "requires violata in dist: a.x != b.x || a.y != b.y", Info(fn = :dist, clause = :requires, cond = :(a.x != b.x || a.y != b.y)))
tipo: contract
almeno un nipote
alice è nonna di dave? true
```

Exit code atteso: `0`

## destruttura

Sorgente: [`conformance/cases/destruttura/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/cases/destruttura)

```julia
# destrutturazione: assegnamento multiplo, for su coppie, errore di arità
(a, b) = [10, 32]
println(a + b)

tot = 0
for (k, v) in [[1, 2], [3, 4]]
    tot += k + v
end
println(tot)

e = try (a, b) = [1] end
println(e.kind)
```

Output atteso (`expected.out`):

```text
42
10
bounds
```

Exit code atteso: `0`

## dispatch

Sorgente: [`conformance/cases/dispatch/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/cases/dispatch)

```julia
# dispatch: struct, operatori-funzione, multiple dispatch, errori come dati
struct Punto
    x::Float
    y::Float
end

function +(a::Punto, b::Punto)
    Punto(a.x + b.x, a.y + b.y)
end

area(n::Int) = :intero
area(n::Number) = :numero

p = Punto(1, 2)
q = Punto(3, 4)
r = p + q
println(r.x, ",", r.y)
println(area(1), " ", area(1.5))

e = try p.z end
println(e.kind)
e = try Punto("a", 1) end
println(e.kind)
```

Output atteso (`expected.out`):

```text
4.0,6.0
intero numero
field
type
```

Exit code atteso: `0`

## errore

Sorgente: [`conformance/cases/errore/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/cases/errore)

```julia
# errore non gestito: il processo deve uscire con 1 e non scrivere su stdout
boom()
```

Output atteso (`expected.out`):

_(stdout vuoto)_

Exit code atteso: `1`

## famiglia

Sorgente: [`conformance/cases/famiglia/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/cases/famiglia)

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

Output atteso (`expected.out`):

```text
discendenti di tom: [:bob, :liz, :ann, :pat, :jim]
fratelli di ann: [:pat]
madri: ["pat -> jim"]
senza figli: [:liz, :ann, :jim]
over 50: [:tom, :bob]
modi di spezzare [1, 2, 3]:
  [] ++ [1, 2, 3]
  [1] ++ [2, 3]
  [1, 2] ++ [3]
  [1, 2, 3] ++ []
figli di bob: [:ann, :pat]
```

Exit code atteso: `0`

## garanzie_core

Sorgente: [`conformance/cases/garanzie_core/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/cases/garanzie_core)

```julia
# garanzie: contratti, budget, tracce, effetti (senza gensym instabili)
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end
println(safe_div(10, 4))
e = try safe_div(1, 0) end
println(e.kind, " ", e.data.clause)

r = with budget(steps = 2000)
    i = 0
    while true
        i += 1
    end
end
println(r.kind)

fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)
t = with trace
    fib(5)
end
println(t.result, " ", length(t.trace))

function saluta(n::String) !io
    println("ciao ", n)
end
saluta("Triad")

function rumorosa(x)
    println(x)
end
println((try rumorosa(1) end).kind)
```

Output atteso (`expected.out`):

```text
2.5
contract requires
budget
5 30
ciao Triad
effect
```

Exit code atteso: `0`

## hello_shebang

Sorgente: [`conformance/cases/hello_shebang/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/cases/hello_shebang)

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

Argomenti (`args.txt`): `Ada`, `Bob`

Output atteso (`expected.out`):

```text
=== File .td eseguibile ===
ARGS = ["Ada", "Bob"]
Ciao, Ada! Benvenuto in Triad.
Ciao, Bob! Benvenuto in Triad.

Query logica: grandparent(:alice, ?who)
Risultato: [{who = :charlie}]
```

Exit code atteso: `0`

## macro

Sorgente: [`conformance/cases/macro/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/cases/macro)

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

Output atteso (`expected.out`):

```text
codice:  :(a.x + f(b, 2))
head:    call
args:    [:+, :(a.x), :(f(b, 2))]
sexpr:   (call + (dot a x) (call f b 2))
:(7 * 7) = 49
parse:   (if (call > x 0) (block (sym pos)) (block (sym neg)))
unparse: if x > 0; :pos; else; :neg; end
dopo @swap: x = 2, y = 1
x non è minore di y
somma -> 5050
polinomio: :(0 + 1 * x ^ 0 + 2 * x ^ 1 + 3 * x ^ 2)
p(2) = 17
```

Exit code atteso: `0`

## macro_eval

Sorgente: [`conformance/cases/macro_eval/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/cases/macro_eval)

```julia
# macro_eval: quote, sexpr, parse/unparse, macro
c = :(a.x + f(b, 2))
println(c.head)
println(sexpr(c))

n = 7
q = :($n * $n)
println(eval(q))

t = parse("if x > 0; :pos; else; :neg; end")
println(unparse(t))

macro unless(c, body)
    :(if !$c; $body; end)
end
@unless(2 > 3, println("non maggiore"))
```

Output atteso (`expected.out`):

```text
call
(call + (dot a x) (call f b 2))
49
if x > 0; :pos; else; :neg; end
non maggiore
```

Exit code atteso: `0`

## prolog

Sorgente: [`conformance/cases/prolog/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/cases/prolog)

```julia
# prolog: regole ricorsive, liste stile Prolog, negazione per fallimento
fact parent(:tom, :bob)
fact parent(:bob, :ann)
fact parent(:bob, :pat)
fact parent(:pat, :jim)

rule ancestor(?a, ?d) :- parent(?a, ?d)
rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)
println([s.d for s in solve ancestor(:tom, ?d)])

rule app([], ?l, ?l)
rule app([?h | ?t], ?l, [?h | ?r]) :- app(?t, ?l, ?r)
println((solve app([1, 2], [3], ?r))[1].r)
println(length(solve app(?a, ?b, [1, 2, 3])))

println(filter(p -> !parent(p, ?_), [:tom, :bob, :ann, :pat, :jim]))
```

Output atteso (`expected.out`):

```text
[:bob, :ann, :pat, :jim]
[1, 2, 3]
4
[:ann, :jim]
```

Exit code atteso: `0`

## tour

Sorgente: [`conformance/cases/tour/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/cases/tour)

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

Output atteso (`expected.out`):

```text
|p| = 5.0
p + q = (4.0, 6.0)
dispatch: area(1) = intero, area(1.5) = numero
dividi(7, 2) = 3.5
contratto violato -> contract (clausola requires)
  valore 2
  errore domain
destrutturazione con arità sbagliata -> bounds
rotte da roma (limit 6):
  milano a 60 minuti
  parigi a 180 minuti
  parigi a 150 minuti
  londra a 230 minuti
  londra a 260 minuti
roma -> londra costa 230 minuti
senza voli in partenza: [:londra]
x + y = 42
  alfa -> 1
  beta -> 2
  gamma -> 3
totale = 6
macro: 2 non è maggiore di 3
polinomio p(2) = 17
budget esaurito -> budget
fib(5) = 5 (30 eventi tracciati)
ciao, Triad!
effetto non dichiarato -> effect
imparato: [:gatto]
```

Exit code atteso: `0`

## valori

Sorgente: [`conformance/cases/valori/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/cases/valori)

```julia
# valori: numeri, stringhe, liste, comprehension
x = 2
y = 21
println(x * y)
println(7 / 2)
println("ab" * "cd")
xs = [1, 2, 3]
println(xs[2])
println(length([:a, :b]))
println(sum([1, 2, 3, 4]))
sq(n) = n * n
println(map(sq, [1, 2, 3]))
println(reduce(+, 1:4))
println(filter(x -> x % 2 == 0, 1:6))
println([x^2 for x in 1:4 if x > 2])
println(3 > 2 ? :grande : :piccolo)
```

Output atteso (`expected.out`):

```text
42
3.5
abcd
2
2
10
[1, 4, 9]
10
[2, 4, 6]
[9, 16]
grande
```

Exit code atteso: `0`
