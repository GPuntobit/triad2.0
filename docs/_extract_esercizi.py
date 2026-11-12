#!/usr/bin/env python3
"""Estrae le sezioni di esercizi da MANUALE.it.md e FONDAMENTA.it.md in file separati.

Uso: python3 docs/_extract_esercizi.py [--dry]
Lo script riscrive MANUALE.it.md / FONDAMENTA.it.md (senza esercizi) e crea
MANUALE-ESERCIZI.it.md / FONDAMENTA-ESERCIZI.it.md.
"""
import re
import sys
import os

DOCS = os.path.dirname(os.path.abspath(__file__))
DRY = '--dry' in sys.argv


def read(p):
    with open(os.path.join(DOCS, p), encoding='utf-8') as f:
        return f.read()


def write(p, s):
    s = re.sub(r'\n{3,}', '\n\n', s)
    s = '\n'.join(l.rstrip() for l in s.split('\n'))
    if not DRY:
        with open(os.path.join(DOCS, p), 'w', encoding='utf-8') as f:
            f.write(s)


# ---------------------------------------------------------------- generico

def heading_blocks(lines):
    """Elenco di (start, end, level, title) per ogni heading."""
    idx = [i for i, l in enumerate(lines) if re.match(r'^#{1,6} ', l)]
    out = []
    for k, i in enumerate(idx):
        level = len(lines[i]) - len(lines[i].lstrip('#'))
        title = lines[i][level:].strip()
        end = idx[k + 1] if k + 1 < len(idx) else len(lines)
        out.append((i, end, level, title))
    return out


def trim_trailing_blank(lines, start, end):
    while end > start and lines[end - 1].strip() == '':
        end -= 1
    return end


def trim_separator(lines, start, end):
    """Accorcia il blocco per non swalloware il separatore `---` e l'ancor
    `<a id="...">` che chiudono il capitolo."""
    while end > start:
        t = lines[end - 1].strip()
        if t == '' or t == '---' or re.fullmatch(r'<a id="[^"]+"></a>', t):
            end -= 1
            continue
        break
    return end


def demote(lines, start, end):
    """Sposta di un livello gli heading del blocco."""
    return ['#' + l if re.match(r'^#{1,5} ', l) else l for l in lines[start:end]]


def chapter_of(lines, idx):
    for i in range(idx, -1, -1):
        m = re.match(r'^## (\d+)\. (.+)$', lines[i])
        if m:
            return int(m.group(1)), m.group(2)
    return None, None


def anchor_before(lines, idx):
    """Indice della riga <a id="..."> immediatamente prima di idx (se c'è)."""
    j = idx - 1
    while j >= 0 and lines[j].strip() == '':
        j -= 1
    if j >= 0 and re.fullmatch(r'<a id="[^"]+"></a>', lines[j].strip()):
        return j
    return None


def sep_before(lines, idx):
    """Indice della riga '---' che precede idx (se c'è)."""
    j = idx - 1
    while j >= 0 and lines[j].strip() == '':
        j -= 1
    if j >= 0 and lines[j].strip() == '---':
        return j
    return None


# ---------------------------------------------------------------- MANUALE

