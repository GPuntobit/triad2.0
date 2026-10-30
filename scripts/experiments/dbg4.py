import os
print("listdir .:", os.listdir('.')[:20])
print("count", len(os.listdir('.')))
import glob
print("glob md:", glob.glob('*.md')[:10])
