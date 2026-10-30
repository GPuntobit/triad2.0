# Capitolo 20 — Il seed in codice macchina

Il seed è il primo anello della catena: un interprete Triad-Core scritto direttamente in byte
x86-64, senza compilatore né assembler. Questo capitolo spiega com'è fatto e come si modifica.

## 20.1 Che cos'è

`seed/windows-x86_64/seed.exe` è un eseguibile PE32+ di 25 088 byte che importa solo funzioni di
`KERNEL32.dll` (`GetStdHandle`, `GetCommandLineA`, `CreateFileA`, `ReadFile`, `WriteFile`,
`CloseHandle`, `ExitProcess`, `VirtualAlloc`): niente libc, niente runtime. La sua fonte è il
dump `seed.hex`, la cui impronta SHA-256 è verificata dalla CI. Il seed non costruisce un albero
sintattico: interpreta direttamente il testo, con un cursore che scorre i byte del sorgente, e
riesegue il testo del corpo di una funzione a ogni chiamata.

## 20.2 Registri e memoria

Il codice segue convenzioni fisse sull'uso dei registri:

| registro | ruolo |
|---|---|
| `r14` | base della memoria allocata con `VirtualAlloc` |
| `r15` | ambiente delle variabili |
| `rbx` | numero di variabili |
| `r13` | tabella delle funzioni |
| `r12` | handle dello standard output |
| `rsi` | cursore nel sorgente |

I valori sono **parole taggate**: un intero `n` è rappresentato come `n << 2`, `false` come 1,
`true` come 5, una chiusura come puntatore con il bit 1 acceso, gli oggetti sullo heap (come le
stringhe) con tag 3. Il layout completo della memoria e la mappa delle etichette sono in
[`seed/windows-x86_64/README.md`](Doc-seed-windows-README).

## 20.3 Il generatore

Scrivere migliaia di byte a mano non è praticabile: `seed/dev/gen_seed.js` è un piccolo
assembler scritto in JavaScript. Funzioni come `B(...)` emettono byte, `L(nome)` definisce
un'etichetta, `je`, `jne`, `jmp`, `callL` emettono salti con indirizzi risolti alla fine,
`callIat(i)` chiama l'i-esima funzione importata; altri aiutanti con il nome dell'istruzione
(`leaRip`, `movRaxMemRip`, `movMemRipRax`, `xorR`, …) emettono le istruzioni x86-64
corrispondenti, e `reloc` registra gli indirizzi da correggere. In fondo, il
"PE builder" scrive intestazioni, sezione di codice e tabelle di importazione, e salva il dump.

## 20.4 Come si modifica

1. Modifica `seed/dev/gen_seed.js`.
2. Rigenera il dump: `node seed/dev/gen_seed.js seed/windows-x86_64/seed.hex`.
3. Su Windows, decodifica: `certutil -decodehex -f seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe`.
4. Esegui i casi Core sul seed.
5. Aggiorna l'impronta in `.github/workflows/ci.yml` e nei README, e `STATUS.md`.

Le trappole incontrate finora, documentate in `STATUS.md`, sono istruttive: codice cresciuto
fino a sovrapporsi ai dati, registri usati prima di essere inizializzati, argomenti letti dallo
stack nell'ordine sbagliato.

## 20.5 Il seed Linux

`seed/linux-x86_64/seed` è un ELF di 173 byte generato da `seed/dev/gen_seed_linux.js`: stampa
`Triad seed Linux OK` con chiamate di sistema dirette. È lo stadio E0 della milestone M7; gli
stadi successivi porteranno su Linux la logica dell'interprete.

## Riepilogo

- Il seed è codice macchina generato da un dump verificato; usa solo `KERNEL32`.
- Registri a ruolo fisso e valori taggati a 2 bit.
- `gen_seed.js` è l'assembler di sviluppo; ogni modifica aggiorna dump, impronta e documenti.
<!-- nav -->

---

← [Capitolo 19 — L'interprete di riferimento](Libro-19-Interprete-di-riferimento) · [Sommario](Home) · [Capitolo 21 — Verso il self-hosting](Libro-21-Self-hosting) →
