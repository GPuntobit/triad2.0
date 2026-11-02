# Scope dinamico vs lessicale: sul seed la ricerca del nome in una funzione
# parte dal frame del chiamante (env_find scorre tutti i frame attivi), sul
# riferimento JS lo scope e' lessicale. p2 dentro inner vale 100 sul seed e 7
# sul JS. selfhost/source.td rinomina i locali che collidevano con p0..p9.
p2 = 7
function inner(x)
  r = p2 + x
  r
end
function outer(p2)
  r = inner(1)
  r
end
println(outer(100))
