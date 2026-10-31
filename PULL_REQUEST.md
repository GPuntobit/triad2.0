# Pull Request — Rigenerata: tutto il lavoro non ancora pubblicato

**Branch:** `qwen-code-25b29def-032d-42a2-9df2-e2fd8967086e` → `main`
**Stato conflitti:** risolti (merge commit con `origin/main` all'HEAD remoto `b6e97a9`). Il branch si mergea pulito.

## Contenuto (diff vs origin/main)

### Sicurezza
- Hardening `%SystemRoot`/where.exe in `.github/ecc/scripts/lib/utils.js`: path di sistema validato (assoluto, `<drive>:\windows`) o fallback fisso `C:\WINDOWS\System32`; mai un eseguibile controllato dal repo.
- Risoluzione fidata di `git` prima di `subprocess.run` in `scripts/docs/download_chart.py` (path canonici hardcoded + validazione realpath/assoluto/fuori-repo; lista argomenti, shell=False, cwd repo, fallback invariati).
- Guard ReDoS nel parsing tag (`_is_safe_tag_line`, tempo lineare) e suite adversarial.
- Fix CodeQL "incomplete multi-character sanitization": loop a punto fisso in `_evolved_description()` (instinct-cli.py), scanner lineare per lo stripping dei tag HTML nei titoli del libro (build-libro.mjs) e heading matcher ReDoS-safe (niente più regex a quantificatori annidati).
- Suite ripetibile `tests/security/run.sh` (PATH-hijack Windows simulato, shadowing Python, verifica pin SHA via API GitHub, risoluzione script spostati, output chart). ALL PASSED.

### CI/CD
- Tutte le action pinnate a SHA completi (40 hex) con commento del tag.
- Runner Linux pinnati a `ubuntu-24.04` (migrazione ubuntu-latest→26 del 19/10/2026).
- Workflow CodeQL dedicato (C# + JS/TS + Python) con csproj SDK-style per la risoluzione dei tipi WinForms.
- Un solo workflow Pages (static.yml duplicato eliminato) che rigenera la pagina Triad-authored a ogni deploy.
- Fix checkout CI (gitlink orfano obsidian-triad/github-wiki).
- Baseline Codacy sincronizzata con main.

### Riordino repository
- Tre passaggi di riordino con `git mv`: probe/, docs/releases/, tools/, scripts/{docs,seed-runner,experiments}, tutorial/ consolidato; bozze in docs/worklog/. Percorsi contrattuali invariati.

### Documentazione & sito
- Wiki inglese completa (10 pagine, `wiki/`).
- Tutorial russo (`TUTORIAL-RU.md`).
- Sezione Termux nel README (fallback Node.js).
- Sito generato con Triad: `tools/site-gen/generate_site_core.td` → `docs/pages/generated.html` (code-as-data applicato al deploy).
- Release notes v0.8.0-beta.7 EN/IT con tabella download e SHA-256 degli asset.

### Esecuzione
- Modalità dirette: `triad file.td|file.triad` via launcher e `node --require ./seed/dev/triad_core.cjs file.td` (loader Node upstream mantenuto).

## Verifiche post-merge
- `node conformance/run.mjs` → conformance: OK (37/37)
- `bash tests/security/run.sh` → ALL SECURITY VERIFICATIONS PASSED
- `node --check` / `bash -n` sugli script toccati; YAML validati; sito presente e rigenerabile byte-identico.
