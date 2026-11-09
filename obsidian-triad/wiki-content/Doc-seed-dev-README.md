> Copia di [`seed/dev/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/seed/dev/README.md) — torna a [Documenti](Documenti) · [Home](Home)

# Strumenti di sviluppo del seed (NON parte della catena S0→S4)

Questa cartella contiene strumenti di **manutenzione** del seed in codice macchina. Non
fanno parte del prodotto, non sono richiesti per costruire o usare Triad e non introducono
dipendenze nella catena di bootstrap: la fonte del seed resta il dump esadecimale
(`../windows-x86_64/seed.hex`, `../linux-x86_64/seed.hex`), materializzabile con un semplice
decodificatore di sistema (`certutil -decodehex` / `xxd -r -p`).

## `gen_seed.js`

Unico entry point del generatore del seed (Node.js, solo sviluppo):

```sh
node seed/dev/gen_seed.js <windows|linux|all> [out.hex]
```

`windows` e `linux` rigenerano un dump nel suo path canonico
(`../windows-x86_64/seed.hex`, `../linux-x86_64/seed.hex`; `out.hex` lo sovrascrive),
`all` rigenera entrambi. Struttura (decisione 02,
`.scratch/seed-linux-nativo/issues/02`): l'assembler-lite e il **codegen condiviso**
(corpo dell'interprete + confine `os_*`) stanno in `core.js`; i due backend contengono
le emissioni inline `os_*` (posizionamento ordinato degli slot secondo il contratto
`os_*`), le costanti di sistema e i builder dell'eseguibile — `backend_pe.js` (PE
Windows) e `backend_elf.js` (ELF Linux).

Output corrente:

- **windows:** PE da 25088 byte, sha256 di `seed.hex` (verificato dalla CI):
  `20AA566DAE21D2B102E684F7A8C1B67B1B2B44C61C1116E16D196DE31683D7B7`
- **linux** (E2, interprete Triad-Core): ELF da 11977 byte (entry `0x400078`, un solo
  `PT_LOAD` R|X), sha256 di `seed.hex`:
  `8457051F7D083AB834EC860502605A58F1ECCE4A5ABCA88391A804898315D613`,
  sha256 dell'ELF decodificato:
  `CDBC3C3D901D534B66C6FE4C0E4248E968AA2F6333F8F9C10B052B5FAD7D6361`

## Perché sono versionati

Scrivere un interprete in byte a mano senza un generatore è impraticabile oltre poche
istruzioni; perdere il generatore blocca l'estensione del seed. Tenerli qui rende il lavoro
riproducibile e verificabile contro gli hash.

## Regole

- il **prodotto** e la catena S0–S4 non usano Node né questi file;
- i dump `seed.hex` sono la fonte committata; i generatori sono attrezzi, non dipendenze;
- ogni modifica a un generatore deve rigenerare il dump e aggiornare hash/documentazione
  (`../windows-x86_64/README.md`, `../linux-x86_64/README.md`).
