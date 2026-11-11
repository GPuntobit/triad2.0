# Catalogo conformance Triad-Core

Tutti i casi di [`conformance/core/cases/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases) con programma, output atteso ed exit code, generati dai file del repository. Ogni caso è anche un esempio eseguibile: `node seed/dev/triad_core.cjs conformance/core/cases/<caso>/program.td`. La colonna "interprete JS" è il risultato reale dell'esecuzione al momento della generazione; "seed Windows (CI)" indica se il caso è nell'elenco del job `seed-windows` di `.github/workflows/ci.yml`. Guida al formato e a come aggiungere casi: [Parte IV §38](Parte-IV-Codice-del-progetto#cap-38).

| caso | interprete JS | seed Windows (CI) |
|---|---|---|
| [`aritmetica`](#aritmetica) | ✅ | ✅ |
| [`begin_block`](#begin_block) | ✅ | ✅ |
| [`chiusura_in_if`](#chiusura_in_if) | ✅ | ✅ |
| [`chiusure`](#chiusure) | ✅ | ✅ |
| [`chiusure_local`](#chiusure_local) | ✅ | ✅ |
| [`closure`](#closure) | ✅ | ✅ |
| [`confronti`](#confronti) | ✅ | ✅ |
| [`controllo`](#controllo) | ✅ | — |
| [`formula`](#formula) | ✅ | ✅ |
| [`funzioni`](#funzioni) | ✅ | ✅ |
| [`funzioni_blocco`](#funzioni_blocco) | ✅ | ✅ |
| [`funzioni_io`](#funzioni_io) | ✅ | ✅ |
| [`funzioni_semplici`](#funzioni_semplici) | ✅ | ✅ |
| [`gcd`](#gcd) | ✅ | — |
| [`if_else`](#if_else) | ✅ | ✅ |
| [`if_elseif`](#if_elseif) | ✅ | ✅ |
| [`if_nested`](#if_nested) | ✅ | ✅ |
| [`if_no_else`](#if_no_else) | ✅ | ✅ |
| [`interi`](#interi) | ✅ | ✅ |
| [`lambda`](#lambda) | ✅ | ✅ |
| [`let_annidato`](#let_annidato) | ✅ | ✅ |
| [`let_chiusura`](#let_chiusura) | ✅ | ✅ |
| [`liste`](#liste) | ✅ | — |
| [`liste_base`](#liste_base) | ✅ | ✅ |
| [`liste_push`](#liste_push) | ✅ | ✅ |
| [`nothing_base`](#nothing_base) | ✅ | ✅ |
| [`operatori`](#operatori) | ✅ | ✅ |
| [`ricorsione`](#ricorsione) | ✅ | ✅ |
| [`scope`](#scope) | ✅ | ✅ |
| [`simboli_base`](#simboli_base) | ✅ | ✅ |
| [`stringhe`](#stringhe) | ✅ | ✅ |
| [`stringhe_base`](#stringhe_base) | ✅ | ✅ |
| [`stringhe_concat`](#stringhe_concat) | ✅ | ✅ |
| [`stringhe_multi`](#stringhe_multi) | ✅ | ✅ |
| [`valori`](#valori) | ✅ | — |
| [`variabili`](#variabili) | ✅ | ✅ |
| [`while_loop`](#while_loop) | ✅ | ✅ |

## aritmetica

Sorgente: [`conformance/core/cases/aritmetica/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/aritmetica)

```julia
# Triad-Core: interi, precedenza, confronti, logica
println(2 + 3 * 4)
println((2 + 3) * 4)
println(7 % 3)
println(2 ^ 10)
println(10 - 4)
println(-5 + 2)
println(1 < 2)
println(2 == 2)
println(2 != 3)
println(!false)
println(true && true)
println(false || true)
n = 1
n += 41
println(n)
```

Output atteso (`expected.out`):

```text
14
20
1
1024
6
-3
true
true
true
true
true
true
42
```

Exit code atteso: `0`

## begin_block

Sorgente: [`conformance/core/cases/begin_block/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/begin_block)

```julia
# Triad-Core: blocco begin … end
begin
    println(1)
    println(2)
end
println(3)
```

Output atteso (`expected.out`):

```text
1
2
3
```

Exit code atteso: `0`

## chiusura_in_if

Sorgente: [`conformance/core/cases/chiusura_in_if/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/chiusura_in_if)

