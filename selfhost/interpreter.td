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
