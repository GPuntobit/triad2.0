# Post release — v0.8.0-beta.9 (da copiare e incollare)

## Versione per GitHub Release (titolo + corpo, Markdown)

**Titolo:**
```
Triad 2.0 — v0.8.0-beta.9: il linguaggio ora gira nativo su Linux
```

**Corpo:**
```markdown
🎉 **Triad 2.0 v0.8.0-beta.9** è uscito (2026-11-07)!

> Triad 2.0 è un linguaggio che si avvia da solo: il compilatore è scritto in
> Triad e compilato dalla versione precedente di se stesso — nessun linguaggio
> host richiesto (bootstrap S0→S4).

È la release che rende Triad un linguaggio *nativo* su Linux: il seed è un
interprete ELF statico (senza libc, senza Wine), byte-identico al PE Windows, e
l'intera toolchain — installer, launcher, CLI, harness di test — funziona
**senza Node.js**.

### 🐧 Linux nativo
- `seed-linux-x86_64`: ELF statico (8,3 KB, senza libc) che esegue l'intero
  linguaggio Triad-Core — parità byte-esatta con il PE Windows (probe 39/39,
  conformance 38/39: il gap storico su `liste` è documentato).
- `./install.sh` → `bin/triad` → `triad program.td`: senza Node, senza runtime, senza Wine.
- CLI POSIX `bin/triad-cli` (`run` / `test` / `status`) e harness di verifica senza
  Node (`verify.sh`, `conformance/run.sh`, `tests/probes/run_probes.sh`).

### 🖥️ Desktop
- `bin/triad-desktop` mantiene output ed errori visibili fino a `:quit` o EOF.
- `.triad` / `.td` registrati come MIME: il doppio click apre il file in Triad.

### 🧪 Nuovo nel repository
- Front-end S1 (`selfhost/source.td`) derivato dal codice macchina del seed.
- Il sito della documentazione è generato da programmi Triad (`tools/site-gen/`).
- *Fondamenta*, un libro per chi parte da zero, più ~900 esercizi; PDF 424 pagine, KDP conforme.

### 🔒 Sicurezza
- Nessun token GitHub vivo nella working tree; il tooling di push non lo scrive
  più nell'URL del remote. Nuovo test di regressione: `tests/security/no_live_tokens.test.py`.

### 📦 Download
| Asset | Piattaforma | SHA-256 |
|---|---|---|
| `seed.exe` (25 KB) | Runtime Windows x86-64 | `631f401ffe42f5f748bb92ab80c2886a7d68f9e00b09bd8dfde2de0c671fe219` |
| `seed-linux-x86_64` (8,3 KB) | Runtime Linux x86-64 (ELF statico) | `c8c82bc9c77c69e603e07ab7287065076e04c8139a57ae3ee454a472cee2a0ce` |
| `triad-cli` (119 MB) | CLI dev standalone Linux x86-64 | `337c5188ee5cfef7d50256f5b03ab510b47dedf15aac6aa14256e1bf2ebe9cb2` |
| `triad-cli.exe` (83 MB) | CLI dev standalone Windows x86-64 | `d7ab6e05a538a7f1ffd571014c91c7f5029e6b21855e9db0843e15acabb06d5e` |

**Changelog completo**: https://github.com/GPuntobit/triad2.0/compare/v0.8.0-beta.8...v0.8.0-beta.9
```

## Versione breve per social (X / Mastodon / LinkedIn)

```
🚀 Triad 2.0 v0.8.0-beta.9 released!

Triad ora gira nativo su Linux: seed ELF statico, byte-identico al PE Windows.
Installer, launcher, CLI e harness di test — senza Node.js, senza runtime, senza Wine.

In più: launcher desktop con MIME .triad/.td, front-end S1, sito generato da
Triad stesso e *Fondamenta* per chi parte da zero.

📦 github.com/GPuntobit/triad2.0/releases/tag/v0.8.0-beta.9

#Triad #PLT #programminglanguages #opensource #linux
```
