# Triad-Core: algoritmo di Euclide per MCD
mcd(a, b) = b == 0 ? a : mcd(b, a % b)
println(mcd(48, 18))
println(mcd(100, 25))
println(mcd(7, 0))
