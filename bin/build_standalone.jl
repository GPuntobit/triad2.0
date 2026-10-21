#!/usr/bin/env julia
# =====================================================================
#  build_standalone.jl — crea un eseguibile standalone di Triad
#
#  Usa PackageCompiler.jl per compilare triad.jl in un binario nativo
#  che NON richiede Julia installato. Il risultato è bin/triad-native
#  (o triad-native.exe su Windows).
#
#  Uso:
#    julia --startup-file=no bin/build_standalone.jl          # compila
#    triad --build                                             # scorciatoia
#
#  Requisiti:
#    - Julia ≥ 1.6
#    - Pacchetto PackageCompiler (installato automaticamente se assente)
#
#  Nota: la prima compilazione può richiedere alcuni minuti e ~2 GB di
#  spazio temporaneo. Il binario finale è tipicamente 80-150 MB.
# =====================================================================

using Pkg

# Assicura che PackageCompiler sia disponibile
println("==> Verifica PackageCompiler...")
try
    using PackageCompiler
catch
    println("==> Installazione PackageCompiler...")
    Pkg.activate(temp = true)
    Pkg.add("PackageCompiler")
    using PackageCompiler
end

triad_home = dirname(dirname(abspath(@__FILE__)))
triad_jl   = joinpath(triad_home, "triad.jl")
output_dir = joinpath(triad_home, "bin")
app_name   = Sys.iswindows() ? "triad-native.exe" : "triad-native"
app_path   = joinpath(output_dir, app_name)

println("==> Compilazione Triad standalone...")
println("    Sorgente:  $triad_jl")
println("    Output:    $app_path")
println("    Piattaforma: $(Sys.MACHINE)")
println()

# Crea una sysimage + eseguibile
# Il precompile script esegue le funzioni principali per includerle nell'immagine
precompile_file = joinpath(triad_home, "bin", "_precompile_triad.jl")

# Genera uno script di precompilazione minimale
if !isfile(precompile_file)
    write(precompile_file, """
    # Precompilazione per lo standalone Triad
    using Triad
    w = Triad.World()
    Triad.run_source(w, "x = 1 + 2")
    Triad.run_source(w, "fact parent(:a, :b)")
    Triad.parse_program("function f(x::Int)::Int; x + 1; end")
    Triad.tshow(42)
    Triad.sexpr(Triad.Node(:call, Any[:+, 1, 2]))
    """)
end

try
    create_app(
        triad_home,           # package dir (contiene triad.jl come modulo)
        output_dir;           # directory di output
        app_name = "triad-native",
        precompile_execution_file = precompile_file,
        force = true,
        c_driver_program = nothing,
    )
    println()
    println("✓ Compilazione completata!")
    println("  Eseguibile: $app_path")
    println()
    println("Uso:")
    println("  $app_path                    # REPL")
    println("  $app_path file.td arg1 arg2  # esegui un file")
    println("  $app_path --help             # aiuto")
catch e
    println(stderr, "✗ Errore durante la compilazione: $e")
    println(stderr)
    println(stderr, "Alternative:")
    println(stderr, "  - Assicurati che triad.jl sia caricabile come pacchetto")
    println(stderr, "  - Prova: julia -e 'using Pkg; Pkg.activate(\".\"); Pkg.add(\"PackageCompiler\")'")
    println(stderr, "  - Oppure usa i launcher triad/triad.cmd che cercano Julia automaticamente")
    exit(1)
end
