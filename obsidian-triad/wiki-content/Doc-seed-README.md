> Copia di [`seed/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/seed/README.md) — torna a [Documenti](Documenti) · [Home](Home)

# Seed di bootstrap (S0)

Questa cartella contiene **S0**, il primo eseguibile Triad: programmi scritti in **codice
macchina**, senza compilatori, assembler o altri linguaggi. Il "sorgente" è un dump
esadecimale; l'eseguibile si ottiene decodificandolo con uno strumento di sistema.

La catena completa è descritta in [`../BOOTSTRAP.md`](https://github.com/GPuntobit/triad2.0/blob/main/BOOTSTRAP.md).

## Stato

| milestone | piattaforma | stato |
|---|---|---|
| M1 — stampa una riga ed esce con 0 | Windows x86-64 (PE) | ✅ |
| M2 — legge il file dal primo argomento e ne scrive i byte | Windows x86-64 (PE) | ✅ |
| M3 — interprete Triad-Core | Windows x86-64 (PE) | in corso: M3b1 ✅, M3b2a ✅, M3b2b1 ✅, M3b2b2 ✅, M3b2b3a-e ✅, **M3b2b3f** ⚠️ (cattura instabile), **M3b2b3g** ✅ (`!`, `&&`, `||`, `+=`), **M3b2b3h** ✅ (`function … end`), **M3b2b3i** ✅ (corpo a più istruzioni), **M3b2b3j** ✅ (frame lessicali, `let`; `scope`), **M3b2b3k** ✅ (chiusure; `closure`/`chiusure`), **M3b2b3l** ✅ (`begin`/`end`), **M3b2b3m** ✅ (stringhe base), **M3b2b3n** ✅ (`nothing`), **M3b2b3o** ✅ (concatenazione), **M3b2b3p** ✅ (simboli `:nome`; `simboli_base`); restano `string()`, cattura multi-binding, `elseif`, liste |
| M7 — port Linux (ELF) | Linux x86-64 | ✅ **E0 → E1 → E2 → E3**: ELF minimale (write/exit) → runner di file (argv + I/O) → **interprete Triad-Core** (11977 byte, parità byte-esatta col PE: conformance 42/42 + probe 57/57 + golden S1) → **toolchain senza Node** (`install.sh` → `bin/triad`/`bin/triad-cli`, CI `seed-linux` nativa) |

## Contratto del seed

Il seed **non** è un'implementazione Triad-Core completa: è un interprete diretto
(scannerless) scritto in codice macchina, e fa da *veicolo di transizione* per S1 (il
front-end scritto in Triad-Core). «Sottoinsieme certificato» = l'insieme dei programmi
Triad-Core che il seed esegue con la semantica di `SPEC-CORE.md`.

Il contratto è in due pezzi:

- **`dev/certified-subset.txt`** — il contratto *leggibile dalla macchina*: l'envelope
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

## Build (nessun compilatore)

Windows:

```powershell
Remove-Item seed\windows-x86_64\seed.exe -ErrorAction SilentlyContinue
certutil -decodehex seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe
```

Linux/macOS:

```sh
xxd -r -p seed/windows-x86_64/seed.hex seed/windows-x86_64/seed.exe
```

Nota: il file prodotto è un PE per Windows; per Linux c'è il seed ELF in
`linux-x86_64/` (vedi sotto). `certutil`/`xxd` sono solo decodificatori: non contengono
logica Triad e non fanno parte della catena.

Esecuzione del PE su Linux/macOS (solo sviluppo, via wine):

```sh
scripts/seed-runner/seed-wine.sh FILE.td [ARG...]   # un programma Triad
scripts/seed-runner/seed-wine.sh --check            # conformance Core + probe + golden S1
```

L'harness (`seed-wine.sh`) decodifica una volta `windows-x86_64/seed.hex` in una cache
(`~/.cache/triad2.0/seed-wine`), ridecodificandola solo quando cambia lo SHA-256 del
dump, ed esegue il PE sotto `wine`. Funziona anche come runtime per i runner Node
(`TRIAD_SEED="$PWD/scripts/seed-runner/seed-wine.sh" sh conformance/run.sh`).
È uno strumento di sviluppo: non fa parte della catena di bootstrap S0→S4 e la
verifica gira sull'ELF nativo (il PE è coperto dal gate degli hash + dai golden
 congelati).

Linux ELF (E2 — interprete Triad-Core):

```sh
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed
chmod +x seed/linux-x86_64/seed
./seed/linux-x86_64/seed tuo_programma.td   # interprete Triad-Core, stdout byte-exatto
```

Oppure, per l'installazione completa della toolchain POSIX (launcher in
`~/.local/bin`, smoke test e voce di menu opzionale):

```sh
./install.sh              # dalla radice del repository, senza root
```

## Verifica

Windows (seed PE):

```powershell
$exe = .\seed\windows-x86_64\seed.exe
& $exe conformance\core\cases\interi\program.td       # 7 9 6 -3 5 7
& $exe conformance\core\cases\closure\program.td      # 15 105 15
& $exe conformance\core\cases\funzioni\program.td     # 5 16 120 55
& $exe conformance\core\cases\while_loop\program.td   # 15 5
& $exe ; $LASTEXITCODE                                # 2
& $exe non_esiste.td ; $LASTEXITCODE                  # 1
```

Linux (seed ELF E2):

```sh
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed
chmod +x seed/linux-x86_64/seed
./seed/linux-x86_64/seed file.td       # esegue il programma, exit 0
./seed/linux-x86_64/seed               # usage su stderr, exit 2
./seed/linux-x86_64/seed non_esiste.td # errore su stderr, exit 1
sh seed/linux-x86_64/check_seed.sh     # 7 casi (contratto errori/limiti)
sh verify.sh                           # gate completo: conformance 42 + probe 57 + golden S1
```

Il PE Windows e l'ELF Linux coprono lo **stesso dominio di codice macchina** e passano
**42/42 casi Core byte per byte** sui golden condivisi (il gap storico `liste` è chiuso
dal rebuild N03/N04: `xs[i]` e `push!` come statement funzionano e il gate non ha più
esclusioni). Dettagli in
[`windows-x86_64/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/seed/windows-x86_64/README.md) e
[`linux-x86_64/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/seed/linux-x86_64/README.md).

## Regole

- Il seed **non** contiene Julia né altri linguaggi: solo byte x86-64 e dati.
- Il dump esadecimale è la fonte; il listing/layout in `windows-x86_64/README.md` lo rende
  modificabile senza tool. Il generatore di manutenzione è in `dev/` (non fa parte della
  catena e non è richiesto per usare o ricostruire il seed).
- Gli strumenti di sviluppo (script usa-e-getta che ha prodotto il dump, editor, decoder)
  non fanno parte della catena S0→S4: per usare/ricostruire il seed basta il dump.
- A ogni estensione del seed (M3, …) si aggiornano: dump, documentazione, hash e milestone in
  `../BOOTSTRAP.md`.
