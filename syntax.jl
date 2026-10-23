# =====================================================================
#  syntax.jl — lessico e parser della sintassi Triad (Julia-like).
#  Produce l'albero uniforme `Node(head, args)` eseguito da triad.jl.
#  Incluso dentro `module Triad`: usa Node, TVar, raise, info.
# =====================================================================

# ---------------- LESSICO --------------------------------------------
struct Tok
    kind::Symbol      # :ident :num :str :sym :tvar :op :kw :nl :macro :eof
    val::Any
    line::Int
    col::Int
    spc::Bool         # spazio (o inizio riga) prima del token
end

const KEYWORDS = Set{String}([
    "function", "struct", "end", "if", "elseif", "else", "for", "while",
    "let", "begin", "return", "break", "continue", "fact", "rule", "solve",
    "macro", "quote", "try", "catch", "with", "requires", "ensures",
    "true", "false", "nothing", "in", "isa", "is"])

const OPS2 = Set{String}(["->", "==", "!=", "<=", ">=", "&&", "||", "+=", "-=", "*="])
const OPS1 = "+-*/%^<>=!.,()[]{}|\$?"

syntax_error(msg, line, col; incomplete::Bool = false) =
    raise(:syntax, "riga $line, colonna $col: $msg",
          info(line = line, col = col, incomplete = incomplete))

isidstart(c::Char) = isletter(c) || c == '_'

function value_end(t::Tok)
    t.kind in (:ident, :num, :str, :sym, :tvar) && return true
    t.kind === :op && t.val in (")", "]", "}") && return true
    t.kind === :kw && t.val in ("end", "true", "false", "nothing") && return true
    false
end

function interpolation_end(cs::Vector{Char}, open::Int, n::Int)
    contexts = Symbol[:code]
    depths = Int[1]
    i = open + 1
    while i <= n
        c = cs[i]
        if contexts[end] === :string
            if c == '\\'
                i += 2
            elseif c == '"'
                pop!(contexts)
                i += 1
            elseif c == '$' && i < n && cs[i+1] == '('
                push!(contexts, :code)
                push!(depths, 1)
                i += 2
            else
                i += 1
            end
        elseif c == '"'
            push!(contexts, :string)
            i += 1
        elseif c == '#'
            if i < n && cs[i+1] == '='
                comment_depth = 1
                i += 2
                while i <= n && comment_depth > 0
                    if i < n && cs[i] == '#' && cs[i+1] == '='
                        comment_depth += 1
                        i += 2
                    elseif i < n && cs[i] == '=' && cs[i+1] == '#'
                        comment_depth -= 1
                        i += 2
                    else
                        i += 1
                    end
                end
            else
                while i <= n && cs[i] != '\n'
                    i += 1
                end
            end
        elseif c == '('
            depths[end] += 1
            i += 1
        elseif c == ')'
            depths[end] -= 1
            if depths[end] == 0
                pop!(depths)
                pop!(contexts)
                isempty(contexts) && return i
            else
                i += 1
            end
        else
            i += 1
        end
    end
    nothing
end

