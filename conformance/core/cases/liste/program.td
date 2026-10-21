# Triad-Core: liste, indici, push!, lunghezza, iterazione con while
xs = [1, 2, 3]
println(xs[1])
println(length(xs))
push!(xs, 4)
println(xs)

tot = 0
i = 1
while i <= length(xs)
    tot += xs[i]
    i += 1
end
println(tot)
