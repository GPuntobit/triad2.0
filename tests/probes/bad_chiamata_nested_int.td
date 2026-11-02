function inner(x)
    x * 2
end
function outer(x)
    inner(x) + 1
end
println(outer(5))
