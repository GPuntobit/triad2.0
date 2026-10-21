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
