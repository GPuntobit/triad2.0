# Simbolo operatore (':+'): previsto da SPEC-CORE §2 e accettato
# dall'interprete JS; il codice macchina lo rifiuta (exit 1). Lo scanner del
# front-end S1 lo accetta (superset). Punto 5 dei problemi aperti.
m = :+
println(typeof(m))
