function classify(n)
    r = "altro"
    if n == 0
        r = "zero"
    else
        r = "nonzero"
    end
    r
end
println(classify(0))
println(classify(7))
