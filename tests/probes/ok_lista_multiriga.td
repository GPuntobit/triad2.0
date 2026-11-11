# Letterale di lista su piu' righe: ora accettato da entrambi i runtime.
# Il parser del riferimento JS salta i separatori dentro [ ... ] (come il
# seed, che tratta i newline come trivia); il probe e' stato ribaltato da
# bad_ a ok_ il 2026-11-02.
x = [1,
2]
println(length(x))
