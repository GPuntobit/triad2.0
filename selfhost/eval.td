# Test eval without block-style functions
# Ambiente: 1="x", 10
env = [1, 10]

# Sorgente simulato: "42" -> [1, 42, 2]
token_num = [1, 42, 2]
type_num = get(token_num, 0)
if type_num == 1  # NUMBER
  result_num = get(token_num, 1)
  println("eval(42): " * string(result_num))
end

# Sorgente simulato: "x" -> [2, 1, 1] (type=2, name_start=1 corresponds to key=1 in env)
token_id = [2, 1, 1]
type_id = get(token_id, 0)
if type_id == 2  # IDENTIFIER
  name_start = get(token_id, 1)
  pos = 0
  while pos < get(env, 0)
    if get(env, pos) == name_start
      result_id = get(env, pos + 1)
      println("eval(x): " * string(result_id))
      break
    end
    pos = pos + 2
  end
end