# -*- coding: utf-8 -*-
"""Esegue i blocchi ```triad del libro con l'interprete di riferimento e confronta
current vs HEAD. Serve a garantire che le modifiche editoriali non abbiano rotto
esempi esistenti.

Uso: python .bookrun.py
"""
import re
import subprocess
import sys
import tempfile
from pathlib import Path

from book_helpers import git_show

ROOT = Path(__file__).resolve().parent
NODE = r"C:\Users\xbos\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\node\bin\node.exe"
INTERP = ROOT / "seed" / "dev" / "triad_core.cjs"
FILES = ["MANUALE.md", "TUTORIAL.md"]

FENCE_OPEN = re.compile(r"^```([A-Za-z0-9_+-]*)\s*$")


def extract(md: str):
    """(lang, body, start_line) per ogni blocco di codice."""
    lines = md.split("\n")
    blocks = []
    i = 0
    while i < len(lines):
        m = FENCE_OPEN.match(lines[i])
        if m:
            lang = m.group(1)
            j = i + 1
            body = []
            while j < len(lines) and not lines[j].startswith("```"):
                body.append(lines[j])
                j += 1
            blocks.append((lang, "\n".join(body), i + 1))
            i = j + 1
            continue
        i += 1
    return blocks


def run_block(body: str):
    with tempfile.NamedTemporaryFile("w", suffix=".triad", delete=False, encoding="utf-8") as f:
        f.write(body + "\n")
        path = f.name
    try:
        p = subprocess.run(
            [NODE, str(INTERP), path],
            capture_output=True, text=True, timeout=15,
            encoding="utf-8", errors="replace",
        )
        return p.returncode, p.stdout, p.stderr
    except subprocess.TimeoutExpired:
        return "timeout", "", ""
    finally:
        Path(path).unlink(missing_ok=True)


def analyze(rel: str, text: str):
    res = {}
    for lang, body, line in extract(text):
        if lang != "triad":
            continue
        key = body.strip()
        if not key:
            continue
        code, out, err = run_block(body)
        res[key] = {"code": code, "out": out, "err": err, "line": line}
    return res


def main():
    rc = 0
    for rel in FILES:
        cur = analyze(rel, (ROOT / rel).read_text(encoding="utf-8"))
        head = analyze(rel, git_show(rel))
        current_only = [k for k in cur if k not in head]
        regressions = []
        for k, v in cur.items():
            if k in head:
                h = head[k]
                if h["code"] == 0 and v["code"] != 0:
                    regressions.append((v["line"], k, v["code"], v["err"].strip().splitlines()[:2]))
        new_bad = [
            (v["line"], k, v["code"], v["err"].strip().splitlines()[:2])
            for k, v in cur.items()
            if k in current_only and v["code"] != 0
        ]
        print(f"=== {rel}: {len(head)} blocchi triad nel HEAD, {len(cur)} ora "
              f"({len(current_only)} nuovi)")
        if regressions:
            rc = 1
            print(f"  REGRESSIONI ({len(regressions)}): esempi che prima giravano e ora no")
            for line, k, code, err in regressions[:12]:
                print(f"    riga {line}: exit {code}: {k.splitlines()[0][:80]!r} {err}")
        if new_bad:
            print(f"  nuovi blocchi non eseguibili ({len(new_bad)}) — possono essere frammenti:")
            for line, k, code, err in new_bad[:15]:
                print(f"    riga {line}: exit {code}: {k.splitlines()[0][:80]!r} {err}")
        if not regressions and not new_bad:
            print("  nessuna regressione e nessun nuovo blocco non eseguibile")
    return rc


if __name__ == "__main__":
    sys.exit(main())
