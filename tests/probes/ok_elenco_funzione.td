function riga(n)
    s = "<li>"
    s = s * string(n)
    s = s * "</li>"
    s
end
i = 0
while i < 3
    println(riga(i))
    i += 1
end