def manuale():
    lines = read('MANUALE.it.md').split('\n')
    blocks = heading_blocks(lines)

    ex_blocks = []          # (start, end, title)
    parte2 = None           # (start, end) della Parte II
    for start, end, level, title in blocks:
        if level == 3 and re.fullmatch(r'(?:\d+\.\d+ )?Esercizi(?: sul lessico)?', title):
            ex_blocks.append((start, end, title))
        elif level == 1 and title == 'Parte II — Esercizi':
            parte2 = (start, end)
    assert parte2, 'Parte II non trovata'

    # --- costruiscono il file degli esercizi -------------------------------
    per_cap = {}
    order = []
    for start, end, title in ex_blocks:
        cap_no, cap_title = chapter_of(lines, start)
        if cap_no is None:
            continue
        e = trim_separator(lines, start, trim_trailing_blank(lines, start, end))
        per_cap.setdefault(cap_no, (cap_title, []))[1].append((start, e, title))
        if cap_no not in order:
            order.append(cap_no)

    out = []
    out.append('# Esercizi — Manuale di Triad 2.0')
    out.append('')
    out.append('> Gli esercizi del [Manuale di Triad 2.0](MANUALE.it.md), raccolti in un file')
    out.append('> separato per non appesantire il testo del manuale. I rimandi a «cap. N»')
    out.append('> e a «cap. N.M» indicano i capitoli e le sezioni del manuale.')
    out.append('')
    out.append('## Esercizi per capitolo')
    out.append('')

    for cap_no in order:
        if cap_no >= 25:          # i capitoli di riferimento vanno in coda
            continue
        cap_title, blks = per_cap[cap_no]
        out.append(f'### {cap_no}. {cap_title}')
        out.append('')
        for start, end, title in blks:
            body = demote(lines, start, end)
            if title.endswith('Esercizi sul lessico'):
                body[0] = '#### Esercizi'
            out.extend(body)
            out.append('')

    # Parte II: esercizi guidati (Core) e su Triad-Full, con le soluzioni
    p2_start = parte2[0]
    p2_end = next(s for s, e, l, t in blocks if s > p2_start and l == 1)
    p2 = lines[p2_start:trim_trailing_blank(lines, p2_start, p2_end)]
    # rimuove gli ancor duplicati: le sezioni esercizi non sono numerate
    p2 = [l for l in p2 if not re.fullmatch(r'<a id="[^"]+"></a>', l.strip())]
    assert p2[0] == '# Parte II — Esercizi'
    p2 = p2[1:]
    while p2 and p2[0].strip() == '':
        p2.pop(0)
    p2 = [l.replace('## 23. Esercizi guidati (Triad-Core)', '## Esercizi guidati (Triad-Core)')
           .replace('## 24. Esercizi su Triad-Full', '## Esercizi su Triad-Full')
          for l in p2]
    out.append('---')
    out.append('')
    out.extend(p2)
    out.append('')

    # esercizi dei capitoli di riferimento (25..29 nel manuale originale)
    ref_caps = sorted(c for c in per_cap if c >= 25)
    out.append('---')
    out.append('')
    out.append('## Esercizi di riferimento')
    out.append('')
    for cap_no in ref_caps:
        cap_title, blks = per_cap[cap_no]
        out.append(f'### {cap_no}. {cap_title}')
        out.append('')
        for start, end, title in blks:
            out.extend(demote(lines, start, end))
            out.append('')

    write('MANUALE-ESERCIZI.it.md', '\n'.join(out).rstrip() + '\n')


    # --- nuova versione del manuale ---------------------------------------
    remove = set()
    for start, end, _t in ex_blocks:
        e = trim_separator(lines, start, trim_trailing_blank(lines, start, end))
        for i in range(start, e):
            remove.add(i)

    # Parte II: rimuove l'ancor duplicato, il contenuto e il separatore finale
    a = anchor_before(lines, p2_start)
    end_anchor = None
    for i in range(p2_start, p2_end):
        if lines[i].strip() == '<a id="parte-3"></a>':
            end_anchor = i
            break
    assert end_anchor is not None, 'ancor parte-3 non trovato'
    sep = sep_before(lines, end_anchor)
    start = a if a is not None else p2_start
    for i in range(start, (sep if sep is not None else end_anchor) + 1):
        remove.add(i)

    new = [l for i, l in enumerate(lines) if i not in remove]
    txt = '\n'.join(new)

    # rimuove eventuali righe vuote multiple e spazi finali
    txt = re.sub(r'\n{3,}', '\n\n', txt)
    txt = '\n'.join(l.rstrip() for l in txt.split('\n'))

    # --- nuova versione del manuale ---------------------------------------

    write('MANUALE.it.md', txt)
    print(f'MANUALE: rimossi {len(ex_blocks)} blocchi esercizi + Parte II '
          f'({p2_end - p2_start} righe)')


# ---------------------------------------------------------------- FONDAMENTA

