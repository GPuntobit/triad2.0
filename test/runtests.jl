# test/runtests.jl — julia --startup-file=no test/runtests.jl
using Test
include(joinpath(@__DIR__, "..", "triad.jl"))
using .Triad
const T = Triad

"Esegue sorgente in un mondo nuovo: (valore, output stampato)."
function run(src)
    w = T.World(out = IOBuffer())
    v = T.run_source(w, src)
    v, String(take!(w.out))
end
val(src) = run(src)[1]
out(src) = run(src)[2]
"L'Err sollevato (o restituito) da src."
function err(src)
    v = T.eval_source(T.World(out = IOBuffer()), src)
    @assert v isa T.Err "atteso un Err, ottenuto $(T.tshow(v))"
    v
end
N(h, xs...) = T.Node(h, Any[xs...])
ptop(src) = T.parse_program(src).args[1]

@testset "Triad" begin

@testset "lessico e parser" begin
    @test ptop("x = 1 + 2 * 3") == N(:assign, :x, N(:call, :+, 1, N(:call, :*, 2, 3)))
    @test ptop("-x^2") == N(:call, :-, N(:call, :^, :x, 2))
    @test ptop("1:n") == N(:call, Symbol(":"), 1, :n)
    @test err("1: 2").kind === :syntax
    @test ptop("f(:a, ?x, ?_)").args[2] == N(:sym, :a)
    @test ptop("f(:a, ?x)").args[3] == T.TVar(:x)
    @test ptop("a.x != b.x || c") ==
          N(:or, N(:call, Symbol("!="), N(:dot, :a, :x), N(:dot, :b, :x)), :c)
    @test ptop("xs[2:end]") == N(:index, :xs, N(:call, Symbol(":"), 2, Symbol("end")))
    @test ptop("x -> x + 1") == N(:lambda, N(:tuple, :x), N(:call, :+, :x, 1))
    @test ptop("reduce(+, xs)") == N(:call, :reduce, :+, :xs)
    @test ptop("[h | t]") == N(:cons, N(:list, :h), :t)
    @test ptop("[x for x in xs if x > 1]").head === :comprehension
    @test ptop("\"a \$x b \$(y + 1)\"") == N(:string, "a ", :x, " b ", N(:call, :+, :y, 1))
    quoted_paren = "x = \"value \$(" * "\")\"" * ")\""
    @test val(quoted_paren) == "value )"
    multiline_interpolation = "x = \"" * '$' * "(1 +\n 2)\"\ny = 3"
    @test T.parse_toplevel(multiline_interpolation)[2] == [1, 3]
    e = err("x = \"" * '$' * "(1 + )\"")
    @test e.kind === :syntax && e.data.line == 1 && e.data.col == 12
    e = err("x = \"" * '$' * "(1 +\n )\"")
    @test e.kind === :syntax && e.data.line == 2 && e.data.col == 2
    f = ptop("function f(a::Int, b)::Float !io\n a\nend")
    @test f.head === :function && f.args[1] === :f && f.args[3] === :Float
    @test f.args[2] == N(:tuple, N(:typed, :a, :Int), :b)
    @test f.args[4] == N(:tuple, :io)
    @test ptop("sq(x) = x * x").head === :function
    r = ptop("rule g(?x, ?z) :- p(?x, ?y),\n    p(?y, ?z)")
    @test r.head === :rule && length(r.args) == 3
    s = ptop("solve p(?x) && q(?x) limit 3 trace")
    @test s.head === :solve && s.args[1].head === :and && length(s.args[2].args) == 2
    q = ptop(":(if !\$c; \$body; end)")
    @test q.head === :quasi && q.args[1].head === :if
    @test ptop("@unless(a, b)") == N(:macrocall, :unless, :a, :b)
    @test length(T.parse_program("a = 1; b = 2\n\n c = 3").args) == 3
    # newline dentro le parentesi non conta
    @test ptop("f(1,\n  2)") == N(:call, :f, 1, 2)
    # errori di sintassi con posizione e flag "incompleto"
    e = err("x = (1 +")
    @test e.kind === :syntax && e.data.incomplete === true
    e = err("x = 1\ny = )")
    @test e.kind === :syntax && e.data.line == 2 && e.data.incomplete === false
    e = err("function f(x)\n x")
    @test e.data.incomplete === true
