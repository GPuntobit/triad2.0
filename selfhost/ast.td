# S1 AST e strutture dati in Triad-Core

# Tipo per i nodi AST
type AST = Int  # simplified: use Int for type tags
  AST_ATOM = 0
  AST_LIST = 1
  AST_CALL = 2
  AST_IF = 3
  AST_WHILE = 4
  AST_LET = 5
  AST_BEGIN = 6
  AST_LAMBDA = 7

# Creare nodo AST
function make_atom(val)
  # For now, just return the value
  val
end

function make_list(items)
  # Create a list of AST nodes
  items
end

function make_call(func, args)
  # Create a call node
  [func, args]
end
