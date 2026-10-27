# Triad-Core: funzioni, chiusure e cicli
fattoriale(n) = n < 2 ? 1 : n * fattoriale(n - 1)
crea = n -> (x -> x + n)
piu10 = crea(10)

i = 1
while i <= 5
    println(string(i) * "! = " * string(fattoriale(i)))
    i = i + 1
end
println("ciao " * "Triad, " * string(piu10(32)))