end

@testset "unparse / sexpr" begin
    for src in ["a.x != b.x || a.y != b.y", "f(x, y) + 2 * z", "(a + b) * c",
                "x -> x ^ 2", "[1, 2, 3]", "!(a && b)", ":foo"]
        @test T.unparse(ptop(T.unparse(ptop(src)))) == T.unparse(ptop(src))
    end
    @test T.unparse(ptop("(a + b) * c")) == "(a + b) * c"
    @test T.sexpr(ptop("f(:a, ?x)")) == "(call f (sym a) ?x)"
end

@testset "Julia: valori, controllo, funzioni" begin
    @test val("x = 2; y = x * 21; y") == 42
    @test val("7 / 2") == 3.5
    @test val("\"ab\" * \"cd\"") == "abcd"
    @test val("s = 0; for i in 1:10; s += i; end; s") == 55
    @test val("i = 0; while i < 5; i += 1; end; i") == 5
    @test val("let a = 1, b = a + 1\n a + b\nend") == 3
    @test val("if 1 > 2; :a; elseif 2 > 1; :b; else; :c; end") === :b
    @test val("sq(x) = x * x; map(sq, [1, 2, 3])") == Any[1, 4, 9]
    @test val("reduce(+, [1, 2, 3, 4])") == 10
    @test val("filter(x -> x % 2 == 0, 1:6)") == Any[2, 4, 6]
    @test val("[x^2 for x in 1:4 if x > 2]") == Any[9, 16]
    @test val("xs = [1, 2, 3]; xs[end]") == 3
    @test val("function f(n)\n for i in 1:n\n if i == 3\n return i\n end\n end\n 0\nend; f(10)") == 3
    @test val("function mk(k)\n n -> n + k\nend; add3 = mk(3); add3(4)") == 7
    @test val("x = 5; \"x = \$x, doppio \$(x * 2)\"") == "x = 5, doppio 10"
    @test out("println(\"a\", 1, :b, [:c])") == "a1b[:c]\n"    # print come Julia
    @test val("x = 3; x > 2 ? :big : :small") === :big
    @test val("f(n) = n < 2 ? n : f(n - 1) + f(n - 2); f(10)") == 55
    @test val("function fact_(n::Int)::Int\n if n <= 1\n return 1\n end\n n * fact_(n - 1)\nend; fact_(10)") == 3628800
end

@testset "scope e closure mutabili" begin
    @test val("""
        x = 1
        function f()
            x = 2
            x
        end
        f()
        x
        """) == 1
    @test val("""
        function make_counter()
            count = 0
            function next()
                count += 1
                count
            end
            next
        end
        counter = make_counter()
        [counter(), counter()]
        """) == Any[1, 2]
    @test err("for i in [1]; end\ni").kind === :undef
end

@testset "destrutturazione" begin
    @test val("(a, b) = [1, 2]; [a, b]") == Any[1, 2]
    @test val("(a, b) = [1, 2]; a") == 1
    @test val("(a, b) = [1, 2]; b") == 2
    e = err("(a, b) = [1]")
    @test e.kind === :bounds
    e = err("(a, b) = [1, 2, 3]")
    @test e.kind === :bounds
    @test val("xs = []; for (k, v) in [[1, 2], [3, 4]]; push!(xs, [k, v]); end; xs") == Any[Any[1, 2], Any[3, 4]]
    @test val("mk = (a, b) -> a + b; mk(10, 20)") == 30
    @test val("function f((a, b)) a + b end; f(10, 20)") == 30
end

