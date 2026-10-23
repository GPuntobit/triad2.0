#!/usr/bin/env julia

include(joinpath(@__DIR__, "triad.jl"))
using .Triad

a = Triad.Term(:male, Any[:bob])
b = Triad.Term(:male, Any[:bob])
@assert Triad.unify!(a, b, Triad.Store())

x = Triad.TVar(:x)
cyclic = Triad.Term(:f, Any[x])
@assert !Triad.unify!(x, cyclic, Triad.Store())
println("Unification and occurs-check passed.")
