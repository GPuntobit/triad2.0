#!/usr/bin/env python3
"""Ripulisce la copia wiki del confronto linguaggi (stessa pulizia di docs/).

Uso: python3 docs/_cleanup_wiki.py [--dry]
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DRY = '--dry' in sys.argv

TARGETS = [
    'obsidian-triad/wiki-content/Doc-confronto-linguaggi.md',
    'obsidian-triad/github-wiki/Doc-confronto-linguaggi.md',
]

EDITS = [
    # la regola applicata diventa parte della sezione 1
    ("""Regola applicata: basare ogni valore su ciò che il documento e il codice dicono effettivamente; se un confronto non è sostenibile, lasciare il campo vuoto e indicarne il motivo.

## 1. Base dell'analisi

**Cosa ha fornito Graphify.**""",
     """## 1. Base dell'analisi

**Regola applicata.** Ogni valore qui sotto è basato su ciò che il documento e il codice dicono effettivamente; se un confronto non è sostenibile il campo resta vuoto e ne è indicato il motivo.

**Cosa ha fornito Graphify.**"""),
    # riferimento a un file che non esiste più
    ("""non certifica la correttezza semantica, la copertura dei test o l'assenza di bug (vedi `TASKS.md`).""",
     """non certifica la correttezza semantica, la copertura dei test o l'assenza di bug (vedi `TASK.md`)."""),
    # marcatori del kit: restano i nomi delle sezioni, non le etichette dell'analisi
    ("## 2. Sintesi comparativa (ANCÒRA)", "## 2. Sintesi comparativa"),
    ("## 3. Tabella (ANCÒRA + RADAR)", "## 3. Tabella comparativa"),
    ("## 4. Voci inferite (RADAR)", "## 4. Voci inferite"),
    ("## 5. Cosa non è stato affermato (PENALITÀ)", "## 5. Cosa non è stato affermato"),
    ("## 6. SPECCHIO — campi problematici", "## 6. Campi problematici"),
    # conteggio del grafo: `TASKS.md` non esiste più
    ("""| Conteggio del grafo | No | Sì: 648/1.497/21 ora vs 649/1.494/21 in `TASKS.md` | Sì | **Alto** | `TASKS.md` descrive l'indice a `b4fb8ae`; quello corrente è a `98e3fdb` |
""", ""),
    # numero dei test
    ("""`Triad \\| 261 261 44.1s` — exit 0""", """`Triad \\| 261/261 \\| 44.1s` — exit 0"""),
    # sezioni morte: TODO su documenti inesistenti e credenziali di accesso
    ("""
## 8. Documenti da aggiornare (segnalati, non modificati)

- `PROMPT_JEV.md`: dichiara «243 test, tutti verdi (243/243)», ma a `98e3fdb` la suite è a **261/261**.
- `TASKS.md`: riporta 649 nodi / 1.494 relazioni / 21 comunità (indice a `b4fb8ae`); l'indice corrente è **648 / 1.497 / 21**.

## 9. Accesso a Graphify

- Server MCP: `https://api.graphify.com/v1/mcp` con header `Authorization: Bearer gfy_mcp_…` (Workspace API Token, valido solo per l'MCP: la REST `api.graphify.com/v1/*` risponde 401).
- Workspace: `gpuntobit-01-s-workspace`, tenant `a3bccac0-3ea8-49ce-8114-bf5b8fbadb11`.
- Il token è pinnato al workspace e non può cambiarlo (`workspace_pinned`).
- `GPuntobit/triad2.1` **non** è indicizzato: la GitHub App è collegata solo all'installazione dell'organizzazione `SEIS0-official`. Poiché `98e3fdb` è anche `main` di `SEIS0-official/triad2.0`, l'indice contiene lo stesso codice di `triad2.1`. Per indicizzare il fork serve agganciare l'installazione personale al tenant (flusso `link/start` + OAuth GitHub avviato dalla sessione del browser).
""", "\n"),
]

if __name__ == '__main__':
    for rel in TARGETS:
        path = os.path.join(ROOT, rel)
        with open(path, encoding='utf-8', newline='') as f:
            txt = f.read()
        crlf = '\r\n' in txt
        txt = txt.replace('\r\n', '\n')
        for old, new in EDITS:
            if old not in txt:
                raise SystemExit(f'{rel}: frammento non trovato:\n{old[:120]!r}')
            txt = txt.replace(old, new, 1)
        txt = re.sub(r'\n{3,}', '\n\n', txt)
        if crlf:
            txt = txt.replace('\r\n', '\n').replace('\n', '\r\n')
        if not DRY:
            with open(path, 'w', encoding='utf-8', newline='') as f:
                f.write(txt)
        print(f'{rel}: {len(EDITS)} modifiche')
