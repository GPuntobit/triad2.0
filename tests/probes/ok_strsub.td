# strsub(s, a, b): byte da a a b inclusi (1-based) (SPEC-CORE.md §8).
s = "ciao"
println(strsub(s, 1, 4))
println(strsub(s, 2, 3))
println(strlen(strsub(s, 3, 3)))
