# -*- coding: utf-8 -*-
"""QA redazionale per 'Il libro di Triad'.

Controlla, per MANUALE.md e TUTORIAL.md:
- blocchi di codice: tutti quelli del HEAD devono ancora esistere identici (multiset);
  sono ammessi nuovi blocchi.
- blocchi di output: quelli del HEAD devono restare identici (multiset); sono ammessi nuovi.
- anchor: ogni link interno "#..." deve puntare a un id presente;
  ogni <a id="cap-*|parte-*|app-*"> di HEAD deve ancora esistere.
- numerazione dei capitoli "## N." e delle parti "# Parte ...".
- occorrenze della parola "wiki".
"""
import re
import sys
from collections import Counter
from pathlib import Path

from book_helpers import git_show

ROOT = Path(r"C:\Users\xbos\Documents\progetti\triad2.0")
FILES = ["MANUALE.md", "TUTORIAL.md"]

FENCE_RE = re.compile(r"^```([A-Za-z0-9_+-]*)\s*$")
OUTPUT_RE = re.compile(r"^\s*(?:\*\*)?Output(?:\s*\(golden Full\))?(?:\*\*)?:?\s*$", re.I)


def parse_blocks(text: str):
    """Ritorna (code_blocks, output_blocks). code_blocks: lista (lang, contenuto normalizzato).
    output_blocks: lista di (contesto, contenuto) dove contesto e' la riga prima di Output."""
    lines = text.split("\n")
    code, outputs = [], []
    i = 0
    while i < len(lines):
        m = FENCE_RE.match(lines[i])
        if m:
            lang = m.group(1)
            body = []
            i += 1
            while i < len(lines) and not lines[i].startswith("```"):
                body.append(lines[i])
                i += 1
            i += 1
            if lang == "" and body and body[0].startswith("text") and len(body) == 1:
                pass
            code.append((lang, "\n".join(body).strip("\n")))
            continue
        i += 1
    for idx, line in enumerate(lines):
        if OUTPUT_RE.match(line):
            # cerca il primo fence ```text dopo la riga Output:
            j = idx + 1
            while j < len(lines) and not lines[j].startswith("```"):
                if lines[j].strip() and j > idx + 3:
                    break
                j += 1
            if j < len(lines) and lines[j].strip() == "```text":
                body = []
                j += 1
                while j < len(lines) and not lines[j].startswith("```"):
                    body.append(lines[j])
                    j += 1
                outputs.append("\n".join(body).strip("\n"))
    return code, outputs


def ids_and_links(text: str):
    ids = set(re.findall(r'<a\s+id="([^"]+)"', text))
    links = set(re.findall(r"\]\(#([^)]+)\)", text))
    return ids, links


def chapter_numbers(text: str):
    nums = [int(n) for n in re.findall(r"^##\s+(\d+)\.\s", text, re.M)]
    parts = re.findall(r"^#\s+Parte\s+([IVX]+)\b", text, re.M)
    apps = re.findall(r"^#\s+Appendice\s+([A-Z])\b", text, re.M)
    return nums, parts, apps


def compare(name, head, cur):
    problems, notes = [], []
    hc, ho = parse_blocks(head)
    cc, co = parse_blocks(cur)

    # I blocchi di codice non testuali (triad, triad-full, sh, cmd, js, ebnf, ecc.)
    def code_key(lang, body):
        return (lang, body)

    h_counter = Counter(code_key(l, b) for l, b in hc)
    c_counter = Counter(code_key(l, b) for l, b in cc)
    missing_code = h_counter - c_counter
    added_code = c_counter - h_counter
    if missing_code:
        problems.append(f"{sum(missing_code.values())} blocchi di codice del HEAD mancanti o modificati")
        for (lang, body), n in list(missing_code.items())[:6]:
            problems.append(f"    [{lang}] {body.splitlines()[0][:90]!r} x{n}")
    if added_code:
        notes.append(f"{sum(added_code.values())} nuovi blocchi di codice")

    h_out, c_out = Counter(ho), Counter(co)
    missing_out = h_out - c_out
    added_out = c_out - h_out
    if missing_out:
        problems.append(f"{sum(missing_out.values())} blocchi di output del HEAD mancanti o modificati")
        for body, n in list(missing_out.items())[:6]:
            problems.append(f"    {body.splitlines()[0][:90]!r} x{n}")
    if added_out:
        notes.append(f"{sum(added_out.values())} nuovi blocchi di output")

    hid, hlinks = ids_and_links(head)
    cid, clinks = ids_and_links(cur)
    lost_ids = hid - cid
    if lost_ids:
        problems.append(f"anchor persi: {sorted(lost_ids)}")
    dangling = sorted(clinks - cid)
    if dangling:
        problems.append(f"link interni senza destinazione: {dangling}")

    hnum, hparts, happs = chapter_numbers(head)
    cnum, cparts, happs2 = chapter_numbers(cur)
    if hnum != cnum:
        problems.append(f"numerazione capitoli cambiata: HEAD {hnum} vs attuale {cnum}")
    if hparts != cparts:
        problems.append(f"parti cambiate: {hparts} -> {cparts}")
    if happs != happs2:
        problems.append(f"appendici cambiate: {happs} -> {happs2}")

    wiki = [i + 1 for i, line in enumerate(cur.split("\n")) if "wiki" in line.lower()]
    if wiki:
        problems.append(f"occorrenze 'wiki' alle righe {wiki}")

    return problems, notes


def main():
    total = 0
    for rel in FILES:
        path = ROOT / rel
        cur = path.read_text(encoding="utf-8")
        head = git_show(rel)
        problems, notes = compare(rel, head, cur)
        print(f"=== {rel}: {len(head.splitlines())} -> {len(cur.splitlines())} righe")
        for n in notes:
            print(f"  nota: {n}")
        for p in problems:
            print(f"  PROBLEMA: {p}")
        total += len(problems)
    if total:
        print(f"\n{total} problemi da valutare")
        return 1
    print("\nOK: struttura, esempi, output, anchor e wiki coerenti con il HEAD")
    return 0


if __name__ == "__main__":
    sys.exit(main())
