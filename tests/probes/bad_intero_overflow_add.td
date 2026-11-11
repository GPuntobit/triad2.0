# Overflow in addizione: il risultato esce dal range dei 62 bit del seed
# (D25) -> il seed rifiuta il programma (exit 1), non stampa un numero
# sbagliato (SPEC-CORE.md §5 vuole il wrap a 64 bit).
x = 2305843009213693951
println(x + 1)
