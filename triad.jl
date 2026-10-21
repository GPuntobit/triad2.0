#!/usr/bin/env julia
# =====================================================================
#  TRIAD — un linguaggio che si legge come Julia e prende da Prolog
#  e da Lisp i pezzi che mancano a Julia.        (kernel: triad.jl)
#
#   * JULIA  : function ... end, struct, tipi con ::, multiple dispatch,
#              operatori che sono funzioni, if/for/while/let
#   * PROLOG : fact, rule, unificazione con occurs-check, SLD con
#              backtracking; `solve` restituisce un valore (lista)
#   * LISP   : il codice è dato (albero Node), :( ... ) / $ e macro
#
#  E come caratteristiche del linguaggio: errori come dati, contratti
#  (requires/ensures), budget, tracce, effetti dichiarati.
#
#  Spec: SPEC.md        Sintassi: syntax.jl       Zero dipendenze.
#
#  AVVIO — tre modalità indipendenti da Julia:
#
#  1. Launcher (consigliato, cerca Julia automaticamente):
#       triad                           REPL
#       triad file.td a b               esegue un file
#       triad -l file.td                carica e apre il REPL
#       triad --build                   crea eseguibile standalone
#
#  2. File .td eseguibili direttamente (shebang):
#       #!/usr/bin/env triad            ← prima riga del file .td
#       chmod +x programma.td
#       ./programma.td arg1 arg2
#
#  3. Standalone (nessuna dipendenza da Julia):
#       triad --build                   compila bin/triad-native
#       bin/triad-native file.td        esegue senza Julia
#
#  Fallback (se Julia è disponibile):
#       julia triad.jl [opzioni]        funziona ancora
#       Tutte le opzioni: triad --help
# =====================================================================
module Triad

export World, run_source, parse_program, unparse, sexpr, tshow, repl, main

# ---------------- 1. VALORI E ALBERO ----------------------------------
"Variabile logica `?x`."
struct TVar
    name::Symbol
end

"Termine composto della logica: `f(args...)`."
struct Term
    f::Symbol
    args::Vector{Any}
end

"Lista-pattern `[h | t]` della logica."
struct Cons
    head::Any
    tail::Any
end

"Nodo dell'albero uniforme: tutto il codice Triad è fatto di Node."
struct Node
    head::Symbol
    args::Vector{Any}
end

"Istanza di struct (named=false) o record interno con nomi (Event, Info...)."
struct Rec
    tag::Symbol
    fields::NamedTuple
    named::Bool
end

"Errore come dato."
struct Err
    kind::Symbol
    msg::String
    data::Any
end

"Una soluzione di `solve`: legami delle variabili della query."
struct Solution
    names::Vector{Symbol}
    vals::Vector{Any}
end

struct TType          # un tipo come valore: Int, Float, Point...
    name::Symbol
end
struct GenericFn      # funzione generica (insieme di metodi) come valore
    name::Symbol
end
struct BuiltinFn
    name::Symbol
    f::Function
    effect::Union{Symbol,Nothing}
end

for T in (:Term, :Cons, :Node, :Rec, :Err, :Solution)
    @eval Base.:(==)(a::$T, b::$T) = all(getfield(a, k) == getfield(b, k) for k in fieldnames($T))
    @eval Base.hash(a::$T, h::UInt) =
        hash(Tuple(getfield(a, k) for k in fieldnames($T)), hash($(QuoteNode(T)), h))
end

# comodità lato Julia: r.campo legge i campi della struct Triad
Base.getproperty(r::Rec, k::Symbol) =
    k in (:tag, :fields, :named) ? getfield(r, k) : getfield(r, :fields)[k]
function Base.getproperty(s::Solution, k::Symbol)
    k in (:names, :vals) && return getfield(s, k)
    i = findfirst(==(k), getfield(s, :names))
    i === nothing && error("la soluzione non lega ?$k")
    getfield(s, :vals)[i]
end

# ---------------- 2. ERRORI E SEGNALI ---------------------------------
struct TriadError <: Exception
    err::Err
end
struct ReturnSig <: Exception
    val::Any
end
struct BreakSig <: Exception end
struct ContinueSig <: Exception end

info(; kw...) = Rec(:Info, (; kw...), true)
raise(kind::Symbol, msg::AbstractString, data = nothing) =
    throw(TriadError(Err(kind, String(msg), data)))
iscontrol(ex) = ex isa ReturnSig || ex isa BreakSig || ex isa ContinueSig || ex isa InterruptException

"Converte qualsiasi eccezione (anche dell'host) in un Err."
function to_err(ex)
    ex isa TriadError && return ex.err
    ex isa StackOverflowError && return Err(:overflow, "ricorsione troppo profonda (stack overflow)", nothing)
    ex isa DivideError && return Err(:domain, "divisione intera per zero", nothing)
    ex isa DomainError && return Err(:domain, sprint(showerror, ex), nothing)
    ex isa BoundsError && return Err(:bounds, "indice fuori dai limiti", nothing)
    ex isa InexactError && return Err(:domain, "conversione non esatta: $(ex.val)", nothing)
    Err(:host, sprint(showerror, ex), nothing)
end

# ---------------- 3. AMBIENTI -----------------------------------------
struct Unbound end
const UNBOUND = Unbound()

mutable struct Env
    parent::Union{Env,Nothing}
    vars::Dict{Symbol,Any}
    types::Dict{Symbol,Symbol}  # tipo dichiarato di un nome: vincola gli assegnamenti successivi
    isfn::Bool            # frame di funzione: confine per l'assegnamento ai globali
end
# [QODER] newenv aveva tre argomenti (parent, vars, isfn): aggiunto `types`, sempre vuoto all'inizio.
newenv(parent; isfn::Bool = false) = Env(parent, Dict{Symbol,Any}(), Dict{Symbol,Symbol}(), isfn)

function lookup(e::Union{Env,Nothing}, k::Symbol)
    while e !== nothing
        v = get(e.vars, k, UNBOUND)
        v === UNBOUND || return v
        e = e.parent
    end
    UNBOUND
end

# ---------------- 4. MONDO --------------------------------------------
struct Lam
    params::Vector{Symbol}
    types::Vector{Symbol}
    body::Any
    env::Env
end

struct TMethod
    name::Symbol
    params::Vector{Symbol}
    types::Vector{Symbol}
    rettype::Symbol
    effects::Vector{Symbol}
    body::Any
    env::Env
end

struct MacroDef
    params::Vector{Symbol}
    body::Any
    env::Env
end

struct StructDef
    name::Symbol
    fields::Vector{Symbol}
    types::Vector{Symbol}
end

struct Clause
    head::Term
    body::Vector{Any}
end

mutable struct Frame
    name::Symbol
    ensures::Vector{Tuple{Any,Env}}
end

mutable struct World
    globals::Env
    funcs::Dict{Symbol,Vector{TMethod}}
    structs::Dict{Symbol,StructDef}
    macros::Dict{Symbol,MacroDef}
    kb::Dict{Tuple{Symbol,Int},Vector{Clause}}
    prednames::Set{Symbol}
    steps::Int                         # passi eseguiti
    budget::Int                        # passo oltre il quale scatta Err(:budget)
    budget_owner::Int                  # id del `with budget` che l'ha fissato
    effects::Union{Nothing,Set{Symbol}}  # effetti permessi; nothing = tutti (top level)
    frames::Vector{Frame}
    tracer::Union{Nothing,Vector{Any}}
    counter::Int
    out::IO
end
World(; out::IO = stdout) =
    World(newenv(nothing), Dict{Symbol,Vector{TMethod}}(), Dict{Symbol,StructDef}(),
          Dict{Symbol,MacroDef}(), Dict{Tuple{Symbol,Int},Vector{Clause}}(), Set{Symbol}(),
          0, typemax(Int), 0, nothing, Frame[], nothing, 0, out)
nextid!(w::World) = (w.counter += 1)

function tick!(w::World)
    w.steps += 1
    w.steps > w.budget &&
        raise(:budget, "budget esaurito: superati i passi consentiti",
              info(owner = w.budget_owner, steps = w.steps))
    nothing
end

const KNOWN_EFFECTS = Set{Symbol}([:io, :state])

# ---------------- 5. TIPI ---------------------------------------------
const PRIM_TYPES = Set{Symbol}([:Any, :Number, :Int, :Float, :String, :Symbol, :Bool,
    :Nothing, :List, :Function, :Err, :Solution, :Expr, :Term, :LVar, :Type])

function typeof_t(x)::Symbol
    x isa Bool && return :Bool
    x isa Integer && return :Int
    x isa AbstractFloat && return :Float
    x isa AbstractString && return :String
    x isa Symbol && return :Symbol
    x === nothing && return :Nothing
    x isa AbstractVector && return :List
    (x isa Lam || x isa GenericFn || x isa BuiltinFn) && return :Function
    x isa Rec && return x.tag
    x isa Err && return :Err
    x isa Solution && return :Solution
    x isa Node && return :Expr
    (x isa Term || x isa Cons) && return :Term
    x isa TVar && return :LVar
    x isa TType && return :Type
    :Any
end

issub(a::Symbol, b::Symbol) = a === b || b === :Any || (b === :Number && (a === :Int || a === :Float))
known_type(w::World, T::Symbol) = T in PRIM_TYPES || haskey(w.structs, T)

"Controlla (e converte Int→Float, come Julia) un valore contro un tipo dichiarato."
function conform(v, T::Symbol, what)
    T === :Any && return v
    T === :Float && v isa Integer && !(v isa Bool) && return Float64(v)
    issub(typeof_t(v), T) ||
        raise(:type, "$what: atteso $T, ricevuto $(typeof_t(v)) ($(tshow(v)))",
              info(expected = T, got = typeof_t(v)))
    v
end

# ---------------- 6. UNIFICAZIONE -------------------------------------
# I legami vivono in uno Store mutabile con trail (come nella WAM):
# lookup O(1), e il backtracking annulla i legami fino a un segno.
mutable struct Store
    b::Dict{Symbol,Any}
    trail::Vector{Symbol}
end
Store() = Store(Dict{Symbol,Any}(), Symbol[])
mark(s::Store) = length(s.trail)
function undo!(s::Store, m::Int)
    while length(s.trail) > m
        delete!(s.b, pop!(s.trail))
    end
end

function walk(t, s::Store)
    while t isa TVar
        v = get(s.b, t.name, UNBOUND)
        v === UNBOUND && return t
        t = v
    end
    t
end

function occurs(name::Symbol, t, s::Store)
    t = walk(t, s)
    t isa TVar && return t.name === name
    t isa Term && return any(a -> occurs(name, a, s), t.args)
    t isa Cons && return occurs(name, t.head, s) || occurs(name, t.tail, s)
    t isa AbstractVector && return any(a -> occurs(name, a, s), t)
    t isa Rec && return any(a -> occurs(name, a, s), values(t.fields))
    false
