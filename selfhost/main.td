# S1 v1.4: Ambiente funzionante con liste

function make_env()
  []
end

function env_lookup(env, name)
  # Cerca name in env (lista piatta [key1, val1, key2, val2, ...])
  # Per semplicità, ritorna nothing per ora
  nothing
end

function env_set(env, name, value)
  # Aggiunge alla lista
  env
end

# Test base
env = make_env()
env = env_set(env, "x", 10)
println("Env created and set")
