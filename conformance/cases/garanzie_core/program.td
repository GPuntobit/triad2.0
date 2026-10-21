# garanzie: contratti, budget, tracce, effetti (senza gensym instabili)
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end
println(safe_div(10, 4))
e = try safe_div(1, 0) end
println(e.kind, " ", e.data.clause)

r = with budget(steps = 2000)
    i = 0
    while true
        i += 1
    end
end
println(r.kind)

fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)
t = with trace
    fib(5)
end
println(t.result, " ", length(t.trace))

function saluta(n::String) !io
    println("ciao ", n)
end
saluta("Triad")

function rumorosa(x)
    println(x)
end
println((try rumorosa(1) end).kind)
