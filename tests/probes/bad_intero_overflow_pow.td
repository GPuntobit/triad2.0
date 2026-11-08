# Overflow in potenza: il risultato esce dal range dei 62 bit del seed (D25)
# -> rifiuto (exit 1), non un numero sbagliato.
println(3 ^ 40)