function lex(src::AbstractString)
    cs = collect(src)
    n = length(cs)
    toks = Tok[]
    i = 1; line = 1; linestart = 1
    spc = true

    # legge un identificatore da j; '!' e' ammesso solo come suffisso finale, non prima di '='
    function read_ident(j)
        k = j
        while k <= n && (isletter(cs[k]) || isdigit(cs[k]) || cs[k] == '_')
            k += 1
        end
        if k <= n && cs[k] == '!' &&
           !(k < n && (isletter(cs[k+1]) || isdigit(cs[k+1]) ||
                       cs[k+1] == '_' || cs[k+1] == '='))
            k += 1
        end
        return String(cs[j:k-1]), k
    end

    while i <= n
        c = cs[i]
        tl = line; tc = i - linestart + 1
        tok(kind, val) = push!(toks, Tok(kind, val, tl, tc, spc))

        if c == '\n'
            (isempty(toks) || toks[end].kind !== :nl) && tok(:nl, "\n")
            i += 1; line += 1; linestart = i; spc = true
            continue
        elseif c == ' ' || c == '\t' || c == '\r'
            i += 1; spc = true
            continue
        elseif c == '#'
            if i < n && cs[i+1] == '='
                depth = 1
                j = i + 2
                while j < n && depth > 0
                    if cs[j] == '#' && cs[j+1] == '='
                        depth += 1; j += 2
                    elseif cs[j] == '=' && cs[j+1] == '#'
                        depth -= 1; j += 2
                    else
                        if cs[j] == '\n'
                            (isempty(toks) || toks[end].kind !== :nl) &&
                                push!(toks, Tok(:nl, "\n", line, j - linestart + 1, true))
                            line += 1
                            linestart = j + 1
                        end
                        j += 1
                    end
                end
                depth == 0 || syntax_error("commento #= non chiuso", tl, tc; incomplete = true)
                i = j
            else
                while i <= n && cs[i] != '\n'
                    i += 1
                end
            end
            spc = true
            continue
        elseif c == ';'
            tok(:nl, ";")
            i += 1; spc = true
            continue
        elseif isdigit(c)
            j = i
            while j <= n && (isdigit(cs[j]) || cs[j] == '_')
                j += 1
            end
            isfloat = false
            if j < n && cs[j] == '.' && isdigit(cs[j+1])
                isfloat = true
                j += 1
                while j <= n && isdigit(cs[j])
                    j += 1
                end
            end
            if j < n && (cs[j] == 'e' || cs[j] == 'E') &&
               (isdigit(cs[j+1]) || (j + 1 < n && cs[j+1] in "+-" && isdigit(cs[j+2])))
                isfloat = true
                j += 2
                while j <= n && isdigit(cs[j])
                    j += 1
                end
            end
            s = replace(String(cs[i:j-1]), "_" => "")
            tok(:num, isfloat ? parse(Float64, s) : parse(Int, s))
            i = j
        elseif isidstart(c)
            s, j = read_ident(i)
            tok(s in KEYWORDS ? :kw : :ident, s)
            i = j
        elseif c == '"'
            parts = Any[]
            buf = IOBuffer()
            j = i + 1
            while true
                j > n && syntax_error("stringa non chiusa", tl, tc; incomplete = true)
                d = cs[j]
                if d == '"'
                    break
                elseif d == '\\'
                    j == n && syntax_error("stringa non chiusa", tl, tc; incomplete = true)
                    e = cs[j+1]
                    e in ('n', 't', '"', '\\', '$') ||
                        syntax_error("escape sconosciuto '\\$e' (validi: \\n \\t \\\" \\\\ \x24)",
                                     line, j - linestart + 1)
                    write(buf, e == 'n' ? '\n' : e == 't' ? '\t' : e)
                    j += 2
                elseif d == '$' && j < n && (cs[j+1] == '(' || isidstart(cs[j+1]))
                    buf.size > 0 && push!(parts, String(take!(buf)))
                    if cs[j+1] == '('
                        expr_line = line
                        expr_col = j + 2 - linestart + 1
                        k = interpolation_end(cs, j + 1, n)
                        k === nothing && syntax_error("\$( non chiusa nella stringa", tl, tc; incomplete = true)
                        for q in j+2:k-1
                            if cs[q] == '\n'
                                line += 1
                                linestart = q + 1
                            end
                        end
                        push!(parts, (:expr, String(cs[j+2:k-1]), expr_line, expr_col))
                        j = k + 1
                    else
                        s, k = read_ident(j + 1)
                        push!(parts, Symbol(s))
                        j = k
                    end
                else
                    d == '\n' && (line += 1; linestart = j + 1)
                    write(buf, d)
                    j += 1
                end
            end
            buf.size > 0 && push!(parts, String(take!(buf)))
            val = isempty(parts) ? "" :
                  (length(parts) == 1 && parts[1] isa String) ? parts[1] : parts
            tok(:str, val)
            i = j + 1
        elseif c == '?' && !(i < n && isidstart(cs[i+1]))
            tok(:op, "?")                  # ternario: c ? a : b
            i += 1
        elseif c == '?'                    # variabile logica: ?x (attaccato)
            k = i + 1
            while k <= n && (isletter(cs[k]) || isdigit(cs[k]) || cs[k] == '_')
                k += 1
            end
            tok(:tvar, String(cs[i+1:k-1]))
            i = k
        elseif c == '@'
            (i < n && isidstart(cs[i+1])) || syntax_error("'@' deve precedere il nome di una macro", tl, tc)
            s, k = read_ident(i + 1)
            tok(:macro, s)
            i = k
        elseif c == ':'
            # `1:n` (range) se attaccato a un valore; altrimenti `:sym` o `:( ... )`
            prevval = !isempty(toks) && value_end(toks[end]) && !spc
            if i < n && cs[i+1] == ':'
                tok(:op, "::"); i += 2
            elseif i < n && cs[i+1] == '-'
                tok(:op, ":-"); i += 2
            elseif !prevval && i < n && cs[i+1] == '('
                tok(:op, ":("); i += 2
            elseif !prevval && i < n && isidstart(cs[i+1])
                s, k = read_ident(i + 1)
                tok(:sym, s)
                i = k
            elseif !prevval && i < n && cs[i+1] in "+*/^%<>=!"   # :+  :==  :<= ...
                two = i + 2 <= n ? String(cs[i+1:i+2]) : ""
                s = two in ("==", "!=", "<=", ">=") ? two : string(cs[i+1])
                tok(:sym, s)
                i += 1 + length(s)
            else
                tok(:op, ":"); i += 1
            end
        else
            c == '\'' && syntax_error("Triad non ha i caratteri: usa una stringa, es. \"c\"", tl, tc)
            two = i < n ? String(cs[i:i+1]) : ""
            if two in OPS2
                tok(:op, two); i += 2
            elseif c in OPS1
                tok(:op, string(c)); i += 1
            else
                syntax_error("carattere inatteso '$c'", tl, tc)
            end
        end
        spc = false
    end
    push!(toks, Tok(:eof, nothing, line, i - linestart + 1, true))
    return toks
