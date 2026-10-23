#!/usr/bin/env julia

include(joinpath(@__DIR__, "triad.jl"))
using .Triad

world = World(out = IOBuffer())
source = """
fact parent(:alice, :bob)
fact parent(:bob, :dave)
fact male(:bob)
rule father(?x, ?y) :- parent(?x, ?y), male(?x)
rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)
"""
run_source(world, source)

father = run_source(world, "solve father(?x, :dave)")
grandparent = run_source(world, "solve grandparent(:alice, ?who)")
@assert father == Any[Triad.Solution([:x], Any[:bob])]
@assert grandparent == Any[Triad.Solution([:who], Any[:dave])]
println("Knowledge-base queries passed.")
