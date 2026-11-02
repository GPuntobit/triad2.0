function fib(n)
    r = 0
    if n < 2
        r = n
    else
        r = fib(n - 1) + fib(n - 2)
    end
    r
end
println(fib(10))
