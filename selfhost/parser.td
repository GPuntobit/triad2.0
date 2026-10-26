# S1.11: Parser completo - test semplice keyword
# Controlla se caratteri formano "if"
chars = [105, 102]  # "if"
if (get(chars, 0) == 105) && (get(chars, 1) == 102)
  println("Recognized: if")
end

# Controlla se caratteri formano "end"
chars_end = [101, 110, 100]  # "end"
if (get(chars_end, 0) == 101) && (get(chars_end, 1) == 110) && (get(chars_end, 2) == 100)
  println("Recognized: end")
end