@testset "tipi, struct, multiple dispatch" begin
    base = """
    struct Point
        x::Float
        y::Float
    end
    area(n::Number) = :number
    area(n::Int) = :int
    area(p::Point) = :point
    area(s::String) = :string
    """
    @test val(base * "Point(3, 4).x") === 3.0           # Int → Float come Julia
    @test val(base * "area(1)") === :int                # il più specifico vince
    @test val(base * "area(1.5)") === :number
    @test val(base * "area(Point(1, 2))") === :point
    @test val(base * "typeof(Point(1, 2)) == Point") === true
    @test val(base * "Point(1, 2) isa Point") === true
    @test val("f(x::Int) = :old\nf(x::Int) = :new\nf(1)") === :new
    @test err(base * "area(:x)").kind === :method
    @test err(base * "Point(\"a\", 2)").kind === :type
    @test err(base * "Point(1, 2).z").kind === :field
    @test err("struct P\n x::Int\n x::Int\nend").kind === :type
    amb = "g(a::Int, b::Any) = 1\ng(a::Any, b::Int) = 2\ng(1, 1)"
    @test err(amb).kind === :ambiguous
    # operatori ridefinibili; fallback al builtin per i numeri
    @test val(base * "function +(a::Point, b::Point)\n Point(a.x + b.x, a.y + b.y)\nend\n(Point(1, 2) + Point(3, 4)).y") == 6.0
    @test val(base * "function +(a::Point, b::Point)\n a\nend\n1 + 2") == 3
    @test err("function f(x)::Int\n 1.5\nend\nf(1)").kind === :type
    @test err("function f(x::Banana)\n 1\nend").kind === :type
    @test err("if 1; 2; end").kind === :type             # condizioni solo Bool
end

@testset "Prolog: fatti, regole, solve" begin
    fam = """
    fact parent(:alice, :bob)
    fact parent(:alice, :carol)
    fact parent(:bob, :dave)
    fact parent(:carol, :erin)
    fact male(:bob)
    fact male(:dave)
    rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)
    rule father(?x, ?y) :- parent(?x, ?y), male(?x)
    rule ancestor(?x, ?y) :- parent(?x, ?y)
    rule ancestor(?x, ?y) :- parent(?x, ?z), ancestor(?z, ?y)
    """
    r = val(fam * "solve grandparent(:alice, ?who)")
    @test [s.who for s in r] == [:dave, :erin]
    @test val(fam * "length(solve ancestor(:alice, ?d))") == 4
    @test val(fam * "length(solve ancestor(:alice, ?d) limit 2)") == 2
    @test val("fact p(:a)\nsolve p(:a) depth 0") == Any[]
    @test length(val("fact p(:a)\nsolve p(:a) depth 1")) == 1
    @test val("fact p(:a)\nrule q(?x) :- p(?x)\nsolve q(?x) depth 0") == Any[]
    @test length(val("fact p(:a)\nrule q(?x) :- p(?x)\nsolve q(?x) depth 2")) == 1
    @test val(fam * "[s.x for s in solve father(?x, :dave)]") == Any[:bob]
    @test val(fam * "solve parent(:alice, ?_)") == Any[T.Solution(Symbol[], Any[]), T.Solution(Symbol[], Any[])]
    @test val(fam * "solve parent(:zed, ?x)") == Any[]
    @test val(fam * "grandparent(:alice, :erin)") === true      # predicato come Bool
    @test val(fam * "parent(:dave, :alice)") === false
    @test val(fam * "[s.x for s in solve parent(?x, ?_) && !male(?x)]") == Any[:alice, :alice, :carol]
    @test val(fam * "[s.x for s in solve (?x = :bob) || (?x = :carol)]") == Any[:bob, :carol]
    @test val(fam * "who = :bob\nlength(solve parent(who, ?c))") == 1   # identificatori = valori host
    @test err(fam * "solve parent(alice, ?c)").kind === :undef
    @test err("solve nessuno(?x)").kind === :undef
end

