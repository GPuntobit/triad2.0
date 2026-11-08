# Output beyond pipe buffers must reach the caller in full (SPEC-CORE §§5,7).
i = 0
while i < 1024
    println("abcdefghijklmnopqrstuvwxyz0123456789")
    i += 1
end
