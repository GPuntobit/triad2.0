# Sorgenti self-hosted (S1, `selfhost/`)

Codice completo dei prototipi di S1, l'interprete di Triad scritto in Triad-Core. Questi file girano sul **seed Windows** (`seed\windows-x86_64\seed.exe selfhost\<file>`), non sull'interprete JS: usano l'helper non standard `get(xs, i)` con indici da 0. Convenzioni e stato: [Parte IV §37](Parte-IV-Codice-del-progetto#cap-37); task S1.3–S1.15 in [`TASK.md`](https://github.com/GPuntobit/triad2.0/blob/main/TASK.md).

| file | cosa contiene |
|---|---|
| [`ast.td`](#asttd) | bozza di tag dei nodi AST e costruttori. |
| [`env.td`](#envtd) | stub di lookup/assegnamento. |
| [`eval.td`](#evaltd) | valutazione di un token numerico e lookup di un identificatore nell'ambiente. |
| [`heap.td`](#heaptd) | stub di allocatore bump. |
| [`interpreter.td`](#interpretertd) | bozza di interprete con ambiente a coppie e `eval_expr`. |
| [`let.td`](#lettd) | probe di `let`. |
| [`main.td`](#maintd) | ambiente inline come lista piatta `[chiave, valore]`; smoke test in CI (atteso `Value: 10`). |
| [`parser.td`](#parsertd) | riconoscimento delle keyword `if`/`end` dai codici ASCII. |
| [`program.td`](#programtd) | valutazione di una sequenza di token: assegnamento e `println`. |
| [`test.td`](#testtd) | probe di funzione a blocco. |
| [`tokenizer.td`](#tokenizertd) | `next_token(chars, pos)` su un sorgente codificato come `[lunghezza, byte…]`; restituisce token `[tipo, valore, pos]`. |
| [`value.td`](#valuetd) | valori taggati a 2 bit simulati con interi (`make_int`, `make_bool`, `as_int`). |

## ast.td

```julia
# S1 AST e strutture dati in Triad-Core

# Tipo per i nodi AST
type AST = Int  # simplified: use Int for type tags
  AST_ATOM = 0
  AST_LIST = 1
  AST_CALL = 2
  AST_IF = 3
  AST_WHILE = 4
  AST_LET = 5
  AST_BEGIN = 6
  AST_LAMBDA = 7

# Creare nodo AST
function make_atom(val)
  # For now, just return the value
  val
end

function make_list(items)
  # Create a list of AST nodes
  items
end

function make_call(func, args)
  # Create a call node
  [func, args]
end
```

## env.td

```julia
# S1.2: Ambiente (nome -> valore)

function env_lookup(name)
  nothing
end

function env_set(name, value)
  value
end

# Test
val = env_lookup("x")
println("Lookup result: " * string(val))
```

## eval.td

```julia
# Test eval without block-style functions
# Ambiente: 1="x", 10
env = [1, 10]

# Sorgente simulato: "42" -> [1, 42, 2]
token_num = [1, 42, 2]
type_num = get(token_num, 0)
if type_num == 1  # NUMBER
  result_num = get(token_num, 1)
  println("eval(42): " * string(result_num))
end

# Sorgente simulato: "x" -> [2, 1, 1] (type=2, name_start=1 corresponds to key=1 in env)
token_id = [2, 1, 1]
type_id = get(token_id, 0)
if type_id == 2  # IDENTIFIER
  name_start = get(token_id, 1)
  pos = 0
  # Environment stores [name1, value1, name2, value2, ...]
  # Loop while there are still pairs to check (use length, not first element)
  while pos + 1 < length(env)
    if get(env, pos) == name_start
      result_id = get(env, pos + 1)
      println("eval(x): " * string(result_id))
      break
    end
    pos = pos + 2
  end
end
```

## heap.td

```julia
# S1.1: Heap bump pointer (versione compatibile seed)

function heap_alloc(heap_ptr, size)
  heap_ptr + size
end

function heap_reset()
  0
end

# Test
hp = 0
np = heap_alloc(hp, 100)
println("Heap allocated at: " * string(np))
```

## interpreter.td

```julia
# S1 Interprete Triad-Core minimale

# Ambiente: mappa nome -> valore
function make_env()
  []  # lista di coppie [nome, valore]
end

function env_lookup(env, name)
  i = 0
  while i < length(env)
    if env[i] == name
      return env[i + 1]
    end
    i = i + 2
  end
  nothing
end

function env_set(env, name, value)
  # Aggiorna o aggiunge
  i = 0
  while i < length(env)
    if env[i] == name
      env[i + 1] = value
      return
    end
    i = i + 2
  end
  # Non trovato, aggiungi
  push!(env, name)
  push!(env, value)
end

# Eval base
function eval_expr(ast, env)
  # Per ora, solo atomi (Int, Bool, String)
  ast
end

# Main entry point
function interpret(program)
  env = make_env()
  # Eval would go here
  env
end
```

## let.td

```julia
let x = 7
println(x)
end
```

## main.td

```julia
# S1 v1.9: Ambiente inline (senza funzioni helper)

# Crea ambiente vuoto
env = []

# Aggiunge binding (1 = "x", 10 = valore)
env = push!(env, 1)
env = push!(env, 10)

# Lookup: controlla prima entry
if get(env, 0) == 1
  val = get(env, 1)
  println("Value: " * string(val))
end
```

## parser.td

```julia
# S1.11: Parser completo - test semplice keyword
# Controlla se caratteri formano "if"
chars = [105, 102]  # "if"
if (get(chars, 0) == 105) && (get(chars, 1) == 102)
  println("Recognized: if")
end

# Controlla se caratteri formano "end"
chars_end = [101, 110, 100]  # "end"
if (get(chars_end, 0) == 101) && (get(chars_end, 1) == 110) && (get(chars_end, 2) == 100)
  println("Recognized: end")
end
```

## program.td

```julia
# S1.12: Eval programmi completi
# Valuta statement sequenziali con ambiente

# Statement types
# 0: NUMBER
# 1: IDENTIFIER
# 2: ASSIGN (=)
# 3: PRINTLN

# Valuta statement assegnazione (x = 42)
function eval_assign(tokens, pos, env)
  # Assumiamo formato: [IDENTIFIER, ASSIGN, NUMBER, ...]
  # Salta identificatore e =
  pos = pos + 2
  # Valuta valore
  token = get(tokens, pos)
  type = get(token, 0)
  if type == 0  # NUMBER
    value = get(token, 1)
    # Aggiungi all'ambiente
    env = push!(env, 1)  # key=1 (nome x)
    env = push!(env, value)
    [env, pos + 1]
  else
    [env, pos + 1]
  end
end

# Valuta statement println(x)
function eval_println(tokens, pos, env)
  # Assumiamo formato: [IDENTIFIER (println), NUMBER/IDENTIFIER, ...]
  pos = pos + 1
  token = get(tokens, pos)
  type = get(token, 0)
  if type == 0  # NUMBER
    value = get(token, 1)
    println(value)
  else if type == 1  # IDENTIFIER
    key = get(token, 1)
    value = 0
    p = 0
    while p + 1 < length(env)
      if get(env, p) == key
        value = get(env, p + 1)
        break
      end
      p = p + 2
    end
    println(value)
  end
  [env, pos + 1]
end

# Valuta programma (lista di statements)
function eval_program(tokens, env)
  pos = 0
  while pos < get(tokens, 0)
    token = get(tokens, pos)
    type = get(token, 0)
    if type == 2  # ASSIGN
      result = eval_assign(tokens, pos, env)
      env = get(result, 0)
      pos = get(result, 1)
    else if type == 3  # PRINTLN
      result = eval_println(tokens, pos, env)
      env = get(result, 0)
      pos = get(result, 1)
    else
      pos = pos + 1
    end
  end
  env
end

# Test eval programmi
# Programma: x = 42; println(x)
# Tokens: [IDENTIFIER(1), ASSIGN(2), NUMBER(42,3), IDENTIFIER(println,3), IDENTIFIER(1,3)]
tokens = [2, 1, 1, 2, 0, 42, 3, 3, 1, 1, 3]
env = []
env = eval_program(tokens, env)
```

## test.td

```julia
function test()
  42
end

println(test())
```

## tokenizer.td

```julia
# S1.4: Tokenizer simulato
# Token types (tag 0)
# 0: EOF
# 1: NUMBER
# 2: IDENTIFIER
# 3: PLUS (+)
# 4: MINUS (-)
# 5: STAR (*)
# 6: LPAREN (()
# 7: RPAREN ())
# 8: EQUAL (=)

# Caratteri come codici ASCII
char_0 = 48
char_9 = 57
char_a = 65
char_z = 90
char_lower_a = 97
char_lower_z = 122
char_underscore = 95
char_tab = 9
char_linefeed = 10
char_carriage_return = 13
char_plus = 43
char_minus = 45
char_star = 42
char_lparen = 40
char_rparen = 41
char_equal = 61
char_space = 32

# Tokenizza prossimo token
function next_token(chars, pos)
  size = get(chars, 0)
  skipping = 1
  while (pos < size) && (skipping == 1)
    c = get(chars, pos + 1)
    if (c == char_space) || (c == char_tab) || (c == char_linefeed) || (c == char_carriage_return)
      pos = pos + 1
    else
      skipping = 0
    end
  end
  if pos >= size
    [0, 0, pos]
  else
    c = get(chars, pos + 1)
    if (c >= char_0) && (c <= char_9)
      value = 0
      scanning = 1
      while (pos < size) && (scanning == 1)
        c = get(chars, pos + 1)
        if (c >= char_0) && (c <= char_9)
          value = value * 10 + c - char_0
          pos = pos + 1
        else
          scanning = 0
        end
      end
      [1, value, pos]
    elseif ((c >= char_a) && (c <= char_z)) || ((c >= char_lower_a) && (c <= char_lower_z)) || (c == char_underscore)
      start = pos
      scanning = 1
      while (pos < size) && (scanning == 1)
        c = get(chars, pos + 1)
        if ((c >= char_a) && (c <= char_z)) || ((c >= char_lower_a) && (c <= char_lower_z)) || ((c >= char_0) && (c <= char_9)) || (c == char_underscore)
          pos = pos + 1
        else
          scanning = 0
        end
      end
      # Gli identificatori sono riferimenti all'intervallo [start, pos) nella sorgente.
      [2, start, pos]
    elseif c == char_plus
      [3, c, pos + 1]
    elseif c == char_minus
      [4, c, pos + 1]
    elseif c == char_star
      [5, c, pos + 1]
    elseif c == char_lparen
      [6, c, pos + 1]
    elseif c == char_rparen
      [7, c, pos + 1]
    elseif c == char_equal
      [8, c, pos + 1]
    else
      [0, 0, pos + 1]
      end
  end
end

# Test tokenizer
# Simula "42 +\n_x2": lunghezza seguita dai codici ASCII dei caratteri.
source = [8, 52, 50, 32, 43, 10, 95, 120, 50]
println("Source: " * string(get(source, 0)) * " chars")

pos = 0
token = next_token(source, pos)
println("Token 1: type=" * string(get(token, 0)) * ", value=" * string(get(token, 1)))

pos = get(token, 2)
token = next_token(source, pos)
println("Token 2: type=" * string(get(token, 0)) * ", value=" * string(get(token, 1)))

pos = get(token, 2)
token = next_token(source, pos)
println("Token 3: type=" * string(get(token, 0)) * ", start=" * string(get(token, 1)) * ", end=" * string(get(token, 2)))
```

## value.td

```julia
# S1.3: Sistema di valori taggati (semplificato senza floor)
# Encoding: 2 bit tag, 30 bit valore
# Tag 0: Int (valore * 4)
# Tag 1: Bool (false=1, true=5)
# Tag 2: List (ptr * 4 + 2)
# Tag 3: String/Nothing/Symbol (ptr * 4 + 3)

# Crea valore Int con tag 0 (valore * 4)
function make_int(n)
  n * 4
end

# Crea valore Bool con tag 1
function make_bool(b)
  if b
    5  # true = 101b
  else
    1  # false = 001b
  end
end

# Estrae il valore grezzo usando solo operazioni Triad-Core
function as_int(v)
  remaining = v
  result = 0
  while remaining >= 4
    remaining = remaining - 4
    result = result + 1
  end
  while remaining <= -4
    remaining = remaining + 4
    result = result - 1
  end
  result
end

# Test primitive
x = make_int(42)
println("make_int(42): " * string(x))
println("as_int: " * string(as_int(x)))

negative = make_int(-7)
println("as_int(-7): " * string(as_int(negative)))

zero = make_int(0)
println("as_int(0): " * string(as_int(zero)))

b = make_bool(true)
println("make_bool(true): " * string(b))
```
