# Separatore newline dopo un operatore: divergenza misurata fra i due runtime.
# 'x = 1' seguito da '-2': il codice macchina (scannerless) prosegue
# l'espressione oltre il newline e vale 'x = 1 - 2' (-1); il riferimento JS
# tratta il newline come separatore di statement (x = 1, poi -2) e stampa 1.
# SPEC-CORE §2 elenca il newline come separatore ma non decide la continuazione
# dopo un operatore: serve una decisione normativa (come per lo scope, punto 12
# dei problemi aperti) prima di allineare i runtime. Misurato il 2026-11-02.
x = 1
-2
println(x)
