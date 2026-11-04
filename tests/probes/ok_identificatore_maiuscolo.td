# Identificatore e simbolo con iniziale maiuscola: SPEC-CORE §2 ammette le
# lettere [A-Za-z]. Il seed rifiutava entrambi (exit 1) per due test del primo
# byte senza case-folding: stmt_assign (dispatch statement) e sym_scan (salto
# morto sul ramo A-Z). Corretto il 2026-11-02 (N01): probe ribaltato da bad_.
Ab = 0
println(Ab)
m = :Ab
println(m)