end

# ---------------- PARSER ---------------------------------------------
mutable struct Parser
    toks::Vector{Tok}
    i::Int
    depth::Int     # >0 dentro ( [ : gli a capo non contano
    inindex::Int   # >0 dentro xs[...]: `end` = ultimo indice
end
Parser(toks) = Parser(toks, 1, 0, 0)

function pk(p::Parser)
    if p.depth > 0
        while p.toks[p.i].kind === :nl
            p.i += 1
        end
    end
    p.toks[p.i]
end
raw(p::Parser) = p.toks[p.i]
function next!(p::Parser)
    t = pk(p)
    t.kind === :eof || (p.i += 1)
    t
end
skipnl!(p::Parser) = while p.toks[p.i].kind === :nl
    p.i += 1
end

isop(t::Tok, v) = t.kind === :op && t.val == v
iskw(t::Tok, v) = t.kind === :kw && t.val == v
desc(t::Tok) = t.kind === :eof ? "fine del testo" : t.kind === :nl ? "fine riga" :
               t.kind === :str ? "una stringa" : t.kind === :tvar ? "'?$(t.val)'" :
               t.kind === :sym ? "':$(t.val)'" : t.kind === :macro ? "'@$(t.val)'" : "'$(t.val)'"
perr(p::Parser, t::Tok, msg) =
    syntax_error("$msg (trovato $(desc(t)))", t.line, t.col; incomplete = t.kind === :eof)

function expect_op!(p::Parser, v)
    t = next!(p)
    isop(t, v) || perr(p, t, "atteso '$v'")
    t
end
function expect_kw!(p::Parser, v)
    t = next!(p)
    iskw(t, v) || perr(p, t, "atteso '$v'")
    t
end
function expect_ident!(p::Parser, what)
    t = next!(p)
    t.kind === :ident || perr(p, t, "atteso $what")
    Symbol(t.val)
end

"Analizza un programma: restituisce `(Node(:block, stmts), righe)`."
function parse_toplevel(src::AbstractString)
    p = Parser(lex(src))
    stmts = Any[]
    lines = Int[]
    while true
        skipnl!(p)
        t = pk(p)
        t.kind === :eof && break
        push!(lines, t.line)
        push!(stmts, parse_stmt(p))
        t = pk(p)
        t.kind in (:nl, :eof) || perr(p, t, "attesa fine istruzione (a capo o ';')")
    end
    return Node(:block, stmts), lines