end

function bindvar!(v::TVar, t, s::Store)
    occurs(v.name, t, s) && return false          # occurs-check
    s.b[v.name] = t
    push!(s.trail, v.name)
    true
end

atom_eq(a, b) = a === b || (typeof(a) === typeof(b) && isequal(a, b))

function unify_seq!(xs, ys, s::Store)
    length(xs) == length(ys) || return false
    for (x, y) in zip(xs, ys)
        unify!(x, y, s) || return false
    end
    true
end

"Unifica a e b estendendo lo store. Se fallisce, il chiamante annulla con undo!."
function unify!(a, b, s::Store)
    a = walk(a, s); b = walk(b, s)
    a isa TVar && b isa TVar && a.name === b.name && return true
    a isa TVar && return bindvar!(a, b, s)
    b isa TVar && return bindvar!(b, a, s)
    if a isa Term && b isa Term
        (a.f === b.f && length(a.args) == length(b.args)) || return false
        return unify_seq!(a.args, b.args, s)
    end
    a isa Rec && b isa Term && ((a, b) = (b, a))
    if a isa Term && b isa Rec     # pattern su struct: Point(?x, ?y)
        a.f === b.tag || return false
        return unify_seq!(a.args, collect(values(b.fields)), s)
    end
    a isa AbstractVector && b isa Cons && ((a, b) = (b, a))
    if a isa Cons
        if b isa Cons
            return unify!(a.head, b.head, s) && unify!(a.tail, b.tail, s)
        elseif b isa AbstractVector
            isempty(b) && return false
            return unify!(a.head, b[1], s) && unify!(a.tail, Any[b[2:end]...], s)
        end
        return false
    end
    a isa AbstractVector && b isa AbstractVector && return unify_seq!(a, b, s)
    if a isa Rec && b isa Rec
        (a.tag === b.tag && keys(a.fields) == keys(b.fields)) || return false
        return unify_seq!(collect(values(a.fields)), collect(values(b.fields)), s)
    end
    atom_eq(a, b)
end

"Tenta l'unificazione; se fallisce non lascia legami."
function try_unify!(a, b, s::Store)
    m = mark(s)
    unify!(a, b, s) && return true
    undo!(s, m)
    false
end

"Applica a fondo i legami (le liste restano Vector{Any})."
function resolve(t, s::Store)
    t = walk(t, s)
    t isa Term && return Term(t.f, Any[resolve(x, s) for x in t.args])
    if t isa Cons
        h = resolve(t.head, s); tl = resolve(t.tail, s)
        return tl isa AbstractVector ? vcat(Any[h], tl) : Cons(h, tl)
    end
    t isa AbstractVector && return Any[resolve(x, s) for x in t]
    if t isa Rec
        ks = keys(t.fields)
        return Rec(t.tag, NamedTuple{ks}(Tuple(resolve(v, s) for v in values(t.fields))), t.named)
    end
    t
end

"Standardizzazione a parte: variabili fresche, una per nome, per ogni uso di clausola."
function renamevars(t, m::Dict{Symbol,TVar}, w::World)
    t isa TVar && return get!(() -> TVar(Symbol(t.name, "#", nextid!(w))), m, t.name)
    t isa Term && return Term(t.f, Any[renamevars(x, m, w) for x in t.args])
    t isa Cons && return Cons(renamevars(t.head, m, w), renamevars(t.tail, m, w))
    t isa AbstractVector && return Any[renamevars(x, m, w) for x in t]
    if t isa Rec     # i record sono termini come gli altri: le variabili al loro interno vanno rinate
        ks = keys(t.fields)
        return Rec(t.tag, NamedTuple{ks}(Tuple(renamevars(v, m, w) for v in values(t.fields))), t.named)
    end
    t
end

function collect_vars!(acc::Vector{Symbol}, t)
    if t isa TVar
        startswith(string(t.name), "_") || t.name in acc || push!(acc, t.name)
    elseif t isa Term
        foreach(a -> collect_vars!(acc, a), t.args)
    elseif t isa Cons
        collect_vars!(acc, t.head); collect_vars!(acc, t.tail)
    elseif t isa AbstractVector
        foreach(a -> collect_vars!(acc, a), t)
    elseif t isa Rec
        foreach(v -> collect_vars!(acc, v), values(t.fields))
    end
    acc
end

# ---------------- 7. RISOLUZIONE SLD (iterativa) -----------------------
# DFS con uno stack esplicito di stati: niente ricorsione dell'host,
# quindi niente stack overflow; i cicli infiniti finiscono in Err(:budget).
struct GL                       # lista di goal (immutabile)
    goal::Any
    depth::Int
    next::Union{GL,Nothing}
end
struct ExitMark                 # marcatore per l'evento :exit della traccia
    goal::Any
    depth::Int
end
struct State
    goals::Union{GL,Nothing}
    mark::Int                   # lunghezza del trail quando lo stato è nato
    alt::Int                    # 0 = goal nuovo; i = riprova dalla clausola i
end

const DEFAULT_SOLVE_STEPS = 1_000_000
const CMP_OPS = Set{Symbol}(Symbol.(["==", "!=", "<", "<=", ">", ">="]))

event(port::Symbol, goal, depth::Int) = Rec(:Event, (port = port, goal = goal, depth = depth), true)

prepend(goals::Vector{Any}, depth::Int, rest) = foldr((g, acc) -> GL(g, depth, acc), goals; init = rest)

function solve_goal(w::World, goal, s::Store = Store(); limit::Int = typemax(Int),
                    maxdepth::Int = typemax(Int), steps::Int = DEFAULT_SOLVE_STEPS,
                    trace::Union{Nothing,Vector{Any}} = nothing,
                    qvars::Vector{Symbol} = collect_vars!(Symbol[], goal),
                    each::Union{Nothing,Function} = nothing)
    # each(sol, more): se c'è, riceve le soluzioni una alla volta invece di accumularle
    # (more = restano punti di scelta); se restituisce false la ricerca si ferma.
    # La usa la query interattiva del REPL.
    sols = Any[]
    limit <= 0 && return sols
    base = mark(s)
    stack = State[State(GL(goal, 0, nothing), base, 0)]
    n = 0; nfound = 0
    try
        while !isempty(stack)
            st = pop!(stack)
            undo!(s, st.mark)
            n += 1
            n > steps && raise(:budget, "solve: superato il limite di $steps passi",
                               info(owner = 0, steps = steps, solutions = nfound))
            tick!(w)
            gl = st.goals
            if gl === nothing
                sol = Solution(qvars, Any[resolve(TVar(v), s) for v in qvars])
                nfound += 1
                each === nothing ? push!(sols, sol) : (each(sol, !isempty(stack)) === false && break)
                nfound >= limit && break
                continue
            end
            g = gl.goal; d = gl.depth; rest = gl.next
            here = mark(s)
            if g isa ExitMark
                trace === nothing || push!(trace, event(:exit, resolve(g.goal, s), g.depth))
                push!(stack, State(rest, here, 0))
                continue
            end
            g = walk(g, s)
            g isa TVar && raise(:instantiation, "goal non istanziato: $(tshow(g))")
            if g isa Bool
                g && push!(stack, State(rest, here, 0))
                continue
            end
            g isa Term || raise(:type, "goal non valido: $(tshow(g))")
            f = g.f; ar = length(g.args)
            if f === :and && ar == 2
                push!(stack, State(GL(g.args[1], d, GL(g.args[2], d, rest)), here, 0))
            elseif f === :or && ar == 2
                push!(stack, State(GL(g.args[2], d, rest), here, 0))
                push!(stack, State(GL(g.args[1], d, rest), here, 0))
            elseif f === :not && ar == 1
                inner = solve_goal(w, g.args[1], s; limit = 1, maxdepth = maxdepth,
                                   steps = steps - n, qvars = Symbol[])
                isempty(inner) && push!(stack, State(rest, here, 0))
            elseif f === Symbol("=") && ar == 2
                try_unify!(g.args[1], g.args[2], s) && push!(stack, State(rest, mark(s), 0))
            elseif f === :is && ar == 2
                v = eval_term(w, g.args[2], s)
                try_unify!(g.args[1], v, s) && push!(stack, State(rest, mark(s), 0))
            elseif f in CMP_OPS && ar == 2
                r = call_named(w, f, Any[eval_term(w, g.args[1], s), eval_term(w, g.args[2], s)])
                r === true && push!(stack, State(rest, here, 0))
            elseif haskey(w.kb, (f, ar))
                if d >= maxdepth
                    trace === nothing || push!(trace, event(:depth, resolve(g, s), d))
                    continue
                end
                cls = w.kb[(f, ar)]
                trace === nothing || push!(trace, event(st.alt == 0 ? :call : :redo, resolve(g, s), d))
                found = false
                for i in max(st.alt, 1):length(cls)
                    m = Dict{Symbol,TVar}()
                    try_unify!(renamevars(cls[i].head, m, w), g, s) || continue
                    body = Any[renamevars(b, m, w) for b in cls[i].body]
                    i < length(cls) && push!(stack, State(gl, here, i + 1))   # punto di scelta
                    nxt = trace === nothing ? rest : GL(ExitMark(g, d), d, rest)
                    push!(stack, State(prepend(body, d + 1, nxt), mark(s), 0))
                    found = true
                    break
                end
                found || trace === nothing || push!(trace, event(:fail, resolve(g, s), d))
            elseif is_callable_name(w, f)
                # una funzione Triad usata come goal: argomenti valutati, deve dare Bool
                r = call_named(w, f, Any[eval_term(w, a, s) for a in g.args])
                r isa Bool || raise(:type, "la funzione $f usata come goal deve restituire Bool, " *
                                           "ha restituito $(tshow(r))")
                r && push!(stack, State(rest, here, 0))
            else
                raise(:undef, "predicato sconosciuto: $f/$ar", info(predicate = f, arity = ar))
            end
        end
    finally
        undo!(s, base)
    end
    sols
end

"Valuta un termine come espressione (per `is` e i confronti nei goal)."
function eval_term(w::World, t, s::Store)
    t = walk(t, s)
    t isa TVar && raise(:instantiation, "variabile $(tshow(t)) non legata in un'espressione",
                        info(var = t.name))
    if t isa Term
        if is_callable_name(w, t.f) && !haskey(w.kb, (t.f, length(t.args)))
            return call_named(w, t.f, Any[eval_term(w, a, s) for a in t.args])
        end
        return resolve(t, s)
    end
    t isa AbstractVector && return Any[eval_term(w, a, s) for a in t]
    t isa Cons && return resolve(t, s)
    t
end