```julia
n = 10
if n > 5
    f = x -> x + n
    println(f(1))
end
```

Output atteso (`expected.out`):

```text
11
```

Exit code atteso: `0`

## chiusure

Sorgente: [`conformance/core/cases/chiusure/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/chiusure)

```julia
# Triad-Core: lambda e chiusure
function add(n)
    x -> x + n
end

f = add(10)
println(f(5))
g = add(100)
println(g(5))
```

Output atteso (`expected.out`):

```text
15
105
```

Exit code atteso: `0`

## chiusure_local

Sorgente: [`conformance/core/cases/chiusure_local/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/chiusure_local)

```julia
function crea(n)
    m = n * 2
    x -> x + m
end
f = crea(5)
println(f(1))
```

Output atteso (`expected.out`):

```text
11
```

Exit code atteso: `0`

## closure

Sorgente: [`conformance/core/cases/closure/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/closure)

```julia
# Triad-Core: chiusura che cattura il parametro della funzione che la crea
crea = n -> (x -> x + n)
f = crea(10)
g = crea(100)
println(f(5))
println(g(5))
println(f(5))
```

Output atteso (`expected.out`):

```text
15
105
15
```

Exit code atteso: `0`

## confronti

Sorgente: [`conformance/core/cases/confronti/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/confronti)

```julia
# Triad-Core: confronti e valori Bool stampabili
println(1 < 2)
println(2 == 1)
println(3 != 4)
println(1 <= 1)
println(2 > 3)
println(2 >= 2)
```

Output atteso (`expected.out`):

```text
true
false
true
true
false
true
```

Exit code atteso: `0`

## controllo

Sorgente: [`conformance/core/cases/controllo/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/controllo)

```julia
# Triad-Core: if/elseif/else, while, let, begin
x = 0
while x < 3
    println(x)
    x += 1
end

if x == 3
    println("tre")
elseif x > 3
    println("più")
else
    println("meno")
end

let a = 10
    println(a + 5)
end

begin
    println("blocco")
end
```

Output atteso (`expected.out`):

```text
0
1
2
tre
15
blocco
```

Exit code atteso: `0`

## formula

Sorgente: [`conformance/core/cases/formula/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/formula)

```julia
# Calcolo dell'area di un rettangolo: area = base * altezza
function area_rettangolo(base, altezza)
    base * altezza
end

println(area_rettangolo(7, 6))
println(area_rettangolo(3, 5))
```

Output atteso (`expected.out`):

```text
42
15
```

Exit code atteso: `0`

## funzioni

Sorgente: [`conformance/core/cases/funzioni/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/funzioni)

```julia
# Triad-Core: funzioni, forma breve, ricorsione
function somma(a, b)
    a + b
end

quadrato(x) = x * x
fattoriale(n) = n < 2 ? 1 : n * fattoriale(n - 1)
fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)

println(somma(2, 3))
println(quadrato(4))
println(fattoriale(5))
println(fib(10))
```

Output atteso (`expected.out`):

```text
5
16
120
55
```

Exit code atteso: `0`

## funzioni_blocco

Sorgente: [`conformance/core/cases/funzioni_blocco/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/funzioni_blocco)

```julia
# Triad-Core: funzione con corpo a più istruzioni e valore dell'ultima espressione
function calcola(n)
    m = n + 1
    m * 2
end
println(calcola(3))
```

Output atteso (`expected.out`):

```text
8
```

Exit code atteso: `0`

## funzioni_io

Sorgente: [`conformance/core/cases/funzioni_io/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/funzioni_io)

```julia
# Triad-Core: funzione a blocco con output dichiarato
function mostra() !io
    println("hello from block")
    20 + 22
end

println(mostra())
```

Output atteso (`expected.out`):

```text
hello from block
42
```

Exit code atteso: `0`

## funzioni_semplici

Sorgente: [`conformance/core/cases/funzioni_semplici/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/funzioni_semplici)

```julia
# Triad-Core: funzioni in forma breve con parametri
somma(a, b) = a + b
doppio(x) = x * 2
quadrato(x) = x * x
println(somma(2, 3))
println(doppio(5))
println(quadrato(4))
```

Output atteso (`expected.out`):

```text
5
10
16
```

Exit code atteso: `0`

## gcd

