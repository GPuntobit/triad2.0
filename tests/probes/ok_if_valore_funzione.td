function fib(n)
    if n < 2
        n
    else
        fib(n - 1) + fib(n - 2)
    end
end
function dist(a, b)
    a + b
end
println(fib(10))
println(dist(2, 3))
