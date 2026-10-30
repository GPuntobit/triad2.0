import os
root = r"c:\Users\xbos\Documents\progetti\triad2.0"
print("exists", os.path.exists(root))
print("listdir", os.listdir(root)[:10])
print("MANUALE exists", os.path.exists(os.path.join(root, "MANUALE.md")))