@testset "Prolog: aritmetica, liste, struct, fusione" begin
    @test val("""
        fact edge(:a, :b, 2)
        fact edge(:b, :c, 3)
        rule path(?x, ?y, ?c) :- edge(?x, ?y, ?c)
        rule path(?x, ?y, ?c) :- edge(?x, ?z, ?c1), path(?z, ?y, ?c2), ?c is ?c1 + ?c2
        (solve path(:a, :c, ?cost))[1].cost
        """) == 5
    @test val("""
        rule app([], ?l, ?l)
        rule app([?h | ?t], ?l, [?h | ?r]) :- app(?t, ?l, ?r)
        (solve app([1, 2], [3], ?r))[1].r
        """) == Any[1, 2, 3]
    @test length(val("""
        rule app([], ?l, ?l)
        rule app([?h | ?t], ?l, [?h | ?r]) :- app(?t, ?l, ?r)
        solve app(?a, ?b, [1, 2, 3])
        """)) == 4
    @test val("""
        struct P
            x::Int
            y::Int
        end
        fact at(:home, P(1, 2))
        (solve at(:home, P(?x, ?y)))[1].y
        """) == 2
    # una funzione Triad usata come goal
    @test val("""
        big(n::Int) = n > 10
        fact size(:a, 5)
        fact size(:b, 50)
        [s.k for s in solve size(?k, ?n) && big(?n)]
        """) == Any[:b]
    @test val("fact age(:bob, 30)\nrule adult(?p) :- age(?p, ?a), ?a >= 18\nadult(:bob)") === true
    @test err("rule r(?x) :- ?y > 1\nsolve r(1)").kind === :instantiation
    @test err("y = ?z").kind === :syntax          # variabile logica fuori dalla logica
    # occurs-check
    @test val("solve ?x = f(?x)") == Any[]
    budgeted_negations = "fact p(:a)\nfact q(:a)\nsolve not(p(:z)) && not(q(:z)) steps "
    @test err(budgeted_negations * "5").kind === :budget
    @test length(val(budgeted_negations * "6")) == 1
    # fatti con valori calcolati via \$
    @test val("fact sq(3, \$(3 * 3))\n(solve sq(3, ?v))[1].v") == 9
end

@testset "Lisp: codice come dato, macro" begin
    @test val("c = :(1 + 2); c.head") === :call
    @test val("c = :(1 + 2); eval(c)") == 3
    @test val("x = 10; c = :(\$x * 2); eval(c)") == 20
    @test val("c = parse(\"f(a, 1)\"); c.args[1]") === :f
    @test val("unparse(:(a.x + f(b)))") == "a.x + f(b)"
    @test val("""
        macro unless(c, body)
            :(if !\$c; \$body; end)
        end
        x = 1
        @unless(x > 5, :piccolo)
        """) === :piccolo
    @test val("""
        macro swap(a, b)
            t = gensym()
            quote
                \$t = \$a
                \$a = \$b
                \$b = \$t
            end
        end
        p = 1; q = 2
        @swap(p, q)
        [p, q]
        """) == Any[2, 1]
    @test val("macro twice(e)\n :(begin; \$e; \$e; end)\nend\nn = 0\n@twice(n += 1)\nn") == 2
    @test err("@nope(1)").kind === :undef
    @test val("typeof(:(f(x)))") == T.TType(:Expr)
    @test val("eval(Expr(:call, :+, 1, 2))") == 3
    @test val("[:*, :<=, :!]") == Any[:*, :<=, :!]
    @test val("fact p(:a)\ns = (solve p(?x))[1]\n[s[:x], vars(s)]") == Any[:a, Any[:x]]
end

@testset "errori come dati" begin
    @test val("1 / 0") == Inf                      # Float: come Julia
    e = val("try div(1, 0) end")
    @test e isa T.Err && e.kind === :domain
    @test val("try\n throw(err(:mio, \"ops\", 42))\ncatch e\n e.data + 1\nend") == 43
    @test val("try error(\"boom\") catch e\n e.msg\nend") == "boom"
    @test val("e = err(:x, \"m\"); iserr(e)") === true
    @test val("e = try nondefinito end; e.kind") === :undef
    @test val("try\n [1, 2][5]\ncatch e\n e.kind\nend") === :bounds
    @test val("try sqrt(-1.0) end").kind === :domain
    @test val("f(x::Int) = x\ne = try f(\"a\") end\ne.data.types") == Any[:String]
    # gli Err non gestiti risalgono con la riga
    e = err("x = 1\ny = nondefinito")
    @test e.kind === :undef && occursin("riga 2", e.msg)