end
parse_program(src::AbstractString) = parse_toplevel(src)[1]

function parse_block(p::Parser, terms::Tuple)
    saved = (p.depth, p.inindex)
    p.depth = 0; p.inindex = 0
    stmts = Any[]
    while true
        skipnl!(p)
        t = pk(p)
        t.kind === :kw && t.val in terms && break
        t.kind === :eof && perr(p, t, "blocco non chiuso: manca '$(terms[end])'")
        push!(stmts, parse_stmt(p))
        t = pk(p)
        (t.kind === :nl || (t.kind === :kw && t.val in terms)) ||
            perr(p, t, "attesa fine istruzione (a capo o ';')")
    end
    p.depth, p.inindex = saved
    Node(:block, stmts)
end

function parse_stmt(p::Parser)
    t = pk(p)
    if t.kind === :kw
        v = t.val
        if v == "function"
            next!(p)
            return parse_function(p)
        elseif v == "struct"
            next!(p); return parse_struct(p)
        elseif v == "macro"
            next!(p); return parse_macro(p)
        elseif v == "fact"
            next!(p); return Node(:fact, Any[parse_expr(p)])
        elseif v == "rule"
            next!(p); return parse_rule(p)
        elseif v == "requires" || v == "ensures"
            next!(p); return Node(Symbol(v), Any[parse_expr(p)])
        elseif v == "return"
            next!(p)
            u = raw(p)
            (u.kind in (:nl, :eof) || iskw(u, "end")) && return Node(:return, Any[nothing])
            return Node(:return, Any[parse_expr(p)])
        elseif v == "break" || v == "continue"
            next!(p); return Node(Symbol(v), Any[])
        end
    end
    e = parse_expr(p)
    # forma breve: f(x) = espressione
    if e isa Node && e.head === :assign && e.args[1] isa Node &&
       e.args[1].head === :call && e.args[1].args[1] isa Symbol
        call = e.args[1]
        return Node(:function, Any[call.args[1], Node(:tuple, call.args[2:end]), :Any,
                                   Node(:tuple, Any[]), Node(:block, Any[e.args[2]])])
    end
    # destrutturazione: (a, b) = expr  (parentesi richieste, almeno 2 simboli)
    if e isa Node && e.head === :assign && e.args[1] isa Node &&
       e.args[1].head === :tuple && length(e.args[1].args) >= 2 &&
       all(x -> x isa Symbol, e.args[1].args)
        return Node(:destructure, Any[e.args[1], e.args[2]])
    end
    e
end

const OVERLOADABLE = Set{String}(["+", "-", "*", "/", "%", "^", "==", "<", "<=", ">", ">="])

function parse_params(p::Parser)   # '(' già consumata
    p.depth += 1
    params = Any[]
    if isop(pk(p), ")")
        next!(p)
    else
        while true
            if isop(raw(p), "(")          # parametro-tuple: (a, b)
                next!(p)
                ids = Symbol[]
                while true
                    push!(ids, expect_ident!(p, "nome di variabile nel parametro"))
                    t = next!(p)
                    isop(t, ",") && continue
                    isop(t, ")") && break
                    perr(p, t, "atteso ',' o ')' nel parametro-tuple")
                end
                push!(params, Node(:tuple, ids))
            else
                name = expect_ident!(p, "nome di parametro")
                if isop(pk(p), "::")
                    next!(p)
                    push!(params, Node(:typed, Any[name, expect_ident!(p, "nome di tipo")]))
                else
                    push!(params, name)
                end
            end
            t = next!(p)
            isop(t, ",") && continue
            isop(t, ")") && break
            perr(p, t, "atteso ',' o ')' nei parametri")
        end
    end
    p.depth -= 1
    params
end

