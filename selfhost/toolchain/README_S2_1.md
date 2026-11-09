# TRIAD S2.1 — Assembler nativo x86-64 con etichette e rilocazioni locali

**Stato:** prototipo sperimentale. Tutto il parsing del linguaggio assembler,
la risoluzione dei simboli, la selezione degli opcode, il calcolo dei salti e
la costruzione del file ELF64 sono implementati in **Triad-Core**, eseguito
dal seed nativo `bin/triad`. Non ci sono dipendenze JavaScript, Node.js,
Python, C, Rust o altri assemblatori nel generatore.

Il launcher `assemble.sh` usa esclusivamente shell POSIX per validare e
trasportare byte da un file `.s2asm` al programma Triad e usa `xxd -r -p`
per convertire l'output esadecimale in byte eseguibili: **non assembla
nessuna istruzione e non risolve etichette**.

## Utilizzo

```sh
sh selfhost/toolchain/assemble.sh \
  selfhost/toolchain/tests/fixtures/forward.s2asm /tmp/triad-forward
/tmp/triad-forward
echo "$?"  # 42

sh selfhost/toolchain/tests/run_s2_1.sh
```

## Sintassi del sottoinsieme S2.1

Una istruzione o etichetta per riga, nome e operando separati da spazi,
solo lettere minuscole ASCII, cifre e underscore. Nessun commento inline,
stringhe, espressioni o macro. Identificatori delle etichette: lettera
iniziale, poi lettere/cifre/underscore, massimo 40 caratteri. Nomi unici
nel file.

| Forma | Encoding x86-64 | Byte |
|---|---|---:|
| `label nome` | registra offset, nessun byte | 0 |
| `byte N` | byte costante, `0..255` | 1 |
| `nop` / `ret` | `90` / `c3` | 1 |
| `syscall` | `0f05` | 2 |
| `mov_edi N`, `mov_eax N`, `mov_edx N` | `bf/b8/ba imm32` | 5 |
| `add_edi N`, `sub_edi N`, `cmp_edi N` | `81 c7/ef/ff imm32` | 6 |
| `jmp nome`, `call nome` | `e9/e8 rel32` | 5 |
| `jz nome`, `jnz nome` | `0f 84/85 rel32` | 6 |
| `lea_rsi nome` | `48 8d 35 rel32` | 7 |

Gli immediati numerici sono decimali non negativi `0..65535`, eccetto
`byte` limitato a `0..255`. Questa restrizione è un contratto
del prototipo, non un limite dell'architettura x86-64.

La risoluzione dei simboli avviene in **due passaggi nativi**:
1. Validazione sintattica, lunghezze, offset delle etichette,
   rilevamento dei duplicati, budget del codice.
2. Generazione dei byte e dei displacement con segno
   `rel32 = offset_destinazione − (offset_istruzione + lunghezza)`.

Per il formato ELF il generatore usa un unico segmento `PT_LOAD`
leggibile/eseguibile, `ET_EXEC`, con base virtuale `0x400000`,
entrypoint `0x400078` e 120 byte di intestazioni. La dimensione
del segmento dipende dal numero effettivo di byte assemblati.

### Esempio: ciclo finito con salto negativo

```text
mov_edi 3
label loop
sub_edi 1
cmp_edi 0
jnz loop
mov_eax 60
syscall
```

La destinazione del salto condizionato è all'indietro:
`jnz loop` codifica un displacement `-18` (`0f85eeffffff`).
La macchina esce con stato `0` dopo tre iterazioni.

### Esempio: accesso a dati attraverso un indirizzo RIP-relative

Il file `tests/fixtures/rip_data.s2asm` usa `lea_rsi message`
per puntare a un byte `65` (la lettera `A`); poi invoca
`write(1, buffer, 1)` con un syscall Linux e termina con `exit(0)`.

## Test e protezioni

```sh
sh selfhost/toolchain/tests/run_s2_1.sh
sh selfhost/toolchain/tests/run.sh
sh verify.sh
```

La suite S2.1 confronta gli opcode del payload con golden indipendenti,
esegue realmente gli ELF su Linux e prova:
- salto in avanti con codice saltato, `exit(42)`;
- salto condizionato all'indietro, `exit(0)`;
- `add_edi`, `cmp_edi` e salto condizionato `jz` in avanti, `exit(5)`;
- `lea_rsi` su dati, output esatto `A`;
- `call`/`ret`, `exit(17)`;
- build deterministica byte per byte;
- rigetto di simboli non definiti, duplicati, opcode e arità errati,
  immediati fuori intervallo e tentativi di iniettare sorgente Triad.

Il launcher rifiuta caratteri non ammessi anziché interpolare input
eseguibile. Il codice binario ottenuto **non è un programma sandboxed**:
va eseguito soltanto se il suo input assembler è attendibile.

## Limiti e prossimi milestone

- È un **assembler per un sottoinsieme dichiarativo di istruzioni**,
  non un parser di sorgenti Triad, né un compilatore auto-ospitato completo.
- Non produce object file ELF relocatable, tabelle di simboli ELF,
  relocation di un linker esterno, librerie o PE/Windows.
  Le etichette sono risolte durante l'assemblaggio come displacement
  PC-relative all'interno di un solo payload.
- Supporta file di input di massimo 12.000 byte, massimo 1.024 statement
  e 4.096 byte di codice. Non è pensato per grandi moduli.
- Non genera né sostituisce `seed/linux-x86_64/seed.hex`;
  non implementa il linguaggio Triad-Full e non compila il compilatore.
- Il trasporto da/verso file è ancora POSIX/`xxd`, poiché la scrittura
  nativa dei file non fa parte delle primitive S0 verificate.

I successivi milestone prevedono un IR Triad tipizzato, ulteriori
istruzioni e operandi, relocation più generali e finalmente
la ricostruzione verificabile di parti del seed S0. La conformità
e l'assenza di JavaScript rimangono prerequisiti a ogni passo.