end

@testset "contratti" begin
    c = """
    function safe_div(a::Number, b::Number)::Float
        requires b != 0
        ensures result * b == a
        a / b
    end
    function bad(x::Int)::Int
        ensures result > x
        x - 1
    end
    """
    @test val(c * "safe_div(6, 3)") == 2.0
    e = err(c * "safe_div(1, 0)")
    @test e.kind === :contract && e.data.clause === :requires && e.data.fn === :safe_div
    @test occursin("b != 0", e.msg)
    e = err(c * "bad(5)")
    @test e.kind === :contract && e.data.clause === :ensures && e.data.result == 4
    @test err("requires 1 > 2").kind === :contract     # requires al top level = asserzione
    @test err("ensures true").kind === :syntax
end

@testset "budget" begin
    e = val("with budget(steps = 1000)\n while true\n end\nend")
    @test e isa T.Err && e.kind === :budget
    @test val("with budget(steps = 10_000)\n s = 0; for i in 1:10; s += i; end; s\nend") == 55
    # il budget interno non cattura quello esterno
    e = val("with budget(steps = 500)\n x = with budget(steps = 100_000)\n while true; end\n end\n :mai\nend")
    @test e isa T.Err && e.kind === :budget
    # ricorsione sinistra: Err invece di blocco
    lr = "rule anc(?x, ?y) :- anc(?x, ?z), anc(?z, ?y)\nrule anc(?x, ?y) :- p(?x, ?y)\nfact p(1, 2)\n"
    @test err(lr * "solve anc(1, ?w) steps 5000").kind === :budget
    @test val(lr * "r = with budget(steps = 3000)\n solve anc(1, ?w)\nend\nr.kind") === :budget
    # con la clausola base per prima, limit basta a fermarsi
    rl = "rule anc(?x, ?y) :- p(?x, ?y)\nrule anc(?x, ?y) :- anc(?x, ?z), anc(?z, ?y)\nfact p(1, 2)\n"
    @test length(val(rl * "solve anc(1, ?w) limit 1")) == 1
    # depth: taglia i rami troppo profondi (nat(0) .. nat(4))
    @test val("rule nat(0)\nrule nat(?n) :- nat(?m), ?n is ?m + 1\n[s.n for s in solve nat(?n) depth 5]") ==
          Any[0, 1, 2, 3, 4]
end

@testset "tracce" begin
    t = val("fact p(1)\nfact p(2)\nrule q(?x) :- p(?x), ?x > 1\nsolve q(?x) trace")
    @test t.tag === :Traced
    @test t.fields.result[1].x == 2
    ports = [e.fields.port for e in t.fields.trace]
    @test ports[1] === :call && :exit in ports && :redo in ports
    t = val("fact p(:a)\nsolve not(p(:z)) trace")
    ports = [e.fields.port for e in t.fields.trace]
    @test :call in ports && :fail in ports
    t = val("fact p(:a)\nsolve not(p(:a)) trace")
    ports = [e.fields.port for e in t.fields.trace]
    @test :call in ports && :exit in ports
    t = val("sq(x) = x * x\nf(x) = sq(x) + 1\nwith trace\n f(3)\nend")
    @test t.fields.result == 10
    @test [(e.fields.port, e.fields.fn) for e in t.fields.trace] ==
          [(:call, :f), (:call, :sq), (:exit, :sq), (:exit, :f)]
end

