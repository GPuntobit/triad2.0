# -*- coding: utf-8 -*-
"""Esegue i blocchi ```triad del libro con l'interprete di riferimento e confronta
current vs HEAD. Serve a garantire che le modifiche editoriali non abbiano rotto
esempi esistenti. I blocchi sono codice eseguibile: dopo aver verificato il
contenuto del checkout, abilitarne l'esecuzione con --execute-docs.

Uso: python .bookrun.py --execute-docs --node <node.exe> --git <git.exe>
"""
import argparse
import re
import subprocess  # nosec B404
import sys
import tempfile
from pathlib import Path

from book_helpers import approved_executable, git_show

ROOT = Path(__file__).resolve().parent
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


def repo_file(path: Path) -> Path:
    resolved = path.resolve(strict=True)
    try:
        resolved.relative_to(ROOT)
    except ValueError as error:
        raise ValueError(f"Refusing to use a path outside the repository: {path}") from error
    if not resolved.is_file():
        raise ValueError(f"Expected a repository file: {path}")
    return resolved


def approved_node(value: str) -> Path:
    return approved_executable(value, {"node", "node.exe"})


def approved_git(value: str) -> Path:
    return approved_executable(value, {"git", "git.exe"})


def run_block(body: str, node: Path, interpreter: Path):
    with tempfile.NamedTemporaryFile("w", suffix=".triad", delete=False, encoding="utf-8") as f:
        f.write(body + "\n")
        path = f.name
    try:
        # Intentional execution: enabled only by explicit opt-in; node and interpreter are validated.
        # nosemgrep: python.lang.security.audit.dangerous-subprocess-use-audit.dangerous-subprocess-use-audit
        p = subprocess.run(  # nosec B603
            [str(node), str(interpreter), path],
            capture_output=True, text=True, timeout=15,
            encoding="utf-8", errors="replace",
            cwd=ROOT,
        )
        return p.returncode, p.stdout, p.stderr
    except subprocess.TimeoutExpired:
        return "timeout", "", ""
    except OSError as error:
        raise RuntimeError(f"Unable to run the approved Node.js executable: {error}") from error
    finally:
        Path(path).unlink(missing_ok=True)


def analyze(rel: str, text: str, node: Path, interpreter: Path):
    res = {}
    for lang, body, line in extract(text):
        if lang != "triad":
            continue
        key = body.strip()
        if not key:
            continue
        code, out, err = run_block(body, node, interpreter)
        res[key] = {"code": code, "out": out, "err": err, "line": line}
    return res


def execution_tools(argv):
    parser = argparse.ArgumentParser(description="Compare executable Triad examples in the book against HEAD.")
    parser.add_argument(
        "--execute-docs",
        action="store_true",
        help="execute Triad blocks in the current documentation (review the checkout first)",
    )
    parser.add_argument(
        "--node",
        help="absolute path to the approved Node.js executable",
    )
    parser.add_argument(
        "--git",
        help="absolute path to the approved Git executable",
    )
    args = parser.parse_args(argv)
    if not args.execute_docs:
        parser.error(
            "execution is disabled by default; review the checkout and pass "
            "--execute-docs --node <absolute-node-path> --git <absolute-git-path>"
        )
    if not args.node:
        parser.error("--node must specify the approved absolute path to Node.js")
    if not args.git:
        parser.error("--git must specify the approved absolute path to Git")

    try:
        node = approved_node(args.node)
        git = approved_git(args.git)
    except (OSError, ValueError) as error:
        parser.error(str(error))
    return node, git


def main(argv=None):
    node, git = execution_tools(argv)
    interpreter = repo_file(INTERP)
    rc = 0
    for rel in FILES:
        doc_path = repo_file(ROOT / rel)
        cur = analyze(rel, doc_path.read_text(encoding="utf-8"), node, interpreter)
        head = analyze(rel, git_show(rel, git), node, interpreter)
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
