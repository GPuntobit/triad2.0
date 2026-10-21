# Strumenti di sviluppo del seed (NON parte della catena S0→S4)

Questa cartella contiene strumenti di **manutenzione** del seed in codice macchina. Non
fanno parte del prodotto, non sono richiesti per costruire o usare Triad e non introducono
dipendenze nella catena di bootstrap: la fonte del seed resta il dump esadecimale
`../windows-x86_64/seed.hex`, materializzabile con un semplice decodificatore di sistema
(`certutil -decodehex` / `xxd -r -p`).

## `gen_seed.js`

Generatore del PE del seed (Node.js, solo sviluppo). Contiene l'assembler-lite e la
descrizione delle strutture PE; produce `seed.hex` e ne stampa etichette e dimensioni.

```sh
node seed/dev/gen_seed.js seed/windows-x86_64/seed.hex
```

Output corrente: PE da **8704 byte**, codice **6866 byte**, sha256 di `seed.hex`:

```
73B1C5852C4D60129F0D87FEFAF15CB7EEA4BEAF9EA4B9738943648D6EE39470
```

Se l'hash non corrisponde, il generatore e il dump sono divergenti: va corretto prima di
considerare valido il seed.

## Perché è versionato

Scrivere un interprete in byte a mano senza un generatore è impraticabile oltre poche
istruzioni; perdere il generatore blocca l'estensione del seed (è già successo una volta in
questa sessione, ed è stato ricostruito e verificato contro l'hash). Tenerlo qui rende il
lavoro riproducibile e verificabile.

## Regole

- il **prodotto** e la catena S0–S4 non usano Node né questo file;
- il dump `seed.hex` è la fonte committata; il generatore è un attrezzo, non una dipendenza;
- ogni modifica al generatore deve rigenerare il dump e aggiornare hash/documentazione in
  `../windows-x86_64/README.md`.