# ---------------- 8. VISUALIZZAZIONE ----------------------------------
const BINPREC = Dict{Symbol,Int}(
    :or => 3, :and => 4,
    Symbol("==") => 5, Symbol("!=") => 5, :< => 5, :<= => 5, :> => 5, :>= => 5,
    :in => 5, :isa => 5, :is => 5, Symbol("=") => 5,
    Symbol(":") => 6, :+ => 7, :- => 7, :* => 8, :/ => 8, :% => 8, :^ => 10)

function tshow(io::IO, x)
    if x === nothing
        print(io, "nothing")
    elseif x isa AbstractString
        show(io, x)
    elseif x isa Symbol
        print(io, ":", x)
    elseif x isa Bool || x isa Number
        print(io, x)
    elseif x isa AbstractVector
        print(io, "[")
        for (i, v) in enumerate(x)
            i > 1 && print(io, ", ")
            tshow(io, v)
        end
        print(io, "]")
    elseif x isa TVar
        print(io, "?", x.name)
    elseif x isa Term
        show_term(io, x, 0)
    elseif x isa Cons
        print(io, "["); tshow(io, x.head); print(io, " | "); tshow(io, x.tail); print(io, "]")
    elseif x isa Rec
        print(io, x.tag, "(")
        for (i, (k, v)) in enumerate(pairs(x.fields))
            i > 1 && print(io, ", ")
            x.named && print(io, k, " = ")
            tshow(io, v)
        end
        print(io, ")")
    elseif x isa Solution
        print(io, "{")
        for (i, (k, v)) in enumerate(zip(x.names, x.vals))
            i > 1 && print(io, ", ")
            print(io, k, " = "); tshow(io, v)
        end
        print(io, "}")
    elseif x isa Err
        print(io, "Err(:", x.kind, ", "); show(io, x.msg)
        x.data === nothing || (print(io, ", "); tshow(io, x.data))
        print(io, ")")
    elseif x isa Node
        print(io, ":(", unparse(x), ")")
    elseif x isa Lam
        print(io, "#lambda(", join(x.params, ", "), ")")
    elseif x isa GenericFn
        print(io, "#function ", x.name)
    elseif x isa BuiltinFn
        print(io, "#builtin ", x.name)
    elseif x isa TType
        print(io, x.name)
    else
        show(io, x)
    end
end
tshow(x) = sprint(tshow, x)
tstring(x) = x isa AbstractString ? String(x) : x isa Symbol ? string(x) : tshow(x)   # print, come Julia

function show_term(io::IO, t::Term, prec::Int)
    if length(t.args) == 2 && haskey(BINPREC, t.f)
        p = BINPREC[t.f]
        p < prec && print(io, "(")
        op = t.f === :and ? "&&" : t.f === :or ? "||" : string(t.f)
        sub(x, q) = x isa Term ? show_term(io, x, q) : tshow(io, x)
        sub(t.args[1], p); print(io, " ", op, " "); sub(t.args[2], p + 1)
        p < prec && print(io, ")")
    elseif t.f === :not && length(t.args) == 1
        print(io, "!"); t.args[1] isa Term ? show_term(io, t.args[1], 9) : tshow(io, t.args[1])
    elseif isempty(t.args)
        print(io, t.f)
    else
        print(io, t.f, "(")
        for (i, a) in enumerate(t.args)
            i > 1 && print(io, ", ")
            tshow(io, a)
        end
        print(io, ")")
    end
end

for T in (:TVar, :Term, :Cons, :Rec, :Err, :Solution, :Node, :Lam, :GenericFn, :BuiltinFn, :TType)
    @eval Base.show(io::IO, x::$T) = tshow(io, x)
end

"Codice → testo Triad (una riga)."
unparse(x) = sprint(io -> up(io, x, 0))

function up_list(io, xs, sep = ", ")
    for (i, x) in enumerate(xs)
        i > 1 && print(io, sep)
        up(io, x, 0)
    end
end
up_stmts(io, b) = b isa Node && b.head === :block ? up_list(io, b.args, "; ") : up(io, b, 0)

function up(io::IO, x, prec::Int)
    if !(x isa Node)
        x isa Symbol ? print(io, x) :
        x isa TVar ? print(io, "?", x.name) :
        tshow(io, x)
        return
    end
    h = x.head; a = x.args
    binary(op, p, l, r) = begin
        p < prec && print(io, "(")
        up(io, l, p); print(io, " ", op, " "); up(io, r, p + 1)
        p < prec && print(io, ")")
    end
    if h === :call
        f = a[1]
        if f isa Symbol && f === Symbol(":") && length(a) == 3
            # il range si scrive attaccato: `1:n`, altrimenti il lexer non lo riconosce
            6 < prec && print(io, "(")
            up(io, a[2], 7); print(io, ":"); up(io, a[3], 7)
            6 < prec && print(io, ")")
        elseif f isa Symbol && haskey(BINPREC, f) && length(a) == 3
            binary(f, BINPREC[f], a[2], a[3])
        elseif f isa Symbol && (f === :- || f === :!) && length(a) == 2
            print(io, f); up(io, a[2], 9)
        else
            up(io, f, 12); print(io, "("); up_list(io, a[2:end]); print(io, ")")
        end
    elseif h === :and
        binary("&&", 4, a[1], a[2])
    elseif h === :or
        binary("||", 3, a[1], a[2])
    elseif h === :assign
        1 < prec && print(io, "(")
        up(io, a[1], 2); print(io, " = "); up(io, a[2], 1)
        1 < prec && print(io, ")")
    elseif h === :opassign
        up(io, a[2], 2); print(io, " ", a[1], "= "); up(io, a[3], 1)
    elseif h === :destructure
        up(io, a[1], 0); print(io, " = "); up(io, a[2], 1)
    elseif h === :dfor
        print(io, "for "); up(io, a[1], 0); print(io, " in "); up(io, a[2], 0)
        print(io, "; "); up_stmts(io, a[3]); print(io, "; end")
    elseif h === :sym
        print(io, ":", a[1])
    elseif h === :dot
        up(io, a[1], 12); print(io, ".", a[2])
    elseif h === :index
        up(io, a[1], 12); print(io, "["); up_list(io, a[2:end]); print(io, "]")
    elseif h === :list
        print(io, "["); up_list(io, a); print(io, "]")
    elseif h === :cons
        print(io, "["); up_list(io, a[1].args); print(io, " | "); up(io, a[2], 0); print(io, "]")
    elseif h === :comprehension
        print(io, "["); up(io, a[1], 0); print(io, " for ", a[2], " in "); up(io, a[3], 0)
        a[4] === nothing || (print(io, " if "); up(io, a[4], 0))
        print(io, "]")
    elseif h === :tuple
        print(io, "("); up_list(io, a); length(a) == 1 && print(io, ","); print(io, ")")
    elseif h === :typed
        up(io, a[1], 11); print(io, "::", a[2])
    elseif h === :lambda
        ps = a[1].args
        2 < prec && print(io, "(")
        length(ps) == 1 ? print(io, ps[1]) : (print(io, "("); up_list(io, ps); print(io, ")"))
        print(io, " -> ")
        if a[2] isa Node && a[2].head === :block
            print(io, "begin "); up_stmts(io, a[2]); print(io, " end")
        else
            up(io, a[2], 2)
        end
        2 < prec && print(io, ")")
    elseif h === :quasi
        if a[1] isa Node && a[1].head === :block
            print(io, "quote "); up_stmts(io, a[1]); print(io, " end")
        else
            print(io, ":("); up(io, a[1], 0); print(io, ")")
        end
    elseif h === :unquote
        if a[1] isa Symbol
            print(io, "\$", a[1])
        else
            print(io, "\$("); up(io, a[1], 0); print(io, ")")
        end
    elseif h === :string
        print(io, "\"")
        for part in a
            if part isa String
                print(io, escape_string(part, "\"\$"))
            elseif part isa Symbol
                print(io, "\$(", part, ")")
            else
                print(io, "\$("); up(io, part, 0); print(io, ")")
            end
        end
        print(io, "\"")
    elseif h === :block
        if length(a) == 1
            up(io, a[1], prec)
        else
            print(io, "begin "); up_stmts(io, x); print(io, " end")
        end
    elseif h === :if
        print(io, "if "); up(io, a[1], 0); print(io, "; "); up_stmts(io, a[2])
        e = a[3]
        while e isa Node && e.head === :if
            print(io, "; elseif "); up(io, e.args[1], 0); print(io, "; "); up_stmts(io, e.args[2])
            e = e.args[3]
        end
        e === nothing || (print(io, "; else; "); up_stmts(io, e))
        print(io, "; end")
    elseif h === :while
        print(io, "while "); up(io, a[1], 0); print(io, "; "); up_stmts(io, a[2]); print(io, "; end")
    elseif h === :for
        print(io, "for ", a[1], " in "); up(io, a[2], 0); print(io, "; "); up_stmts(io, a[3]); print(io, "; end")
    elseif h === :let
        print(io, "let "); up_list(io, a[1].args); print(io, "; "); up_stmts(io, a[2]); print(io, "; end")
    elseif h === :function
        print(io, "function ", a[1], "("); up_list(io, a[2].args); print(io, ")")
        a[3] === :Any || print(io, "::", a[3])
        isempty(a[4].args) || print(io, " !", join(a[4].args, ", "))
        print(io, "; "); up_stmts(io, a[5]); print(io, "; end")
    elseif h === :struct
        print(io, "struct ", a[1], "; "); up_list(io, a[2].args, "; "); print(io, "; end")
    elseif h === :macro
        print(io, "macro ", a[1], "("); up_list(io, a[2].args); print(io, "); ")
        up_stmts(io, a[3]); print(io, "; end")
    elseif h === :macrocall
        print(io, "@", a[1], "("); up_list(io, a[2:end]); print(io, ")")
    elseif h === :fact
        print(io, "fact "); up(io, a[1], 0)
    elseif h === :rule
        print(io, "rule "); up(io, a[1], 0)
        length(a) > 1 && (print(io, " :- "); up_list(io, a[2:end]))
    elseif h === :solve
        print(io, "solve "); up(io, a[1], 1)
        for o in a[2].args
            o.args[1] === :trace ? print(io, " trace") : (print(io, " ", o.args[1], " "); up(io, o.args[2], 7))
        end
    elseif h === :try
        print(io, "try "); up_stmts(io, a[1])
        a[3] === nothing || (print(io, "; catch"); a[2] === nothing || print(io, " ", a[2]);
                             print(io, "; "); up_stmts(io, a[3]))
        print(io, "; end")
    elseif h === :with
        print(io, "with "); up_list(io, a[1].args); print(io, "; "); up_stmts(io, a[2]); print(io, "; end")
    elseif h in (:return, :requires, :ensures)
        print(io, h)
        a[1] === nothing || (print(io, " "); up(io, a[1], 0))
    elseif h in (:break, :continue)
        print(io, h)
    else
        print(io, sexpr(x))
    end
