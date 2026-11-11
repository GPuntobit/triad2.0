# D16 risolta — i primitivi §8 (`readfile`, `strlen`, `strbyte`, `strsub`)
# sono implementati dal seed: le guardie statiche non li vietano piu'.
s = readfile("selfhost/main.td")
println(strlen(s))
println(strbyte(s, 1))
println(strsub(s, 1, 4))
