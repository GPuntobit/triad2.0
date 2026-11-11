import pymupdf
d = pymupdf.open('Il-libro-di-triad.pdf')
out=[]
for i in range(0,20):
    out.append(f"\n===== PAGE {i+1} =====\n")
    out.append(d[i].get_text())
open('extract_p1-20.txt','w',encoding='utf-8').write(''.join(out))
print('done')
