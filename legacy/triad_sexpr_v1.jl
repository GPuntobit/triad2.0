#!/usr/bin/env julia
# =====================================================================
#  TRIAD — un linguaggio, tre anime: Julia ∪ Prolog ∪ Lisp
#  (triad.jl — kernel eseguibile, zero dipendenze, Julia >= 1.6)
#
#  FUSIONE:
#   * PROLOG : fatti, regole, unificazione (con occurs-check),
#              SLD resolution (backward chaining) con backtracking
#   * LISP   : S-expressions homoiconiche, lambda, let, if, quote,
#              map/filter/reduce, macro, environment lessicali
#   * JULIA  : multiple dispatch (classe + aria), record tipizzati,
#              operatori e funzioni come valori, codice host veloce
#
#  UNA S-EXPRESSION SCEGLIE IL PROPRIO MOTORE AL VOLO:
#    head = forma speciale (if/let/defun/fact/...)  -> Lisp/Julia/Prolog
#    head = funzione defun/defmethod                -> dispatch Julia
#    head = predicato della KB                      -> query Prolog
#    head = altro valore richiamabile               -> higher-order
#
#  SINTASSI DEL READER:
#    ( ... )   S-expression        abc     simbolo (fn Lisp / atomo Prolog)
#    X Y Z     maiuscole -> variabile PROLOG     _ -> anonima (fresca)
#    :point    simbolo letterale   42 3.14  numeri   "testo" stringa
#    'forma    quote              ; commento fino a fine riga
#
#  USO:
#    julia --startup-file=no triad.jl
#    julia> include("triad.jl")      (demo + TRIAD REPL)
# =====================================================================

# ---------------- 1. TERMINI ------------------------------------------
# Atomi = Symbol, Numeri = Int/Float64, S-exp/termini = Vector{Any},
# variabili Prolog = TVar, simboli letterali = SLit, record = Rec.

struct TVar;  name::Symbol;  end
struct SLit;  s::Symbol;     end
struct Rec
    tag::Symbol
    fields::NamedTuple
end
struct OpF;  op::Symbol;  end          # operatore come valore (alla Julia)
struct SymFn;  name::Symbol;  end      # builtin come valore

function is_var_name(n::Symbol)
    s = string(n)
    !isempty(s) && (s[1] == '_' || isuppercase(s[1]))
end

Base.show(io::IO, v::TVar)   = print(io, "(", v.name, ")")
Base.show(io::IO, l::SLit)   = show(io, l.s)
Base.show(io::IO, r::Rec)    = print(io, r.tag, "(", r.fields, ")")
Base.show(io::IO, o::OpF)    = print(io, string(o.op))
Base.show(io::IO, f::SymFn)  = print(io, "fn/", f.name)

# ---------------- 2. ENVIRONMENT LESSICALI ----------------------------
const UNBOUND = Symbol("__triad_unbound__")

struct Env
    parent::Union{Env,Nothing}
    vars::Dict{Symbol,Any}
    Env() = new(nothing, Dict{Symbol,Any}())
    Env(p, v) = new(p, v)
end

child_env(e::Env) = Env(e, Dict{Symbol,Any}())

function lookup_env(e::Env, k::Symbol)
    while e !== nothing
        haskey(e.vars, k) && return e.vars[k]
        e = e.parent
    end
    return UNBOUND
end

# ---------------- 3. UNIFICAZIONE -------------------------------------
const PSub = Dict{Symbol,Any}

function apply_sub(t, sub::PSub)
    t isa TVar && return get(sub, t.name, t)
    t isa Vector{Any} && return map(a -> apply_sub(a, sub), t)
    return t
end

function occurs(name, t, sub::PSub)
    t = apply_sub(t, sub)
    t isa TVar && return t.name == name
    t isa Vector{Any} && return any(a -> occurs(name, a, sub), t)
    return false
end

function bind_var(name, term, sub::PSub)
    term isa TVar && term.name == name && return sub
    occurs(name, term, sub) && return nothing          # occurs-check
    s2 = copy(sub)
    s2[name] = term
    return s2
