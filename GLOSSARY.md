# Triad 2.0

Linguaggio di programmazione autonomo con bootstrap senza linguaggi host: il lessico qui
definisce i termini del progetto e dei suoi sforzi (seed, bootstrap, parità, toolchain).

## Language

**Seed nativo**:
L'interprete Triad-Core in codice macchina della piattaforma corrente (PE su Windows, ELF
su Linux), l'artefatto eseguibile da cui la catena S0→S4 ha inizio.
_Avoid_: runtime, emulatore, binario precompilato

**Parità byte-a-byte**:
L'equivalenza fra due seed nativi: stessi programmi Triad-Core, stessi byte su stdout e
stessi exit code sulle suite di riferimento; i messaggi d'errore non fanno parte della
parità.
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

**Launcher**:
Il punto d'ingresso d'uso garantito per eseguire programmi Triad (`triad programma.td`):
l'unica interfaccia utente del percorso zero-install.
_Avoid_: runtime (è il seed nativo), wrapper (meccanismo d'installazione), script di avvio

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

**Golden**:
Il file che registra l'esito atteso di un caso di verifica (stdout ed exit code): il
registro del comportamento atteso su cui cade ogni confronto.
_Avoid_: expected, snapshot, fixture

**Gate di verifica**:
Il controllo il cui esito decide la validità del lavoro: tutte le suite di riferimento
verde sui golden.
_Avoid_: CI (è il meccanismo che lo esegue), test (generico)

**Sottoinsieme certificato**:
L'insieme dei programmi Triad-Core che il seed nativo esegue con semantica identica a
quella specificata. Ciò che ne sta fuori o è **rifiutato** (errore esplicito) o è
**divergente** (risultato diverso, senza errore): le due cose vanno distinte.
_Avoid_: sottoinsieme supportato (non distingue il rifiuto dalla divergenza), feature del seed

**Divergenza silenziosa**:
La differenza di comportamento rispetto alla specifica che produce un risultato sbagliato
**senza** segnalare errore. È più insidiosa del rifiuto esplicito: non si vede, e quindi
non può essere scoperta da un errore a runtime.
_Avoid_: bug (non è un difetto occasionale ma una non conformità misurata), mismatch

**Corpus certificato**:
L'insieme dei programmi che il seed deve poter eseguire, dichiarato in
`seed/dev/certified-corpus.txt`. Un programma nel corpus certificato è soggetto a tutti i
presidî (guardie statiche, gate differenziale seed↔JS); un programma che ne è fuori è
«fuori contratto»: viene comunque segnalato, ma come avviso.
_Avoid_: sorgenti S1 (il corpus certificato include anche i generatori del sito)

**Contratto del seed**:
La dichiarazione *machine-readable* di cosa il seed esegue, rifiuta o esegue in modo
divergente (`seed/dev/certified-subset.txt`, leggibile in `seed/README.md`). Le guardie
statiche sono legate alle sue voci: quando una divergenza sparisce dal contratto, la
regola corrispondente si spegne da sola.
_Avoid_: specifica del seed (il contratto descrive un'implementazione, non il linguaggio)

**Gate differenziale**:
Il confronto *byte per byte* dell'output di uno stesso programma su due runtime (il seed e
il riferimento JS), con confronto del codice di uscita. È il presidio delle divergenze che
una regola statica non può decidere (quelle che dipendono dai tipi a runtime).
_Avoid_: test (non confronta un risultato atteso, confronta due implementazioni)

**Range degli interi del seed**:
L'intervallo numerico che il seed sa rappresentare: `Int` è una parola taggata e i bit del
tag ne rubano due, quindi il payload è un intero signed a **62 bit**,
`[-2^61, 2^61-1]`. Un valore fuori range è **rifiutato** (exit 1), non prodotto
sbagliato: i 64 bit signed con wrap di `SPEC-CORE.md` §5 sono un vincolo per S1, che gira
sul seed e deve implementarli da sé.
_Avoid_: interi a 64 bit (non è vero per il seed), overflow silenzioso (il seed rifiuta)

## Bootstrap

**Catena S0→S4**:
La sequenza di stadi del bootstrap: seed in codice macchina (S0), implementazione completa
scritta in Triad-Core (S1), compilatore nativo scritto in Triad (S2), compilatore
self-hosted (S3), Triad completo (S4).
_Avoid_: pipeline di build, catena di release

**Punto fisso**:
La proprietà del compilatore nativo per cui ricompilare la propria sorgente produce un
binario identico byte-a-byte al proprio.
_Avoid_: fixed point, autocompilazione (è il processo, non la proprietà)

**Self-hosting**:
Lo stato della catena in cui il compilatore è compilato da sé stesso e nessun linguaggio
host partecipa.
_Avoid_: bootstrap (è il processo che porta allo stato)

**Seed ritirato**:
Lo stato in cui la catena d'uso e di ricostruzione non richiede più il seed, la cui
sorgente annotata resta versionata.
_Avoid_: rimosso, eliminato, decommissionato
