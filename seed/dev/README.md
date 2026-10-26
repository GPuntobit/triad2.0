# Strumenti di sviluppo del seed (NON parte della catena S0→S4)

Questa cartella contiene strumenti di **manutenzione** del seed in codice macchina. Non
fanno parte del prodotto, non sono richiesti per costruire o usare Triad e non introducono
dipendenze nella catena di bootstrap: la fonte del seed resta il dump esadecimale
(`../windows-x86_64/seed.hex`, `../linux-x86_64/seed.hex`), materializzabile con un semplice
decodificatore di sistema (`certutil -decodehex` / `xxd -r -p`).

## `gen_seed.js`

Generatore del PE Windows del seed (Node.js, solo sviluppo). Contiene l'assembler-lite e la
descrizione delle strutture PE; produce `seed.hex` e ne stampa etichette e dimensioni.

```sh
node seed/dev/gen_seed.js seed/windows-x86_64/seed.hex
```

Output corrente: PE da **25088 byte**, sha256 di `seed.hex` (lo stesso verificato dalla CI):

```
3A75A21E2F47D8DC4C88D4BC2580A85D5349BCDF7550E5FFA16E2C0AC7CA8C11
```

## `gen_seed_linux.js`

Generatore dell'ELF Linux x86-64 del seed (E0: syscall `write`/`exit`, messaggio
`Triad seed Linux OK`). Costruisce ELF64 statico, entry `0x400078`, un solo `PT_LOAD` R|X.

```sh
node seed/dev/gen_seed_linux.js seed/linux-x86_64/seed.hex
```

Output corrente: ELF da **173 byte**, sha256 di `seed.hex`:

```
AD4C9F08176D9964D5BE17D44C72230184434025980447395E7A3250F63CA5EA
```

sha256 dell'ELF decodificato:
`6d504451e1d8a39c6e139a8a120bfaf03373131894292be12f0039eb8a7797f9`.

Lo script verifica magic, `e_machine`, entry e round-trip del dump prima di uscire.

## Perché sono versionati

Scrivere un interprete in byte a mano senza un generatore è impraticabile oltre poche
istruzioni; perdere il generatore blocca l'estensione del seed. Tenerli qui rende il lavoro
riproducibile e verificabile contro gli hash.

## Regole

- il **prodotto** e la catena S0–S4 non usano Node né questi file;
- i dump `seed.hex` sono la fonte committata; i generatori sono attrezzi, non dipendenze;
- ogni modifica a un generatore deve rigenerare il dump e aggiornare hash/documentazione
  (`../windows-x86_64/README.md`, `../linux-x86_64/README.md`).
