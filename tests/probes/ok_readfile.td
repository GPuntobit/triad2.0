# readfile(path): il contenuto del file come Stringa (SPEC-CORE.md §8).
c = readfile("tests/probes/readfile_data.txt")
println(strlen(c))
println(c)
