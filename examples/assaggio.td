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
