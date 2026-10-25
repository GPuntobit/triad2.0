# S1.5: Eval espressioni base semplice
# Valuta espressioni Int con ambiente inline (identificatori -> valori)

# Valuta un token NUMBER
function eval_number(token)
  get(token, 1)
end

# Valuta un identificatore con lookup nell'ambiente
function eval_identifier(token, env)
  name_start = get(token, 1)
  # Cerca nell'ambiente: env = [key1, val1, key2, val2, ...]
  pos = 0
  while pos < get(env, 0)
    if get(env, pos) == name_start
      return get(env, pos + 1)
    end
    pos = pos + 2
  end
  0  # Non trovato, restituisce 0
end

# Valuta espressione semplice (solo NUMBER o IDENTIFIER)
function eval_expr(token, env)
  type = get(token, 0)
  if type == 1  # NUMBER
    eval_number(token)
  else if type == 2  # IDENTIFIER
    eval_identifier(token, env)
  else
    0
  end
end

# Test eval
# Ambiente: 1="x", 10
env = [1, 10]

# Sorgente simulato: "42" -> [1, 42, 2]
token_num = [1, 42, 2]
result = eval_expr(token_num, env)
println("eval(42): " * string(result))

# Sorgente simulato: "x" -> [2, 1, 1] (name_start=1 corrisponde a key=1 in env)
token_id = [2, 1, 1]
result = eval_expr(token_id, env)
println("eval(x): " * string(result))
