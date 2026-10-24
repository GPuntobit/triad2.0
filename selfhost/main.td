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