def fondamente():
    lines = read('FONDAMENTA.it.md').split('\n')
    blocks = heading_blocks(lines)

    ex_blocks = []
    for start, end, level, title in blocks:
        if level == 3 and re.fullmatch(
                r'(?:\d+\.\d+ )?(?:Esercizi(?: per sottogenere)?|Soluzioni)', title):
            ex_blocks.append((start, end, title))

    per_cap = {}
    order = []
    for start, end, title in ex_blocks:
        cap_no, cap_title = chapter_of(lines, start)
        if cap_no is None:
            continue
        e = trim_separator(lines, start, trim_trailing_blank(lines, start, end))
        body_start = start
        if title.endswith('Esercizi per sottogenere'):
            # la lista esercizi parte dalla prima etichetta di categoria
            first = None
            for i in range(start, e):
                if re.match(r'^\d+\. ', lines[i]):
                    first = i
                    break
            if first is not None:
                j = first
                while j > start and lines[j - 1].strip() == '':
                    j -= 1
                if j > start and re.match(r'^\*\*[^*]+\*\*$', lines[j - 1].strip()):
                    j -= 1
                body_start = j
        per_cap.setdefault(cap_no, (cap_title, []))[1].append((body_start, e, title))
        if cap_no not in order:
            order.append(cap_no)

    # il capitolo 14 è interamente dedicato agli esercizi: si sposta per intero
    ch14 = None
    for i, l in enumerate(lines):
        if l == '## 14. Esercizi':
            ch14 = i
            break
    assert ch14 is not None
    ch14_end = next(s for s, e, l, t in blocks if s > ch14 and l == 2)

    out = []
    out.append('# Esercizi — Fondamenta: programmare da zero con Triad')
    out.append('')
    out.append('> Gli esercizi delle [Fondamenta](FONDAMENTA.it.md), con le soluzioni, in un')
    out.append('> file separato. I rimandi a «capitolo N» indicano i capitoli delle')
    out.append('> Fondamenta; quelli al «Manuale» indicano il')
    out.append('> [Manuale di Triad 2.0](MANUALE.it.md).')
    out.append('')

    for cap_no in order:
        cap_title, blks = per_cap[cap_no]
        if cap_no == 14:
            body = lines[ch14:trim_trailing_blank(lines, ch14, ch14_end)]
            # l'ancor del capitolo successivo non segue gli esercizi
            body = [l for l in body if not re.fullmatch(r'<a id="[^"]+"></a>', l.strip())]
            out.extend(body)
            out.append('')
            continue
        out.append(f'## {cap_no}. {cap_title}')
        out.append('')
        for start, end, title in blks:
            if title.endswith('Esercizi per sottogenere'):
                # l'introduzione e la tabella dei sottogeneri restano nel capitolo:
                # si estrae solo la lista numerata
                out.append('### Esercizi per sottogenere')
                out.append('')
                out.extend(lines[start:end])
                out.append('')
            elif title.endswith('Soluzioni'):
                out.append('### Soluzioni')
                out.append('')
                out.extend(lines[start + 1:end])
                out.append('')
            else:
                out.extend(lines[start:end])
                out.append('')

    write('FONDAMENTA-ESERCIZI.it.md', '\n'.join(out).rstrip() + '\n')

    remove = set()
    for start, end, title in ex_blocks:
        if title.endswith('Esercizi per sottogenere'):
            first = None
            for i in range(start, end):
                if re.match(r'^\d+\. ', lines[i]):
                    first = i
                    break
            if first is None:
                continue
            j = first
            while j > start and lines[j - 1].strip() == '':
                j -= 1
            if j > start and re.match(r'^\*\*[^*]+\*\*$', lines[j - 1].strip()):
                j -= 1
            e2 = trim_trailing_blank(lines, j, end)
            for i in range(j, e2):
                remove.add(i)
            continue
        e = trim_separator(lines, start, trim_trailing_blank(lines, start, end))
        for i in range(start, e):
            remove.add(i)

    # capitolo 14: rimosso per intero, con l'ancor e il separatore finale
    a = anchor_before(lines, ch14)
    nxt = next(s for s, e, l, t in blocks if s > ch14 and l == 2)
    sep = None
    for i in range(ch14, nxt):
        if lines[i].strip() == '---':
            sep = i
    start = a if a is not None else ch14
    for i in range(start, (sep if sep is not None else nxt) + 1):
        remove.add(i)

    new = [l for i, l in enumerate(lines) if i not in remove]
    txt = '\n'.join(new)
    txt = re.sub(r'\n{3,}', '\n\n', txt)
    txt = '\n'.join(l.rstrip() for l in txt.split('\n'))
    write('FONDAMENTA.it.md', txt)
    print(f'FONDAMENTA: rimossi {len(ex_blocks)} blocchi esercizi + capitolo 14')


if __name__ == '__main__':
    manuale()
    fondamente()
