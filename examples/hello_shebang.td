#!/usr/bin/env triad
# =====================================================================
#  hello_shebang.td — esempio di file .td eseguibile direttamente
#
#  Rendi eseguibile e lancia:
#    chmod +x hello_shebang.td
#    ./hello_shebang.td Alice Bob
#
#  Oppure con il launcher:
#    triad hello_shebang.td Alice Bob
#
#  La prima riga (shebang) viene rimossa automaticamente dal runtime.
# =====================================================================

function saluta(nome::String) !io
    println("Ciao, ", nome, "! Benvenuto in Triad.")
end

# Mostra gli argomenti passati dalla riga di comando
println("=== File .td eseguibile ===")
println("ARGS = ", ARGS)

if isempty(ARGS)
    println("Uso: ./hello_shebang.td nome1 [nome2 ...]")
    println("Provo con un esempio:")
    saluta("mondo")
else
    for nome in ARGS
        saluta(String(nome))
    end
end

# Dimostra che la logica funziona anche nei file shebang
fact parent(:alice, :bob)
fact parent(:bob, :charlie)
rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

println()
println("Query logica: grandparent(:alice, ?who)")
result = solve grandparent(:alice, ?who)
println("Risultato: ", result)
