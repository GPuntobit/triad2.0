include("C:/Users/xbos/Documents/progetti/triad2.0/triad.jl")
println("\n===== DIAGNOSI =====")
w = World(); env = Env()
run_program(w, load_program("(fact (male bob)) (fact (color red)) (rule (father X Y) (parent X Y) (male X))"), env)
println("1) KB size = ", length(w.kb), "  prednames = ", collect(w.prednames))
cl = w.kb[1]
println("2) kb[1].head = ", cl.head, "  isa Vector{Any} = ", cl.head isa Vector{Any})
g = [Symbol(:male), Symbol(:bob)]
println("3) unify(kb[1].head, g) = ", unify(cl.head, g))
println("4) sld(male bob) => ", sld(w.kb, [g]))
gc = [Symbol(:color), TVar(Symbol("_1"))]
print("5) sld(color _) => ")
for s in sld(w.kb, gc)
    println("  ", s)
end
