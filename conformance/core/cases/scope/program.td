# Triad-Core: scope lessicale (funzione, let, globali)
x = 1

function f()
    x = 2
    x
end

println(f())
println(x)

let x = 10
    println(x)
end
println(x)
