import re
p = r".github/agents/bengali-reviewer.md"
lines = open(p, encoding='utf-8').read().split('\n')
for i,l in enumerate(lines,1):
    if re.search(r'[àèéìòù]', l):
        print(i, repr(l[:120]))
        if i>20: break
