# macro.td — il codice è dato (Lisp), con la faccia di Julia

# un pezzo di codice è un valore: un albero con head e args
c = :(a.x + f(b, 2))
println("codice:  ", c)
println("head:    ", c.head)
println("args:    ", c.args)
println("sexpr:   ", sexpr(c))

# $ inserisce valori nel codice; eval lo esegue
n = 7
quadrato = :($n * $n)
println(quadrato, " = ", eval(quadrato))

# parse/unparse: testo <-> albero
t = parse("if x > 0; :pos; else; :neg; end")
println("parse:   ", sexpr(t))
println("unparse: ", unparse(t))

# macro: ricevono codice, restituiscono codice
macro unless(c, body)
    :(if !$c; $body; end)
end

macro swap(a, b)
    tmp = gensym(:tmp)            # nome fresco: niente catture accidentali
    quote
        $tmp = $a
        $a = $b
        $b = $tmp
    end
end

macro time_it(label, e)
    :(begin
        r = $e
        println($label, " -> ", r)
        r
    end)
end

x = 1
y = 2
@swap(x, y)
println("dopo @swap: x = ", x, ", y = ", y)
@unless(x < y, println("x non è minore di y"))
@time_it("somma", reduce(+, 1:100))

# costruire codice con un programma: un polinomio come albero
function poly(coeffs)
    acc = :(0)
    i = 0
    for c in coeffs
        acc = :($acc + $c * x ^ $i)
        i += 1
    end
    acc
end
p = poly([1, 2, 3])
println("polinomio: ", p)
x = 2
println("p(2) = ", eval(p))
