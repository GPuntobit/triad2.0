> Copia di [`STATUS.md`](https://github.com/GPuntobit/triad2.0/blob/main/STATUS.md) — torna a [Documenti](Documenti) · [Home](Home)

# Stato di Triad e del bootstrap S0

Aggiornato al **2026-11-09** (ciclo D22, release `0.8.0-beta.10`).

## Obiettivo

Triad come linguaggio autonomo e riconosciuto: standard proprio, conformance, estensione `.triad`, tooling editor, bootstrap senza linguaggi ospiti e self-hosting.

## Cosa è pronto

- **Standard**: `SPEC.md` (v0.2.0), `SPEC-CORE.md`, `VERSION` (`0.8.0-beta.10`), `CHANGELOG.md`.
- **Conformance**: harness POSIX `conformance/run.sh` (senza Node, senza Julia); Triad-Core
  **42/42 verde e byte-exatto** sul seed ELF nativo (`seed/linux-x86_64/seed`, niente Wine);
  gate `conformance/gate.sh` **senza esclusioni**. Triad-Full: 12 casi, oggi passa solo
  `errore` (fuori dal gate). Golden `expected.out`/`expected.code` versionati; un golden
  mancante fa fallire il caso con `golden mancante`.
- **Estensione canonica**: `.triad` (`.td` alias storico), grammatiche VS Code/Vim e voce Linguist preparata.
- **Seed S0** (codice macchina, nessun runtime/compilatore): interprete Triad-Core in due
  artefatti con **parità byte-esatta** — PE Windows (25088 byte, codice 11996 byte, dump
  `20aa566d…83d7b7`) ed ELF Linux (11977 byte, dump `8457051f…315d613`); coprono interi,
  variabili, funzioni (forma breve e `function … end`), ricorsione, Bool, operatori
  (`% ^ ! && || += -=`), `if`/`elseif`/`else`, `while`, `let`, `begin`, lambda, chiusure,
  stringhe, `nothing`, simboli, liste di interi (`xs[i]` 1-based, `xs[i] = v`, `push!`) e i
  primitivi §8 `get`, `exit`, `readfile`, `strlen`, `strbyte`, `strsub`.
- **Contratto del seed**: `seed/dev/certified-subset.txt` (leggibile dalla macchina) elenca
  envelope, primitivi e **divergenze** D1–D25 dal comportamento di `SPEC-CORE.md`
  (classe `silent` = risultato sbagliato senza errore, `noisy` = exit 1); le guardie
  statiche (`tools/selfhost-guard/`) e il gate differenziale seed↔JS consumano il contratto
  e si spengono da sole quando una divergenza viene risolta.
- **S1 (Triad in Triad-Core)**: front-end in `selfhost/` (scanner + parser ricorsivo
  discendente, AST in pre-order) e **motore logico eseguibile** in `selfhost/logic/engine.td`
  (`triad --logic FILE`): fatti/regole, unificazione con occurs-check, backtracking,
  congiunzione/disgiunzione/negazione, proiezioni e comprensioni, `solve` come valore,
  `trace`, `struct` e funzioni booleane — **29/29 casi logici** su seed e riferimento.
- **Launcher/CLI**: il runtime predefinito per `.triad` è il seed in codice macchina
  (`bin/triad`, `bin/triad.cmd`); `bin/triad-cli` è la CLI POSIX senza Node
  (`run`/`test`/`status`); `cli/triad-cli.mjs` resta la CLI Node dei soli comandi dev
  (`seed`/`ai`/`ext`). L'implementazione Julia è stata rimossa dal repository.
- **CI**: `.github/workflows/ci.yml` — **solo runner Linux nativi** (decisione 04): job
  `conformance-core`, `logic-engine`, `security`, `site-gen`, `seed-linux` (hash PE **ed**
  ELF + anti-drift `cmp` dei due dump + `check_seed.sh`) e `linux-toolchain` (installazione
  senza root, smoke test byte-exatto, caso negativo).
- **Sito e libro**: il sito statico in `docs/` è generato da programmi Triad
  (`tools/site-gen/`, 13 file generati, lint `E010` rimosso con D22); il libro
  (`docs/libro/`) è costruito dalle sorgenti Italiane (PDF/EPUB/DOCX).

## Cosa manca

| area | stato |
|---|---|
| `stringhe` (`string()`) | ✅ implementato per `Int`/`String`; `Bool`/`Symbol`/`Nothing` assenti |
| `liste` | ✅ caso Core verde sul seed: costruzione, stampa, `xs[i]` 1-based, `xs[i] = v`, `push!`; `length` e iterazione non supportate |
| `valori` (liste/simboli/stringhe insieme) | parziale; liste solo intere, senza operazioni o valori misti |
| `controllo` (`elseif`) | ✅ implementato |
| `continue` | assente dal seed (exit 1): divergenza `D5` |
| `-=`, `*=` a nome | ✅ risolti (D6 chiusa); resta `xs[i] += v` (divergenza `D24`, noisy) |
| `while`-espressione (`x = while … end`) | assente dal seed (exit 1): divergenza `D7` |
| `if` come valore | solo in coda al corpo di una funzione: divergenza `D8` |
| corpo di `if`/`while` | il seed non crea un ambiente proprio: divergenza `D20` |
| condizione `while` non-`Bool` | il seed salta il corpo in silenzio: divergenza `D21` |
| interi a 64 bit con wrap (`SPEC-CORE.md` §5) | il seed ha 2 bit di tag: range utile `[-2^61, 2^61−1]`; fuori range **rifiutato** (exit 1), non prodotto sbagliato in silenzio — divergenza `D25`, decisione `docs/adr/0003-range-interi-del-seed.md` |
| S1 (Triad in Triad-Core) | in corso in `selfhost/`: front-end e motore logico eseguibili, non ancora conformance completa |
| Triad-Full | 11/12 casi non implementati (passa solo `errore`) |
| CLI seed | solo esecuzione di file; REPL e opzioni di SPEC §14 da fare |
| S2–S3 (compilatore nativo, self-hosting) | non iniziati |

## Comandi di verifica

```sh
sh verify.sh                        # gate unico: conformance + probe + logica
sh conformance/run.sh               # Core, 42 casi, byte-exatti sull'ELF nativo
sh tests/probes/run_probes.sh       # 57 probe (ok_*/bad_* + golden S1)
sh conformance/logic/run.sh         # 29 casi logici (S1)
sh seed/linux-x86_64/check_seed.sh  # errori/limiti del seed (7 casi)
node tools/selfhost-guard/guard.mjs        # guardie statiche sul corpus certificato
node tools/selfhost-guard/test.mjs         # self-test delle guardie
node tools/selfhost-guard/differential.mjs  # gate differenziale seed <-> riferimento JS
```

Windows, seed (PE invariato, non rieseguito dal gate — ADR 0002):

```powershell
certutil -decodehex -f seed/windows-x86_64/seed.hex seed/windows-x86_64/seed.exe
.\seed\windows-x86_64\seed.exe conformance\core\cases\closure\program.td
```

Sviluppo su Linux/macOS: `scripts/seed-runner/seed-wine.sh FILE.td` esegue il PE sotto wine
(cache in `~/.cache/triad2.0/seed-wine`); è uno strumento di sviluppo, fuori dalla catena
S0→S4.

## Riconoscimento esterno (richiede il maintainer)

- `LICENSE` aggiunta (MIT, 2026-10-22);
- PR a GitHub Linguist con `editors/linguist/languages.yml`;
- pubblicazione delle estensioni VS Code / Open VSX e Vim;
- eventuale registrazione del linguaggio/standard.

## Ultimi cicli (2026-11-05 → 2026-11-09)

- **E1 → E2 → E3 (port Linux, 2026-11-05)**: runner di un file `.td` → ELF interprete
  Triad-Core (parità byte-exatta col PE) → toolchain senza Node (`./install.sh` →
  `bin/triad`/`bin/triad-cli`, CI `seed-linux` nativa). Windows mantiene il PE invariato.
- **Motore logico S1 (2026-11-08)**: `triad --logic FILE` su `selfhost/logic/engine.td`,
  29/29 casi logici su seed e riferimento; profilo `:logic`/`:core` espliciti nella
  sessione desktop.
- **D25 (2026-11-08)**: l'overflow degli interi del seed è un **errore** (exit 1,
  `seed: integer overflow`), non un numero sbagliato in silenzio.
- **D16 (2026-11-08)**: i primitivi §8 `readfile`, `strlen`, `strbyte`, `strsub` sono nel
  seed; un simbolo non è più una stringa.
- **D22 (2026-11-09)**: le parole chiave sono token **esatti** (`iffy`, `myif`, `endx`,
  `elsewhere` sono identificatori) e il testo di un letterale non conta per l'annidamento
  dei blocchi.
