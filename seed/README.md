# Bootstrap seed (S0)
This folder contains **S0**, the first Triad executable: programs written in **code
machine**, without compilers, assemblers or other languages. The "source" is a dump
hexadecimal; the executable is obtained by decoding it with a system tool.
The complete chain is described in [`../BOOTSTRAP.md`](../BOOTSTRAP.md).
## State
| milestones | platform | status |
|---|---|---|
| M1 — prints a line and exits with 0 | Windows x86-64 (PE) | ✅ |
| M2 — reads the file from the first argument and writes its bytes | Windows x86-64 (PE) | ✅ |
| M3 — Triad-Core interpreter | Windows x86-64 (PE) | in progress: M3b1 ✅, M3b2a ✅, M3b2b1 ✅, M3b2b2 ✅, M3b2b3a-e ✅, **M3b2b3f** ⚠️ (unstable capture), **M3b2b3g** ✅ (`!`, `&&`, `||`, `+=`), **M3b2b3h** ✅ (`function … end`), **M3b2b3i** ✅ (multi-statement body), **M3b2b3j** ✅ (lexical frames, `let`; `scope`), **M3b2b3k** ✅ (closures; `closure`/`closures`), **M3b2b3l** ✅ (`begin`/`end`), **M3b2b3m** ✅ (base strings), **M3b2b3n** ✅ (`nothing`), **M3b2b3o** ✅ (concatenation), **M3b2b3p** ✅ (symbols `:name`; `base_symbols`); `string()`, multi-binding capture, `elseif`, lists | remain
| M7 — Linux port (ELF) | Linux x86-64 | ✅ **E0 → E1 → E2 → E3**: minimal ELF (write/exit) → file runner (argv + I/O) → **Triad-Core interpreter** (11977 byte, parità byte-exatta col PE: conformance 42/42 + probe 57/57 + golden S1) → **toolchain senza Node** (`install.sh` → `bin/triad`/`bin/triad-cli`, CI `seed-linux` nativa) |
## Contratto del seed
Il seed **non** è un'implementazione Triad-Core completa: è un interprete diretto
(scannerless) scritto in codice macchina, e fa da *veicolo di transizione* per S1 (il
front-end scritto in Triad-Core). «Sottoinsieme certificato» = l'insieme dei programmi
Triad-Core che il seed esegue con la semantica di `SPEC-CORE.md`.

Il contratto è in due pezzi:

- **`dev/certified-subset.txt`** — il contratto *macchina-leggibile*: l'envelope
  (buffer sorgente 1 MiB, heap 8 MiB, liste da 64 elementi, funzioni da 4 parametri),
  i primitivi §8 presenti (`get`, `exit`, `readfile`, `strlen`, `strbyte`, `strsub`),
  l'envelope (buffer sorgente 1 MiB, heap 8 MiB, liste da 64 elementi, funzioni da 4
  parametri, file da 1 MiB, path da 1024 byte) e l'elenco delle **divergenze** dal
  comportamento della specifica, con la loro classe (`silent` = risultato sbagliato
  senza errore, `noisy` = exit 1);
- **questa sezione** — la versione leggibile.

Le guardie statiche sulla sorgente di S1 (`tools/selfhost-guard/`) e il gate differenziale
seed↔JS consumano il contratto: ogni regola è legata a una divergenza e si spegne da
sola quando la divergenza sparisce dal contratto.

Divergenze note dal comportamento di `SPEC-CORE.md` (misurate sul seed):

| # | costrutto | `SPEC-CORE.md` | seed |
|---|---|---|---|
| D1 | scope dei nomi | §5 lessicale | **dinamico**: il callee vede i locali del chiamante |
| D2 | chiusure | §5 cattura condivisa | cattura **per valore** |
| D3 | escape nelle stringhe | §2 interpretati | non interpretati |
| D4 | `==` su stringhe | §5 per valore | sempre `false` |
| D5 | `continue` | §4/§6 | assente (exit 1) |
| D7 | `while` come valore | §4 | assente (exit 1) |
| D8 | `if` come valore | §5 | solo come ultima espressione del corpo di una funzione; altrove assente (exit 1) |
| D10 | `return` in funzione a blocco | §4/§5 | assente (exit 1) |
| D11 | blocco-lambda `function (x) … end` | §4 | assente (exit 1) |
| D12 | `let` multi-binding | §4 | assente (exit 1) |
| D14 | `typeof`, `Int()`, `Symbol()` | §7 | assenti (exit 1) |
| D15 | `string(x)` | §7 | solo `Int`/`String` (le altre forme sbagliano) |
| D17 | simboli operatore `:+` | §2 | rifiutati (exit 1) |
| D18 | chiamata a livello di file prima della definizione | §4 | rifiutata (exit 1) |
| D19 | newline dopo un operatore | §2 separatore | **prosegue** l'espressione |
| D20 | corpo di `if`/`while` | §5 ambiente proprio | **nessun** ambiente proprio (il nome resta visibile fuori) |
| D21 | condizione `while` non-`Bool` | §5 solo `Bool` | **salta** il corpo in silenzio |
| D24 | assegnazione composta a indice `xs[i] += v` | §7 (oltre la grammatica di Core) | assente (exit 1); `xs[i] = v` funziona |
| D25 | interi a 64 bit con wrap | §5 | il tag occupa il bit basso: il range utile è `[-2^61, 2^61−1]`; un letterale o un risultato aritmetico fuori range è **rifiutato** (exit 1, `seed: integer overflow` su stderr ELF), non prodotto sbagliato in silenzio (decisione `docs/adr/0003-range-interi-del-seed.md`) |

