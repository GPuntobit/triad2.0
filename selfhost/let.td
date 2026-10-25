# S1.8: Variabili con let e scope
# let crea binding locale nell'ambiente

# Aggiunge binding all'ambiente (key, value)
function env_bind(env, key, value)
  push!(env, key)
  push!(env, value)
end

# Lookup variabile nell'ambiente
function env_lookup(env, key)
  pos = 0
  # Environment stores [key1, value1, key2, value2, ...]
  # Use length(env) not get(env, 0) which returns first element
  while pos + 1 < length(env)
    if get(env, pos) == key
      return get(env, pos + 1)
    end
    pos = pos + 2
  end
  0  # Non trovato
end

# Simula let x = 10; println(x)
env = []
env = env_bind(env, 1, 10)  # 1 = "x"
val = env_lookup(env, 1)
println("let x = 10, x = " * string(val))

# Simula scope annidato: let y = 20; println(y)
# env già ha x=10
env = env_bind(env, 2, 20)  # 2 = "y"
val = env_lookup(env, 2)
println("let y = 20, y = " * string(val))

# Lookup ancora x (dovrebbe ancora funzionare)
val = env_lookup(env, 1)
println("x ancora = " * string(val))
