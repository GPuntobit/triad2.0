# Corpus pulito: nessuna regola deve scattare.
# NOTA: l'ultimo statement di un programma non puo' essere una chiamata
# (il seed non la valuta): il programma termina con un'assegnazione.
totale = 0
function somma(xs)
  i = 1
  n = length(xs)
  while i <= n
    totale = totale + get(xs, i)
    i = i + 1
  end
  totale
end
v = somma([1, 2, 3])
risultato = println(v)
