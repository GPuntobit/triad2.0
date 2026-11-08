# Overflow in moltiplicazione: il risultato esce dal range dei 62 bit del
# seed (D25) -> rifiuto (exit 1), non un numero sbagliato.
x = 1152921504606846976
println(x * 2)