end

"Codice → S-expression: la vista 'Lisp' dell'albero uniforme."
function sexpr(x)
    x isa Node || return x isa Symbol ? string(x) : x isa TVar ? "?$(x.name)" : tshow(x)
    "(" * join([string(x.head); [sexpr(a) for a in x.args]], " ") * ")"
end

# ---------------- 9. VALUTATORE ---------------------------------------
ev(x::Symbol, env::Env, w::World) = lookup_name(x, env, w)
ev(x::TVar, env::Env, w::World) =
    raise(:syntax, "la variabile logica ?$(x.name) si usa solo in fact, rule e solve",
          info(var = x.name))
ev(x::Node, env::Env, w::World) = ev_node(x, env, w)
ev(x, env::Env, w::World) = x

function lookup_name(x::Symbol, env::Env, w::World)
    v = lookup(env, x)
    v === UNBOUND || return v
    haskey(w.funcs, x) && return GenericFn(x)
    (haskey(w.structs, x) || x in PRIM_TYPES) && return TType(x)
    haskey(BUILTINS, x) && return BUILTINS[x]
    raise(:undef, "'$x' non è definito", info(name = x))
end

"Scrive `k` nell'ambiente dove è già legato (o in `env`): il tipo dichiarato con `x::T = e`
vincola anche gli assegnamenti successivi, come in Julia."
function set_var!(env::Env, k::Symbol, v, w::World; T::Union{Symbol,Nothing} = nothing)
    # [QODER] prima: `e.vars[k] = v` e basta, senza consultare alcun tipo — `x::Int = 1`
    # seguito da `x = 0.5` lasciava un Float nel nome dichiarato Int (SPEC §4, «vincolo del dichiarato»).
    e = env
    crossed = false            # dentro una funzione i globali non si riassegnano
    while e !== nothing
        e === w.globals && crossed && break
        if haskey(e.vars, k)
            T !== nothing && T !== :Any && (e.types[k] = T)
            haskey(e.types, k) && (v = conform(v, e.types[k], "assegnamento a $k"))
            e.vars[k] = v
            return v
        end
        e.isfn && (crossed = true)
        e = e.parent
    end
    T !== nothing && T !== :Any && (env.types[k] = T)
    ty = get(env.types, k, nothing)
    env.vars[k] = ty === nothing ? v : conform(v, ty, "assegnamento a $k")
end

function need_bool(v, where)
    v isa Bool || raise(:type, "$where: attesa una condizione Bool, ricevuto $(typeof_t(v)) ($(tshow(v)))",
                        info(expected = :Bool, got = typeof_t(v)))
    v
end

cur_fn(w::World) = isempty(w.frames) ? :toplevel : w.frames[end].name

function with_effects(f, w::World, eff)
    old = w.effects
    w.effects = eff
    try
        f()
    finally
        w.effects = old
    end
end

function ev_node(x::Node, env::Env, w::World)
    h = x.head; a = x.args
    if h === :call
        return eval_call(x, env, w)
    elseif h === :block
        v = nothing
        for s in a
            v = ev(s, env, w)
        end
        return v
    elseif h === :sym
        return a[1]
    elseif h === :string
        return join(tstring(ev(p, env, w)) for p in a)
    elseif h === :list || h === :tuple
        return Any[ev(e, env, w) for e in a]
    elseif h === :cons
        tail = ev(a[2], env, w)
        tail isa AbstractVector || raise(:type, "la coda di [... | t] deve essere una lista")
        return vcat(ev(a[1], env, w), tail)
    elseif h === :comprehension
        out = Any[]
        for v in iterable(ev(a[3], env, w))
            tick!(w)
            e2 = newenv(env); e2.vars[a[2]] = v
            a[4] === nothing || need_bool(ev(a[4], e2, w), "filtro della comprehension") || continue
            push!(out, ev(a[1], e2, w))
        end
        return out
    elseif h === :and
        need_bool(ev(a[1], env, w), "&&") || return false
        return need_bool(ev(a[2], env, w), "&&")
    elseif h === :or
        need_bool(ev(a[1], env, w), "||") && return true
        return need_bool(ev(a[2], env, w), "||")
    elseif h === :assign
        return assign!(a[1], ev(a[2], env, w), env, w)
    elseif h === :opassign
        return opassign!(a[2], a[1], a[3], env, w)
    elseif h === :destructure
        return destructure!(a[1], a[2], env, w)
    elseif h === :dot
        return getfield_t(ev(a[1], env, w), a[2])
    elseif h === :index
        coll = ev(a[1], env, w)
        e2 = newenv(env)
        (coll isa AbstractVector || coll isa AbstractString) && (e2.vars[Symbol("end")] = length(coll))
        return index_t(coll, Any[ev(i, e2, w) for i in a[2:end]])
    elseif h === :if
        if need_bool(ev(a[1], env, w), "if")
            return ev(a[2], env, w)
        end
        return a[3] === nothing ? nothing : ev(a[3], env, w)
    elseif h === :while
        while need_bool(ev(a[1], env, w), "while")
            tick!(w)
            try
                ev(a[2], newenv(env), w)
            catch ex
                ex isa BreakSig && break
                ex isa ContinueSig && continue
                rethrow()
            end
        end
        return nothing
    elseif h === :for
        for v in iterable(ev(a[2], env, w))
            tick!(w)
            e2 = newenv(env); e2.vars[a[1]] = v
            try
                ev(a[3], e2, w)
            catch ex
                ex isa BreakSig && break
                ex isa ContinueSig && continue
                rethrow()
            end
        end
        return nothing
    elseif h === :dfor
        pat = a[1]
        pat isa Node && pat.head === :tuple || raise(:syntax, "dfor richiede un pattern di variabili")
        names = Symbol[p for p in pat.args]
        for v in iterable(ev(a[2], env, w))
            tick!(w)
            e2 = newenv(env)
            destructure_bind!(names, v, e2, w)
            try
                ev(a[3], e2, w)
            catch ex
                ex isa BreakSig && break
                ex isa ContinueSig && continue
                rethrow()
            end
        end
        return nothing
    elseif h === :let
        e2 = newenv(env)
        for b in a[1].args
            e2.vars[b.args[1]] = ev(b.args[2], e2, w)
        end
        return ev(a[2], e2, w)
    elseif h === :lambda
        params, types = split_params(a[1])
        for T in types
            known_type(w, T) || raise(:type, "tipo sconosciuto $T nella lambda", info(type = T))
        end
        return Lam(params, types, a[2], env)
    elseif h === :function
        return define_function(x, env, w)
    elseif h === :struct
        return define_struct(x, w)
    elseif h === :macro
        w.macros[a[1]] = MacroDef(Symbol[p for p in a[2].args], a[3], env)
        return nothing
    elseif h === :macrocall
        return ev(expand_macro(x, w), env, w)
    elseif h === :quasi
        return eval_qq(a[1], env, w)
    elseif h === :unquote
        raise(:syntax, "\$ si usa solo dentro :( ... ), quote o un termine logico")
    elseif h === :typed
        return conform(ev(a[1], env, w), a[2], "asserzione ::$(a[2])")
    elseif h === :return
        throw(ReturnSig(a[1] === nothing ? nothing : ev(a[1], env, w)))
    elseif h === :break
        throw(BreakSig())
    elseif h === :continue
        throw(ContinueSig())
    elseif h === :requires
        check_contract(:requires, a[1], env, w)
        return nothing
    elseif h === :ensures
        isempty(w.frames) && raise(:syntax, "ensures si usa solo dentro una function")
        push!(w.frames[end].ensures, (a[1], env))
        return nothing
    elseif h === :fact || h === :rule
        return assert_clause(x, env, w)
    elseif h === :solve
        return run_solve(x, env, w)
    elseif h === :try
        return eval_try(x, env, w)
    elseif h === :with
        return eval_with(x, env, w)
    end
    raise(:syntax, "forma sconosciuta: $h")
end

iterable(v) = v isa AbstractVector || v isa AbstractString ? v :
    raise(:type, "non iterabile: $(typeof_t(v)) ($(tshow(v)))")

function assign!(lhs, v, env::Env, w::World)
    if lhs isa Symbol
        return set_var!(env, lhs, v, w)
    elseif lhs isa Node && lhs.head === :typed && lhs.args[1] isa Symbol
        # [QODER] prima: `set_var!(env, nome, conform(v, T, …), w)` conformava qui senza ricordare T.
        return set_var!(env, lhs.args[1], v, w; T = lhs.args[2])
    elseif lhs isa Node && lhs.head === :index && length(lhs.args) == 2
        coll = ev(lhs.args[1], env, w)
        coll isa AbstractVector || raise(:type, "assegnamento con indice su $(typeof_t(coll))")
        e2 = newenv(env)
        e2.vars[Symbol("end")] = length(coll)
        i = ev(lhs.args[2], e2, w)
        (i isa Integer && 1 <= i <= length(coll)) || raise(:bounds, "indice $i fuori da 1:$(length(coll))")
        coll[i] = v
        return v
    elseif lhs isa Node && lhs.head === :dot
        raise(:type, "le struct sono immutabili: non si può assegnare $(unparse(lhs))")
    end
    raise(:syntax, "non si può assegnare a $(unparse(lhs))")
end

"lhs += rhs: la posizione a sinistra è valutata una volta sola."
function opassign!(place, op::Symbol, rhs, env::Env, w::World)
    if place isa Symbol || (place isa Node && place.head === :typed && place.args[1] isa Symbol)
        name = place isa Symbol ? place : place.args[1]
        old = lookup_name(name, env, w)
        return assign!(place, apply_value(w, GenericFn(op), Any[old, ev(rhs, env, w)]), env, w)
    elseif place isa Node && place.head === :index && length(place.args) == 2
        coll = ev(place.args[1], env, w)
        coll isa AbstractVector || raise(:type, "assegnamento con indice su $(typeof_t(coll))")
        e2 = newenv(env)
        e2.vars[Symbol("end")] = length(coll)
        i = ev(place.args[2], e2, w)
        (i isa Integer && 1 <= i <= length(coll)) || raise(:bounds, "indice $i fuori da 1:$(length(coll))")
        v = apply_value(w, GenericFn(op), Any[coll[i], ev(rhs, env, w)])
        coll[i] = v
        return v
    end
    raise(:syntax, "non si può assegnare a $(unparse(place))")
end

"Esegue (a, b) = expr: valuta rhs come lista, unifica col pattern e assegna."
function destructure!(pat::Node, rhs::Any, env::Env, w::World)
    pat.head === :tuple || raise(:syntax, "pattern di destrutturazione non valido")
    names = Symbol[p for p in pat.args]
    length(names) >= 2 || raise(:syntax, "destrutturazione richiede almeno 2 variabili")
    value = ev(rhs, env, w)
    destructure_bind!(names, value, env, w)
    return value
