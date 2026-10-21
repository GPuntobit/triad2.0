# Triad-Core: lambda a un parametro, anche passate come argomento
doppio = x -> x * 2
base = 10
aggiungi = x -> x + base
applica = f -> f(3)
println(doppio(5))
println(aggiungi(7))
println(applica(x -> x * x))