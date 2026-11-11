> Copia di [`seed/linux-x86_64/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/seed/linux-x86_64/README.md) — torna a [Documenti](Documenti) · [Home](Home)

# S0 / Linux x86-64 — seed ELF (E2: interprete Triad-Core)

Il seed Linux è un **ELF64 statico** senza libc né linker dinamico, che usa solo le
syscall Linux (`openat`/`read`/`write`/`exit`, isolate nelle routine `os_*`). **E2**
copre lo stesso dominio di codice macchina del PE Windows: interi Triad-Core, variabili,
funzioni (forma breve e `function … end`), ricorsione, Bool, operatori, `if`/`elseif`/
`else`, `while`, `let`, `begin`, lambda/chiusure, stringhe base + `string()`, `nothing`,
simboli, liste (costruzione, stampa, `push!`, `get`). Lo stdout è **byte-identico** al
PE sui golden condivisi (parità N17, `TASK.md`).

Il dump esadecimale è [`seed.hex`](https://github.com/GPuntobit/triad2.0/blob/main/seed/linux-x86_64/seed.hex): è la fonte committata.

## Comportamento (E2)

| invocazione | stdout | stderr | exit |
|---|---|---|---|
| `./seed file.td [ARG…]` | output del programma, byte-exatto | vuoto | `0` (o l'exit del programma) |
| `./seed` (nessun argomento) | vuoto | `usage: seed FILE.td` | `2` |
| `./seed ""` (path vuoto) | vuoto | `usage: seed FILE.td` | `2` |
| `./seed missing.td` | vuoto | `seed: cannot open file` | `1` |
| sorgente ≥ `0x100000` byte | vuoto | `seed: read error` | `1` |

I codici di uscita seguono il contratto `os_*`
(`.scratch/seed-linux-nativo/issues/03`): `2` = uso errato, `1` = fallimento di
apertura/lettura o sorgente troppo grande (l'arena riserva 1 MiB di sorgente dalla N20,
lo slot della mask di blocco è a `+0x100000`, stesso limite del PE). Il caso
«troppo grande» condivide l'etichetta `read_fail` con i veri errori di lettura (limite
noto del seed: una sola etichetta di uscita per i due casi, quindi la diagnostica è
`seed: read error`).

Il PE è muto: le diagnostiche su stderr esistono **solo** sull'ELF, fuori dal contratto
di parità (che copre solo lo stdout byte-identico). Gli errori di runtime di un programma
(es. i probe `bad_*`) escono con codice non zero e stdout vuoto, identicamente al PE; i
limiti noti del PE restano limiti documentati (vedi
[`tests/probes/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/tests/probes/README.md)).

## Numeri

- **File ELF:** 11977 byte (`0x2ec9`)
- **Base:** `0x400000`; **entry:** `0x400078`
- **Program header:** un solo `PT_LOAD` R|X, offset 0, filesz/memsz `0x2ec9`, align `0x1000`
  (nessun section header, come il dump del PE: l'artefatto è puro codice macchina)
- **sha256 di `seed.hex`:** `8457051F7D083AB834EC860502605A58F1ECCE4A5ABCA88391A804898315D613`
- **sha256 dell'ELF decodificato:** `CDBC3C3D901D534B66C6FE4C0E4248E968AA2F6333F8F9C10B052B5FAD7D6361`

## Build e prova (Linux)

```sh
cd seed/linux-x86_64
xxd -r -p seed.hex seed
chmod +x seed
./seed ../../../tests/probes/test_simple.td   # stampa: test
echo $?          # 0
sh check_seed.sh # 7 casi di accettazione (contratto errori/limiti), byte-exatti
```

Gate completo dalla radice del repository (conformance 42 + probe + golden S1 + smoke):

```sh
sh verify.sh
```

Verifiche opzionali con binutils:

```sh
readelf -h seed      # ELF64, ET_EXEC, entry 0x400078
readelf -l seed      # un PT_LOAD R E
```

## Riproducibilità

```sh
node seed/dev/gen_seed.js linux seed/linux-x86_64/seed.hex
```

(il path di uscita predefinito è già `seed/linux-x86_64/seed.hex`; la forma esplicita
è mostrata per chiarezza). Il dump è la fonte canonica e riproducibile; l'ELF prodotto
può essere committato insieme a esso (non è più in `.gitignore`). Il generatore è uno
strumento di sviluppo e non fa parte della catena S0→S4. Il job CI `seed-linux` riesegue
il generatore e richiede l'uguaglianza con `cmp` (anti-drift), più `check_seed.sh` e
`verify.sh`.

## Limiti noti (invariati rispetto al PE)

- Buffer del path: 256 byte, copia non limitata (rispecchia il parsing di
  `GetCommandLineA` nel PE).
- Sorgente: max `0xFFFFF` byte (1 MiB − 1, arena N20; `0x100000` è lo slot della mask);
  buffer di lettura `0x100000`. Una sorgente di `0x100000` byte o più è rifiutata
  (exit 1).
- I limiti del dominio di codice macchina del PE (heap dei letterali di lista, scope
  dinamico, massimo 4 parametri, letterali di lista su più righe, …) sono misurati e
  registrati in
  [`tests/probes/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/tests/probes/README.md).
  Tutti i 42 casi Core, `liste` compreso, sono richiesti dal gate senza esclusioni.

## Prossimi passi

- **E3 (N18) ✅ chiusa:** toolchain Linux senza Node — `install.sh` → `bin/triad` con
  questo seed come unico runtime (la logica di stub/fallback è uscita dal launcher),
  CLI POSIX `bin/triad-cli` (`run`/`test`/`status`), CI `seed-linux` sull'ELF nativo.

> **Task principale dal 2026-11-03:** E1/E2/E3 sono la task principale del progetto
> (`TASK.md` → «Task principale (2026-11-03): seed Linux nativo — senza Wine», N15–N18)
> e precedono N03 e le altre sotto-task meccaniche.

La toolchain POSIX è pronta: `./install.sh` ridecodifica questo seed da `seed.hex`
(anti-drift), installa `bin/triad` e `bin/triad-cli` come wrapper a percorso assoluto in
`~/.local/bin` e supera uno **smoke test byte-exatto** (mismatch => installazione
fallisce). Il launcher esegue sempre il seed: nessun fallback JS nel percorso utente
(il riferimento `../dev/triad_core.cjs` resta solo nel tooling di sviluppo). Il job CI
`linux-toolchain` copre launcher + install + gate; `seed-linux` copre check_seed.sh,
hash PE/ELF, dump riproducibili e `verify.sh`.

Vedi [`../dev/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/seed/dev/README.md) e
[`../../BOOTSTRAP.md`](https://github.com/GPuntobit/triad2.0/blob/main/BOOTSTRAP.md).
