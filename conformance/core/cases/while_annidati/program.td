# Triad-Core: while annidati, break sul ciclo piu' interno, uscita con variabile di stato
i = 1
while i <= 2
    j = 1
    while j <= 3
        if j == 2
            break
        end
        println(string(i) * "-" * string(j))
        j += 1
    end
    i += 1
end

esci = false
a = 1
while a <= 3 && !esci
    b = 1
    while b <= 3 && !esci
        if a * b == 6
            esci = true
        else
            println(string(a) * "x" * string(b) * " = " * string(a * b))
        end
        b += 1
    end
    a += 1
end
println("fine")
