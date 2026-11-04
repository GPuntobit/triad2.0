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

**Zero-install**:
La garanzia sul percorso di esecuzione: eseguire programmi Triad richiede solo il checkout
della repository e una shell POSIX, nessun Wine, Node o linguaggio host installato.
_Avoid_: standalone, portabile
