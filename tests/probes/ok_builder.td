function elenco(n)
    r = "<ul>"
    i = 0
    while i < n
        r = r * "<li>"
        r = r * string(i)
        r = r * "</li>"
        i += 1
    end
    r = r * "</ul>"
    r
end
println(elenco(3))