function parse_function(p::Parser)  # 'function' già consumata
    t = next!(p)
    if t.kind === :ident
        name = Symbol(t.val)
    elseif t.kind === :op && t.val in OVERLOADABLE
        name = Symbol(t.val)
    elseif isop(t, "(")      # function (x, y) ... end  (anonima)
        params = parse_params(p)
        body = parse_block(p, ("end",)); expect_kw!(p, "end")
        return Node(:lambda, Any[Node(:tuple, params), body])
    else
        perr(p, t, "atteso il nome della funzione")
    end
    expect_op!(p, "(")
    params = parse_params(p)
    rettype = :Any
    if isop(pk(p), "::")
        next!(p)
        rettype = expect_ident!(p, "tipo di ritorno")
    end
    effects = Any[]
    if isop(raw(p), "!")
        next!(p)
        push!(effects, expect_ident!(p, "nome di effetto (io, state)"))
        while isop(raw(p), ",")
            next!(p)
            push!(effects, expect_ident!(p, "nome di effetto"))
        end
    end
    body = parse_block(p, ("end",))
    expect_kw!(p, "end")
    Node(:function, Any[name, Node(:tuple, params), rettype, Node(:tuple, effects), body])
end

function parse_struct(p::Parser)
    name = expect_ident!(p, "nome della struct")
    fields = Any[]
    while true
        skipnl!(p)
        t = pk(p)
        iskw(t, "end") && (next!(p); break)
        f = expect_ident!(p, "nome di campo")
        if isop(pk(p), "::")
            next!(p)
            push!(fields, Node(:typed, Any[f, expect_ident!(p, "nome di tipo")]))
        else
            push!(fields, f)
        end
        u = pk(p)
        (u.kind === :nl || iskw(u, "end")) || perr(p, u, "atteso a capo dopo il campo")
    end
    Node(:struct, Any[name, Node(:tuple, fields)])
end

function parse_macro(p::Parser)
    name = expect_ident!(p, "nome della macro")
    expect_op!(p, "(")
    params = parse_params(p)
    all(x -> x isa Symbol, params) || perr(p, raw(p), "i parametri di macro non hanno tipo")
    body = parse_block(p, ("end",))
    expect_kw!(p, "end")
    Node(:macro, Any[name, Node(:tuple, params), body])
end

function parse_rule(p::Parser)
    head = parse_expr(p)
    goals = Any[]
    if isop(pk(p), ":-")
        next!(p)
        push!(goals, parse_expr(p))
        while true
            # [QODER] prima: `while isop(raw(p), ",")` — una virgola in testa alla riga di
            # continuazione arrivava dopo un :nl e il corpo del rule si fermava al primo goal.
            j = p.i                                   # la virgola puo' stare a inizio riga
            while p.toks[j].kind === :nl
                j += 1
            end
            isop(p.toks[j], ",") || break
            while p.i < j
                next!(p)
            end
            next!(p)
            skipnl!(p)
            push!(goals, parse_expr(p))
        end
    end
    Node(:rule, Any[head; goals])
end

# ---- espressioni (Pratt) ----
const BINOPS = Dict{String,Tuple{Int,Bool}}(   # (precedenza, associativa a destra)
    "=" => (1, true), "+=" => (1, true), "-=" => (1, true), "*=" => (1, true),
    "->" => (2, true), "?" => (2, true),
    "||" => (3, false), "&&" => (4, false),
    "==" => (5, false), "!=" => (5, false), "<" => (5, false), "<=" => (5, false),
    ">" => (5, false), ">=" => (5, false), "in" => (5, false), "isa" => (5, false),
    "is" => (5, false),
    ":" => (6, false),
    "+" => (7, false), "-" => (7, false),
    "*" => (8, false), "/" => (8, false), "%" => (8, false),
    "^" => (10, true),
    "::" => (11, false))
const UNARY_PREC = 9
const POSTFIX_PREC = 12

function binop_info(t::Tok)
    (t.kind === :op || (t.kind === :kw && t.val in ("in", "isa", "is"))) || return nothing
    t.val == ":" && t.spc && return nothing      # `a : b` con spazi è il ':' del ternario
    get(BINOPS, t.val, nothing)
end

