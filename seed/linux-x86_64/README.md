# S0 / Linux x86-64 — seed ELF (E0)

Primo passo del port Linux: un **ELF64 statico** senza libc né linker dinamico, che usa
solo syscall Linux e stampa:

```
Triad seed Linux OK
```

ed esce con `0`. Non è ancora l'interprete Triad-Core: serve a validare header ELF, entry
`_start`, syscall e caricamento su CachyOS/Linux x86-64.

Il dump esadecimale è [`seed.hex`](seed.hex): è la fonte committata.

## Numeri

- **File ELF:** 173 byte (`0xAD`)
- **Codice macchina:** 33 byte; messaggio: 20 byte
- **Base:** `0x400000`; **entry:** `0x400078`
- **Program header:** un solo `PT_LOAD` R|X, offset 0, filesz/memsz `0xAD`, align `0x1000`
- **sha256 di `seed.hex`:** `AD4C9F08176D9964D5BE17D44C72230184434025980447395E7A3250F63CA5EA`
- **sha256 dell'ELF decodificato:** `6d504451e1d8a39c6e139a8a120bfaf03373131894292be12f0039eb8a7797f9`

## Build e prova (Linux)

```sh
cd seed/linux-x86_64
xxd -r -p seed.hex seed
chmod +x seed
./seed
echo $?          # 0
```

Output atteso:

```
Triad seed Linux OK
```

Verifiche opzionali con binutils:

```sh
readelf -h seed      # ELF64, ET_EXEC, entry 0x400078
readelf -l seed      # un PT_LOAD R E
objdump -d seed      # write(1,msg,20); exit(0)
```

## Riproducibilità

```sh
node seed/dev/gen_seed_linux.js seed/linux-x86_64/seed.hex
```

Il dump è la fonte canonica e riproducibile; l'ELF prodotto può essere committato
insieme a esso (non è più in `.gitignore`). Il generatore è uno strumento di sviluppo
e non fa parte della catena S0→S4.

## Prossimi passi

- **E1:** `_start` con argc/argv, `openat`/`read`/`write` per leggere un file.
- **E2:** port dell'interprete Triad-Core; obiettivo i 26 casi Core supportati dal seed
  Windows.
- **E3:** job CI Linux nativo senza Wine.

Nel frattempo la toolchain POSIX è pronta: `./install.sh` decodifica questo seed,
installa `bin/triad` e `bin/triad-cli` in `~/.local/bin` e i launcher usano
automaticamente l'interprete JS di riferimento finché il seed resta uno stub E0
(soglia: 4 KB). Il job CI `linux-toolchain` copre launcher + install + conformance.

Vedi [`../dev/README.md`](../dev/README.md) e [`../../BOOTSTRAP.md`](../../BOOTSTRAP.md).
