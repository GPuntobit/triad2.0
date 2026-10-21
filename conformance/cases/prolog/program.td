# prolog: regole ricorsive, liste stile Prolog, negazione per fallimento
fact parent(:tom, :bob)
fact parent(:bob, :ann)
fact parent(:bob, :pat)
fact parent(:pat, :jim)

rule ancestor(?a, ?d) :- parent(?a, ?d)
rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)
println([s.d for s in solve ancestor(:tom, ?d)])

rule app([], ?l, ?l)
rule app([?h | ?t], ?l, [?h | ?r]) :- app(?t, ?l, ?r)
println((solve app([1, 2], [3], ?r))[1].r)
println(length(solve app(?a, ?b, [1, 2, 3])))

println(filter(p -> !parent(p, ?_), [:tom, :bob, :ann, :pat, :jim]))
