# Triad 2.0: zero JavaScript source policy and removal plan

**Owner objective:** The Triad repository, not just the end-user runtime, shall
contain **no JavaScript/TypeScript source**, browser JS, Node/npm development
entry points, or vendored JavaScript plugins. Triad must remain independently
executable with its existing native S0/S1 machine-code bootstrap. This policy
applies to the checked-out tree after the migration is merged, not to historical
Git commits (whose history is intentionally preserved).

## Stato attuale del repository

La scansione dell'albero Git `main` del 9 novembre 2026 mostra:
- **0 file sorgente** con estensioni `.js`, `.cjs`, `.mjs`,
  `.jsx`, `.ts`, `.tsx`, `.mts`, `.cts`.
- **0 manifest npm** o lockfile npm/yarn/pnpm.
- **0 archivi** `.zip`, `.tgz`, `.tar`, `.gz` nei file versionati.
- 22 file HTML/SVG da sorvegliare tramite `scripts/no-js.sh`.
- Un gate CI di sicurezza e documentazione statica che esegue
  `scripts/no-js.sh`, ora richiamato anche da `verify.sh`.

Questa è un'ispezione dell'albero versionato, **non dell'intera storia Git**.
L'assenza di sorgenti JavaScript non prova che le dipendenze di
**GitHub Actions di terze parti** non usino JavaScript internamente.
Lo sviluppo avanzato (generazione dei seed, plugin e strumenti web
storici) non ha necessariamente ancora un sostituto nativo.

Le istruzioni storiche riportate nella sezione successiva sono mantenute
esclusivamente come inventario della migrazione precedente, **non** come
funzionalità attuali.

## Inventario storico precedente alla rimozione (2026-11-09)

Prima della migrazione, l'albero Git conteneva **94 file JavaScript/TypeScript**:
50 `.js`, 38 `.mjs`, three `.cjs`, three `.tsx` (~5.7 MB), of which ~5 MB
are vendored Obsidian plugins. This is not the whole JavaScript surface:
HTML pages embed `<script>` elements and remote JS dependencies, npm
manifests bring Node toolchains, and multiple CI jobs execute Node.

| Family | Previous role | Approved JS-free disposition | Replacement gate |
| --- | --- | --- | --- |
| `seed/dev/*.{js,cjs}` | ELF/PE seed generator and development oracle | Remove after identifying reproducibility gap; retain the committed machine-code `seed.hex` plus hash tests, and implement future generator in native Triad | `sh verify.sh`, native seed hash, separate Triad generator milestone |
| `cli/**/*.mjs`, npm manifests | Development CLI | Native `bin/triad-cli` is authoritative; unsupported seed-generation/extension commands must fail with documented status, never quietly use Node | `triad-cli status`, `triad-cli test all` |
| `tools/selfhost-guard/*.mjs` | JS AST guard and JS-oracle comparison | Replace critical checks with native conformance / certified-corpus execution; acknowledge temporary loss of differential JS oracle | Core, S1 and security golden tests |
| `docs/assets/js/*`, inline scripts, browser playground | Interactive browser UI, dynamic navigation, in-browser JS interpreter | Serve static HTML + CSS and instruct users to run the *native* runtime locally; no active playground until a non-JS/browser-native architecture is available | Static HTML script gate, Pages deployment |
| `tools/site-gen/*.mjs`, `scripts/docs/*.mjs,cjs` | Generators and document exports | Retain generated static assets; replace necessary build paths in native Triad or non-JS scripts before restoring generation | Documentation smoke + native generators as added |
| `tools/webcmd-graphify/*.js` | Graphify plugin | Remove unsupported plugin and archives, or reimplement protocol in Triad | No plugin archive or JS source in checkout |
| `.github/skills/**/*.js,*.mjs,*.tsx` | External skill snippets | Remove JavaScript executables and samples from repository, keep text assets where useful | Tracked-tree gate |
| `obsidian-triad/.obsidian/plugins/**/*.js` and `graphify/graph.html` | Third-party bundled plugins/graph | Remove JavaScript binaries and executable graph HTML, keep Markdown vault content | No vendored JS or inline scripts |
| `ai/*.mjs`, `tests/**/*.js,*.mjs` | JS oracle-based audits/tests | Replace with Triad native tests before claiming equivalent coverage | Explicit regression matrix and CI |

## Non-negotiable safety and quality constraints

1. **Never change `main` directly**: review through a dedicated draft PR.
2. **No false parity**: deleting a JS seed generator is not the same as
   providing a reproducible *source-to-machine-code* native generator. Note
   reduced maintenance capability prominently until a Triad replacement exists.
3. Preserve **all source manifests, Triad programs, native seed hex dumps,
   existing conformance goldens, and S1 interpreter sources**.
4. Maintain a functioning native `install.sh`, `bin/triad`, `bin/triad-cli`,
   `verify.sh`, S1 logic, TRID native tests, and source-security tests.
5. Explicitly retire the *browser* playground rather than pretend it can
   execute native Triad in a browser without a browser runtime.
6. Inspect documentation pages and SVG for inline `<script>` or handler
   attributes; script-free HTML may remain.
7. For bundles and archives which could hide JS, remove them unless their
   content is independently audited and known free of JS.
8. A zero-JS CI gate cannot establish that external GitHub Actions use no JS
   internally. If the requirement extends to **all third-party tooling**,
   GitHub-hosted Actions must also be replaced with native shell/self-hosted
   equivalents and reviewed separately.

## Criteri di accettazione

- [ ] Tracked repo has **zero** `*.js`, `*.cjs`, `*.mjs`, `*.jsx`, `*.ts`,
  `*.tsx`, `*.mts`, `*.cts`.
- [ ] No npm manifests / dependency locks / bundled plugin archives.
- [ ] No inline browser scripts, event handlers, JS URLs or remote JS loads.
- [ ] No Node/npm commands in runtime, installer, build workflows.
- [ ] `sh scripts/no-js.sh` passes.
- [ ] `sh verify.sh` passes on supported x86-64 Linux.
- [ ] `sh cognitive/native/tests/run.sh` passes.
- [ ] `sh cognitive/native/tests/run_05.sh` and `run_06.sh` pass.
- [ ] Native PE and ELF seed hashes are checked without regenerating them via JS.
- [ ] Security and static documentation gates do not silently disappear.
- [ ] Excluded capabilities have explicit replacement tickets and
  user-facing status in README.
- [ ] CI green on the draft PR before merge.

**Important:** Removing JavaScript source without equivalent Triad replacements
necessarily disables some development functionality and the browser playground.
Do not characterize that as feature parity. The long-term goal is entirely
self-hosted source regeneration and a Triad-based development toolchain.
