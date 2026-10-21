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
