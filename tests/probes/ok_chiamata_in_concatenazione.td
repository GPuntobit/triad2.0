function corpo(t)
    "<p>" * t * "</p>"
end
function pagina(t)
    "<div>" * corpo(t) * "</div>"
end
println(pagina("ciao"))
