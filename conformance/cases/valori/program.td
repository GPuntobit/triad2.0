# valori: numeri, stringhe, liste, comprehension
x = 2
y = 21
println(x * y)
println(7 / 2)
println("ab" * "cd")
xs = [1, 2, 3]
println(xs[2])
println(length([:a, :b]))
println(sum([1, 2, 3, 4]))
sq(n) = n * n
println(map(sq, [1, 2, 3]))
println(reduce(+, 1:4))
println(filter(x -> x % 2 == 0, 1:6))
println([x^2 for x in 1:4 if x > 2])
println(3 > 2 ? :grande : :piccolo)
