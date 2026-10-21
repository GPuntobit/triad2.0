# Triad-Core: if/elseif/else, while, let, begin
x = 0
while x < 3
    println(x)
    x += 1
end

if x == 3
    println("tre")
elseif x > 3
    println("più")
else
    println("meno")
end

let a = 10
    println(a + 5)
end

begin
    println("blocco")
end
