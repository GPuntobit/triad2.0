# S1 v1.8: Ambiente senza length

function make_env()
  []
end

function env_set(env, name_id, value)
  env = push!(env, name_id)
  env = push!(env, value)
  env
end

function env_lookup(env, name_id)
  # Controlla solo la prima entry (i=0)
  if get(env, 0) == name_id
    return get(env, 1)
  end
  nothing
end

# Test (1 = "x")
env = make_env()
env = env_set(env, 1, 10)
val = env_lookup(env, 1)
println("Value: " * string(val))
