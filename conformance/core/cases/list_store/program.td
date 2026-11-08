xs = [1, 2, 3]
xs[2] = 9
println(xs[2])
function change(ys)
    ys[1] = 7
    ys[3] = ys[2] + 1
    ys[3]
end
println(change(xs))
println(xs[1])
println(xs[2])
