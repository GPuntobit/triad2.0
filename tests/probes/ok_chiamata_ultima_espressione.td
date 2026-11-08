function inner(x)
    length(x)
end
function outer(y)
    inner("abcd")
end
println(outer(5))
