# D20 — il nome creato nel corpo di `if` resta visibile fuori (nel seed).
function f()
  if true
    z = 1
  end
  r = z
  r
end
v = f()
println(v)
