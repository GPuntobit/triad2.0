#!/usr/bin/env python3
"""Verifica: ogni riferimento action nei workflow usa un commit SHA completo (40 hex)."""
import re
import sys
from pathlib import Path

WF_DIR = Path(__file__).resolve().parents[2] / ".github" / "workflows"
pattern = re.compile(r"^\s*(?:-\s*)?uses:\s*([^@\s]+)@(\S+)")
failures = []
total = 0
for wf in sorted(WF_DIR.glob("*.yml")) + sorted(WF_DIR.glob("*.yaml")):
    for lineno, line in enumerate(wf.read_text(encoding="utf-8").splitlines(), 1):
        m = pattern.match(line)
        if not m:
            continue
        total += 1
        owner_repo, ref = m.group(1), m.group(2)
        if ref == ".":  # action locale nel repo
            continue
        if not re.fullmatch(r"[0-9a-f]{40}", ref):
            failures.append(f"{wf.name}:{lineno} {owner_repo}@{ref} non e un SHA a 40 caratteri")
print(f"checked {total} uses: refs; " + ("FAIL:\n" + "\n".join(failures) if failures else "PASS: all pinned to full commit SHAs"))
sys.exit(1 if failures else 0)
