# Triad 2.0 — v0.8.0-beta.9 (2026-11-07)

**Seed Linux nativo, toolchain senza Node, desktop launcher.**
Elenco completo delle modifiche in [CHANGELOG.md](../../CHANGELOG.md). Sintesi qui sotto.

## Cosa è cambiato

### Added
- **Seed Linux nativo** — `seed-linux-x86_64`: interprete Triad-Core completo in ELF statico
  (senza libc, senza Wine), con **parità byte-esatta** rispetto al PE Windows
  (conformance 39/39 — 38/39 con il gap noto su `liste` — probe 39/39, golden S1 identico).
- **Toolchain senza Node** — `install.sh` (decoder hex sh-puro, verifica anti-drift del
  binario decodificato, smoke test byte-esatto che fa fallire l'installazione su mismatch),
  `bin/triad` (esegue sempre il seed) e la CLI POSIX `bin/triad-cli`
  (`run` / `test` / `status`).
- **Harness di verifica senza Node** — `conformance/run.sh`, `tests/probes/run_probes.sh`,
  `verify.sh` (entry point unico) e `seed/linux-x86_64/check_seed.sh`.
- **Launcher desktop** — `bin/triad-desktop`: sessione POSIX che mantiene output ed errori
  visibili fino a `:quit` o EOF; `install.sh --desktop` registra anche i MIME `.triad` / `.td`,
  così il doppio click apre il file in Triad.
- **Front-end S1** — `selfhost/source.td`: nuovo scanner + root-scan + discesa ricorsiva
  derivati dal codice macchina del seed; stampa l'AST in pre-ordine (byte-identico sul seed
  PE e sull'interprete JS di riferimento).
- **Sito generato da sorgenti Triad** — `tools/site-gen/`: le pagine di `docs/` sono emesse
  da programmi Triad, verificati byte per byte contro l'interprete JS di riferimento.
- **Libro: *Fondamenta*** — `docs/FONDAMENTA.it.md` (programmazione da zero) e ~900 esercizi
  aggiunti ai capitoli conclusi; PDF a 424 pagine, geometria KDP conforme.
- **Governance del repository** — `GLOSSARY.md`, ADR `0001` (immutabilità del dump PE) e
  `0002` (verifica di parità senza rieseguire il PE), issue tracker locale in `.scratch/`.

### Changed
- **CI solo su Linux nativo** (decisione 04): eliminate le gambe Windows; il lato PE resta
  garantito dal gate hash di `seed.hex` e dai golden congelati (ADR 0002).
- **CI ripristinata** — `ci.yml` conteneva uno scalare non quotato con `": "`: GitHub non
  avviava alcun job (riportava solo «this run likely failed because of a workflow file
  issue»). Corretto, più la nuova regressione `tests/security/workflows_yaml.test.py`:
  ogni workflow deve essere YAML valido.
- **Gate di conformità con gap noti espliciti** — `conformance/gate.sh` esegue l'oracle
  `conformance/run.sh` e tollera **solo** i fallimenti già documentati (`liste`, gap N03),
  stampandoli sempre; ogni altro fallimento fa fallire il gate. `verify.sh` e
  `triad-cli test conformance` usano il gate; l'oracle puro resta con
  `triad-cli test conformance --strict`.
- **Golden dei probe e del golden S1 versionati** — `tests/probes/*.expected.out` e
  `selfhost/*.expected.out` erano esclusi da git: in un checkout pulito il harness dei
  probe falliva con «golden mancante» su 23 probe su 39. Ora sono versionati, come i
  golden di `conformance/`.

### Fixed
- **Seed: rimosso il codegen rotto di `xs[i]`** — il tentativo del 6 novembre leggeva il
  campo tipo della lista nel registro che teneva il puntatore (`mov rdx, [rdx]`): la
  lettura falliva con parse error e la scrittura `xs[i] = v` terminava con **SIGSEGV**.
  Il codegen torna allo stato documentato (il gap N03 resta aperto: `xs[i]` 1-based non è
  implementato nel seed) e i dump PE/ELF tornano coincidere con i gate hash della CI
  (PE `4235a707…`, ELF `0e121db8…`); il binario PE committato non cambia (`631f401f…`).
- **Generatore del seed** — entry point unico `gen_seed.js <windows|linux|all>`: core del
  codegen condiviso + `backend_pe` / `backend_elf`; il confine `os_*` isola le chiamate di
  sistema. Il dump PE rigenerato resta byte-identico.
- **Interprete JS di riferimento** — `seed/dev/triad_core.cjs` riallineato al seed
  (`get(xs, i)` 0-based, newline grezzi nelle stringhe, ternario con `:` attaccato).

### Security
- **Credential-storage hardening** — il PAT GitHub in chiaro presente nella working tree è
  stato rimosso e il token non è più nell'URL del remote `origin`; il tooling di push usa
  una `credential.helper` temporanea alimentata dall'ambiente. Nuovo test di regressione
  `tests/security/no_live_tokens.test.py`.

## Problemi noti

- Il caso di conformance `liste` fallisce ancora sul seed (**38/39** verdi): il gap storico
  è registrato dall'harness (exit 1, stdout vuoto) e il gate `conformance/gate.sh` lo
  esclude in modo esplicito e rumoroso. I probe sono **39/39**. Nessun golden è stato
  riscritto per mascherare il gap.
- Il launcher GUI per Windows (`TriadDesktop.exe`) **non** è pubblicato in questa release:
  punta ancora alla CLI Node pre-beta.9 (`status` / `test`), sostituita dalla CLI POSIX
  `bin/triad-cli`. Va portato e ricostruito su Windows (`cli/windows-gui/build.ps1`).

## Download

| Asset | Piattaforma | Dimensione | SHA-256 |
|---|---|---|---|
| `seed.exe` | Runtime Windows x86-64 (PE) | 25 KB | `631f401ffe42f5f748bb92ab80c2886a7d68f9e00b09bd8dfde2de0c671fe219` |
| `seed-linux-x86_64` | Runtime Linux x86-64 (ELF statico, senza libc) | 8,3 KB | `c8c82bc9c77c69e603e07ab7287065076e04c8139a57ae3ee454a472cee2a0ce` |
| `triad-cli` | CLI dev standalone Linux x86-64 (Node SEA) | 119 MB | `337c5188ee5cfef7d50256f5b03ab510b47dedf15aac6aa14256e1bf2ebe9cb2` |
| `triad-cli.exe` | CLI dev standalone Windows x86-64 (Node SEA) | 83 MB | `d7ab6e05a538a7f1ffd571014c91c7f5029e6b21855e9db0843e15acabb06d5e` |

**Percorso zero-install**: clona il repository ed esegui `./install.sh` — non servono Node.js,
runtime o Wine; su Linux il seed gira nativamente.

**Changelog completo**: https://github.com/GPuntobit/triad2.0/compare/v0.8.0-beta.8...v0.8.0-beta.9
