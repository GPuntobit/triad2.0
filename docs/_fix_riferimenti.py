#!/usr/bin/env python3
"""Rinumerazioni e correzioni di riferimenti dopo l'estrazione degli esercizi.

Uso: python3 docs/_fix_riferimenti.py [--dry]
"""
import re
import os
import sys

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


def renum(txt, mapping, anchor='', subs=False):
    """Applica una mappa di rinumerazione di capitoli, in ordine crescente."""
    for old, new in mapping:
        txt = txt.replace(f'<a id="{anchor}{old}"></a>', f'<a id="{anchor}{new}"></a>')
        txt = txt.replace(f'(#{anchor}{old})', f'(#{anchor}{new})')
        txt = re.sub(rf'^## {old}\. ', f'## {new}. ', txt, flags=re.M)
        txt = re.sub(rf'^### {old}\. ', f'### {new}. ', txt, flags=re.M)
        if subs:
            txt = re.sub(rf'^### {old}\.(\d)', rf'### {new}.\1', txt, flags=re.M)
        txt = re.sub(rf'\[capitolo {old}\]', f'[capitolo {new}]', txt)
        txt = re.sub(rf'\[{old}\. ', f'[{new}. ', txt)
        txt = re.sub(rf'capitolo {old}(?!\d)', f'capitolo {new}', txt)
        txt = re.sub(rf'cap\. {old}(?!\d)', f'cap. {new}', txt)
    return txt


# ---------------------------------------------------------------- MANUALE

def manuale():
    # il file degli esercizi del manuale: 25..29 -> 23..27
    p = 'MANUALE-ESERCIZI.it.md'
    txt = read(p)
    txt = renum(txt, [(25, 23), (26, 24), (27, 25), (28, 26), (29, 27)], anchor='cap-', subs=True)
    write(p, txt)

    # il manuale: numeri di capitolo e di sezione 25..29 -> 23..27
    p = 'MANUALE.it.md'
    txt = read(p)
    txt = renum(txt, [(25, 23), (26, 24), (27, 25), (28, 26), (29, 27)], anchor='cap-', subs=True)
    write(p, txt)


# -------------------------------------------------------------- FONDAMENTA

def fondamente():
    mapping = [(15, 14), (16, 15), (17, 16), (18, 17)]

    # --- file degli esercizi ------------------------------------------------
    p = 'FONDAMENTA-ESERCIZI.it.md'
    txt = read(p)

    # il capitolo 14 (esercizi generali) diventa una sezione senza numero,
    # collocata in fondo al file
    m = re.search(r'^## 14\. Esercizi\n', txt, flags=re.M)
    assert m, 'capitolo 14 degli esercizi non trovato'
    start = m.start()
    nxt = re.search(r'^## \d+\. ', txt[m.end():], flags=re.M)
    end = m.end() + nxt.start() if nxt else len(txt)
    chapter = txt[start:end].rstrip()
    chapter = re.sub(r'^## 14\. Esercizi$', '## Esercizi generali', chapter, flags=re.M)
    txt = txt[:start].rstrip() + '\n\n' + txt[end:].lstrip('\n')

    txt = renum(txt, mapping)
    txt = txt.rstrip() + '\n\n---\n\n' + chapter + '\n'
    write(p, txt)

    # --- testo principale --------------------------------------------------
    p = 'FONDAMENTA.it.md'
    txt = read(p)
    txt = renum(txt, mapping, anchor='fond-')
    write(p, txt)


if __name__ == '__main__':
    manuale()
    fondamente()
