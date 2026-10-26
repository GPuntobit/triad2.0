#!/usr/bin/env julia
# =====================================================================
#  conformance/run.jl — generatore/verificatore di conformita'
#
#  Strumento TEMPORANEO di sviluppo (fase 0): usa lo stage0 Julia per
#  produrre e verificare i golden. Non fa parte della catena di
#  bootstrap S0->S4 e non sara' necessario quando il runner sara'
#  `triad --conformance DIR`, implementato in Triad.
#
#  Uso:
#    julia --startup-file=no conformance/run.jl [--cases DIR] [--update]
#
#    --cases DIR   directory dei casi (default: conformance/cases)
#                  profilo Core: --cases conformance/core/cases
#    --update      rigenera i golden (expected.out / expected.code)
# =====================================================================

include(joinpath(@__DIR__, "..", "src", "triad.jl"))
using .Triad

function parse_opts(argv)
    cases = joinpath(@__DIR__, "cases")
    update = false
    i = 1
    while i <= length(argv)
        a = argv[i]
        if a == "--update"
            update = true
        elseif a == "--cases"
            i == length(argv) && error("--cases vuole una directory")
            cases = abspath(argv[i + 1])
            i += 1
        else
            error("opzione sconosciuta: $a")
        end
        i += 1
    end
    return cases, update
end

"Esegue un caso come script: restituisce (exit_code, stdout)."
function run_case(dir::AbstractString)
    prog = abspath(joinpath(dir, "program.td"))
    args = String[]
    af = joinpath(dir, "args.txt")
    if isfile(af)
        args = [replace(l, "\r" => "") for l in readlines(af)]
    end
    w = Triad.World(out = IOBuffer())
    w.globals.vars[:ARGS] = Any[args...]
    s = Triad.Session(w, String[], args)
    ok = Triad.load_file!(s, prog)
    return (ok ? 0 : 1), String(take!(w.out))
end

case_dirs(cases) = sort([d for d in readdir(cases, join = true)
                         if isdir(d) && isfile(joinpath(d, "program.td"))])

function check_or_update(cases::AbstractString, update::Bool)
    fails = 0
    for dir in case_dirs(cases)
        name = basename(dir)
        code, out = run_case(dir)
        if update
            write(joinpath(dir, "expected.out"), out)
            write(joinpath(dir, "expected.code"), string(code))
            println("aggiornato  ", name)
        else
            eout = isfile(joinpath(dir, "expected.out")) ? read(joinpath(dir, "expected.out"), String) : ""
            ecode = isfile(joinpath(dir, "expected.code")) ?
                    parse(Int, strip(read(joinpath(dir, "expected.code"), String))) : 0
            ok = out == eout && code == ecode
            if ok
                println("PASS  ", name)
            else
                fails += 1
                println("FAIL  ", name, "  (exit $code, atteso $ecode, ",
                        "stdout ", ncodeunits(out), " byte, attesi ", ncodeunits(eout), ")")
            end
        end
    end
    if update
        println("golden aggiornati")
        return 0
    end
    println(fails == 0 ? "conformance: OK" : "conformance: $fails casi falliti")
    return fails == 0 ? 0 : 1
end

cases, update = parse_opts(ARGS)
exit(check_or_update(cases, update))
