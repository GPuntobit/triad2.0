> Copia di [`CHANGELOG.md`](https://github.com/GPuntobit/triad2.0/blob/main/CHANGELOG.md) — torna a [Documenti](Documenti) · [Home](Home)

# Changelog — standard Triad

Le modifiche normative aggiornano anche `VERSION`, la specifica (`SPEC.md`) e, se cambia
il comportamento, i golden di `conformance/`.

## D22 risolta: le parole chiave sono token *esatti* nel seed — 2026-11-09

Il seed riconosceva le parole chiave confrontando i **byte grezzi** del sorgente: un
identificatore che inizia con una keyword (`iffy`, `myif`) veniva scambiato per il
costrutto, e dentro un corpo di blocco il contatore di annidamento contava anche le
keyword contenute nel testo di un letterale (`"if end else while"`), spostando la fine
del blocco (exit 1).

- **fix (seed)**: helper `kw_bound` (confine bilatero della parola chiave) e routine
  `sc_string` (salto del testo di un letterale) in `seed/dev/core.js`;
- **contratto**: `D22` esce da `seed/dev/certified-subset.txt`; guardia `G-D22` rimossa;
  la regola `E010` del lint del sito è rimossa (un letterale può contenere `if` anche
  dentro un blocco);
- **probe**: `bad_if_in_blocco`/`bad_if_in_blocco_while` → `ok_if_in_blocco`/
  `ok_if_in_blocco_while`; nuovi `ok_keyword_confine` e `ok_keyword_inizio_sorgente`
  (55 → 57 probe);
- **artefatti**: dump PE (25088 byte, codice 11996 byte) ed ELF (11977 byte) rigenerati,
  hash CI aggiornati (PE `20aa566d…`, ELF `8457051f…`).

Verifiche PASS: conformance 42/42, probe 57/57 (ELF e PE via wine), logica 29/29,
guardie 23 test, differenziale 0 differenze, anti-drift e hash CI verdi. Nessun golden
riscritto.

## D16 risolta: i primitivi §8 (`readfile`, `strlen`, `strbyte`, `strsub`) sono nel seed — 2026-11-08

Il seed dichiarava `exit` disponibile **senza implementarlo** e non implementava gli altri
primitivi §8: senza `readfile` S1 non può nemmeno caricare il programma da interpretare.

- **seed**: `strlen(s)`, `strbyte(s, i)`, `strsub(s, a, b)` (byte, 1-based),
  `readfile(path)` (max 1 MiB, path max 1024 byte) e `exit(n)`;
- **fix (seed)**: un **simbolo** non è più una stringa (tipo 5): `strlen(:x)` e `"a" * :b`
  falliscono come sul riferimento JS;
- **contratto**: `D16` esce dal contratto; `[available]` dichiara i quattro primitivi;
  nuovi limiti in `[envelope]` (`file.max_bytes`, `path.max_bytes`);
- **probe**: 47 → 55 (`ok_readfile`, `ok_strlen`, `ok_strbyte`, `ok_strsub`, `ok_exit` e i
  casi `bad_*` corrispondenti);
- **artefatti**: dump PE (25088 byte) ed ELF (11465 byte) rigenerati (PE `0432c4ca…`,
  ELF `a5fa3e50…`).

Verifiche PASS: conformance 42/42, probe 55/55, logica 29/29, guardie 24 test,
differenziale 0 differenze. Nessun golden riscritto.

## D25: l'overflow degli interi del seed è un errore, non un numero sbagliato — 2026-11-08

Il seed rappresenta `Int` con 2 bit di tag (range utile `[-2^61, 2^61−1]`), mentre
`SPEC-CORE.md` §5 vuole interi a 64 bit signed con wrap: un valore fuori range veniva
prodotto sbagliato **in silenzio**. Ora il seed lo **rifiuta** (exit 1,
`seed: integer overflow` su stderr ELF) e la divergenza `D25` diventa `noisy`. Decisione:
`docs/adr/0003-range-interi-del-seed.md` (i 64 bit restano un vincolo per S1).

- **fix (seed)**: controllo di range sui risultati aritmetici e sui letterali decimali
  (`int_chk62` in `seed/dev/core.js`);
- **probe**: `bad_intero_64bit` da divergenza silenziosa a rifiuto; nuovi
  `bad_intero_overflow_add`, `bad_intero_overflow_mul`, `bad_intero_overflow_pow`
  (44 → 47 probe).

Verifiche PASS: conformance 42/42, probe 47/47, logica 29/29, guardie 25 test.

## Ciclo di rebuild del seed: `-=` corretto, `xs[i]` e chiamata in posizione finale chiusi — 2026-11-08

Chiuso il ciclo `core.js` → dump PE/ELF → binari → hash CI → documentazione: il generatore
riproduce i dump committati byte per byte e il gate hash della CI è allineato.

- **fix (seed)**: `-=` era sbagliato **in silenzio** (operandi invertiti nel codegen);
- **contratto**: chiuse `D6` (`-=`, `*=` a nome), `D9` (chiamata in posizione finale) e
  `D13` (indicizzazione `xs[i]` 1-based e `xs[i] = v`); nuove `D24` (noisy: `xs[i] += v`
  non implementata) e `D25` (interi limitati);
- **probe**: 39 → 44.

Verifiche PASS: conformance 42/42, probe 44/44, guardie 25 test, differenziale 0 differenze.

## Release v0.8.0-beta.10 — 2026-11-08

Prerelease con S1 logico, desktop automatico, fix Core/output e cleanup integrati fino alla
PR #84; versione e metadati allineati, note in `docs/releases/RELEASE_NOTES_v0.8.0-beta.10.md`;
nuovo workflow Release (build nativi Linux/Windows, CLI standalone, archivio sorgente,
SHA256SUMS).

## Motore logico S1 eseguibile — 2026-11-08

Nuovo profilo `triad --logic FILE` (oppure `-` per stdin), scritto in Triad-Core in
`selfhost/logic/engine.td`: fatti/regole, unificazione iterativa con occurs-check,
backtracking con choice stack e trail, congiunzione/disgiunzione/negazione, liste e code,
`solve` come valore, proiezioni e comprensioni, predicati come Bool, `limit`/`depth`/`steps`.
Lo shell trasporta solo byte con `od`/`printf`: nessun interprete Node/Julia nel percorso
runtime.

Corretto un prerequisito reale del seed: dopo `xs[i] = valore` il cursore veniva
ripristinato all'inizio dello statement (loop infinito). Aggiunti in seguito `trace`,
`struct`, funzioni booleane e sorgenti paginati (fino a 65535 byte).

Validazione: suite logica 29/29 su seed e riferimento JS, Core 42/42, probe 57/57,
`verify.sh` PASS. Limiti espliciti in `selfhost/logic/README.md`.

## Port Linux del seed e toolchain senza Node — 2026-11-05 (0.8.0-beta.9)

- **E1**: l'ELF esegue un file `.td` (argv + I/O);
- **E2**: l'ELF è un **interprete Triad-Core** (11977 byte) con **parità byte-esatta** col
  PE Windows: conformance 42/42 + probe 57/57 + golden S1, Linux nativo **senza Wine**;
- **E3**: toolchain senza Node — `./install.sh` (decodifica del seed con `printf`, wrapper a
  percorso assoluto, smoke test byte-exatto che fallisce l'installazione su mismatch) →
  `bin/triad` + CLI POSIX `bin/triad-cli` (`run`/`test`/`status`); `cli/triad-cli.mjs`
  ridotta ai comandi dev (`seed`/`ai`/`ext`);
- **CI**: rimosse le gambe Windows (decisione 04), aggiunti i job `seed-linux` e
  `linux-toolchain` nativi, hash PE **ed** ELF con anti-drift `cmp` dei due dump.

## Gate senza esclusioni e suite complete — 2026-11-08

Rimossa l'ultima esclusione `liste`: `conformance/gate.sh` delega all'oracle e propaga il
suo exit code; aggiornati `verify.sh`, il nome dello step CI, `AGENTS.md` e la
documentazione. Nessun golden, dump o generatore modificato. Riferimento normativo:
`SPEC-CORE.md` §11.

## D23 risolta: ternario con simbolo reinserito nel gate — 2026-11-08

Un `:` seguito dall'inizio di un identificatore appartiene a un simbolo e non decrementa
la profondità dei ternari (`SPEC.md` §1, `SPEC-CORE.md` §§2, 4–6): `D23` esce dal
contratto e l'esclusione `ternario_simbolo` dal gate.

## Audit runtime: output JS troncato su pipe — 2026-11-08

`process.exit()` terminava il riferimento JS prima dello svuotamento di stdout su pipe:
il CLI ora imposta `process.exitCode` e lascia svuotare gli stream. Aggiunto il caso Core
`output_pipe` con golden deterministico.

## Installazione desktop KDE senza qtpaths — 2026-11-08

Con `KDE_SESSION_VERSION >= 5` e `qtpaths` assente, la sola chiamata `xdg-mime default`
usa il backend standard (X-Generic). Nessun runtime o golden modificato.

## Parametri tipizzati e dispatch S1 — 2026-11-08

Parser delle firme, tabella metodi, ordine parziale di specificità, ridefinizione e
ritorni scalari; `Err(:method)` e `Err(:ambiguous)` per mancata selezione e ambiguità.
La suite logica passa a 29 casi su seed e riferimento.

## Cleanup del codice inutilizzato — 2026-11-08

Rimossi due script non richiamati, tre assegnazioni/allocazioni inutili di S1 e la guardia
`D23` inattiva. Nessun golden o artefatto macchina modificato; evidenze in
`docs/unused-code-audit.md`.

## Non rilasciato — 2026-10-26

- **Conformità**: nuovo caso Core `gcd` (Euclide, ricorsione e `%`); la suite Core ha 37 casi.
- **Golden versionati**: `.gitignore` non esclude più `conformance/**/expected.out` e
  `expected.code`; il runner accetta `expected.golden` come copia di riserva.
- **Runner**: `conformance/run.mjs` usa l'interprete `seed/dev/triad_core.cjs` su Linux/macOS
  (il seed ELF è ancora E0) e fallisce con `golden mancante` invece di confrontare con uno
  stdout vuoto; rimosso il golden `gcd` scritto nel codice del runner.
- **Julia rimossa**: `triad.jl`, `syntax.jl`, `test/` e `bin/build_standalone.jl` non fanno più
  parte del repository; la CI usa solo Node e il seed.

## Non rilasciato — 2026-10-22

- **Open source**: aggiunta `LICENSE` MIT; inclusi nel repository i binari del seed
  (`seed/windows-x86_64/seed.exe`, `seed/linux-x86_64/seed`) e i lockfile
  (`Manifest.toml`, `Cargo.lock`); `.gitignore` e `.gitattributes` aggiornati.

## 0.2.0 — 2026-10-20

- **Standard Triad v0.2.0**: `SPEC.md` diventa un documento normativo indipendente
  dall'implementazione (stato, normatività, profili di conformità e versionamento in §16).
- **Conformità eseguibile**: aggiunta `conformance/` con 12 casi golden (stdout + exit code)
  e un runner di sviluppo basato sullo stage0; la suite è parte dello standard.
- **AI benchmark** (strumento di sviluppo): `ai/` con prompt di sistema, task Triad-Core e
  `ai verify` per generare codice con un LLM e verificarlo contro i golden.
- **Seed Linux E0**: primo ELF x86-64 statico, solo syscall (`write`/`exit`).
- **Estensione canonica**: `.triad`; `.td` resta supportata come alias storico.
- **Indipendenza**: piano di bootstrap senza linguaggi ospiti in `BOOTSTRAP.md`.
- **Tooling editor**: grammatiche di sintassi per VS Code e Vim/Neovim (`editors/`) e
  preparazione della voce Linguist (`editors/linguist/`).
- **Seed M1/M2**: primo eseguibile Triad in codice macchina (PE Windows x86-64), poi I/O
  reale dal primo argomento della command line.
- **Triad-Core**: nuovo standard di profilo [`SPEC-CORE.md`](https://github.com/GPuntobit/triad2.0/blob/main/SPEC-CORE.md)
  (sottoinsieme normativo per il bootstrap self-hosted) e suite `conformance/core/`.
- **Seed M3b1…M3b2b3p**: il seed in codice macchina **interpreta** Triad-Core — interi,
  variabili, funzioni, confronti, ricorsione, blocchi `if`/`while`, lambda, chiusure,
  stringhe, `nothing`, simboli, `begin … end`, frame lessicali, operatori `!`/`&&`/`||`/`+=`.

## 0.1.0 — iniziale

- Kernel S-expression `legacy/triad_sexpr_v1.jl` (storico).