end

function unify(t, u, sub::PSub = PSub())
    t = apply_sub(t, sub)
    u = apply_sub(u, sub)
    t === u && return sub
    t isa TVar && return bind_var(t.name, u, sub)
    u isa TVar && return bind_var(u.name, t, sub)
    if t isa Symbol || t isa Int || t isa Float64 || t isa String ||
       u isa Symbol || u isa Int || u isa Float64 || u isa String
        return (t === u) ? sub : nothing
    end
    if !(t isa Vector{Any} && u isa Vector{Any})
        return nothing
    end
    isempty(t) && isempty(u) && return sub
    (isempty(t) || isempty(u)) && return nothing
    t[1] === u[1] || return nothing
    length(t) == length(u) || return nothing
    acc = sub
    for i in 2:length(t)
        acc = unify(t[i], u[i], acc)
        acc === nothing && return nothing
    end
    return acc
end

# ---------------- 4. CLAUSOLE + SLD -----------------------------------
struct Clause
    head::Any
    body::Vector{Any}
    Clause(h, b=Vector{Any}()) = new(h, b)
end

# Standardizzazione a parte: ogni istanza di clausola riceve variabili
# fresche -> nessuna collisione di nomi tra query e knowledge base.
const FRESH = Ref(0)
function freshen(t)
    if t isa TVar
        FRESH[] += 1
        return TVar(Symbol("v" * string(FRESH[])))
    end
    if t isa Vector{Any}
        return map(freshen, t)
    end
    return t
end

function sld(prog, goals, sub::PSub = PSub(); limit::Int = typemax(Int))
    isempty(goals) && return [copy(sub)]
    g = goals[1]
    rest = goals[2:end]
    sols = Any[]
    for c in prog
        ch = freshen(c.head)
        cb = map(a -> freshen(a), c.body)
        su = unify(ch, g, sub)
        su === nothing && continue
        nb = map(a -> apply_sub(a, su), cb)
        nr = map(a -> apply_sub(a, su), rest)
        for s2 in sld(prog, vcat(nb, nr), su; limit = limit)
            push!(sols, s2)
            length(sols) >= limit && return sols
        end
    end
    return sols
end

# ---------------- 5. MONDO CONDIVISO ----------------------------------
struct Method
    name::Symbol
    params::Vector{Symbol}
    tags::Vector{Symbol}
    body::Any
end

struct Lam
    params::Vector{Symbol}
    body::Any
    env::Env
end

mutable struct World
    kb::Vector{Clause}
    prednames::Set{Symbol}
    funcs::Dict{Symbol,Vector{Method}}
    macros::Dict{Symbol,Method}
    records::Dict{Symbol,Vector{Symbol}}
    World() = new(Clause[], Set{Symbol}(),
                   Dict{Symbol,Vector{Method}}(),
                   Dict{Symbol,Method}(),
                   Dict{Symbol,Vector{Symbol}}())
end

function class_of(x)
    if x isa TVar
        return :var
    elseif x isa Int || x isa Float64
        return :num
    elseif x isa Symbol || x isa SLit
        return :atom
    elseif x isa Vector{Any}
        return :list
    elseif x isa Lam
        return :fn
    elseif x isa Rec
        return x.tag
    end
    return :_
end

# ---------------- 6. VALUTATORE ---------------------------------------
falsy(x) = (x === false) || (x === 0) || (x === 0.0) ||
           (x === :false) || (x === nothing)

const EQ, LT, LE, GT, GE = Symbol("=="), Symbol("<"), Symbol("<="), Symbol(">"), Symbol(">=")

