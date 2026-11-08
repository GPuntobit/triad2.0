# Triad-Core: ternario con simbolo nel ramo *then*
# (SPEC.md §1: il separatore del ternario è un ':' circondato da spazi —
#  il ':' di un simbolo ':nome' non è un separatore)
f(n) = n == 1 ? :intero : :numero
println(f(1))
println(f(2))

# controllo: il simbolo nel ramo *else* non confonde il seed
g(n) = n == 1 ? 1 : :numero
println(g(2))
