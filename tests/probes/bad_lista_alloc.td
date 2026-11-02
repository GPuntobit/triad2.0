# Limite misurato del seed: ogni valutazione di un letterale di lista alloca
# 528 byte fissi nell'heap (64 KB totali, bump allocator senza liberazione).
# 150 valutazioni di liste qui sotto: il seed esce per access violation, il
# riferimento JS (heap gestito) stampa normalmente. Sopra ~60 liste il seed
# degrada; il front-end S1 (selfhost/source.td) quindi non usa liste.
function mk2(x)
  r = [x, x + 1]
  r
end
i = 0
s = 0
while i < 150
  t = mk2(i)
  s = s + get(t, 0)
  i = i + 1
end
println(s)
