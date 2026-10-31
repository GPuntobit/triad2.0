#!/usr/bin/env python3
"""Regression test (Codacy suggestion): a repository-controlled git executable
must never be invoked by load_releases_from_tags()/resolve_git_path().

Run with: python3 tests/security/git_path_hijack.test.py
"""
import os
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
SCRIPT = REPO / "scripts" / "docs" / "download_chart.py"
sys.path.insert(0, str(REPO / "scripts"))
import docs.download_chart as dc  # noqa: E402


def main() -> int:
    failures = []

    src = SCRIPT.read_text(encoding="utf-8")
    for label, cond in {
        "shell=False explicit": "shell=False" in src,
        "OSError handled": "OSError" in src,
        "FileNotFoundError handled": "FileNotFoundError" in src,
        "cwd pinned to repo root": "cwd=repo_root" in src,
    }.items():
        if not cond:
            failures.append(label)

    resolved = dc.resolve_git_path(REPO)
    if resolved is not None:
        try:
            Path(resolved).resolve().relative_to(REPO.resolve())
            failures.append("resolve_git_path returned a path inside the repository")
        except ValueError:
            pass
        if not os.path.isabs(resolved):
            failures.append("resolve_git_path returned a non-absolute path")

    old_path = os.environ.get("PATH")
    os.environ["PATH"] = str(REPO)
    try:
        resolved2 = dc.resolve_git_path(REPO)
        if resolved2 is not None:
            try:
                Path(resolved2).resolve().relative_to(REPO.resolve())
                failures.append("PATH hijack via repository root succeeded")
            except ValueError:
                pass
    finally:
        if old_path is None:
            os.environ.pop("PATH", None)
        else:
            os.environ["PATH"] = old_path

    print("FAIL: " + "; ".join(failures) if failures else "PASS: repository-controlled git is never invoked")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
PY