function parse_expr(p::Parser, minprec::Int = 0)
    lhs = parse_unary(p)
    while true
        t = pk(p)
        bi = binop_info(t)
        bi === nothing && break
        if t.val == ":" && p.toks[p.i+1].kind ∉ (:eof, :nl) && p.toks[p.i+1].spc
            break
        end
        prec, right = bi
        prec < minprec && break
        next!(p)
        op = t.val
        if op == "->"
            params = lhs isa Symbol ? Any[lhs] :
                     (lhs isa Node && lhs.head === :tuple && all(x -> x isa Symbol, lhs.args)) ? lhs.args :
                     perr(p, t, "parametri di lambda non validi")
            lhs = Node(:lambda, Any[Node(:tuple, params), parse_expr(p, prec)])
        elseif op == "?"
            yes = parse_expr(p, prec + 1)
            expect_op!(p, ":")
            lhs = Node(:if, Any[lhs, yes, parse_expr(p, prec)])
        elseif op == "="
            lhs = Node(:assign, Any[lhs, parse_expr(p, prec)])
        elseif op in ("+=", "-=", "*=")
            # [QODER] prima: Node(:assign, Any[lhs, Node(:call, ...lhs...)]) duplicava il sotto-albero
            # lhs, quindi `xs[f()] += 1` valutava indice e collection due volte. Ora un nodo :opassign.
            rhs = parse_expr(p, prec)
            lhs = Node(:opassign, Any[Symbol(op[1:1]), lhs, rhs])
        elseif op == "::"
            ty = parse_expr(p, prec + 1)
            ty isa Symbol || perr(p, t, "atteso un nome di tipo dopo '::'")
            lhs = Node(:typed, Any[lhs, ty])
        else
            rhs = parse_expr(p, right ? prec : prec + 1)
            lhs = op == "&&" ? Node(:and, Any[lhs, rhs]) :
                  op == "||" ? Node(:or, Any[lhs, rhs]) :
                  Node(:call, Any[Symbol(op), lhs, rhs])
        end
    end
    lhs
end

# un operatore seguito da ',' o ')' è un valore: reduce(+, xs)
function op_as_value(p::Parser)
    t = raw(p)
    t.kind === :op && (t.val in OVERLOADABLE || t.val in ("!", "!=")) || return false
    nt = p.toks[p.i + 1]
    isop(nt, ",") || isop(nt, ")")
end

function parse_unary(p::Parser)
    skipnl!(p)
    t = pk(p)
    if t.kind === :op
        if op_as_value(p)
            next!(p)
            return Symbol(t.val)
        elseif t.val in ("-", "!", "+")
            next!(p)
            operand = parse_expr(p, UNARY_PREC)
            t.val == "+" && return operand
            t.val == "-" && operand isa Number && return -operand
            return Node(:call, Any[Symbol(t.val), operand])
        elseif t.val == "\$"
            next!(p)
            return Node(:unquote, Any[parse_primary(p)])
        end
    end
    parse_postfix(p, parse_primary(p))
end

function parse_args(p::Parser, close::String)   # apertura già consumata
    p.depth += 1
    items = Any[]
    if isop(pk(p), close)
        next!(p)
    else
        while true
            push!(items, parse_expr(p))
            t = next!(p)
            if isop(t, ",")
                isop(pk(p), close) && (next!(p); break)
                continue
            end
            isop(t, close) && break
            perr(p, t, "atteso ',' o '$close'")
        end
    end
    p.depth -= 1
    items
end

function parse_postfix(p::Parser, e)
    while true
        t = raw(p)
        if isop(t, "(") && !t.spc
            next!(p)
            e = Node(:call, Any[e; parse_args(p, ")")])
        elseif isop(t, "[") && !t.spc
            next!(p)
            p.inindex += 1
            idx = parse_args(p, "]")
            p.inindex -= 1
            e = Node(:index, Any[e; idx])
        elseif isop(t, ".")
            next!(p)
            e = Node(:dot, Any[e, expect_ident!(p, "nome di campo dopo '.'")])
        else
            break
        end
    end
    e
end

const ANON_COUNTER = Ref(0)
tvar_of(name::String) = name == "_" ? TVar(Symbol("_", ANON_COUNTER[] += 1)) : TVar(Symbol(name))

