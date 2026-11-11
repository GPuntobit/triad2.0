# Gli interi del seed sono limitati a +/- (2^61 - 1) (D25): un valore fuori
# range e' **rifiutato** (exit 1), non eseguito in silenzio come vorrebbe
# SPEC-CORE.md §5 (interi a 64 bit signed con wrap).
x = 9223372036854775807
println(x)