end

"Assegna i nomi del pattern al valore (lista) per destrutturazione. Arità esatta."
function destructure_bind!(names::Vector{Symbol}, value, env::Env, w::World)
    value isa AbstractVector || raise(:type, "destrutturazione: attesa una lista, ricevuto $(typeof_t(value)) ($(tshow(value)))")
    length(value) == length(names) || raise(:bounds, "destrutturazione: attesi $(length(names)) elementi, ricevuti $(length(value))", info(expected = length(names), got = length(value)))
    for (i, name) in enumerate(names)
        set_var!(env, name, value[i], w)
    end
    nothing
end

function getfield_t(v, k::Symbol)
    if v isa Rec
        haskey(v.fields, k) || raise(:field, "$(v.tag) non ha il campo $k", info(type = v.tag, field = k))
        return v.fields[k]
    elseif v isa Solution
        i = findfirst(==(k), v.names)
        i === nothing && raise(:field, "la soluzione non lega ?$k", info(field = k))
        return v.vals[i]
    elseif v isa Err
        k === :kind && return v.kind
        k === :msg && return v.msg
        k === :data && return v.data
    elseif v isa Node
        k === :head && return v.head
        k === :args && return copy(v.args)
    elseif v isa Term
        k === :functor && return v.f
        k === :args && return copy(v.args)
    end
    raise(:field, "$(typeof_t(v)) non ha il campo $k", info(type = typeof_t(v), field = k))
end

function index_t(coll, idx)
    length(idx) == 1 || raise(:method, "è ammesso un solo indice")
    i = idx[1]
    if coll isa Solution && i isa Symbol
        return getfield_t(coll, i)
    elseif coll isa AbstractVector || coll isa AbstractString
        if i isa Integer
            1 <= i <= length(coll) || raise(:bounds, "indice $i fuori da 1:$(length(coll))",
                                            info(index = i, length = length(coll)))
            return coll[i]
        elseif i isa AbstractVector && all(x -> x isa Integer, i)
            all(x -> 1 <= x <= length(coll), i) || raise(:bounds, "intervallo fuori da 1:$(length(coll))")
            return coll isa AbstractString ? join(collect(coll)[Int.(i)]) : Any[coll[Int.(i)]...]
        end
    end
    raise(:type, "non si può indicizzare $(typeof_t(coll)) con $(typeof_t(i))")
end

# ---- chiamate e dispatch ----
is_callable_name(w::World, f::Symbol) = haskey(w.funcs, f) || haskey(w.structs, f) || haskey(BUILTINS, f)

function eval_call(x::Node, env::Env, w::World)
    f = x.args[1]
    argn = x.args[2:end]
    for a in argn
        a isa Node && a.head === :assign &&
            raise(:syntax, "argomenti con nome non supportati in $(unparse(x))")
    end
    tick!(w)
    if f isa Symbol
        v = lookup(env, f)
        if v === UNBOUND
            is_callable_name(w, f) && return call_named(w, f, Any[ev(a, env, w) for a in argn])
            if f in w.prednames
                # un predicato chiamato come funzione: vero se dimostrabile
                goal = Term(f, Any[build_term(a, env, w) for a in argn])
                return !isempty(solve_goal(w, goal; limit = 1, qvars = Symbol[]))
            end
            raise(:undef, "funzione o predicato sconosciuto: $f", info(name = f))
        end
        return apply_value(w, v, Any[ev(a, env, w) for a in argn])
    end
    apply_value(w, ev(f, env, w), Any[ev(a, env, w) for a in argn])
end

function call_named(w::World, f::Symbol, args::Vector{Any})
    haskey(w.funcs, f) && return call_generic(w, f, args)
    haskey(w.structs, f) && return construct(w.structs[f], args)
    haskey(BUILTINS, f) && return call_builtin(w, BUILTINS[f], args)
    raise(:undef, "funzione sconosciuta: $f", info(name = f))
end

function apply_value(w::World, f, args::Vector{Any})
    f isa Lam && return apply_lam(w, f, args)
    f isa GenericFn && return call_generic(w, f.name, args)
    f isa BuiltinFn && return call_builtin(w, f, args)
    f isa TType && return call_named(w, f.name, args)
    raise(:type, "valore non chiamabile: $(tshow(f))")
end

function apply_lam(w::World, f::Lam, args::Vector{Any})
    length(f.params) == length(args) ||
        raise(:method, "la lambda vuole $(length(f.params)) argomenti, ne ha ricevuti $(length(args))")
    e = newenv(f.env; isfn = true)
    for (p, T, v) in zip(f.params, f.types, args)
        e.vars[p] = conform(v, T, "parametro $p della lambda")
        T !== :Any && (e.types[p] = T)
    end
    run_frame(w, :lambda, f.body, e, :Any)
end

function run_frame(w::World, name::Symbol, body, env::Env, rettype::Symbol)
    fr = Frame(name, Tuple{Any,Env}[])
    push!(w.frames, fr)
    try
        r = try
            ev(body, env, w)
        catch ex
            ex isa ReturnSig || rethrow()
            ex.val
        end
        r = conform(r, rettype, "valore restituito da $name")
        for (c, cenv) in fr.ensures
            e2 = newenv(cenv); e2.vars[:result] = r
            ok = with_effects(() -> ev(c, e2, w), w, Set{Symbol}())
            ok === true || raise(:contract, "ensures violata in $name: $(unparse(c))",
                                 info(fn = name, clause = :ensures, cond = c, result = r))
        end
        return r
    finally
        pop!(w.frames)
    end
end

function check_contract(kind::Symbol, c, env::Env, w::World)
    ok = with_effects(() -> ev(c, env, w), w, Set{Symbol}())
    ok isa Bool || raise(:type, "$kind: attesa una condizione Bool, ricevuto $(tshow(ok))")
    ok || raise(:contract, "$kind violata in $(cur_fn(w)): $(unparse(c))",
                info(fn = cur_fn(w), clause = kind, cond = c))
    nothing
end

applicable_m(m::TMethod, args) =
    length(m.types) == length(args) && all(issub(typeof_t(args[i]), m.types[i]) for i in eachindex(args))
morespecific(a::TMethod, b::TMethod) =
    a.types != b.types && all(issub(a.types[i], b.types[i]) for i in eachindex(a.types))

function call_generic(w::World, name::Symbol, args::Vector{Any})
    ms = get(w.funcs, name, TMethod[])
    cands = [m for m in ms if applicable_m(m, args)]
    if isempty(cands)
        haskey(BUILTINS, name) && return call_builtin(w, BUILTINS[name], args)
        sig = join(typeof_t.(args), ", ")
        raise(:method, "nessun metodo $name($sig)",
              info(fn = name, types = Any[typeof_t.(args)...],
                   methods = Any["$name(" * join(m.types, ", ") * ")" for m in ms]))
    end
    best = [m for m in cands if !any(o -> morespecific(o, m), cands)]
    length(best) == 1 ||
        raise(:ambiguous, "chiamata ambigua $name($(join(typeof_t.(args), ", "))): " *
              join(["$name(" * join(m.types, ", ") * ")" for m in best], " e "),
              info(fn = name))
    invoke_method(w, best[1], args)
end

function invoke_method(w::World, m::TMethod, args::Vector{Any})
    if w.effects !== nothing && !issubset(m.effects, w.effects)
        missing_ = setdiff(m.effects, w.effects)
        raise(:effect, "$(m.name) dichiara !$(join(missing_, ", !")) ma $(cur_fn(w)) non lo permette " *
                       "(funzione pura o effetto non dichiarato)",
              info(fn = m.name, caller = cur_fn(w), missing = Any[missing_...]))
    end
    depth = length(w.frames)
    w.tracer === nothing ||
        push!(w.tracer, Rec(:Event, (port = :call, fn = m.name, args = copy(args), depth = depth), true))
    e = newenv(m.env; isfn = true)
    for (p, T, v) in zip(m.params, m.types, args)
        e.vars[p] = v
        T !== :Any && (e.types[p] = T)   # il parametro mantiene il tipo dichiarato nel frame
    end
    r = with_effects(() -> run_frame(w, m.name, m.body, e, m.rettype), w, Set{Symbol}(m.effects))
    w.tracer === nothing ||
        push!(w.tracer, Rec(:Event, (port = :exit, fn = m.name, value = r, depth = depth), true))
    r
end

function call_builtin(w::World, b::BuiltinFn, args::Vector{Any})
    if b.effect !== nothing && w.effects !== nothing && !(b.effect in w.effects)
        raise(:effect, "$(b.name) richiede !$(b.effect) ma $(cur_fn(w)) non lo dichiara",
              info(fn = b.name, caller = cur_fn(w), missing = Any[b.effect]))
    end
    try
        return b.f(w, args)
    catch ex
        (ex isa TriadError || iscontrol(ex)) && rethrow()
        if ex isa MethodError
            raise(:method, "nessun metodo $(b.name)($(join(typeof_t.(args), ", ")))",
                  info(fn = b.name, types = Any[typeof_t.(args)...]))
        end
        throw(TriadError(to_err(ex)))
    end
end

function construct(sd::StructDef, args::Vector{Any})
    length(args) == length(sd.fields) ||
        raise(:method, "$(sd.name) ha $(length(sd.fields)) campi, ricevuti $(length(args)) argomenti")
    vals = Tuple(conform(args[i], sd.types[i], "campo $(sd.name).$(sd.fields[i])") for i in eachindex(args))
    Rec(sd.name, NamedTuple{Tuple(sd.fields)}(vals), false)
end

# ---- definizioni ----
function split_params(t::Node)
    names = Symbol[]; types = Symbol[]
    for p in t.args
        if p isa Symbol
            push!(names, p); push!(types, :Any)
        elseif p isa Node && p.head === :typed && p.args[1] isa Symbol
            push!(names, p.args[1]); push!(types, p.args[2])
        elseif p isa Node && p.head === :tuple && all(x -> x isa Symbol, p.args)
            for id in p.args
                push!(names, id); push!(types, :Any)
            end
        else
            raise(:syntax, "parametro non valido: $(unparse(p))")
        end
    end
    names, types
end

function define_function(x::Node, env::Env, w::World)
    name, ptuple, rettype, efftuple, body = x.args
    params, types = split_params(ptuple)
    for T in [types; rettype]
        known_type(w, T) || raise(:type, "tipo sconosciuto $T nella definizione di $name", info(type = T))
    end
    effects = Symbol[e for e in efftuple.args]
    for e in effects
        e in KNOWN_EFFECTS || raise(:effect, "effetto sconosciuto !$e (noti: io, state)")
    end
    if env !== w.globals          # funzione locale: una chiusura
        return set_var!(env, name, Lam(params, types, body, env), w)
    end
    m = TMethod(name, params, types, rettype, effects, body, env)
    ms = get!(w.funcs, name, TMethod[])
    filter!(o -> o.types != types, ms)     # ridefinire una firma la sostituisce
    push!(ms, m)
    GenericFn(name)
