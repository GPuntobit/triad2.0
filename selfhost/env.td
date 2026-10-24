# S1.2: Ambiente (nome -> valore)

function env_lookup(name)
  nothing
end

function env_set(name, value)
  value
end

# Test
val = env_lookup("x")
println("Lookup result: " * string(val))