Sorgente: [`conformance/core/cases/gcd/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/gcd)

```julia
# Triad-Core: algoritmo di Euclide per MCD
mcd(a, b) = b == 0 ? a : mcd(b, a % b)
println(mcd(48, 18))
println(mcd(100, 25))
println(mcd(7, 0))
```

Output atteso (`expected.out`):

```text
6
25
7
```

Exit code atteso: `0`

## if_else

Sorgente: [`conformance/core/cases/if_else/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/if_else)

```julia
# Triad-Core: if / else / end
x = 3
if x > 2
    println(100)
else
    println(200)
end
if x < 0
    println(300)
end
y = 1
if y > 2
    println(400)
else
    println(500)
end
println(999)
```

Output atteso (`expected.out`):

```text
100
500
999
```

Exit code atteso: `0`

## if_elseif

Sorgente: [`conformance/core/cases/if_elseif/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/if_elseif)

```julia
x = 2
if x == 1
    println(10)
elseif x == 2
    println(20)
elseif x == 3
    println(30)
else
    println(40)
end
x = 3
if x == 1
    println(50)
elseif x == 2
    println(60)
elseif x == 3
    println(70)
else
    println(80)
end
x = 4
if x == 1
    println(90)
elseif x == 2
    println(100)
elseif x == 3
    println(110)
else
    println(120)
end
```

Output atteso (`expected.out`):

```text
20
70
120
```

Exit code atteso: `0`

## if_nested

Sorgente: [`conformance/core/cases/if_nested/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/if_nested)

```julia
x = 2
if x > 1
    if x == 2
        println(10)
    elseif x == 3
        println(20)
    else
        println(30)
    end
else
    println(40)
end
println(50)
```

Output atteso (`expected.out`):

```text
10
50
```

Exit code atteso: `0`

## if_no_else

Sorgente: [`conformance/core/cases/if_no_else/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/if_no_else)

```julia
x = 0
if x > 0
    println(10)
end
println(20)
```

Output atteso (`expected.out`):

```text
20
```

Exit code atteso: `0`

## interi

Sorgente: [`conformance/core/cases/interi/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/interi)

```julia
# Triad-Core: interi, precedenza e parentesi (primo incremento dell'interprete)
println(1 + 2 * 3)
println((1 + 2) * 3)
println(10 - 4)
println(-5 + 2)
println(2 + 3)
println(7)
```

Output atteso (`expected.out`):

```text
7
9
6
-3
5
7
```

Exit code atteso: `0`

## lambda

Sorgente: [`conformance/core/cases/lambda/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/lambda)

```julia
# Triad-Core: lambda a un parametro, anche passate come argomento
doppio = x -> x * 2
base = 10
aggiungi = x -> x + base
applica = f -> f(3)
println(doppio(5))
println(aggiungi(7))
println(applica(x -> x * x))
```

Output atteso (`expected.out`):

```text
10
17
9
```

Exit code atteso: `0`

## let_annidato

Sorgente: [`conformance/core/cases/let_annidato/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/let_annidato)

```julia
x = 1
let x = 10
    let x = 20
        println(x)
    end
    println(x)
end
println(x)
```

Output atteso (`expected.out`):

```text
20
10
1
```

Exit code atteso: `0`

## let_chiusura

Sorgente: [`conformance/core/cases/let_chiusura/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/let_chiusura)

```julia
let n = 10
    f = x -> x + n
    println(f(5))
end
```

Output atteso (`expected.out`):

```text
15
```

Exit code atteso: `0`

## liste

Sorgente: [`conformance/core/cases/liste/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/liste)

```julia
# Triad-Core: liste, indici, push!, lunghezza, iterazione con while
xs = [1, 2, 3]
println(xs[1])
println(length(xs))
push!(xs, 4)
println(xs)

tot = 0
i = 1
while i <= length(xs)
    tot += xs[i]
    i += 1
end
println(tot)
```

Output atteso (`expected.out`):

```text
1
3
[1, 2, 3, 4]
10
```

Exit code atteso: `0`

## liste_base

Sorgente: [`conformance/core/cases/liste_base/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/liste_base)

```julia
xs = [1, 2, 3]
println(xs)
```

Output atteso (`expected.out`):

```text
[1, 2, 3]
```

Exit code atteso: `0`

## liste_push

Sorgente: [`conformance/core/cases/liste_push/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/liste_push)

```julia
lst = []
lst = push!(lst, 10)
alias = lst
lst = push!(lst, 20)
println(alias)
```

