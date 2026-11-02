# Arity limite del seed: le funzioni accettano al massimo 4 parametri
# (st_function/st_func contano 16 byte per parametro fino a 64). Il riferimento
# JS non ha il limite. SPEC-CORE non impone arita' massima.
function f5(a, b, c, d, e)
  r = a + b + c + d + e
  r
end
println(f5(1, 2, 3, 4, 5))
