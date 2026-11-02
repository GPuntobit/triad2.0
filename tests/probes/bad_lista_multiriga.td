# Letterale di lista su piu' righe: il seed tratta i newline come trivia e lo
# accetta; il parser del riferimento JS si ferma su "parse error: unexpected
# token SEP". Per portabilita' i letterali di lista vanno scritti su una riga.
x = [1,
2]
println(length(x))
