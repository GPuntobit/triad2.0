# S1.12: Eval programmi completi (abbozzo)
# Valuta statement sequenziali con ambiente piatto [chiave, valore, ...].
#
# Sorgente tokenizzato come LISTA PIATTA di interi (il seed ha liste di soli
# interi): ogni token e' una coppia [tipo, valore] e ogni statement e' una
# coppia di token (4 interi):
#   tipo 0 = NUMBER   (valore = letterale)
#   tipo 1 = IDENT    (valore = chiave dell'ambiente)
#   tipo 2 = ASSIGN   (il token successivo e' il valore)
#   tipo 3 = PRINTLN  (il token successivo e' l'argomento)

# Ricerca nell'ambiente piatto: l'ultima coppia [chiave, valore] vince
function env_lookup(env, key)
  r = 0
  i = 0
  while i < length(env)
    if get(env, i) == key
      r = get(env, i + 1)
    end
    i = i + 2
  end
  r
end

# Valuta un operando: letterale oppure lookup nell'ambiente
function eval_operand(tokens, pos, env)
  type = get(tokens, pos)
  value = get(tokens, pos + 1)
  r = value
  if type == 1
    r = env_lookup(env, value)
  end
  r
end

# Esegue i token: ASSIGN aggiorna l'ambiente, PRINTLN stampa
function eval_program(tokens, env)
  pos = 0
  while pos < length(tokens)
    type = get(tokens, pos)
    if type == 2
      key = get(tokens, pos + 1)
      value = eval_operand(tokens, pos + 2, env)
      env = push!(env, key)
      env = push!(env, value)
    else
      if type == 3
        value = eval_operand(tokens, pos + 2, env)
        println(value)
      end
    end
    pos = pos + 4
  end
  env
end

# Test eval programmi: x = 42; println(x); x = 7; println(x)
tokens = [2, 1, 0, 42, 3, 0, 1, 1, 2, 1, 0, 7, 3, 0, 1, 1]
env = []
env = eval_program(tokens, env)
