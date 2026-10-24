# S1.1: Heap bump pointer (versione compatibile seed)

function heap_alloc(heap_ptr, size)
  heap_ptr + size
end

function heap_reset()
  0
end

# Test
hp = 0
np = heap_alloc(hp, 100)
println("Heap allocated at: " * string(np))
