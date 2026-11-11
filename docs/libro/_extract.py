import pymupdf

out = []
with pymupdf.open('Il-libro-di-triad.pdf') as d:
    for i in range(0, 20):
        out.append(f"\n===== PAGE {i+1} =====\n")
        out.append(d[i].get_text())

with open('extract_p1-20.txt', 'w', encoding='utf-8') as target:
    target.write(''.join(out))
print('done')
