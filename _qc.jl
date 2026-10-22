
include("C:/Users/xbos/Documents/progetti/triad2.0/triad.jl"); using .Triad
T = Triad
println("QC1: ", T.unparse(T.parse_program("1:n")))
println("QC2: ", T.run_source(T.World(out=IOBuffer()), "xs = [1,2,3]\nxs[end] = 7\nxs"))
println("QC3: ", T.run_source(T.World(out=IOBuffer()), "f = function (x::Int) x end\nf(3)"))