Output atteso (`expected.out`):

```text
[10, 20]
```

Exit code atteso: `0`

## nothing_base

Sorgente: [`conformance/core/cases/nothing_base/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/nothing_base)

```julia
println(nothing)
```

Output atteso (`expected.out`):

```text
nothing
```

Exit code atteso: `0`

## operatori

Sorgente: [`conformance/core/cases/operatori/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/operatori)

```julia
# Triad-Core: %, ^ e letterali Bool
println(7 % 3)
println(2 ^ 10)
println(10 % 4)
println(3 ^ 3)
println(true)
println(false)
println(true == true)
```

Output atteso (`expected.out`):

```text
1
1024
2
27
true
false
true
```

Exit code atteso: `0`

## ricorsione

Sorgente: [`conformance/core/cases/ricorsione/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/ricorsione)

```julia
# Triad-Core: confronti, ternario e ricorsione con caso base
fattoriale(n) = n < 2 ? 1 : n * fattoriale(n - 1)
fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)
println(fattoriale(5))
println(fib(10))
```

Output atteso (`expected.out`):

```text
120
55
```

Exit code atteso: `0`

## scope

Sorgente: [`conformance/core/cases/scope/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/scope)

```julia
# Triad-Core: scope lessicale (funzione, let, globali)
x = 1

function f()
    x = 2
    x
end

println(f())
println(x)

let x = 10
    println(x)
end
println(x)
```

Output atteso (`expected.out`):

```text
2
1
10
1
```

Exit code atteso: `0`

## simboli_base

Sorgente: [`conformance/core/cases/simboli_base/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/simboli_base)

```julia
println(:alice)
s = :bob
println(s)
```

Output atteso (`expected.out`):

```text
alice
bob
```

Exit code atteso: `0`

## stringhe

Sorgente: [`conformance/core/cases/stringhe/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/stringhe)

```julia
# Triad-Core: stringhe, concatenazione, lunghezza, conversione
nome = "Triad"
println("ciao " * nome)
println(length(nome))
println(string(42))
```

Output atteso (`expected.out`):

```text
ciao Triad
5
42
```

Exit code atteso: `0`

## stringhe_base

Sorgente: [`conformance/core/cases/stringhe_base/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/stringhe_base)

```julia
# Triad-Core: stringhe letterali, stampa, length
s = "ciao"
println(s)
println(length(s))
```

Output atteso (`expected.out`):

```text
ciao
4
```

Exit code atteso: `0`

## stringhe_concat

Sorgente: [`conformance/core/cases/stringhe_concat/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/stringhe_concat)

```julia
nome = "Triad"
println("ciao " * nome)
println(length(nome))
```

Output atteso (`expected.out`):

```text
ciao Triad
5
```

Exit code atteso: `0`

## stringhe_multi

Sorgente: [`conformance/core/cases/stringhe_multi/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/stringhe_multi)

```julia
a = "x"
b = "y"
c = "z"
println(a * b * c)
println(length(a * b * c))
```

Output atteso (`expected.out`):

```text
xyz
3
```

Exit code atteso: `0`

## valori

Sorgente: [`conformance/core/cases/valori/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/valori)

```julia
# Triad-Core: tipi e valori
x = 42
b = true
s = "ciao"
l = [1, 2, 3]
println(x)
println(b)
println(s)
println(l)
println(:alice)
println(nothing)
```

Output atteso (`expected.out`):

```text
42
true
ciao
[1, 2, 3]
alice
nothing
```

Exit code atteso: `0`

## variabili

Sorgente: [`conformance/core/cases/variabili/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/variabili)

```julia
# Triad-Core: variabili e assegnamenti
x = 42
y = x + 8
println(x)
println(y)
x = x + 1
println(x)
z = (x + y) * 2
println(z + 1)
```

Output atteso (`expected.out`):

```text
42
50
43
187
```

Exit code atteso: `0`

## while_loop

Sorgente: [`conformance/core/cases/while_loop/`](https://github.com/GPuntobit/triad2.0/tree/main/conformance/core/cases/while_loop)

```julia
# Triad-Core: while con aggiornamento di variabili
i = 0
somma = 0
while i < 5
    i = i + 1
    somma = somma + i
end
println(somma)
println(i)
```

Output atteso (`expected.out`):

```text
15
5
```

Exit code atteso: `0`
