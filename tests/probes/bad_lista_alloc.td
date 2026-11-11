# Limite misurato del seed: ogni valutazione di un letterale di lista alloca
# 528 byte fissi nell'heap (8 MiB totali dopo N20, bump allocator senza
# liberazione). 20000 valutazioni di liste qui sotto: il seed esaurisce l'heap
# ed esce con codice 1, il riferimento JS (heap gestito) stampa normalmente.
# Il ciclo non chiama funzioni per non saturare prima l'ambiente (32 byte per
# binding): il limite misurato qui e' quello dell'heap.
i = 0
while i < 20000
  t = [i, i + 1]
  i = i + 1
end
println(i)