Divergenze **risolte** dal seed (non sono più nel contratto): **D6** (`-=`, `*=` a nome),
**D9** (chiamata in posizione finale: viene valutata), **D13** (indicizzazione `xs[i]`
1-based e scrittura `xs[i] = v`), **D16** (primitivi §8 `readfile`, `strlen`, `strbyte`,
`strsub`), **D22** (le parole chiave sono token *esatti*: `iffy`, `myif`, `endx`,
`elsewhere` non sono keyword, e il testo di un letterale non conta per
l'annidamento dei blocchi), **D23** (ternario con simbolo).

Correzioni senza id (divergenze *non dichiarate*, cioè bug): `exit(n)` era dichiarato
disponibile ma **non esisteva** (exit 1); i **simboli non sono più stringhe** (un
simbolo ha tipo 5: `strlen(:x)` fallisce e `"a" * :b` fallisce, come sul riferimento
JS) e `string(:x)` copia i byte del simbolo in una Stringa.

Fuori contratto (dichiarato, non implementato): `typeof`, `Int()`, `Symbol()`,
`string()` per `Bool`/`Symbol`/`Nothing`, `:+`, `get` come indicizzazione 1-based.

D23 risolta: il ternario distingue `:nome` dal separatore; il caso
`ternario_simbolo` è obbligatorio nel gate (SPEC.md §1, SPEC-CORE.md §4).

## Build (no compiler)
Windows:
```powershell
Remove-Item seed\windows-x86_64\seed.exe -ErrorAction SilentlyContinue
certutil -decodehex seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe
```

Linux/macOS:
```sh
xxd -r -p seed/windows-x86_64/seed.hex seed/windows-x86_64/seed.exe
```

Note: The product file is a PE for Windows; for Linux there is the ELF E0 seed in
`linux-x86_64/` (see below). `certutil`/`xxd` are decoders only: they do not contain
Triad logic and are not part of the chain.

Run the PE on Linux/macOS (development only, via wine):
```sh
scripts/seed-runner/seed-wine.sh FILE.td [ARG...]   # un programma Triad
scripts/seed-runner/seed-wine.sh --check            # conformance Core + probe + golden S1
```
The harness (`seed-wine.sh`) decodes `windows-x86_64/seed.hex` once into a cache
(`~/.cache/triad2.0/seed-wine`), re-decoding it only when the SHA-256 of the dump
changes, and runs the PE under `wine`. It also works as the runtime for the Node
runners (`TRIAD_SEED="$PWD/scripts/seed-runner/seed-wine.sh" sh conformance/run.sh`).
It is a development tool: it is not part of the S0→S4 bootstrap chain and the
verification runs on the native ELF (the PE is covered by the hash gate + frozen
goldens).
Linux ELF (E2 — interprete Triad-Core):
```sh
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed
chmod +x seed/linux-x86_64/seed
./seed/linux-x86_64/seed tuo_programma.td   # interprete Triad-Core, stdout byte-exatto
```

Or, for the complete installation of the POSIX toolchain (launcher in
`~/.local/bin`, smoke test and optional desktop entry):
```sh
./install.sh              # dalla radice del repository, senza root
```

## Verify
Windows (PE seed):
```powershell
$exe = .\seed\windows-x86_64\seed.exe
& $exe conformance\core\cases\interi\program.td       # 7 9 6 -3 5 7
& $exe conformance\core\cases\closure\program.td      # 15 105 15
& $exe conformance\core\cases\funzioni\program.td     # 5 16 120 55
& $exe conformance\core\cases\while_loop\program.td   # 15 5
& $exe ; $LASTEXITCODE                                # 2
& $exe non_esiste.td ; $LASTEXITCODE                  # 1
```

Linux (ELF E2 seed):
```sh
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed
chmod +x seed/linux-x86_64/seed
./seed/linux-x86_64/seed file.td       # esegue il programma, exit 0
./seed/linux-x86_64/seed               # usage su stderr, exit 2
./seed/linux-x86_64/seed non_esiste.td # errore su stderr, exit 1
sh seed/linux-x86_64/check_seed.sh     # 7 casi (contratto errori/limiti)
sh verify.sh                           # gate completo: conformance 42 + probe 57 + golden S1
```

The Windows PE and the Linux ELF cover the **same machine-code domain** and pass
**42/42 Core cases byte-exactly** on the shared goldens (the historical `liste` gap
is closed since the N03/N04 rebuild: `xs[i]` and `push!` as a statement work, and the
gate has no exclusion left). Details in
[`windows-x86_64/README.md`](windows-x86_64/README.md) and
[`linux-x86_64/README.md`](linux-x86_64/README.md).
## Rules
- The seed **does not** contain Julia or any other language: just x86-64 bytes and data.
- Hex dump is the source; the listing/layout in `windows-x86_64/README.md` makes it
  editable without tools. The maintenance generator is in `dev/` (not part of the
  chain and is not required to use or rebuild the seed).
- The development tools (disposable script that produced the dump, editor, decoder)
  they are not part of the S0→S4 chain: the dump is enough to use/rebuild the seed.
- With each extension of the seed (M3, ...) the following are updated: dump, documentation, hash and milestone in
  `../BOOTSTRAP.md`.