end

function define_struct(x::Node, w::World)
    name = x.args[1]
    fields, types = split_params(x.args[2])
    name in PRIM_TYPES && raise(:type, "$name è un tipo predefinito")
    for T in types
        (known_type(w, T) || T === name) || raise(:type, "tipo sconosciuto $T nel campo di $name")
    end
    w.structs[name] = StructDef(name, fields, types)
    TType(name)
end

# ---- macro e quasi-quote ----
function expand_macro(x::Node, w::World)
    name = x.args[1]
    haskey(w.macros, name) || raise(:undef, "macro @$name non definita", info(name = name))
    m = w.macros[name]
    args = x.args[2:end]
    length(args) == length(m.params) ||
        raise(:method, "@$name vuole $(length(m.params)) argomenti, ne ha ricevuti $(length(args))")
    e = newenv(m.env; isfn = true)
    for (p, a) in zip(m.params, args)
        e.vars[p] = a                   # gli argomenti arrivano come codice
    end
    with_effects(() -> run_frame(w, Symbol("@", name), m.body, e, :Any), w, Set{Symbol}())
end

function eval_qq(t, env::Env, w::World)
    t isa Node || return t
    t.head === :unquote && return ev(t.args[1], env, w)
    t.head === :quasi && return t
    Node(t.head, Any[eval_qq(a, env, w) for a in t.args])
end

# ---- logica: costruzione di termini e goal ----
function build_term(x, env::Env, w::World)
    x isa TVar && return x
    if x isa Symbol
        v = lookup(env, x)
        v === UNBOUND || return v
        is_callable_name(w, x) && return ev(x, env, w)
        raise(:undef, "'$x' non è definito (in un termine usa :$x per un atomo o ?$x per una variabile logica)",
              info(name = x))
    end
    x isa Node || return x
    h = x.head
    h === :sym && return x.args[1]
    if h === :call && x.args[1] isa Symbol
        return Term(x.args[1], Any[build_term(a, env, w) for a in x.args[2:end]])
    end
    h === :list && return Any[build_term(a, env, w) for a in x.args]
    if h === :cons
        items = Any[build_term(a, env, w) for a in x.args[1].args]
        return foldr(Cons, items; init = build_term(x.args[2], env, w))
    end
    h === :unquote && return ev(x.args[1], env, w)
    ev(x, env, w)
end

function build_goal(x, env::Env, w::World)
    x isa Bool && return x
    x isa Symbol && return Term(x, Any[])
    x isa Node || raise(:syntax, "goal non valido: $(tshow(x))")
    h = x.head
    h === :and && return Term(:and, Any[build_goal(x.args[1], env, w), build_goal(x.args[2], env, w)])
    h === :or && return Term(:or, Any[build_goal(x.args[1], env, w), build_goal(x.args[2], env, w)])
    if h === :tuple
        isempty(x.args) && return true
        return foldr((a, acc) -> Term(:and, Any[a, acc]), Any[build_goal(g, env, w) for g in x.args[1:end-1]];
                     init = build_goal(x.args[end], env, w))
    end
    h === :assign && return Term(Symbol("="), Any[build_term(x.args[1], env, w), build_term(x.args[2], env, w)])
    if h === :unquote
        g = ev(x.args[1], env, w)
        (g isa Term || g isa Bool) || raise(:type, "\$(...) in un goal deve dare un Term, ricevuto $(tshow(g))")
        return g
    end
    if h === :call && x.args[1] isa Symbol
        f = x.args[1]
        if (f === :! || f === :not) && length(x.args) == 2
            return Term(:not, Any[build_goal(x.args[2], env, w)])
        end
        return Term(f, Any[build_term(a, env, w) for a in x.args[2:end]])
    end
    raise(:syntax, "goal non valido: $(unparse(x))")
end

function assert_clause(x::Node, env::Env, w::World)
    if w.effects !== nothing && !(:state in w.effects)
        raise(:effect, "$(x.head) modifica la knowledge base: $(cur_fn(w)) deve dichiarare !state",
              info(fn = cur_fn(w), missing = Any[:state]))
    end
    hd = x.args[1]
    head = hd isa Symbol ? Term(hd, Any[]) :
           (hd isa Node && hd.head === :call && hd.args[1] isa Symbol) ? build_goal(hd, env, w) :
           raise(:syntax, "testa di $(x.head) non valida: $(unparse(hd))")
    head isa Term && !(head.f in (:and, :or, :not)) ||
        raise(:syntax, "testa di $(x.head) non valida: $(unparse(hd))")
    body = Any[build_goal(g, env, w) for g in x.args[2:end]]
    push!(get!(w.kb, (head.f, length(head.args)), Clause[]), Clause(head, body))
    push!(w.prednames, head.f)
    nothing
end

function run_solve(x::Node, env::Env, w::World)
    goal = build_goal(x.args[1], env, w)
    opts = solve_opts(x, env, w)
    tr = opts[:trace] ? Any[] : nothing
    sols = solve_goal(w, goal; limit = opts[:limit], maxdepth = opts[:depth],
                      steps = opts[:steps], trace = tr)
    tr === nothing ? sols : Rec(:Traced, (result = sols, trace = tr), true)
end

"Le opzioni `limit depth steps trace` di un nodo :solve, valutate."
function solve_opts(x::Node, env::Env, w::World)
    opts = Dict{Symbol,Any}(:limit => typemax(Int), :depth => typemax(Int),
                            :steps => DEFAULT_SOLVE_STEPS, :trace => false)
    for o in x.args[2].args
        v = ev(o.args[2], env, w)
        if o.args[1] === :trace
            opts[:trace] = v
        else
            (v isa Integer && v >= 0) || raise(:type, "solve: $(o.args[1]) vuole un Int ≥ 0, ricevuto $(tshow(v))")
            opts[o.args[1]] = Int(v)
        end
    end
    opts
end

# ---- errori, budget, tracce ----
function eval_try(x::Node, env::Env, w::World)
    body, var, handler = x.args
    nframes = length(w.frames)
    try
        return ev(body, env, w)
    catch ex
        iscontrol(ex) && rethrow()
        while length(w.frames) > nframes   # (i frame sono già ripuliti dai finally)
            pop!(w.frames)
        end
        err = to_err(ex)
        handler === nothing && return err
        e2 = newenv(env)
        var === nothing || (e2.vars[var] = err)
        return ev(handler, e2, w)
    end
end

function eval_with(x::Node, env::Env, w::World)
    mods, body = x.args
    budget = nothing; dotrace = false
    for m in mods.args
        if m === :trace
            dotrace = true
        elseif m isa Node && m.head === :call && m.args[1] === :budget
            for kw in m.args[2:end]
                (kw isa Node && kw.head === :assign && kw.args[1] === :steps) ||
                    raise(:syntax, "budget accetta solo steps = N")
                budget = ev(kw.args[2], env, w)
                (budget isa Integer && budget >= 0) || raise(:type, "budget: steps vuole un Int ≥ 0")
            end
            budget === nothing && raise(:syntax, "budget(steps = N): manca steps")
        else
            raise(:syntax, "modificatore di with sconosciuto: $(unparse(m)) (ammessi: budget(steps = N), trace)")
        end
    end
    old_budget, old_owner, old_tracer = w.budget, w.budget_owner, w.tracer
    id = nextid!(w)
    if budget !== nothing && w.steps + budget < w.budget
        w.budget = w.steps + budget
        w.budget_owner = id
    end
    dotrace && (w.tracer = Any[])
    events = w.tracer
    result = try
        ev(body, env, w)
    catch ex
        if ex isa TriadError && ex.err.kind === :budget && ex.err.data isa Rec &&
           get(ex.err.data.fields, :owner, 0) == id
            ex.err             # il budget di QUESTO with: l'errore diventa il valore
        else
            rethrow()
        end
    finally
        w.budget, w.budget_owner, w.tracer = old_budget, old_owner, old_tracer
    end
    dotrace ? Rec(:Traced, (result = result, trace = events), true) : result
end

# ---------------- 10. BUILTIN -----------------------------------------
const BUILTINS = Dict{Symbol,BuiltinFn}()
defb(f::Function, name::AbstractString; effect = nothing) =
    (BUILTINS[Symbol(name)] = BuiltinFn(Symbol(name), f, effect))

function arity(a, n, name)
    length(a) == n || raise(:method, "$name vuole $n argomenti, ne ha ricevuti $(length(a))")
    a
end
num(x, name) = (x isa Number && !(x isa Bool)) ? x : raise(:method, "$name: atteso un numero, ricevuto $(typeof_t(x))")

defb("+") do w, a; length(a) == 1 ? num(a[1], "+") : reduce(+, num.(a, "+")) end
defb("-") do w, a; length(a) == 1 ? -num(a[1], "-") : num(arity(a, 2, "-")[1], "-") - num(a[2], "-") end
defb("*") do w, a
    all(x -> x isa AbstractString, a) && return join(a)       # come Julia: "a" * "b"
    reduce(*, num.(a, "*"))
end
defb("/") do w, a; num(arity(a, 2, "/")[1], "/") / num(a[2], "/") end
defb("^") do w, a; num(arity(a, 2, "^")[1], "^") ^ num(a[2], "^") end
defb("%") do w, a; rem(num(arity(a, 2, "%")[1], "%"), num(a[2], "%")) end
defb("==") do w, a; arity(a, 2, "==")[1] == a[2] end
defb("!=") do w, a; arity(a, 2, "!=")[1] != a[2] end
defb("<") do w, a; arity(a, 2, "<")[1] < a[2] end
defb("<=") do w, a; arity(a, 2, "<=")[1] <= a[2] end
defb(">") do w, a; arity(a, 2, ">")[1] > a[2] end
defb(">=") do w, a; arity(a, 2, ">=")[1] >= a[2] end
defb("!") do w, a; !need_bool(arity(a, 1, "!")[1], "!") end
defb("not") do w, a; !need_bool(arity(a, 1, "not")[1], "not") end
defb(":") do w, a
    arity(a, 2, ":")
    (a[1] isa Integer && a[2] isa Integer) || raise(:type, "a:b vuole due Int")
    Any[a[1]:a[2]...]
end
defb("in") do w, a; arity(a, 2, "in")[1] in iterable(a[2]) end
defb("isa") do w, a
    arity(a, 2, "isa")
    a[2] isa TType || raise(:type, "isa vuole un tipo a destra")
    issub(typeof_t(a[1]), a[2].name)
