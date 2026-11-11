import json
s=open('libro.html',encoding='utf-8').read()
i=s.find('<h1>Manuale di Triad 2.0</h1>')
json.dump({'source_file':'libro.html','source_offset':i,'output_file':'Il-libro-di-triad.en.html','status':'in_progress','next':'Manual body'}, open('_translation_progress.json','w',encoding='utf-8'))
print(i)