function apply_op(h::Symbol, vals)
    if h === :+
        return isempty(vals) ? 0 : sum(vals)
    end
    if length(vals) == 1
        h === :- && return -vals[1]
        return vals[1]
    end
    if h === :-
        acc = vals[1]
        for v in vals[2:end]
            acc -= v
        end
        return acc
    end
    if h === :*
        acc = vals[1]
        for v in vals[2:end]
            acc *= v
        end
        return acc
    end
    if h === :/
        acc = vals[1]
        for v in vals[2:end]
            acc = acc / v
        end
        return acc
    end
    length(vals) == 2 || error("triad: operatore $h richiede 2 argomenti")
    if h === EQ
        return vals[1] == vals[2]
    elseif h === LT
        return vals[1] < vals[2]
    elseif h === LE
        return vals[1] <= vals[2]
    elseif h === GT
        return vals[1] > vals[2]
    elseif h === GE
        return vals[1] >= vals[2]
    end
    error("triad: operatore non supportato: $h")
end

const BINS = Dict(
    :abs    => (v) -> abs(v[1]),
    :sqrt   => (v) -> sqrt(v[1]),
    :pow    => (v) -> v[1] ^ v[2],
    :mod    => (v) -> v[1] % v[2],
    :min    => (v) -> minimum(v),
    :max    => (v) -> maximum(v),
    :length => (v) -> length(v[1]),
    :list   => (v) -> Any[v...],
    :println => (v) -> (println(v...); :ok),
)

function apply_lam(f::Lam, vals, w)
    length(f.params) == length(vals) ||
        error("triad: lambda $(f.params) riceve $(length(vals)) argomenti")
    e = child_env(f.env)
    for (p, v) in zip(f.params, vals)
        e.vars[p] = v
    end
    return ev(f.body, e, w)
end

function apply_fn(f, vals, w)
    f isa Lam && return apply_lam(f, vals, w)
    if f isa OpF
        return apply_op(f.op, vals)
    end
    if f isa SymFn
        haskey(BINS, f.name) || error("triad: builtin sconosciuto: $(f.name)")
        return BINS[f.name](vals)
    end
    error("triad: valore non applicabile: $f")
end

function dispatch(w, name, vals)
    ms = w.funcs[name]
    best = nothing
    bestscore = -1
    for m in ms
        length(m.params) != length(vals) && continue
        score = 0
        ok = true
        for i in 1:length(vals)
            tag = (i <= length(m.tags)) ? m.tags[i] : Symbol("_")
            if tag === Symbol("_")
                continue
            end
            if tag === class_of(vals[i])
                score += 1
            else
                ok = false
                break
            end
        end
        if ok && score > bestscore
            best = m
            bestscore = score
        end
    end
    best === nothing && error("triad: nessun metodo per '$name' con argomenti di classe [" *
                              join([string(class_of(v)) for v in vals], ", ") * "]")
    e = Env()
    for (p, v) in zip(best.params, vals)
        e.vars[p] = v
    end
    return ev(best.body, e, w)
end

function show_term(t)
    if t isa TVar
        return startswith(string(t.name), "_") ? "_" : string(t.name)
    end
    if t isa Vector{Any}
        return join(map(show_term, t), " ")
    end
    return string(t)
end

function prolog_query(w, gforms)
    sols = sld(w.kb, gforms)
    if isempty(sols)
        println("  false.")
        return 0
    end
    for s in sols
        pairs = String[]
        for g in gforms
            g isa Vector{Any} || continue
            for a in g[2:end]
                a isa TVar || continue
                lbl = startswith(string(a.name), "_") ? "_" : string(a.name)
                push!(pairs, "$lbl = $(show_term(apply_sub(a, s)))")
            end
        end
        println("  ", isempty(pairs) ? "true." : join(pairs, ", "))
    end
    return length(sols)
end

function norm_sym(x, env, w)
    x isa Symbol && return x
    x isa SLit && return x.s
    return ev(x, env, w)
end

