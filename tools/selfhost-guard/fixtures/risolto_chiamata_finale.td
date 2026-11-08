# D9 risolta — la chiamata in posizione finale e' valutata dal seed.
function k()
  5
end
function g()
  k()
end
v = g()
println(v)
