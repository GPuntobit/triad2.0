function inner(x)
    x * 2
end
function outer(y)
    r = inner(3)
    r
end
println(outer(5))