function ev(t, env, w)
    # ----- termini atomici -----
    if !(t isa Vector{Any})
        if t isa TVar
            error("triad: la variabile Prolog ($(t.name)) non e' ammessa nel contesto di espressione")
        elseif t isa SLit
            return t.s
        elseif t isa Symbol
            v = lookup_env(env, t)
            v === UNBOUND && error("triad: '$t' non e' definito")
            return v
        end
        return t
    end

    head = t[1]
    args = t[2:end]

    if !(head isa Symbol)
        fh = ev(head, env, w)
        vals = [ev(a, env, w) for a in args]
        if fh isa Lam
            return apply_lam(fh, vals, w)
        elseif fh isa OpF
            return apply_op(fh.op, vals)
        elseif fh isa SymFn
            haskey(BINS, fh.name) || error("triad: builtin sconosciuto: $(fh.name)")
            return BINS[fh.name](vals)
        end
        error("triad: head non richiamabile: $head")
    end

    h = head

    # ----- macro -----
    if haskey(w.macros, h)
        m = w.macros[h]
        length(args) == length(m.params) ||
            error("triad: macro '$(m.name)' richiede $(length(m.params)) argomenti")
        e2 = child_env(env)
        for (p, a) in zip(m.params, args)
            e2.vars[p] = a
        end
        return ev(ev(m.body, e2, w), env, w)
    end

    # ----- forme LISP -----
    if h === :if
        c = ev(args[1], env, w)
        return falsy(c) ? ev(get(args, 3, false), env, w) : ev(args[2], env, w)
    end

    if h === :let
        e2 = child_env(env)
        for b in args[1]
            (k, ex) = b
            k isa Symbol || error("triad: chiave di binding non simbolo: $k")
            e2.vars[k] = ev(ex, env, w)
        end
        val = :__void__
        for st in args[2:end]
            val = ev(st, e2, w)
        end
        return val
    end

    if h === :lambda
        return Lam(Vector{Symbol}(args[1]), args[2], env)
    end

    if h === :quote
        return args[1]
    end

    if h === :map || h === :filter || h === :reduce
        f = ev(args[1], env, w)
        (f isa Lam || f isa OpF || f isa SymFn) ||
            error("triad: '$h' richiede una funzione (lambda, operatore o builtin)")
        data = ev(args[2], env, w)
        data isa AbstractArray || error("triad: '$h' richiede una lista")
        if h === :map
            return [apply_fn(f, Any[x], w) for x in data]
        end
        if h === :filter
            out = Any[]
            for x in data
                !falsy(apply_fn(f, Any[x], w)) && push!(out, x)
            end
            return out
        end
        isempty(data) && error("triad: reduce su lista vuota")
        acc = data[1]
        for x in data[2:end]
            acc = apply_fn(f, Any[acc, x], w)
        end
        return acc
    end

    # ----- strato JULIA: record, funzioni, dispatch -----
    if h === :defrecord
        tag = norm_sym(args[1], env, w)
        tag isa Symbol || error("triad: nome record non simbolo")
        w.records[tag] = Vector{Symbol}(args[2])
        return :ok
    end

    if h === :record
        tag = norm_sym(args[1], env, w)
        tag isa Symbol || error("triad: tag record non simbolo")
        haskey(w.records, tag) || error("triad: record '$tag' non definito (defrecord)")
        flds = w.records[tag]
        length(args) - 1 == length(flds) ||
            error("triad: record '$tag' richiede $(length(flds)) campi, dati $(length(args) - 1)")
        vs = [ev(a, env, w) for a in args[2:end]]
        pairs = [flds[i] => vs[i] for i in 1:length(flds)]
        return Rec(tag, NamedTuple{tuple(flds...)}(tuple(vs...)))
    end

    if h === :field
        r = ev(args[1], env, w)
        r isa Rec || error("triad: (field ...) richiede un record")
        k = ev(args[2], env, w)
        k isa Symbol || error("triad: chiave campo non simbolo")
        return r.fields[k]
    end

    if h === :defun || h === :defmethod
        name = args[1]
        name isa Symbol || error("triad: nome funzione non simbolo")
        tags = Symbol[]
        pidx = 2
        if h === :defmethod
            for x in args[2]
                if x isa SLit
                    push!(tags, x.s)
                elseif x isa Symbol
                    push!(tags, x)
                else
                    error("triad: tag di dispatch non valido: $x")
                end
            end
            pidx = 3
        end
        m = Method(name, Vector{Symbol}(args[pidx]), tags, args[pidx + 1])
        push!(get!(w.funcs, name, Method[]), m)
        return :ok
    end

    if h === :defmacro
        name = args[1]
        w.macros[name] = Method(name, Vector{Symbol}(args[2]), Symbol[], args[3])
        return :ok
    end

    # ----- strato PROLOG: fatti, regole, query -----
    if h === :fact
        term = args[1]
        term isa Vector{Any} || error("triad: fatto malformed: $term")
        term[1] isa Symbol || error("triad: fatto senza funtore: $term")
        push!(w.kb, Clause(term, Any[]))
        push!(w.prednames, term[1])
        return :ok
    end

    if h === :rule
        headterm = args[1]
        headterm isa Vector{Any} || error("triad: regola malformed: $headterm")
        headterm[1] isa Symbol || error("triad: regola senza funtore: $headterm")
        push!(w.kb, Clause(headterm, args[2:end]))
        push!(w.prednames, headterm[1])
        return :ok
    end

    if h === :solutions
        isempty(args) && error("triad: (solutions ...) richiede almeno un goal")
        return prolog_query(w, args)
    end

    if h === :once
        return !isempty(sld(w.kb, Any[args[1]]; limit = 1))
    end

    # ----- funzioni JULIA: multiple dispatch -----
    if haskey(w.funcs, h)
        return dispatch(w, h, [ev(a, env, w) for a in args])
    end

    # ----- predicati PROLOG: argomenti NON valutati -----
    if haskey(w.prednames, h)
        return prolog_query(w, args)
    end

    # (gli operatori arrivano come head OpF, gestiti sopra in "head non Symbol")

    # ----- builtin -----
    if haskey(BINS, h)
        return BINS[h]([ev(a, env, w) for a in args])
    end

    # ----- funzione locale (Lisp) -----
    f0 = lookup_env(env, h)
    if f0 isa Lam
        return apply_lam(f0, [ev(a, env, w) for a in args], w)
    end

    # ----- higher-order generico -----
    fh = ev(head, env, w)
    fh isa Lam || error("triad: non si puo' chiamare '$h'")
    return apply_lam(fh, [ev(a, env, w) for a in args], w)