function string_node(t::Tok)
    t.val isa String && return t.val
    parts = Any[]
    for x in t.val
        if x isa Tuple
            sub = Parser(lex(x[2]))
            sub.toks = Tok[Tok(tok.kind, tok.val, x[3] + tok.line - 1,
                                tok.line == 1 ? x[4] + tok.col - 1 : tok.col, tok.spc)
                           for tok in sub.toks]
            e = parse_expr(sub)
            pk(sub).kind === :eof || perr(sub, pk(sub), "espressione non valida in \$( )")
            push!(parts, e)
        else
            push!(parts, x)
        end
    end
    Node(:string, parts)
end

function parse_primary(p::Parser)
    t = next!(p)
    k = t.kind
    k === :num && return t.val
    k === :str && return string_node(t)
    k === :sym && return Node(:sym, Any[Symbol(t.val)])
    k === :tvar && return tvar_of(t.val)
    k === :ident && return Symbol(t.val)
    if k === :macro
        u = raw(p)
        (isop(u, "(") && !u.spc) || perr(p, u, "atteso '(' subito dopo @$(t.val)")
        next!(p)
        return Node(:macrocall, Any[Symbol(t.val); parse_args(p, ")")])
    end
    if k === :kw
        v = t.val
        v == "true" && return true
        v == "false" && return false
        v == "nothing" && return nothing
        v == "end" && p.inindex > 0 && return Symbol("end")
        if v in ("if", "while", "for", "let", "begin", "try", "quote", "with", "solve", "function")
            saved = (p.depth, p.inindex)
            p.depth = 0; p.inindex = 0
            r = v == "if"       ? parse_if(p) :
                v == "while"    ? parse_while(p) :
                v == "for"      ? parse_for(p) :
                v == "let"      ? parse_let(p) :
                v == "begin"    ? parse_begin(p) :
                v == "try"      ? parse_try(p) :
                v == "quote"    ? Node(:quasi, Any[parse_begin(p)]) :
                v == "with"     ? parse_with(p) :
                v == "solve"    ? parse_solve(p) :
                                  parse_function(p)
            p.depth, p.inindex = saved
            return r
        end
        perr(p, t, "parola chiave fuori posto")
    end
    if k === :op
        if t.val == "("
            p.depth += 1
            if isop(pk(p), ")")
                next!(p); p.depth -= 1
                return Node(:tuple, Any[])
            end
            e = parse_expr(p)
            if isop(pk(p), ",")
                items = Any[e]
                while isop(pk(p), ",")
                    next!(p)
                    isop(pk(p), ")") && break
                    push!(items, parse_expr(p))
                end
                e = Node(:tuple, items)
            end
            expect_op!(p, ")")
            p.depth -= 1
            return e
        elseif t.val == "["
            return parse_list(p)
        elseif t.val == ":("
            p.depth += 1
            e = parse_expr(p)
            expect_op!(p, ")")
            p.depth -= 1
            return Node(:quasi, Any[e])
        elseif t.val == "{"
            perr(p, t, "Triad non ha letterali fra graffe: le struct si costruiscono con Nome(...) e le sequenze con [ ... ]")
        end
    end
    perr(p, t, "attesa un'espressione")
end

function parse_list(p::Parser)   # '[' già consumata
    p.depth += 1
    items = Any[]
    result = nothing
    if isop(pk(p), "]")
        next!(p)
        result = Node(:list, items)
    else
        first = parse_expr(p)
        if iskw(pk(p), "for")          # [e for x in xs if c]
            next!(p)
            var = expect_ident!(p, "variabile del for")
            u = next!(p)
            (iskw(u, "in") || isop(u, "=")) || perr(p, u, "atteso 'in'")
            iter = parse_expr(p)
            cond = nothing
            if iskw(pk(p), "if")
                next!(p)
                cond = parse_expr(p)
            end
            expect_op!(p, "]")
            result = Node(:comprehension, Any[first, var, iter, cond])
        else
            push!(items, first)
            while true
                t = next!(p)
                if isop(t, ",")
                    isop(pk(p), "]") && (next!(p); result = Node(:list, items); break)
                    push!(items, parse_expr(p))
                elseif isop(t, "|")
                    tail = parse_expr(p)
                    expect_op!(p, "]")
                    result = Node(:cons, Any[Node(:list, items), tail])
                    break
                elseif isop(t, "]")
                    result = Node(:list, items)
                    break
                else
                    perr(p, t, "atteso ',', '|' o ']'")
                end
            end
        end
    end
    p.depth -= 1
    result