@testset "effetti" begin
    @test out("function hello(n) !io\n println(\"ciao \", n)\nend\nhello(1)") == "ciao 1\n"
    e = err("function pura(n)\n println(n)\nend\npura(1)")
    @test e.kind === :effect && e.data.fn === :println && e.data.caller === :pura
    e = err("function log(x) !io\n println(x)\nend\nfunction calc(x)\n log(x)\nend\ncalc(1)")
    @test e.kind === :effect && e.data.fn === :log
    @test err("function learn(x)\n fact seen(x)\nend\nlearn(1)").kind === :effect
    @test val("function learn(x) !state\n fact seen(\$x)\nend\nlearn(7)\n(solve seen(?v))[1].v") == 7
    @test err("function f(x) !rete\n x\nend").kind === :effect
    # i contratti sono puri
    @test err("function f(x) !io\n requires println(x) == nothing\n x\nend\nf(1)").kind === :effect
    # top level: tutti gli effetti permessi
    @test out("for i in 1:2; println(i); end") == "1\n2\n"
end

@testset "riga di comando e REPL" begin
    root = joinpath(@__DIR__, "..")
    triad(args...; input = "") = begin
        cmd = `$(Base.julia_cmd()) --startup-file=no $(joinpath(root, "triad.jl")) $args`
        o = IOBuffer(); e = IOBuffer()
        p = Base.run(pipeline(ignorestatus(cmd); stdin = IOBuffer(input), stdout = o, stderr = e))
        p.exitcode, String(take!(o)), String(take!(e))
    end
    fam = joinpath(root, "examples", "famiglia")           # senza .td, come in Prolog
    script = "x = 1 +\n  2\nx\n?- ancestor(:tom, ?d) limit 2.\nmother(?m, ?c)\n" *
             "parent(:jim, ?x)\nparent(:pat, ?c)\n:listing mother\nboom()\n:reload\nhalt.\n"
    code, o, e = triad("-q", "-l", fam; input = script)
    @test code == 0
    @test occursin("triad> 3\n", o)                          # blocco su più righe
    @test occursin("?d = :bob ;\n?d = :liz.\n", o)          # ?- con limit
    @test occursin("?m = :pat,\n?c = :jim.\n", o)           # query senza ?-, niente `false.`
    @test occursin("triad> false.\n", o)
    @test occursin("triad> ?c = :jim.\n", o)                 # ultima clausola: nessun punto di scelta
    @test occursin("rule mother(?m, ?c) :- parent(?m, ?c), female(?m)", o)
    @test occursin("ricaricati 1/1 file", o)
    @test occursin("errore (:undef)", e)                     # l'errore non chiude il REPL
    @test triad("-E", "1 + 2")[2] == "3\n"
    @test triad("-", "a", "b"; input = "println(ARGS)")[2] == "[\"a\", \"b\"]\n"
    @test triad("-e", "boom()")[1] == 1
    @test triad("nonesiste.td")[1] == 1
    @test triad("--bogus")[1] == 2
end

