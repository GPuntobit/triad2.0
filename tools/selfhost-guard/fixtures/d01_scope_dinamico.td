# D1 — scope dinamico: `g` e' un globale letto in `lettore` e locale in `chiamante`.
g = 1
function lettore()
  g
end
function chiamante()
  g = 2
  r = lettore()
  r
end
v = chiamante()
println(v)
