# Triad-Core: funzioni, forma breve, ricorsione
function somma(a, b)
    a + b
end

quadrato(x) = x * x
fattoriale(n) = n < 2 ? 1 : n * fattoriale(n - 1)
fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)

println(somma(2, 3))
println(quadrato(4))
println(fattoriale(5))
println(fib(10))
