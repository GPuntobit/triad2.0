#!/usr/bin/env python3
"""Regression: nessun token reale nel working tree e nessun token negli URL git.

Nato dai findings #5/#6 del 2026-11-02 (docs/security/SECURITY-REVIEW.md):
un PAT GitHub era finito in chiaro in `.git-credentials` (root del repository)
e `tools/git-push-with-token.ps1` lo iniettava nell'URL del remote
(`https://<token>@github.com/...`), da cui finiva in `.git/config` e negli
errori di git.

Controlli:
  1. nessun file del working tree (testo o binario, esclusi .git e le
     dipendenze vendored) contiene un token GitHub reale;
  2. `tools/git-push-with-token.ps1` non costruisce URL con token, non fa
     `git remote set-url` e usa il percorso sicuro (`credential.helper`);
  3. `.gitignore` copre `.git-credentials`;
  4. `.git-credentials.example` non istruisce a tenere il credential store
     dentro il repository.

Run with: python3 tests/security/no_live_tokens.test.py
"""
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]

TOKEN = re.compile(
    rb"gh[pousr]_[A-Za-z0-9]{20,}"
    rb"|github_pat_[A-Za-z0-9_]{20,}"
)

SKIP_DIRS = {
    ".git", "node_modules", ".venv", "__pycache__",
    ".delta", ".webcmd", ".kilo", ".kiro", ".mimocode",
}

PUSH_SCRIPT = REPO / "tools" / "git-push-with-token.ps1"
EXAMPLE = REPO / ".git-credentials.example"
GITIGNORE = REPO / ".gitignore"


def iter_worktree_files():
    stack = [REPO]
    while stack:
        d = stack.pop()
        for entry in d.iterdir():
            if entry.is_dir():
                if entry.name in SKIP_DIRS:
                    continue
                stack.append(entry)
            elif entry.is_file():
                yield entry


def main() -> int:
    failures = []

    # 1. nessun token reale nel working tree (byte grezzi: copre anche binari)
    for path in iter_worktree_files():
        data = path.read_bytes()
        m = TOKEN.search(data)
        if m:
            rel = path.relative_to(REPO)
            failures.append(f"live token in {rel}: {m.group(0)[:8].decode('ascii', 'replace')}...")

    # 2. lo script di push non mette il token negli URL e non riscrive il remote
    src = PUSH_SCRIPT.read_text(encoding="utf-8")
    for label, cond in {
        "no `git remote set-url` (token/url rewrite removed)": "set-url" not in src,
        "no token interpolated into a URL": re.search(r"https://[^\"'\s]*\$\{?[Tt]oken", src) is None,
        "safe credential.helper path in use": "credential.helper" in src,
        "git add excludes .git-credentials": ":(exclude).git-credentials" in src,
    }.items():
        if not cond:
            failures.append(f"git-push-with-token.ps1: {label}")

    # 3. .gitignore copre il file credenziali legacy
    gi = GITIGNORE.read_text(encoding="utf-8")
    if not any(ln.strip() == ".git-credentials" for ln in gi.splitlines()):
        failures.append(".gitignore: missing '.git-credentials' entry")

    # 4. il template non istruisce al credential store dentro il repository
    ex = EXAMPLE.read_text(encoding="utf-8")
    if 'store --file=.git-credentials' in ex or 'store --file=".git-credentials"' in ex:
        failures.append(".git-credentials.example: repo-local credential store still instructed")

    if failures:
        for f in failures:
            print(f"FAIL: {f}")
        return 1
    print("PASS: no live tokens in the working tree")
    print("PASS: git-push-with-token.ps1 keeps tokens out of URLs and remotes")
    print("PASS: .gitignore covers .git-credentials")
    print("PASS: .git-credentials.example keeps the credential store outside the repo")
    return 0


if __name__ == "__main__":
    sys.exit(main())
