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
