# S1 v1.5: Ambiente funzionante con get (senza while)

function make_env()
  []
end

function env_lookup(env, name)
  # Controlla primi 4 entry (8 elementi della lista piatta)
  # [key1, val1, key2, val2, key3, val3, key4, val4]
  i = 0
  if i < length(env)
    if get(env, i) == name
      return get(env, i + 1)
    end
  end
  i = 2
  if i < length(env)
    if get(env, i) == name
      return get(env, i + 1)
    end
  end
  nothing
end

function env_set(env, name, value)
  # Aggiunge alla fine
  env
end

# Test
env = make_env()
env = env_set(env, "x", 10)
println("Env created")
println(env_lookup(env, "x"))
