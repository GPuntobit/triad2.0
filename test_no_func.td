# Test without function definitions
env = [1, 10]

# NUMBER evaluation (inline)
result1 = get([1, 42, 2], 1)
println("eval(42): " * string(result1))

# IDENTIFIER evaluation (inline)
token_id = [2, 1, 1]
name_start = get(token_id, 1)
pos = 0
env = [1, 10]
while pos < get(env, 0)
    if get(env, pos) == name_start
        result2 = get(env, pos + 1)
        println("eval(x): " * string(result2))
        break
    end
    pos = pos + 2
end