# S1.4: Tokenizer simulato
# Token types (tag 0)
# 0: EOF
# 1: NUMBER
# 2: IDENTIFIER
# 3: PLUS (+)
# 4: MINUS (-)
# 5: STAR (*)
# 6: LPAREN (()
# 7: RPAREN ())
# 8: EQUAL (=)

# Caratteri come codici ASCII
CHAR_0 = 48
CHAR_9 = 57
CHAR_A = 65
CHAR_Z = 90
CHAR_a = 97
CHAR_z = 122
CHAR_PLUS = 43
CHAR_MINUS = 45
CHAR_STAR = 42
CHAR_LPAREN = 40
CHAR_RPAREN = 41
CHAR_EQUAL = 61
CHAR_SPACE = 32

# Controlla se carattere è cifra
function is_digit(c)
  (c >= CHAR_0) && (c <= CHAR_9)
end

# Controlla se carattere è lettera
function is_alpha(c)
  ((c >= CHAR_A) && (c <= CHAR_Z)) || ((c >= CHAR_a) && (c <= CHAR_z))
end

# Controlla se carattere è spazio
function is_space(c)
  c == CHAR_SPACE
end

# Tokenizza un numero (es: "42" -> [1, 42])
function tokenize_number(chars, pos)
  value = 0
  while pos < get(chars, 0)
    c = get(chars, pos)
    if is_digit(c)
      digit = c - CHAR_0
      value = value * 10 + digit
      pos = pos + 1
    else
      break
    end
  end
  [1, value, pos]
end

# Tokenizza un identificatore (es: "x" -> [2, "x", pos])
function tokenize_identifier(chars, pos)
  name = []
  while pos < get(chars, 0)
    c = get(chars, pos)
    if is_alpha(c)
      name = push!(name, c)
      pos = pos + 1
    else
      break
    end
  end
  [2, name, pos]
end

# Tokenizza carattere singolo
function tokenize_char(chars, pos, char_code, token_type)
  c = get(chars, pos)
  if c == char_code
    [token_type, c, pos + 1]
  else
    [0, 0, pos]
  end
end

# Tokenizza salta spazi
function skip_spaces(chars, pos)
  while pos < get(chars, 0)
    c = get(chars, pos)
    if is_space(c)
      pos = pos + 1
    else
      break
    end
  end
  pos
end

# Tokenizza prossimo token
function next_token(chars, pos)
  pos = skip_spaces(chars, pos)
  if pos >= get(chars, 0)
    [0, 0, pos]
  else
    c = get(chars, pos)
    if is_digit(c)
      tokenize_number(chars, pos)
    else if is_alpha(c)
      tokenize_identifier(chars, pos)
    else if c == CHAR_PLUS
      [3, c, pos + 1]
    else if c == CHAR_MINUS
      [4, c, pos + 1]
    else if c == CHAR_STAR
      [5, c, pos + 1]
    else if c == CHAR_LPAREN
      [6, c, pos + 1]
    else if c == CHAR_RPAREN
      [7, c, pos + 1]
    else if c == CHAR_EQUAL
      [8, c, pos + 1]
    else
      [0, 0, pos + 1]
    end
  end
end

# Test tokenizer
# Simula sorgente "42 + x" come lista di caratteri
source = [52, 50, 32, 43, 32, 120]  # "42 + x"
println("Source: " * string(get(source, 0)) * " chars")

pos = 0
token = next_token(source, pos)
println("Token 1: type=" * string(get(token, 0)) * ", value=" * string(get(token, 1)))

pos = get(token, 2)
token = next_token(source, pos)
println("Token 2: type=" * string(get(token, 0)) * ", value=" * string(get(token, 1)))

pos = get(token, 2)
token = next_token(source, pos)
println("Token 3: type=" * string(get(token, 0)) * ", value=" * string(get(token, 1)))
