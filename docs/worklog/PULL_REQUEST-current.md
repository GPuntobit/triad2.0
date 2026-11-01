# Pull Request — riordino cartelle, fix di sicurezza e tooling (lavoro non ancora pubblicato)

**Branch:** `termux-with-triad-7086e` → `main`
**Contenuto:** 8 commit non ancora in `origin/main` (di cui 1 merge; 84 file nel diff complessivo).
**Stato conflitti:** il branch contiene già il merge con `origin/main`; la bozza precedente
("Rigenerata") è archiviata in [`PULL_REQUEST-rigenerata.md`](PULL_REQUEST-rigenerata.md)
(lavoro ormai confluito in `main`).

## Contenuto (diff vs origin/main)

### Riordino cartelle — commit `523f45a` (45 file)

Riordino della struttura senza toccare i percorsi contrattuali (`SPEC*.md`, `BOOTSTRAP.md`,
`conformance/`, `ai/`, `bin/`, `cli/`, `editors/`, `seed/`, `selfhost/`, `VERSION`, `install.sh`).
Principio: documentazione in `docs/`, materiale di test in `tests/`, scaffold legacy in `tools/`.

| Da | A | Motivo |
|---|---|---|
| `probes/` | `tests/probes/` | probe d'esecuzione usati da CI e `install.sh`, accanto a `tests/security/` |
| `tutorial/` | `docs/tutorial/` | tutta la documentazione long-form in `docs/` |
| `wiki/` | `docs/wiki/` | wiki inglese del progetto, idem |
| `SECURITY-REVIEW.md`, `SECURITY-BACKLOG-TRIAGE.md`, `TRIAGE-SEVERITY.md` | `docs/security/` | registro sicurezza raggruppato (`SECURITY.md` resta alla root, convenzione GitHub) |
| `PULL_REQUEST.md` | `docs/worklog/PULL_REQUEST-current.md` | convenzione già fissata in CHANGELOG; bozza precedente archiviata in `PULL_REQUEST-reorg-struttura.md` |
| `_config.yml`, `index.md`, `_includes/`, `assets/` | `tools/site-jekyll/` | scaffold Jekyll orfano: il sito è l'artifact statico di `docs/` (`pages.yml`/`static.yml`) |
| `served.svg`, `served_raw.svg` | `docs/assets/img/` | bozze dell'animazione di anteprima (duplicate di `anteprima-hello.svg`) |
| `server.err` | *(rimosso)* | log di un server locale, committato per errore |

Riferimenti aggiornati uno a uno: `.github/workflows/ci.yml` (3 path probe), `install.sh`,
`scripts/docs/build-libro.mjs`, `scripts/docs/build-epub.cjs`, `tests/security/run.sh`,
`README.md` (Project Structure + link), `docs/MANUALE.md`/`MANUALE.it.md`, `.codacy.yml`,
`.stylelintignore`, `CHANGELOG.md` (voce "Not released — 2026-11-01"), `STATUS.md`.
Link relativi di `docs/wiki/*.md` riscritti per la nuova profondità e verificati (90/90 risolvono).

Fix preesistente incluso: `build-libro.mjs` usava `escapeHtml` senza mai definirla (la build
crashava); aggiunta la definizione. `docs/libro/libro.html` rigenerato: l'artefatto committato
conteneva marcatori di conflitto di merge irrisolti (`<<<<<<< HEAD … >>>>>>>`); il contenuto è
stato verificato completo dopo la rigenerazione.

### Sicurezza — commit `629b39b`

- `fix(security): sanitize example secrets and escape regex input`: segreti di esempio
  sanitizzati e escaping dell'input regex in `.github/skills/` (SKILL.md di api-design,
  docker-patterns, laravel-security, react-native-patterns, security-review, story-lifecycle,
  visa-doc-translate; `ck/commands/init.mjs`, `ck/commands/migrate.mjs`,
  `story-lifecycle/scripts/ledger.js`).

### Tooling agent — commit `795689c`, `0f4d106`

- `videodb/scripts/ws_listener.py`: gestione dei signal handler non supportati dall'event loop;
  propagazione degli errori dei task durante lo shutdown.

### Sito e release — commit `7fd0335`, `ac60ec5`, `92ef53e`, `e5b32b1`

- Grafico download aggiornato (`docs/assets/img/downloads.svg`, `[skip ci]`).
- Bozze release post v0.8.0-beta.8 (EN/IT) in `docs/releases/`.

## Verifiche

- `node conformance/run.mjs` → `conformance: OK` (Triad-Core 37/37); ripetuto anche via
  `node cli/triad-cli.mjs test conformance` → OK.
- `tests/security/run.sh` step 4 (path risolti dalle nuove cartelle) → `PASS: relocated paths resolve`.
- `workflows_pinned.test.py` → PASS (22 action pinnate a SHA completi, `ci.yml` incluso).
- `incomplete_sanitization.test.mjs` → 7/7; `git_path_hijack.test.py` → PASS.
- Link di `docs/wiki/*.md` → 90/90 risolvono (checker automatico sui link relativi).
- `node scripts/docs/build-epub.cjs` e `node scripts/docs/build-libro.mjs` → OK con il percorso
  `docs/tutorial/TUTORIAL.md`; `node --check` / `bash -n` sugli script toccati.

Note d'ambiente (preesistenti, non bloccanti): `windows_where_path.test.js` (0/6) e
`python_isolation.test.py` non girano nell'ambiente Windows locale (temp dir / shim `python3`;
verificato fallire anche sul tree pulito); il profilo Triad-Full resta a 11/12 casi falliti come
da `STATUS.md` (nessuna modifica al linguaggio in questo diff).
