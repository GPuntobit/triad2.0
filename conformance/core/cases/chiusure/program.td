# Triad-Core: lambda e chiusure
function add(n)
    x -> x + n
end

f = add(10)
println(f(5))
g = add(100)
println(g(5))
