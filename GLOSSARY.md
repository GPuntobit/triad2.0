# Triad 2.0

Linguaggio di programmazione autonomo con bootstrap senza linguaggi host: il lessico qui
definisce i termini del progetto e dei suoi sforzi (seed, bootstrap, parità, toolchain).

## Language

**Seed nativo**:
L'interprete Triad-Core in codice macchina della piattaforma corrente (PE su Windows, ELF
su Linux), l'unico artefatto eseguibile della catena S0→S4.
_Avoid_: runtime, emulatore, binario precompilato

**Parità byte-a-byte**:
L'equivalenza fra due seed nativi: stessi programmi Triad-Core, stessi byte su stdout e
stesso comportamento di uscita sulle suite di riferimento.
_Avoid_: compatibilità, equivalenza funzionale

**Immutabilità del PE**:
Il vincolo per cui i byte del seed PE versionato restano invariati durante il lavoro
strutturale; solo un cambiamento semantico deliberato può rigenerarlo.
_Avoid_: byte-identico (ambiguo con Parità byte-a-byte), congelamento

**Riproducibilità del dump**:
La proprietà per cui i generatori rigenerano esattamente gli artefatti versionati
(`seed.hex` e gli eseguibili decodificati).
_Avoid_: determinismo del generatore, rebuild pulito

**Zero-install**:
La garanzia sul percorso di esecuzione: eseguire programmi Triad richiede solo il checkout
della repository e una shell POSIX, nessun Wine, Node o linguaggio host installato.
_Avoid_: standalone, portabile

**Core del codegen**:
La parte del generatore del seed condivisa da tutte le piattaforme: emissione delle
istruzioni x86-64 e codegen del corpo dell'interprete.
_Avoid_: generatore (ambiguo con l'intero strumento), interprete (è il programma, non il generatore)

**Backend di piattaforma**:
La parte del generatore del seed proprietaria di una piattaforma: formato dell'eseguibile,
fixup e costanti di sistema.
_Avoid_: emettitore (ambiguo con l'emettitore di istruzioni del core), port

**`os_*`**:
Il confine completo fra seed nativo e sistema operativo: l'unico livello in cui i seed
delle piattaforme differiscono.
_Avoid_: routine (ambiguo fra sottoroutine machine-code e funzioni del generatore), syscall (solo Linux), API KERNEL32 (solo Windows)

**Piazzamenti ordinati**:
La forma del contratto `os_*`: ogni chiamata del corpo è una lista ordinata di
materializzazioni di argomenti astratti (slot `handle`, `buf`, `len`, …) terminata
dalla chiamata; ogni backend li mappa sui propri registri nell'ordine della lista,
conservando byte-pa-byte l'emissione storica del PE.
_Avoid_: meta-linguaggio (è solo dati di piazzamento di slot di syscall), ABI (nessuna sottoroutine, nessuna convenzione di chiamata machine-code)

**Arena bump**:
La politica di memoria del seed: una sola regione fissa `0x40000` ottenuta con
`os_alloc` all'avvio; le allocazioni avanzano un puntatore, niente `free` niente GC
fino a S1.
_Avoid_: heap (implica free/riutilizzo), malloc
