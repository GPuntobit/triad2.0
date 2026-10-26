#!/usr/bin/env julia
# =====================================================================
#  ai/verify.jl — esegue le soluzioni generate da un LLM e le confronta
#  con i golden dei task (stdout + exit code).
#
#  Strumento di sviluppo: usa lo stage0 Julia per eseguire il codice
#  Triad generato. Non fa parte della catena S0->S4.
#
#  Uso:
#    julia --startup-file=no ai/verify.jl [--tasks DIR] [--verbose]
# =====================================================================

include(joinpath(@__DIR__, "..", "src", "triad.jl"))
using .Triad

function parse_opts(argv)
    tasks = joinpath(@__DIR__, "tasks")
    verbose = false
    i = 1
    while i <= length(argv)
        a = argv[i]
        if a == "--tasks"
            i == length(argv) && error("--tasks vuole una directory")
            tasks = abspath(argv[i + 1])
            i += 1
        elseif a == "--verbose"
            verbose = true
        else
            error("opzione sconosciuta: $a")
        end
        i += 1
    end
    return tasks, verbose
end

"Esegue solution.triad in un World isolato: (exit_code, stdout)."
function run_solution(path::AbstractString)
    w = Triad.World(out = IOBuffer())
    w.globals.vars[:ARGS] = Any[]
    s = Triad.Session(w, String[], String[])
    ok = Triad.load_file!(s, path)
    return (ok ? 0 : 1), String(take!(w.out))
end

task_dirs(tasks) = sort([d for d in readdir(tasks, join = true)
                         if isdir(d) && isfile(joinpath(d, "task.md"))])

function main()
    tasks, verbose = parse_opts(ARGS)
    dirs = isfile(joinpath(tasks, "task.md")) ? [tasks] : task_dirs(tasks)
    isempty(dirs) && error("nessun task trovato in $tasks")
    fails = 0
    missing = 0
    for dir in dirs
        name = basename(dir)
        sol = joinpath(dir, "solution.triad")
        if !isfile(sol)
            println("SKIP  ", name, "  (manca solution.triad)")
            missing += 1
            continue
        end
        expected_out = isfile(joinpath(dir, "expected.out")) ?
                       read(joinpath(dir, "expected.out"), String) : ""
        expected_code = isfile(joinpath(dir, "expected.code")) ?
                        parse(Int, strip(read(joinpath(dir, "expected.code"), String))) : 0
        code, out = run_solution(sol)
        ok = code == expected_code && out == expected_out
        if ok
            println("PASS  ", name)
        else
            fails += 1
            println("FAIL  ", name, "  (exit $code, atteso $expected_code; ",
                    "stdout ", ncodeunits(out), " byte, attesi ", ncodeunits(expected_out), ")")
            if verbose
                println("--- stdout ottenuto ---")
                print(out)
                println("--- stdout atteso ---")
                print(expected_out)
                println("----------------------")
            end
        end
    end
    println()
    println("task: ", length(dirs), "  pass: ", length(dirs) - fails - missing,
            "  fail: ", fails, "  skip: ", missing)
    exit(fails == 0 ? 0 : 1)
end

main()
