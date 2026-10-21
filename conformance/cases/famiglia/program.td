# famiglia.td — Prolog dentro Triad: fatti, regole, ricorsione, liste

fact parent(:tom, :bob)
fact parent(:tom, :liz)
fact parent(:bob, :ann)
fact parent(:bob, :pat)
fact parent(:pat, :jim)
fact female(:liz)
fact female(:ann)
fact female(:pat)

rule mother(?m, ?c) :- parent(?m, ?c), female(?m)
rule sibling(?a, ?b) :- parent(?p, ?a), parent(?p, ?b), ?a != ?b
rule ancestor(?a, ?d) :- parent(?a, ?d)
rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)

# solve restituisce una lista: si filtra e si trasforma con il resto del linguaggio
discendenti = [s.d for s in solve ancestor(:tom, ?d)]
println("discendenti di tom: ", discendenti)
println("fratelli di ann: ", [s.b for s in solve sibling(:ann, ?b)])
println("madri: ", [string(s.m, " -> ", s.c) for s in solve mother(?m, ?c)])

# negazione per fallimento: chi non ha figli?
persone = [:tom, :bob, :liz, :ann, :pat, :jim]
foglie = filter(p -> !parent(p, ?_), persone)
println("senza figli: ", foglie)

# aritmetica nei goal con `is`, e una funzione Triad usata come goal
fact born(:tom, 1950)
fact born(:bob, 1975)
fact born(:pat, 2001)
rule age(?p, ?a) :- born(?p, ?y), ?a is 2026 - ?y
over50(a::Int) = a > 50
println("over 50: ", [s.p for s in solve age(?p, ?a) && over50(?a)])

# liste in stile Prolog: [testa | coda]
rule app([], ?l, ?l)
rule app([?h | ?t], ?l, [?h | ?r]) :- app(?t, ?l, ?r)
println("modi di spezzare [1, 2, 3]:")
for s in solve app(?a, ?b, [1, 2, 3])
    println("  ", s.a, " ++ ", s.b)
end

# un identificatore nudo in un termine è un valore dell'host
chi = :bob
println("figli di ", chi, ": ", [s.c for s in solve parent(chi, ?c)])
