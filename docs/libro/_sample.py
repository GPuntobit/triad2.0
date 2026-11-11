import pymupdf
d=pymupdf.open('Il-libro-di-triad.pdf')
for i in [60,61,62]:
    print(f"\n===== PAGE {i+1} =====")
    print(d[i].get_text())
