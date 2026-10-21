# Triad-Core: chiusura che cattura il parametro della funzione che la crea
crea = n -> (x -> x + n)
f = crea(10)
g = crea(100)
println(f(5))
println(g(5))
println(f(5))