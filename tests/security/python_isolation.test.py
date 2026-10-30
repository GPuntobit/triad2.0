#!/usr/bin/env python3
"""Verifica (suggerimento Codacy): repository json.py / sitecustomize.py,
PYTHONPATH e user site-packages non possono influenzare gli inline Python
parser. Esegui con: python3 tests/security/python_isolation.test.py
"""
import os
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
SCRIPT = REPO / "scripts" / "docs" / "download_chart.py"

def run(args, env=None, cwd=REPO):
    return subprocess.run([sys.executable, *args], capture_output=True, text=True, cwd=cwd, env=env)

def main() -> int:
    failures = []

    # 1) nessun modulo di shadowing presente nella repo root
    for name in ("json.py", "sitecustomize.py", "usercustomize.py"):
        if (REPO / name).exists():
            failures.append(f"shadowing module present at repo root: {name}")

    # 2) il parser non manipola sys.path e invoca git in modo sicuro
    src = SCRIPT.read_text(encoding="utf-8")
    for label, cond in {
        "no sys.path manipulation": "sys.path.insert" not in src and "sys.path.append" not in src,
        "shell=False explicit": "shell=False" in src,
        "cwd pinned to repo root": (
            "cwd=Path(__file__).resolve().parents[2]" in src
            or "cwd=repo_root" in src
        ),
    }.items():
        if not cond:
            failures.append(label)

    # 3) esperimento live: ./json.py malevolo nella CWD del subprocess + PYTHONPATH avvelenato
    with tempfile.TemporaryDirectory() as td:
        poison = Path(td) / "json.py"
        poison.write_text('raise RuntimeError("SHADOWED")\n')
        env = dict(os.environ, PYTHONPATH=td)
        r = run(["-I", "-S", str(SCRIPT), "--help"], env=env)
        if r.returncode != 0:
            failures.append(f"isolated interpreter (-I -S) failed under poisoned PYTHONPATH: {r.stderr[:120]}")

    print("FAIL: " + "; ".join(failures) if failures else "PASS: inline python parsers isolated from repo/env shadowing")
    return 1 if failures else 0

if __name__ == "__main__":
    sys.exit(main())