@testset "round-trip, end e lambda tipate" begin
    # il range si rilegge solo senza spazi (SPEC §2, riga 6)
    @test T.unparse(ptop("1:n")) == "1:n"
    @test T.unparse(ptop("xs[2:end]")) == "xs[2:end]"
    @test T.unparse(ptop("(1 + 2):(3 * 4)")) == "1 + 2:3 * 4"
    @test T.unparse(ptop(T.unparse(ptop("(1 + 2):(3 * 4)")))) == "1 + 2:3 * 4"
    @test val("n = 2\n1 + 1:n") == Any[2]
    @test T.unparse(ptop("(a, b) = t")) == "(a, b) = t"
    @test T.unparse(ptop("for (k, v) in m; k; end")) == "for (k, v) in m; k; end"
    @test val(T.unparse(ptop("(a, b) = [1, 2]")) * "\n[a, b]") == Any[1, 2]

    # `end` anche quando l'indice è a sinistra di un assegnamento
    @test val("xs = [1, 2, 3]; xs[end] = 7; xs") == Any[1, 2, 7]
    @test val("xs = [1, 2, 3]; xs[end] += 1; xs") == Any[1, 2, 4]
    e = err("xs = [1, 2, 3]; xs[end + 1] = 7")
    @test e.kind === :bounds

    # commenti #= annidati (SPEC §1)
    @test val("#= a #= b =# c =#\n41 + 1") == 42
    @test val("#= #= x =# =#\n1") == 1
    e = err("#= a #= b =#\n1")
    @test e.kind === :syntax && e.data.incomplete === true

    # gli escape sono solo quelli dichiarati: \n \t \" \\ \$
    @test val("\"a\\nb\"") == "a\nb"
    @test val("\"a\\tb\"") == "a\tb"
    @test val("\"a\\\"b\"") == "a\"b"
    @test val("\"a\\\\b\"") == "a\\b"
    @test val("x = 5\n\"a\\\$x\"") == "a\$x"
    e = err("\"a\\rb\"")
    @test e.kind === :syntax && occursin("escape sconosciuto", e.msg)

    # lambda con parametri tipati (SPEC §2: "function" "(" params ")" block "end")
    @test val("f = function (x::Int) x end\nf(3)") == 3
    @test val("f = function (x::Float) x end\nf(2)") == 2.0
    @test val("f = function (a, b) a + b end\nf(2, 3)") == 5
    e = err("f = function (x::Int) x end\nf(:no)")
    @test e.kind === :type && e.data.expected === :Int
    e = err("f = function (x::Banana) x end")
    @test e.kind === :type
end

@testset "opassign, rule a capo e not" begin
    # il nodo è (opassign <op> lhs rhs): la posizione a sinistra appare una volta sola
    @test ptop("x += 1") == N(:opassign, :+, :x, 1)
    @test ptop("x::Int += 1") == N(:opassign, :+, N(:typed, :x, :Int), 1)
    @test ptop("xs[i] += 5") == N(:opassign, :+, N(:index, :xs, :i), 5)
    @test T.unparse(ptop("xs[i] += 5")) == "xs[i] += 5"
    @test T.unparse(ptop(T.unparse(ptop("xs[i] += 5")))) == "xs[i] += 5"
    @test val("x = 5; x += 2; x") == 7
    @test val("x = 5; x *= 3; x") == 15
    @test val("x::Int = 1; x += 2; x") == 3
    e = err("x::Int = 1; x::Int += 0.5")
    @test e.kind === :type && e.data.expected === :Int
    e = err("xs = [1, 2, 3]; xs[7] += 1")
    @test e.kind === :bounds
    # `lhs` valutata una volta sola: l'indice con effetto collaterale stampa "i" una volta
    idx = "function idx() !io\n println(\"i\")\n 1\nend\nxs = [10, 20]\nxs[idx()] += 5\n"
    @test out(idx) == "i\n"
    @test val(idx * "xs") == Any[15, 20]
    # `+=` su un nome non legato resta un errore di variabile indefinita
    e = err("xs = [1, 2, 3]; xs[2] += a")
    @test e.kind === :undef
    # `let`: il valore può essere esso stesso un assegnamento a destra
    @test val("let a = b = 1\n a + b\nend") == 2
    @test val("let a = 1, b = 2\n a + b\nend") == 3
    @test val("let a = 1\n a += 1\n a\nend") == 2

    # corpo di rule con la virgola a inizio riga di continuazione (SPEC §4)
    kb = "fact parent(:a, :b)\nfact parent(:b, :c)\n"
    same = "rule gp(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)\n"
    lead = "rule gp(?x, ?z) :- parent(?x, ?y)\n  , parent(?y, ?z)\n"
    two  = lead * "  , ?x != ?z\n"
    r = ptop(lead)
    @test r.head === :rule && length(r.args) == 3
    for body in (same, lead, two)
        @test val(kb * body * "[s.p for s in solve gp(?p, ?c)]") == Any[:a]
    end

    # `not` anche come funzione a livello di valore (nei goal resta negazione per fallimento)
    @test val("not(true)") === false
    @test val("not(1 == 2)") === true
    @test val("y = true\nnot(y)") === false
    e = err("not(3)")
    @test e.kind === :type && e.data.expected === :Bool
    e = err("not(true, false)")
    @test e.kind === :method
    @test val(kb * "rule leaf(?x) :- parent(:b, ?x), not(parent(?x, ?y))\n[s.q for s in solve leaf(?q)]") == Any[:c]
    @test val(kb * "rule leaf(?x) :- parent(:a, ?x), not(parent(?x, ?y))\nsolve(leaf(?q))") == Any[]
    @test val(kb * "solve(not(parent(:a, :c)))") == Any[T.Solution(Symbol[], Any[])]

    # messaggi d'errore per gli unici due caratteri che il lexer conosce ma il parser no
    e = err("{ 1 }")
    @test e.kind === :syntax && occursin("graffe", e.msg)
    e = err("'c'")
    @test e.kind === :syntax && occursin("usa una stringa", e.msg)
