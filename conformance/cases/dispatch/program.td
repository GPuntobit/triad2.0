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
