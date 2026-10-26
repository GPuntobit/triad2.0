# Run-tests.jl for Triad
# This script runs the quick-check and smoke tests for the Triad interpreter.

# Load the Triad source
include(joinpath(@__DIR__, "..", "src", "triad.jl"))

using .Triad

# Run quick checks
println("Running quick-check tests...")
@assert Triad.unparse(Triad.parse_program("1:n")) == "1:n"
@assert Triad.run_source(Triad.World(out = IOBuffer()), "xs = [1,2,3]\nxs[end] = 7\nxs") == Any[1, 2, 7]
@assert Triad.run_source(Triad.World(out = IOBuffer()), "f = function (x::Int) x end\nf(3)") == 3
println("Quick checks passed.")

# Smoke test: just print version
println("Smoke test: Julia version = ", VERSION)

println("All tests passed!")