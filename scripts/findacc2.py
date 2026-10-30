p = r".github/agents/bengali-reviewer.md"
data = open(p, encoding='utf-8').read()
import re
ms = re.findall(r'[àèéìòù]', data)
print("count", len(ms))
print("unique", set(ms))
# find a line
for line in data.split('\n'):
    if any(c in line for c in 'àèéìòù'):
        print(repr(line[:100]))
        break
