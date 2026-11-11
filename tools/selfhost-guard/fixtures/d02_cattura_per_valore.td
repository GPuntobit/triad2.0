# D2 — cattura per valore: `n` e' catturato dalla chiusura e poi riassegnato.
n = 1
f = x -> x + n
n = 2
v = f(0)
println(v)