end

@testset "tipo dichiarato e variabili nei record" begin
    # il tipo dichiarato vincola gli assegnamenti successivi dello stesso nome (§4)
    @test val("x::Int = 1\nx = 2\nx") == 2
    e = err("x::Int = 1\nx = 0.5\nx")
    @test e.kind === :type && e.data.expected === :Int && e.data.got === :Float
    @test val("y::Float = 1.0\ny = 2\ny") == 2.0          # conversione Int → Float, come in Julia
    @test val("n::Int = 0\nn += 1\nn") == 1
    e = err("n::Int = 0\nn += 0.5")
    @test e.kind === :type
    @test val("x::Int = 1\nx + 0.5") == 1.5               # la lettura non è vincolata
    # una nuova dichiarazione sullo stesso nome sostituisce il vincolo
    @test val("x::Int = 1\nx::Float = 2.5\nx = 3\nx") == 3.0
    # un nome senza tipo dichiarato resta libero
    @test val("s = \"a\"\ns = 3\ns") == 3
    # la rilegatura in un ambiente interno non eredita il vincolo dell'esterno
    @test val("x::Int = 1\nlet x = 2.5\n x\nend") == 2.5

    # parametri di funzione e lambda: il frame mantiene il tipo dichiarato
    @test val("function f(x::Int)\n x = 3\n x\nend\nf(1)") == 3
    e = err("function f(x::Int)\n x = 3.5\n x\nend\nf(1)")
    @test e.kind === :type && e.data.expected === :Int
    @test val("function g(x::Float)\n x = 4\n x\nend\ng(1.0)") == 4.0
    @test val("f = function (x::Int) x = 2; x end\nf(1)") == 2
    e = err("f = function (x::Int) x = 2.5; x end\nf(1)")
    @test e.kind === :type

    # standardizzazione a parte e raccolta variabili: scendono anche nei record
    w = T.World(out = IOBuffer())
    rec = T.Rec(:Info, (a = T.TVar(:x), b = T.TVar(:y)), true)
    m = Dict{Symbol, T.TVar}()
    r = T.renamevars(rec, m, w)
    @test r isa T.Rec && r.a isa T.TVar && r.a.name !== :x && r.b.name !== :y
    @test T.renamevars(T.TVar(:x), m, w) === r.a          # una variabile fresca per nome
    @test T.renamevars(rec, m, w).a === r.a
    @test T.collect_vars!(Symbol[], rec) == [:x, :y]
    @test T.collect_vars!(Symbol[], T.Term(:p, Any[T.Rec(:Info, (a = T.TVar(:q),), true)])) == [:q]
end

@testset "esempi" begin
    dir = joinpath(@__DIR__, "..", "examples")
    for f in sort(readdir(dir))
        (endswith(f, ".td") || endswith(f, ".triad")) || continue
        w = T.World(out = IOBuffer())
        w.globals.vars[:ARGS] = Any[]          # hello_shebang.td legge ARGS
        @test (T.run_source(w, read(joinpath(dir, f), String)); true)
    end
end

end
