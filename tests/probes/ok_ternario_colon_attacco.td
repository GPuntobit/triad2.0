# Ternario con due punti attaccato al ramo ('? 5 :7'): il codice macchina
# scannerless risolve ':' dal contesto; il parser del riferimento JS e il
# front-end S1 (selfhost/source.td) reinterpretano il token SYM come colon
# piu' il resto. Chiuso il 2026-11-02.
t = 1 == 0 ? 5 :7
println(t)
u = 2 > 1 ? 8 :9
println(u)
