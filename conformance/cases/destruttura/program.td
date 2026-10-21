# destrutturazione: assegnamento multiplo, for su coppie, errore di arità
(a, b) = [10, 32]
println(a + b)

tot = 0
for (k, v) in [[1, 2], [3, 4]]
    tot += k + v
end
println(tot)

e = try (a, b) = [1] end
println(e.kind)
