include("C:/Users/xbos/Documents/progetti/triad2.0/triad.jl")
println("=== unify stages ===")
a = [Symbol(:male), Symbol(:bob)]
b = [Symbol(:male), Symbol(:bob)]
println("A) t===u: ", a === b)
println("B) unify(:male,:male) = ", unify(Symbol(:male), Symbol(:male)))
println("C) unify([m],[m]) = ", unify([Symbol(:male)], [Symbol(:male)]))
s = PSub()
println("D) apply_sub(a, s) = ", apply_sub(a, s), " isa Vector{Any}: ", apply_sub(a, s) isa Vector{Any})
println("E) unify(a,b) = ", unify(a, b))
println("F) unify([:m],[:m]) via apply first:")
print("   ")
try
    print(unify(a, b, PSub()))
catch e
    print("ERR ", e)
end
println()
# also test leaf leaf
println("G) unify(Symbol(:m), Symbol(:m)) = ", unify(Symbol(:m), Symbol(:m)))
println("H) t isa Symbol for a[1]: ", a[1] isa Symbol)
