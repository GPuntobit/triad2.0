# D22 risolta (2026-11-09): le parole chiave sono token *esatti* (confine
# bilatero) e il testo di un letterale non conta per l'annidamento dei blocchi.
iffy = 1
myif = 2
endx = 3
elsewhere = 4
whilex = 5
if iffy == 1
    testo = "if end else while function let"
    println(testo)
    println(iffy)
    println(myif)
    println(endx)
    println(elsewhere)
    println(whilex)
end
