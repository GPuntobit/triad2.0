# Triad-Core: while true con break (sentinella) e contatore
p = 1
conta = 0
while true
    if p >= 1000
        break
    end
    conta += 1
    p = p * 2
end
println(conta)
