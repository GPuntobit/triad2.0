import os
print("cwd", os.getcwd())
root = r"c:/Users/xbos/Documents/progetti/triad2.0"
print("exists", os.path.exists(root))
print("MANUALE", os.path.exists(root + "/MANUALE.md"))
