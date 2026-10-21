# Triad-Core: confronti, ternario e ricorsione con caso base
fattoriale(n) = n < 2 ? 1 : n * fattoriale(n - 1)
fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)
println(fattoriale(5))
println(fib(10))