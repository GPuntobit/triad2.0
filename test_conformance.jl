#!/usr/bin/env julia
include(joinpath(@__DIR__, "conformance", "run.jl"))
(code, out) = run_case("conformance/cases/assaggio")
println("code=")
println(code)
println("out=")
print(out)
println("out_len=", length(out))