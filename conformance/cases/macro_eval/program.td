# macro_eval: quote, sexpr, parse/unparse, macro
c = :(a.x + f(b, 2))
println(c.head)
println(sexpr(c))

n = 7
q = :($n * $n)
println(eval(q))

t = parse("if x > 0; :pos; else; :neg; end")
println(unparse(t))

macro unless(c, body)
    :(if !$c; $body; end)
end
@unless(2 > 3, println("non maggiore"))
