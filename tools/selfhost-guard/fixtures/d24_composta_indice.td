# D24 — l'assegnazione composta a indice `xs[i] += v` non esiste nel seed
# (la forma `xs[i] = v` e' invece implementata).
xs = [1, 2, 3]
xs[1] += 1
println(xs[1])
