# test/oracles/oracle_tests.jl — cross-check TRIAD contro SWI-Prolog, SBCL e Julia.
using Test
include(joinpath(@__DIR__, "..", "..", "triad.jl"))
using .Triad

const JULIA_EXE = get(ENV, "TRIAD_ORACLE_JULIA", something(Sys.which("julia"), ""))
const SWIPL_EXE = get(ENV, "TRIAD_ORACLE_SWIPL", something(Sys.which("swipl"), ""))
const SBCL_EXE = get(ENV, "TRIAD_ORACLE_SBCL", something(Sys.which("sbcl"), ""))

function run_cmd(cmd; input::String="")
    isempty(input) ? read(cmd, String) : read(pipeline(cmd, stdin=IOBuffer(input)), String)
end

function normalize(s::AbstractString)
    lines = [strip(l) for l in split(String(s), '\n') if !isempty(strip(l))]
    return join(lines, "\n")
end

"Esegue sorgente Triad e restituisce (stdout, valore)."
function triad_run(src::AbstractString)
    w = World(out=IOBuffer())
    v = run_source(w, src)
    return String(take!(w.out)), v
end

if isfile(SWIPL_EXE)
    @testset "Oracle: SWI-Prolog vs Triad (famiglia)" begin
        plfile = tempname()
        write(plfile, """
        parent(tom, bob). parent(tom, liz). parent(bob, ann). parent(bob, pat). parent(pat, jim).
        female(liz). female(ann). female(pat).
        mother(M, C) :- parent(M, C), female(M).
        ancestor(A, D) :- parent(A, D).
        ancestor(A, D) :- parent(A, X), ancestor(X, D).
        """)

        # --- mother(M, C) ---
        pl_out = run_cmd(`$SWIPL_EXE -s $plfile -g "mother(M,C), format('~w,~w~n',[M,C]), fail; true." -t halt`)
        triad_src = """
        fact parent(:tom, :bob)
        fact parent(:tom, :liz)
        fact parent(:bob, :ann)
        fact parent(:bob, :pat)
        fact parent(:pat, :jim)
        fact female(:liz)
        fact female(:ann)
        fact female(:pat)
        rule mother(?m, ?c) :- parent(?m, ?c), female(?m)
        [println(s.m, ",", s.c) for s in solve mother(?m, ?c)]
        """
        td_out, _ = triad_run(triad_src)
        @test normalize(td_out) == normalize(pl_out)

        # --- ancestor(tom, D) ---
        pl_out = run_cmd(`$SWIPL_EXE -s $plfile -g "ancestor(tom,D), format('~w~n',[D]), fail; true." -t halt`)
        triad_src = """
        fact parent(:tom, :bob)
        fact parent(:tom, :liz)
        fact parent(:bob, :ann)
        fact parent(:bob, :pat)
        fact parent(:pat, :jim)
        rule ancestor(?a, ?d) :- parent(?a, ?d)
        rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)
        [println(s.d) for s in solve ancestor(:tom, ?d)]
        """
        td_out, _ = triad_run(triad_src)
        @test normalize(td_out) == normalize(pl_out)
    end
else
    @testset "Oracle: SWI-Prolog vs Triad (saltato)" begin
        @test_skip true
    end
end

if isfile(SBCL_EXE)
    @testset "Oracle: SBCL vs Triad (closure / lambda)" begin
        lispfile = tempname()
        write(lispfile, """
        (defun mk (a b) (+ a b))
        (format t "~a~%" (mk 10 20))
        (defun fattorial (n) (if (<= n 1) 1 (* n (fattorial (- n 1)))))
        (format t "~a~%" (fattorial 10))
        (quit)
        """)
        lisp_out = normalize(run_cmd(`$SBCL_EXE --noinform --load $lispfile`))

        td_src = """
        mk = (a, b) -> a + b
        println(mk(10, 20))
        function fattorial(n::Int)
            if n <= 1
                return 1
            end
            n * fattorial(n - 1)
        end
        println(fattorial(10))
        """
        td_out, _ = triad_run(td_src)
        @test normalize(td_out) == lisp_out
    end
else
    @testset "Oracle: SBCL vs Triad (saltato)" begin
        @test_skip true
    end
end

if isfile(JULIA_EXE)
    @testset "Oracle: Julia vs Triad (multiple dispatch)" begin
        julia_src = """
        area(n::Number) = :number
        area(n::Int) = :int
        println(area(1))
        println(area(1.5))
        """
        julia_out = normalize(run_cmd(`$JULIA_EXE --startup-file=no -e $julia_src`))

        td_src = """
        area(n::Number) = :number
        area(n::Int) = :int
        println(area(1))
        println(area(1.5))
        """
        td_out, _ = triad_run(td_src)
        @test normalize(td_out) == julia_out
    end
else
    @testset "Oracle: Julia vs Triad (saltato)" begin
        @test_skip true
    end
end
