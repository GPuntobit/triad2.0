# Triad-Core: ternario con simbolo nel ramo *then*
# (SPEC.md §1: il separatore del ternario è un ':' circondato da spazi —
#  il ':' di un simbolo ':nome' non è un separatore)
f(n) = n == 1 ? :intero : :numero
println(f(1))
println(f(2))

# controllo: il simbolo nel ramo *else* non confonde il seed
g(n) = n == 1 ? 1 : :numero
println(g(2))

# Entrambi i rami, iniziali maiuscole e underscore, ternari annidati.
println(true ? :Alpha : :Beta)
println(false ? :Alpha : :Beta)
println(true ? :_yes : :_no)
println(false ? :_yes : :_no)
println(false ? (true ? :a : :b) : :c)
println(true ? (false ? :a : :b) : :c)
println(false ? :a : (true ? :b : :c))
# Il ramo non scelto non deve essere valutato.
println(false ? missing_name : :safe)
println(true ? :safe : missing_name)