end

# ---------------- 7. READER --------------------------------------------
const ANON = Ref(0)

function load_program(src::String)
    chars = collect(src)                # Vector{Char}: reader UTF-8 safe
    pos = 1
    n = length(chars)
    forms = Any[]

    function skipws!()
        while pos <= n && isspace(chars[pos])
            pos += 1
        end
    end

    function read_one()
        skipws!()
        pos > n && return :__eof__
        c = chars[pos]
        if c == '('
            pos += 1
            items = Any[]
            while true
                skipws!()
                pos > n && error("triad: parentesi non chiusa")
                if chars[pos] == ')'
                    pos += 1
                    break
                end
                push!(items, read_one())
            end
            return items
        elseif c == Char(39)
            pos += 1
            return [:quote, read_one()]
        elseif c == '"'
            j = findnext(cc -> cc == '"', chars, pos + 1)
            j === nothing && error("triad: stringa non chiusa")
            s = String(chars[pos + 1 : j - 1])
            pos = j + 1
            return s
        elseif c == ';'
            while pos <= n && chars[pos] != '\n'
                pos += 1
            end
            return read_one()
        else
            j = pos
            while j <= n && !isspace(chars[j]) && chars[j] != ')' && chars[j] != '('
                j += 1
            end
            s = String(chars[pos : j - 1])
            pos = j
            isempty(s) && error("triad: token vuoto")
            try
                return parse(Int, s)
            catch
                try
                    return parse(Float64, s)
                catch
                    if startswith(s, ":")
                        return SLit(Symbol(s[2:end]))
                    end
                    # operatori/builtin come valori (first-class, alla Julia)
                    if s in ("+", "-", "*", "/", "==", "<", "<=", ">", ">=")
                        return OpF(Symbol(s))
                    end
                    if s in ("abs", "sqrt", "pow", "mod", "min", "max",
                             "length", "list", "println")
                        return SymFn(Symbol(s))
                    end
                    sym = Symbol(s)
                    if is_var_name(sym)
                        if startswith(string(sym), "_")
                            ANON[] += 1
                            return TVar(Symbol("_" * string(ANON[])))
                        end
                        return TVar(sym)
                    end
                    return sym
                end
            end
        end
    end

    while true
        f = read_one()
        f === :__eof__ && break
        push!(forms, f)
    end
    return forms
