# Gli interi del seed sono limitati a +/- (2^61 - 1) (D25): il valore
# esce sbagliato senza errore (silent), non come in SPEC-CORE.md §5.
x = 9223372036854775807
println(x)
