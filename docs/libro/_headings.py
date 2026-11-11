import re

with open('libro.html', encoding='utf-8') as source:
    s = source.read()

for m in re.finditer(r'<h[123][^>]*>(.*?)</h[123]>', s, re.S):
    print(m.start(), m.group(0)[:120].replace('\n', ' '))