end

const DEMO = """
; =====================================================================
;  TRIAD DEMO — un linguaggio, tre strati che collaborano
; =====================================================================

; ---------- [1] STRATO JULIA: record + multiple dispatch ----------
(defrecord point (x y))
(defun len (p) (sqrt (+ (* (field p :x) (field p :x))
                        (* (field p :y) (field p :y)))))
(defmethod len (:num)  (n)  (abs n))
(defmethod len (:list) (xs) (sqrt (reduce + (map (lambda (v) (* v v)) xs))))

(println "=== [Julia] multiple dispatch ===")
(let ((p (record :point 3 4)))
  (println "len(point(3,4)) = " (len p)))
(let ((l (list 3 4)))
  (println "len([3 4])      = " (len l)))
(println "len(42)          = " (len 42))

; ---------- [2] STRATO LISP: lambda, let, if, map/reduce, macro ----------
(println "=== [Lisp] S-expressions, lambda, macro ===")
(let ((sq (list 3 4)))
  (println "somma quadrati(3,4) = " (reduce + (map (lambda (v) (* v v)) sq))))
(let ((n 10))
  (if (< n 5)
     (println "n = 10, piccolo")
     (println "n = 10, grande")))
(defmacro makepoint (x y) (record :point x y))
(println "(makepoint 3 4) => " (makepoint 3 4))
(println "operatore * come valore: (reduce * (list 1 2 3 4)) = " (reduce * (list 1 2 3 4)))

; ---------- [3] STRATO PROLOG: fatti + regole + SLD/backtracking ----------
(fact (parent alice bob))
(fact (parent alice carol))
(fact (parent bob dave))
(fact (parent carol erin))
(fact (male bob))
(fact (female alice))
(rule (father X Y) (parent X Y) (male X))
(rule (grandparent X Y) (parent X Z) (parent Z Y))

(fact (color red))
(fact (color blue))
(fact (color green))
(fact (mix red blue purple))
(fact (mix red green yellow))
(fact (mix blue red purple))

(println "=== [Prolog] SLD + backtracking ===")
(println "grandparent(X, Y):")
(solutions (grandparent X Y))
(println "father(X, dave):")
(solutions (father X dave))
(println "(once (male alice)) => " (once (male alice)))
(println "(once (male bob))   => " (once (male bob)))
(println "color(_):")
(solutions (color _))

; ---------- [4] FUSIONE: un'unica espressione attraversa i 3 strati ----------
(let ((p (makepoint 3 4)))
  (println "=== [Fusione] ===")
  (println "len(makepoint 3 4) = " (len p)
           " | colori in KB = " (solutions (color _))
           " | mix(red, _, _) = " (solutions (mix red _ _))))
"""

function run_program(w, forms, env)
    vals = Any[]
    for f in forms
        v = ev(f, env, w)
        push!(vals, v)
    end
    return vals
end

function repl(w, env)
    println()
    println("--- TRIAD REPL (host Julia) — S-expressions; 'quit' per uscire ---")
    while true
        print("triad> ")
        line = readline()
        s = strip(line)
        isempty(s) && continue
        s == "quit" && break
        try
            for form in load_program(s)
                println(ev(form, env, w))
            end
        catch e
            println("errore: ", sprint(showerror, e))
        end
    end
end

function main()
    w = World()
    env = Env()
    run_program(w, load_program(DEMO), env)
    if isinteractive()
        repl(w, env)
    end
end

main()