end
defb("is") do w, a; raise(:syntax, "`is` si usa solo nei goal di rule/solve") end

defb("println"; effect = :io) do w, a
    foreach(x -> print(w.out, tstring(x)), a); println(w.out); nothing
end
defb("print"; effect = :io) do w, a
    foreach(x -> print(w.out, tstring(x)), a); nothing
end
defb("string") do w, a; join(tstring.(a)) end
defb("repr") do w, a; tshow(arity(a, 1, "repr")[1]) end

defb("length") do w, a; length(arity(a, 1, "length")[1]) end
defb("isempty") do w, a; isempty(arity(a, 1, "isempty")[1]) end
defb("first") do w, a
    xs = arity(a, 1, "first")[1]; isempty(xs) && raise(:bounds, "first di una lista vuota"); first(xs)
end
defb("last") do w, a
    xs = arity(a, 1, "last")[1]; isempty(xs) && raise(:bounds, "last di una lista vuota"); last(xs)
end
defb("rest") do w, a; xs = arity(a, 1, "rest")[1]; Any[xs[2:end]...] end
defb("reverse") do w, a; Any[reverse(arity(a, 1, "reverse")[1])...] end
defb("sort") do w, a; Any[sort(arity(a, 1, "sort")[1])...] end
defb("sum") do w, a; xs = arity(a, 1, "sum")[1]; isempty(xs) ? 0 : sum(xs) end
defb("push!") do w, a; push!(arity(a, 2, "push!")[1], a[2]) end
defb("pop!") do w, a
    xs = arity(a, 1, "pop!")[1]; isempty(xs) && raise(:bounds, "pop! di una lista vuota"); pop!(xs)
end
defb("append!") do w, a; append!(arity(a, 2, "append!")[1], a[2]) end
defb("vcat") do w, a; Any[vcat(a...)...] end
defb("collect") do w, a; Any[collect(arity(a, 1, "collect")[1])...] end
defb("map") do w, a; f = arity(a, 2, "map")[1]; Any[apply_value(w, f, Any[x]) for x in iterable(a[2])] end
defb("filter") do w, a
    f = arity(a, 2, "filter")[1]
    Any[x for x in iterable(a[2]) if need_bool(apply_value(w, f, Any[x]), "filter")]
end
defb("reduce") do w, a
    (length(a) == 2 || length(a) == 3) || raise(:method, "reduce(f, xs) o reduce(f, xs, init)")
    f, xs = a[1], iterable(a[2])
    if length(a) == 3
        acc = a[3]; items = xs
    else
        isempty(xs) && raise(:bounds, "reduce su una lista vuota senza valore iniziale")
        acc = xs[1]; items = xs[2:end]
    end
    for x in items
        acc = apply_value(w, f, Any[acc, x])
    end
    acc
end
defb("any") do w, a; f = arity(a, 2, "any")[1]; any(x -> need_bool(apply_value(w, f, Any[x]), "any"), iterable(a[2])) end
defb("all") do w, a; f = arity(a, 2, "all")[1]; all(x -> need_bool(apply_value(w, f, Any[x]), "all"), iterable(a[2])) end
defb("count") do w, a; f = arity(a, 2, "count")[1]; count(x -> need_bool(apply_value(w, f, Any[x]), "count"), iterable(a[2])) end

for (nm, fn) in (("abs", abs), ("sqrt", sqrt), ("floor", floor), ("ceil", ceil), ("round", round),
                 ("exp", exp), ("log", log), ("sin", sin), ("cos", cos))
    defb(nm) do w, a; fn(num(arity(a, 1, nm)[1], nm)) end
end
defb("div") do w, a; div(num(arity(a, 2, "div")[1], "div"), num(a[2], "div")) end
defb("mod") do w, a; mod(num(arity(a, 2, "mod")[1], "mod"), num(a[2], "mod")) end
defb("min") do w, a; length(a) == 1 ? minimum(a[1]) : min(a...) end
defb("max") do w, a; length(a) == 1 ? maximum(a[1]) : max(a...) end

defb("typeof") do w, a; TType(typeof_t(arity(a, 1, "typeof")[1])) end
defb("Int") do w, a; x = arity(a, 1, "Int")[1]; x isa AbstractString ? parse(Int, x) : Int(x) end
defb("Float") do w, a; x = arity(a, 1, "Float")[1]; x isa AbstractString ? parse(Float64, x) : Float64(x) end
defb("String") do w, a; tstring(arity(a, 1, "String")[1]) end
defb("Symbol") do w, a; Symbol(tstring(arity(a, 1, "Symbol")[1])) end

defb("err") do w, a
    (2 <= length(a) <= 3 && a[1] isa Symbol && a[2] isa AbstractString) ||
        raise(:method, "err(:kind, \"messaggio\"[, dati])")
    Err(a[1], String(a[2]), length(a) == 3 ? a[3] : nothing)
end
defb("iserr") do w, a; arity(a, 1, "iserr")[1] isa Err end
defb("throw") do w, a
    e = arity(a, 1, "throw")[1]
    e isa Err || raise(:type, "throw vuole un Err (usa err(:kind, msg))")
    throw(TriadError(e))
end
defb("error") do w, a; raise(:error, join(tstring.(a))) end

defb("gensym") do w, a; Symbol("#", isempty(a) ? "g" : tstring(a[1]), nextid!(w)) end
defb("eval") do w, a; ev(arity(a, 1, "eval")[1], w.globals, w) end
defb("parse") do w, a
    b = parse_program(arity(a, 1, "parse")[1])
    length(b.args) == 1 ? b.args[1] : b
end
defb("unparse") do w, a; unparse(arity(a, 1, "unparse")[1]) end
defb("sexpr") do w, a; sexpr(arity(a, 1, "sexpr")[1]) end
defb("Expr") do w, a
    (length(a) >= 1 && a[1] isa Symbol) || raise(:method, "Expr(:head, args...)")
    Node(a[1], Any[a[2:end]...])
end
defb("vars") do w, a
    s = arity(a, 1, "vars")[1]
    s isa Solution || raise(:type, "vars vuole una Solution")
    Any[s.names...]
end

# ---------------- 11. SINTASSI ----------------------------------------
include("syntax.jl")

# ---------------- 12. ESECUZIONE --------------------------------------
"Rimuove un eventuale shebang (`#!...`) dalla prima riga del sorgente.\nI file .td eseguibili iniziano con `#!/usr/bin/env triad`; il parser\ntratta `#` come commento, ma rimuoverlo esplicitamente rende il\ncomportamento indipendente dal parser e pulisce i numeri di riga."
function strip_shebang(src::AbstractString)
    if startswith(src, "#!")
        nl = findfirst('\n', src)
        nl === nothing && return ""
        return src[nextind(src, nl):end]
    end
    src
end

"Esegue sorgente Triad; restituisce il valore dell'ultima istruzione. Gli errori risalgono come TriadError."
function run_source(w::World, src::AbstractString)
    src = strip_shebang(src)
    code, lines = parse_toplevel(src)
    v = nothing
    for (stmt, line) in zip(code.args, lines)
        w.effects = nothing
        try
            v = ev(stmt, w.globals, w)
        catch ex
            iscontrol(ex) && !(ex isa InterruptException) &&
                (ex = TriadError(Err(:syntax, "$(typeof(ex)) fuori da una funzione/ciclo", nothing)))
            ex isa InterruptException && rethrow()
            err = to_err(ex)
            d = err.data
            located = d isa Rec && haskey(d.fields, :line)
            throw(TriadError(located ? err : Err(err.kind, "riga $line: " * err.msg, err.data)))
        finally
            empty!(w.frames)
        end
    end
    v
end

"Valuta e restituisce sempre un valore: in caso di errore, l'Err."
function eval_source(w::World, src::AbstractString)
    try
        run_source(w, src)
    catch ex
        ex isa InterruptException && rethrow()
        to_err(ex)
    end
end

# ---------------- 13. REPL E RIGA DI COMANDO ---------------------------
const TRIAD_VERSION = v"0.2.0"

"Una sessione: il mondo corrente e i file caricati (per `:reload`)."
mutable struct Session
    w::World
    files::Vector{String}
    args::Vector{String}               # visibili al programma come ARGS
end
Session(args::Vector{String} = String[]) = Session(fresh_world(args), String[], args)

function fresh_world(args::Vector{String})
    w = World()
    w.globals.vars[:ARGS] = Any[args...]
    w
end

"Stampa un errore non gestito in forma leggibile."
function report(ex, where::AbstractString = "")
    e = to_err(ex)
    println(stderr, "errore", isempty(where) ? "" : " in $where", " (:", e.kind, "): ", e.msg)
end

"Estensioni dei sorgenti Triad: `.triad` è canonica, `.td` è l'alias storico."
const SOURCE_EXTENSIONS = (".triad", ".td")

"L'estensione si può omettere: `famiglia` trova `famiglia.triad` o `famiglia.td`."
function find_source(path::AbstractString)
    isfile(path) && return path
    for ext in SOURCE_EXTENSIONS
        isfile(path * ext) && return path * ext
    end
    raise(:io, "file non trovato: $path", info(path = path))
end

"Carica un file nella sessione (come `consult/1`); false se c'è stato un errore."
function load_file!(s::Session, path::AbstractString)
    try
        p = abspath(find_source(path))
        p in s.files || push!(s.files, p)
        run_source(s.w, read(p, String))
        true
    catch ex
        ex isa InterruptException && rethrow()
        report(ex, path)
        false
    end
end

"Ricomincia da un mondo vuoto e ricarica i file (come `make/0`)."
function reload!(s::Session)
    files = copy(s.files)
    s.w = fresh_world(s.args); empty!(s.files)
    n = count(f -> load_file!(s, f), files)
    println("ricaricati $n/$(length(files)) file")
end

"Stampa le clausole della knowledge base; `names` filtra per `nome` o `nome/arità`."
function listing(io::IO, w::World, names)
    shown = false
    for k in sort!(collect(keys(w.kb)))
        isempty(names) || string(k[1]) in names || "$(k[1])/$(k[2])" in names || continue
        shown && println(io)
        println(io, "# ", k[1], "/", k[2])
        for c in w.kb[k]
            isempty(c.body) ? println(io, "fact ", tshow(c.head)) :
                              println(io, "rule ", tshow(c.head), " :- ", join(tshow.(c.body), ", "))
        end
        shown = true
    end
    shown || println(io, isempty(names) ? "knowledge base vuota" : "nessun predicato: $(join(names, " "))")
end

# ---- query interattive (come il top level di Prolog) ----
"Un'istruzione del REPL che è un goal sulla knowledge base, da trattare come query."
function is_query(x, w::World)
    x isa Node || return false
    (x.head === :and || x.head === :or) && return is_query(x.args[1], w) || is_query(x.args[2], w)
    x.head === :call && x.args[1] isa Symbol || return false
    f = x.args[1]
    (f === :! || f === :not) && length(x.args) == 2 && return is_query(x.args[2], w)
    haskey(w.kb, (f, length(x.args) - 1))
