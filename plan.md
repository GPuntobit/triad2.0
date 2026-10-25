---
agent: devin-local
session: mire-aardwolf
created: 2026-10-22T18:16:39Z
updated: 2026-10-25
---
# Piano per completare Triad 2.0 - Stato Aggiornato

## Stato Attuale (Giorno 3)

### Seed S0 Windows - COMPLETATO ✅
- **PE**: 25.088 byte, codice 8315 byte
- **Hash**: `9987105DCD56F42A1AD73451821A281E6F24374ED6CE83993BB8CA56F5EC4822`
- **Funzionalità**:
  - Interi, variabili, funzioni (forma breve e blocco)
  - Ricorsione, Bool, operatori (`% ^ ! && || +=`)
  - `if`/`elseif`/`else`, `while`, `let`, `begin`
  - Lambda, chiusure base
  - Stringhe base + concatenazione + `string(Int/String)`
  - Liste complete (costruzione, stampa, `push!`, `get`)
  - `nothing`, simboli
- **Conformance**: 29/30 casi Windows, 33/33 Core Julia
- **Bug fixato**: `string()` Int conversione (r10 inizializzato correttamente)

### S1 (Interprete Triad in Triad-Core) - IN CORSO 🔄
- **S1.3**: Sistema di valori taggati (Int, Bool) ✅ completato
- **S1.4**: Parser/tokenizer inline ✅ completato
- **S1.5**: Eval espressioni base - ❌ bug (output vuoto nel lookup ambiente)
- **S1.8**: Variabili con let - pending
- **S1.11-S1.15**: Parser completo, funzioni, chiusure, test - pending

### S2-S4 (Bootstrap) - NON INIZIATO
- S2: Compilatore nativo
- S3: Self-hosting
- S4: Runtime completo, Linux parity

## Task Correnti

### Immediato: Debug S1.5
- L'eval degli identificatori produce output vuoto
- Probabile bug nel lookup ambiente o condizione while
- Necessario aggiungere println per debug o semplificare l'approccio

### Dopo S1.5
- S1.8: Variabili con let e scope
- S1.11: Parser completo (if/else, while, function)
- S1.12: Eval programmi completi
- S1.13: Funzioni e chiamate
- S1.14: Chiusure e ricorsione
- S1.15: Test conformance suite

## File S1 Implementati
- `selfhost/value.td`: Sistema di valori taggati
- `selfhost/tokenizer.td`: Parser/tokenizer inline
- `selfhost/eval.td`: Eval espressioni base (bug)
- `selfhost/main.td`: Ambiente inline funzionante

## Limitazioni Seed Attuali
- `string()`: solo Int/String (Bool/Symbol/Nothing non implementati ma non richiesti per conformance)
- Liste: solo interi, max 64 elementi
- Indicizzazione standard, `length`, iterazione: non implementati
- Conformance: 29/30 (if_else l'unico fallimento noto)

## Stato Conformance
- Stage0 Julia: 33/33 Core, 12/12 Full
- Seed Windows: 29/30 Core
- Seed Linux: E0 minimale (non comparabile)
