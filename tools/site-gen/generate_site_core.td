# =====================================================================
# generate_site.td — il sito di Triad generato con Triad stesso
# (Triad-Core: let ... end, concatenazione con *, print/println)
#
# Uso:  triad tools/site-gen/generate_site.td > docs/pages/generated.html
# =====================================================================

let title = "Triad 2.0"
    subtitle = "A language in itself, defined by its standard"
    desc = "Self-contained language: block syntax, declared types, multiple dispatch, integrated logic programming (fact, rule, solve), code as data."
    qmark = "?"
    # --- helper: un badge come funzione (il codice produce dati) ------
    badge = t -> "<span class=\"badge\">" * t * "</span>"

    # --- helper: una sezione hero -------------------------------------
    hero = h1 -> "<section class=\"hero\"><div class=\"container\"><h1>" * h1 * "</h1></div></section>"

    print("<!DOCTYPE html>\n")
    print("<html lang=\"en\">\n<head>\n")
    print("<meta charset=\"utf-8\" />\n")
    print("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />\n")
    print("<title>")
    print(title)
    print(" — programming language</title>\n")
    print("<link rel=\"stylesheet\" href=\"../assets/css/style.css\" />\n")
    print("</head>\n<body>\n")

    print(hero(subtitle))

    print("<main><div class=\"container\">\n")
    print("<p class=\"lead\">")
    print(desc)
    print("</p>\n")

    print("<div class=\"badges\">")
    print(badge("v0.2.0"))
    print(badge("MIT"))
    print(badge("Regulatory spec"))
    print(badge("Conformance 37/37"))
    print("</div>\n")

    print("<nav class=\"hero-actions\">\n")
    print("<a class=\"btn btn-primary\" href=\"playground.html\">▶ Try the Playground</a>\n")
    print("<a class=\"btn btn-ghost\" href=\"getting-started.html\">Start now</a>\n")
    print("<a class=\"btn btn-ghost\" href=\"language-tour.html\">Language tour</a>\n")
    print("<a class=\"btn btn-ghost\" href=\"https://github.com/GPuntobit/triad2.0\">GitHub</a>\n")
    print("</nav>\n")

    print("<pre class=\"code-card\">\n")
    print("fact parent(:alice, :bob)\n")
    print("fact parent(:bob, ")
    print(qmark)
    print(")\n")
    print("rule ancestor(X, Y) :- parent(X, Y).\n")
    print("rule ancestor(X, Z) :- parent(X, Y), ancestor(Y, Z).\n")
    print("solve ancestor(:alice, WHO)\n")
    print("</pre>\n")

    println("</div></main>\n</body>\n</html>")
end