# S1.3: Sistema di valori taggati (semplificato senza floor)
# Encoding: 2 bit tag, 30 bit valore
# Tag 0: Int (valore * 4)
# Tag 1: Bool (false=1, true=5)
# Tag 2: List (ptr * 4 + 2)
# Tag 3: String/Nothing/Symbol (ptr * 4 + 3)

# Crea valore Int con tag 0 (valore * 4)
function make_int(n)
  n * 4
end

# Crea valore Bool con tag 1
function make_bool(b)
  if b
    5  # true = 101b
  else
    1  # false = 001b
  end
end

# Estrae il valore grezzo usando solo operazioni Triad-Core
function as_int(v)
  remaining = v
  result = 0
  while remaining >= 4
    remaining = remaining - 4
    result = result + 1
  end
  while remaining <= -4
    remaining = remaining + 4
    result = result - 1
  end
  result
end

# Test primitive
x = make_int(42)
println("make_int(42): " * string(x))
println("as_int: " * string(as_int(x)))

negative = make_int(-7)
println("as_int(-7): " * string(as_int(negative)))

zero = make_int(0)
println("as_int(0): " * string(as_int(zero)))

b = make_bool(true)
println("make_bool(true): " * string(b))
