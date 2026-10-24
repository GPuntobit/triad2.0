# S1 v1.3: Ambiente semplice senza while

function make_env()
  []
end

function env_lookup(env, name)
  nothing
end

function env_set(env, name, value)
  env
end

# Test base
env = make_env()
println("Env created")
