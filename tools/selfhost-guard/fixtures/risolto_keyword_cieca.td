# D22 risolta — il seed riconosce le parole chiave come token esatti e il
# testo di un letterale non conta per l'annidamento dei blocchi.
if true
  s = "if end else while function let"
  iffy = 1
  myif = 2
  println(s)
  println(iffy)
  println(myif)
end
