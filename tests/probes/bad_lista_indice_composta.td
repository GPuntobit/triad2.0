# L'assegnazione composta a indice non e' implementata dal seed (D24):
# `xs[i] = v` funziona, `xs[i] += v` no (exit 1).
xs = [1, 2, 3]
xs[1] += 1
println(xs[1])
