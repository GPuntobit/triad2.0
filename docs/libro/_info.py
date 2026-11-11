import pymupdf, os
d = pymupdf.open('Il-libro-di-triad.pdf')
print('pages:', d.page_count)
print('meta:', d.metadata)
for i,p in enumerate(d):
    t = p.get_text()
    print('--- page', i+1, 'chars', len(t))
