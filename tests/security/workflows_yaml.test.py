#!/usr/bin/env python3
"""Verifica: ogni workflow GitHub Actions e' YAML valido (il runner non deve fallire).

Regressione: `ci.yml` conteneva `- name: Verify (harness senza Node: conformance ...)`,
uno scalare plain non quotato con ": " -> YAML non valido. GitHub segnalava
"this run likely failed because of a workflow file issue" e non eseguiva alcun job,
lasciando la CI rossa senza che nessun log lo mostrasse.

Il controllo usa PyYAML quando disponibile; altrimenti ripiega su un euristica che
 Individua gli scalari non quotati contenenti ": ".
"""
import re
import sys
from pathlib import Path

WF_DIR = Path(__file__).resolve().parents[2] / ".github" / "workflows"
workflows = sorted(WF_DIR.glob("*.yml")) + sorted(WF_DIR.glob("*.yaml"))

failures = []

try:
    import yaml  # type: ignore

    for wf in workflows:
        try:
            yaml.safe_load(wf.read_text(encoding="utf-8"))
        except Exception as exc:  # noqa: BLE001 - il messaggio ci serve nel report
            failures.append(f"{wf.name}: YAML non valido: {exc}")
except ImportError:
    # Fallback: uno scalare plain non quotato non puo' contenere ": ".
    scalar = re.compile(r"^\s*(?:-\s*)?(?:name|id|run|body|title):\s+(.+?)\s*$")
    for wf in workflows:
        for lineno, line in enumerate(wf.read_text(encoding="utf-8").splitlines(), 1):
            m = scalar.match(line)
            if not m:
                continue
            value = m.group(1)
            if value[0] in "\"'|>" or ": " not in value:
                continue
            failures.append(f"{wf.name}:{lineno} scalare non quotato con ': ' -> {value}")

for f in failures:
    print(f"FAIL {f}")
print(f"checked {len(workflows)} workflow files; " + ("FAIL" if failures else "PASS: all workflow files are valid YAML"))
sys.exit(1 if failures else 0)