end

function parse_if(p::Parser)   # 'if' / 'elseif' già consumata
    c = parse_expr(p)
    b = parse_block(p, ("elseif", "else", "end"))
    t = next!(p)
    iskw(t, "elseif") && return Node(:if, Any[c, b, parse_if(p)])
    if iskw(t, "else")
        e = parse_block(p, ("end",))
        expect_kw!(p, "end")
        return Node(:if, Any[c, b, e])
    end
    Node(:if, Any[c, b, nothing])
end

function parse_while(p::Parser)
    c = parse_expr(p)
    b = parse_block(p, ("end",)); expect_kw!(p, "end")
    Node(:while, Any[c, b])
end

function parse_for(p::Parser)
    # destrutturazione: for (k, v) in xs
    if isop(raw(p), "(")
        next!(p)
        ids = Symbol[]
        while true
            push!(ids, expect_ident!(p, "nome di variabile nel for"))
            t = next!(p)
            if isop(t, ",")
                continue
            elseif isop(t, ")")
                break
            else
                perr(p, t, "atteso ',' o ')' nella destrutturazione del for")
            end
        end
        u = next!(p)
        (iskw(u, "in") || isop(u, "=")) || perr(p, u, "atteso 'in'")
        iter = parse_expr(p)
        b = parse_block(p, ("end",)); expect_kw!(p, "end")
        return Node(:dfor, Any[Node(:tuple, ids), iter, b])
    end
    var = expect_ident!(p, "variabile del for")
    u = next!(p)
    (iskw(u, "in") || isop(u, "=")) || perr(p, u, "atteso 'in'")
    iter = parse_expr(p)
    b = parse_block(p, ("end",)); expect_kw!(p, "end")
    Node(:for, Any[var, iter, b])
end

function parse_let(p::Parser)
    binds = Any[]
    if raw(p).kind ∉ (:nl, :eof)
        while true
            name = expect_ident!(p, "nome nel let")
            expect_op!(p, "=")
            # [QODER] minprec 2 → 1: con 2 `let a = b = 1` si fermava alla seconda '='
            push!(binds, Node(:assign, Any[name, parse_expr(p, 1)]))
            isop(raw(p), ",") || break
            next!(p)
        end
    end
    b = parse_block(p, ("end",)); expect_kw!(p, "end")
    Node(:let, Any[Node(:tuple, binds), b])
end

function parse_begin(p::Parser)
    b = parse_block(p, ("end",)); expect_kw!(p, "end")
    b
end

function parse_try(p::Parser)
    b = parse_block(p, ("catch", "end"))
    t = next!(p)
    iskw(t, "end") && return Node(:try, Any[b, nothing, nothing])
    var = nothing
    if raw(p).kind === :ident
        var = Symbol(next!(p).val)
    end
    h = parse_block(p, ("end",)); expect_kw!(p, "end")
    Node(:try, Any[b, var, h])
end

function parse_with(p::Parser)
    mods = Any[parse_expr(p, 3)]
    while isop(raw(p), ",")
        next!(p)
        push!(mods, parse_expr(p, 3))
    end
    b = parse_block(p, ("end",)); expect_kw!(p, "end")
    Node(:with, Any[Node(:tuple, mods), b])
end

function parse_solve(p::Parser)
    goal = parse_expr(p, 1)
    opts = Any[]
    while true
        t = raw(p)
        if t.kind === :ident && t.val in ("limit", "depth", "steps")
            next!(p)
            push!(opts, Node(:assign, Any[Symbol(t.val), parse_expr(p, 7)]))
        elseif t.kind === :ident && t.val == "trace"
            next!(p)
            push!(opts, Node(:assign, Any[:trace, true]))
        else
            break
        end
    end
    Node(:solve, Any[goal, Node(:tuple, opts)])
end
