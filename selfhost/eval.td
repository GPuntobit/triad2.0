# S1 Evaluator diretto (senza AST completo)

# Ambiente semplice
function eval_expr(expr, env)
  # Per ora, ritorna l'espressione stessa
  expr
end

# Builtin principale
function string(x)
  # Implementazione S1 di string()
  # Per ora, usa il builtin del seed
  # Nota: il seed supporta solo Int e String
  if typeof(x) == Int
    # Conversione Int -> stringa
    # Implementazione manuale in Triad-Core
    str = ""
    n = x
    if n < 0
      str = str * "-"
      n = -n
    end
    while n > 0
      digit = n % 10
      str = string(digit) * str
      n = n / 10
    end
    str
  else
    x  # identity per stringhe
  end
end

# Test
println(string(42))
println(string("hello"))
