import json

with open('libro.html', encoding='utf-8') as source:
    s = source.read()

i = s.find('<h1>Manuale di Triad 2.0</h1>')
with open('_translation_progress.json', 'w', encoding='utf-8') as target:
    json.dump({'source_file': 'libro.html', 'source_offset': i, 'output_file': 'Il-libro-di-triad.en.html', 'status': 'in_progress', 'next': 'Manual body'}, target)
print(i)