end

"Legge un tasto senza attendere l'invio (solo da terminale)."
function readkey()
    raw!(on) = ccall(:jl_tty_set_mode, Int32, (Ptr{Cvoid}, Int32), stdin.handle, on)
    raw!(1)
    try
        read(stdin, Char)
    finally
        raw!(0)
    end
end

function show_answer(io::IO, sol::Solution)
    bound = [(k, v) for (k, v) in zip(sol.names, sol.vals)
             if !startswith(string(k), "_") && v != TVar(k)]
    print(io, isempty(bound) ? "true" : join(["?$k = $(tshow(v))" for (k, v) in bound], ",\n"))
end

show_event(io::IO, e::Rec) =
    println(io, "   ", "  "^e.fields.depth, rpad(string(e.fields.port), 6), tshow(e.fields.goal))

const QUERY_KEYS = """
  ; n spazio    soluzione successiva
  a             tutte le soluzioni rimanenti
  invio . c     basta così"""

"""
Esegue una query alla maniera di Prolog: le soluzioni arrivano una alla volta e, da
terminale, si chiede se cercarne un'altra. `x` è un nodo :solve (con le sue opzioni).
"""
function run_query(s::Session, x::Node)
    w = s.w; env = w.globals
    w.effects = nothing
    goal = build_goal(x.args[1], env, w)
    opts = solve_opts(x, env, w)
    tr = opts[:trace] ? Any[] : nothing
    ask = stdin isa Base.TTY
    seen = 0; found = 0; stopped = false
    function flush_trace()
        tr === nothing && return
        foreach(e -> show_event(stdout, e), @view tr[seen+1:end])
        seen = length(tr)
    end
    function each(sol, more)
        flush_trace()
        found += 1
        show_answer(stdout, sol)
        (more && found < opts[:limit]) || (println("."); stopped = true; return false)
        ask || (println(" ;"); return true)
        print(" ")
        while true
            k = readkey()
            if k in (';', 'n', 'r', ' ', '\t')
                println(";"); return true
            elseif k in ('\r', '\n', '.', 'c', '\x03', '\x04', '\e')
                println("."); stopped = true; return false
            elseif k == 'a'
                println(";"); ask = false; return true
            else
                println("\n", QUERY_KEYS); show_answer(stdout, sol); print(" ")
            end
        end
    end
    try
        solve_goal(w, goal; limit = opts[:limit], maxdepth = opts[:depth],
                   steps = opts[:steps], trace = tr, each = each)
    finally
        empty!(w.frames)
    end
    flush_trace()
    stopped || println("false.")
    nothing
end

# ---- il ciclo del REPL ----
const REPL_HELP = """
Si scrive codice Triad; i blocchi restano aperti finché non sono chiusi da `end`.

query (come in Prolog):
  ?- grandparent(:alice, ?x)       risolve il goal e mostra le soluzioni una alla volta
  grandparent(:alice, ?x)          lo stesso, se il predicato è nella knowledge base
  ?- p(?x) limit 3 trace           accetta le opzioni di `solve`
$QUERY_KEYS

comandi:
  :load FILE...   :l      carica uno o più file (.td si può omettere)
  :reload         :r      riparte da zero e ricarica i file caricati (anche `make`)
  :listing [P]    :ls     mostra la knowledge base, o solo P (`parent` o `parent/2`)
  :tree CODICE            mostra l'albero uniforme (S-expression) del codice
  :reset                  dimentica tutto: definizioni, fatti, file
  :help           :h      questo aiuto
  :quit           :q      esce (anche `halt` o Ctrl-D)"""

const COMMANDS = Set(split(":l :load :consult :r :reload make :ls :listing :tree :reset " *
                           ":h :help :? :q :quit :exit halt"))

function command_name(line::AbstractString)
    t = split(strip(line); limit = 2)
    isempty(t) && return nothing
    c = rstrip(t[1], '.')          # `halt.` e `make.` come in Prolog
    c in COMMANDS ? c : nothing
end

"Esegue un comando del REPL; false vuol dire uscire."
function command!(s::Session, cmd::AbstractString, line::AbstractString)
    rest = something(match(r"^\S+\s*(.*)$"s, strip(line)))[1]
    words = split(rest)
    if cmd in (":q", ":quit", ":exit", "halt")
        return false
    elseif cmd in (":h", ":help", ":?")
        println(REPL_HELP)
    elseif cmd in (":l", ":load", ":consult")
        isempty(words) && (println("uso: :load FILE..."); return true)
        for f in words
            load_file!(s, f) && println("caricato ", f)
        end
    elseif cmd in (":r", ":reload", "make")
        reload!(s)
    elseif cmd in (":ls", ":listing")
        listing(stdout, s.w, String.(words))
    elseif cmd == ":tree"
        foreach(x -> println(sexpr(x)), parse_program(rest).args)
    elseif cmd == ":reset"
        s.w = fresh_world(s.args); empty!(s.files)
        println("mondo vuoto")
    end
    true
end

"`?- goal` diventa `solve goal`; il `.` finale alla Prolog si può scrivere o no."
function query_source(buf::AbstractString)
    b = lstrip(buf)
    startswith(b, "?-") || return buf, false
    q = rstrip(b[3:end])
    endswith(q, ".") && (q = q[1:prevind(q, lastindex(q))])
    "solve " * q, true
end

function incomplete(src::AbstractString)
    try
        parse_toplevel(src)
        false
    catch ex
        ex isa TriadError && ex.err.data isa Rec && get(ex.err.data.fields, :incomplete, false) === true
    end
end

function eval_input(s::Session, src::AbstractString, isquery::Bool)
    code, _ = parse_toplevel(src)
    stmts = code.args
    if isquery
        length(stmts) == 1 || raise(:syntax, "?- vuole un solo goal")
        return run_query(s, stmts[1])
    end
    if length(stmts) == 1 && is_query(stmts[1], s.w)
        return run_query(s, Node(:solve, Any[stmts[1], Node(:tuple, Any[])]))
    end
    v = run_source(s.w, src)
    v === nothing || println(tshow(v))
end

function repl(s::Session = Session(); banner::Bool = true)
    banner && println("Triad $TRIAD_VERSION — Julia ∪ Prolog ∪ Lisp.  " *
                      ":help per l'aiuto, :q o Ctrl-D per uscire.")
    buf = ""
    while true
        try
            print(isempty(buf) ? "triad> " : "     | ")
            eof(stdin) && break
            line = readline(stdin)
            cmd = isempty(buf) ? command_name(line) : nothing
            if cmd !== nothing
                command!(s, cmd, line) || return
                continue
            end
            buf *= line * "\n"
            isempty(strip(buf)) && (buf = ""; continue)
            src, isquery = query_source(buf)
            incomplete(src) && continue          # blocco aperto: leggi un'altra riga
            buf = ""
            eval_input(s, src, isquery)
        catch ex
            buf = ""
            ex isa InterruptException ? println("\ninterrotto") : report(ex)
        end
    end
    println()
end
repl(w::World; kw...) = repl(Session(w, String[], String[]); kw...)

const USAGE = """
uso: triad [opzioni] [file.td [argomenti...]]

  triad                       REPL
  triad file.td a b           esegue file.td ed esce; il programma vede ARGS == ["a", "b"]
  triad -l file.td            carica file.td e apre il REPL (come `swipl file.pl`)
  triad -i file.td            esegue file.td e poi apre il REPL
  triad -E 'solve p(?x)'      valuta e stampa il risultato

opzioni:
  -l, --load FILE      carica FILE (ripetibile); senza script né -e si apre poi il REPL
  -e, --eval CODICE    esegue CODICE (ripetibile)
  -E, --print CODICE   esegue CODICE e ne stampa il valore
  -i, --interactive    apre il REPL alla fine anche dopo uno script o -e
  -q, --quiet          niente banner all'avvio del REPL
      --tree FILE      stampa l'albero uniforme (S-expression) di FILE
  -v, --version        stampa la versione
  -h, --help           questo aiuto

L'estensione .td si può omettere; `-` come script legge il programma da stdin.
Le opzioni si eseguono nell'ordine dato, poi lo script. Codice di uscita: 0, 1 se un
errore non è gestito, 2 se la riga di comando non è valida.
"""

function run_action(s::Session, kind::Symbol, arg::String)
    kind === :load && arg != "-" && return load_file!(s, arg)
    try
        if kind === :load
            run_source(s.w, read(stdin, String))
        elseif kind === :eval
            run_source(s.w, arg)
        elseif kind === :print
            println(tshow(run_source(s.w, arg)))
        elseif kind === :tree
            foreach(x -> println(sexpr(x)), parse_program(read(find_source(arg), String)).args)
        end
        true
    catch ex
        ex isa InterruptException && rethrow()
        report(ex, kind === :load ? "stdin" : kind === :tree ? arg : "")
        false
    end
end

function main(args = ARGS)
    actions = Tuple{Symbol,String}[]
    script = nothing; sargs = String[]
    interactive = false; quiet = false
    withargs = Dict("-l" => :load, "--load" => :load, "-e" => :eval, "--eval" => :eval,
                    "-E" => :print, "--print" => :print, "--tree" => :tree)
    i = 1
    while i <= length(args)
        a = args[i]
        if a in ("-h", "--help")
            print(USAGE); return 0
        elseif a in ("-v", "--version")
            println("triad ", TRIAD_VERSION); return 0
        elseif a in ("-i", "--interactive")
            interactive = true
        elseif a in ("-q", "--quiet")
            quiet = true
        elseif haskey(withargs, a)
            i == length(args) && (println(stderr, "triad: $a vuole un argomento"); return 2)
            push!(actions, (withargs[a], args[i += 1]))
        elseif a == "--"
            i < length(args) && (script = args[i+1]; sargs = args[i+2:end])
            break
        elseif startswith(a, "-") && a != "-"
            println(stderr, "triad: opzione sconosciuta $a (vedi triad --help)"); return 2
        else
            script = a; sargs = args[i+1:end]
            break
        end
        i += 1
    end
    torepl = interactive || (script === nothing && all(a -> a[1] === :load, actions))
    s = Session(String.(sargs))
    script === nothing || push!(actions, (:load, script))
    for (kind, arg) in actions
        run_action(s, kind, arg) || torepl || return 1
    end
    if torepl
        Base.exit_on_sigint(false)       # Ctrl-C interrompe il calcolo, non il REPL
        repl(s; banner = !quiet)
    end
    0
end

end # module Triad

if abspath(PROGRAM_FILE) == @__FILE__
    exit(Triad.main(ARGS))
end
