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
char_0 = 48
char_9 = 57
char_a = 65
char_z = 90
char_lower_a = 97
char_lower_z = 122
char_underscore = 95
char_tab = 9
char_linefeed = 10
char_carriage_return = 13
char_plus = 43
char_minus = 45
char_star = 42
char_lparen = 40
char_rparen = 41
char_equal = 61
char_space = 32

# Tokenizza prossimo token
function next_token(chars, pos)
  size = get(chars, 0)
  skipping = 1
  while (pos < size) && (skipping == 1)
    c = get(chars, pos + 1)
    if (c == char_space) || (c == char_tab) || (c == char_linefeed) || (c == char_carriage_return)
      pos = pos + 1
    else
      skipping = 0
    end
  end
  if pos >= size
    [0, 0, pos]
  else
    c = get(chars, pos + 1)
    if (c >= char_0) && (c <= char_9)
      value = 0
      scanning = 1
      while (pos < size) && (scanning == 1)
        c = get(chars, pos + 1)
        if (c >= char_0) && (c <= char_9)
          value = value * 10 + c - char_0
          pos = pos + 1
        else
          scanning = 0
        end
      end
      [1, value, pos]
    elseif ((c >= char_a) && (c <= char_z)) || ((c >= char_lower_a) && (c <= char_lower_z)) || (c == char_underscore)
      start = pos
      scanning = 1
      while (pos < size) && (scanning == 1)
        c = get(chars, pos + 1)
        if ((c >= char_a) && (c <= char_z)) || ((c >= char_lower_a) && (c <= char_lower_z)) || ((c >= char_0) && (c <= char_9)) || (c == char_underscore)
          pos = pos + 1
        else
          scanning = 0
        end
      end
      # Gli identificatori sono riferimenti all'intervallo [start, pos) nella sorgente.
      [2, start, pos]
    elseif c == char_plus
      [3, c, pos + 1]
    elseif c == char_minus
      [4, c, pos + 1]
    elseif c == char_star
      [5, c, pos + 1]
    elseif c == char_lparen
      [6, c, pos + 1]
    elseif c == char_rparen
      [7, c, pos + 1]
    elseif c == char_equal
      [8, c, pos + 1]
    else
      [0, 0, pos + 1]
      end
  end
end

# Test tokenizer
# Simula "42 +\n_x2": lunghezza seguita dai codici ASCII dei caratteri.
source = [8, 52, 50, 32, 43, 10, 95, 120, 50]
println("Source: " * string(get(source, 0)) * " chars")

pos = 0
token = next_token(source, pos)
println("Token 1: type=" * string(get(token, 0)) * ", value=" * string(get(token, 1)))

pos = get(token, 2)
token = next_token(source, pos)
println("Token 2: type=" * string(get(token, 0)) * ", value=" * string(get(token, 1)))

pos = get(token, 2)
token = next_token(source, pos)
println("Token 3: type=" * string(get(token, 0)) * ", start=" * string(get(token, 1)) * ", end=" * string(get(token, 2)))
