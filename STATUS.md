# Stato di Triad e del bootstrap S0

Aggiornato dopo la verifica A02.

## Obiettivo

Triad come linguaggio autonomo e riconosciuto: standard proprio, conformance, estensione `.triad`, tooling editor, bootstrap senza linguaggi ospiti e self-hosting.

## Cosa è pronto

- **Standard**: `SPEC.md` (v0.2.0), `SPEC-CORE.md`, `VERSION`, `CHANGELOG.md`.
- **Conformance**: runner indipendente; 12 casi Triad-Full e 36 casi Triad-Core, tutti verdi sul seed; `conformance/README.md`.
- **Estensione canonica**: `.triad` (`.td` alias storico), grammatiche VS Code/Vim e voce Linguist preparata.
- **Seed S0** (Windows PE, nessun runtime/compilatore): interprete Triad-Core con
  supporto per interi, variabili, funzioni (forma breve e `function … end` multi-istruzione),
  ricorsione, Bool, operatori (`% ^ ! && || +=`), `if`/`elseif`/`else`, `while`, `let`, `begin`,
  lambda, chiusure con cattura per valore, stringhe base + concatenazione + `string()`,
  `nothing`, simboli e costruzione/stampa di liste di interi.
- **Launcher/CLI**: il runtime predefinito per `.triad` è il seed in codice macchina (`bin/triad`, `bin/triad.cmd`, `cli/lib/utils.mjs`); Julia resta uno strumento di sviluppo (test, conformance, packaging).
- **CI**: `.github/workflows/ci.yml` — conformance Full/Core su Ubuntu e Windows, casi del seed su Windows, hash check.

## Cosa manca

| area | stato |
|---|---|
| `stringhe` (`string()`) | ✅ implementato (Int/String); Bool/Symbol/Nothing non implementati |
| `liste` | costruzione/stampa e `push!` di liste di interi implementati; indicizzazione standard, `length` e iterazione non supportati dal seed |
| `valori` (liste/simboli/stringhe insieme) | parziale; liste solo intere, senza operazioni o valori misti |
| `controllo` (`elseif`) | ✅ implementato |
| S1 (Triad in Triad-Core) | in corso |
| S2–S3 (compilatore nativo, self-hosting) | non iniziati |
| S4 / M7 (parità, Linux ELF) | **E0 ✅** ELF Linux minimale; E1/E2/E3 e parità da fare |

## Comandi di verifica

```sh
```

Windows, seed:

```powershell
certutil -decodehex -f seed/windows-x86_64/seed.hex seed/windows-x86_64/seed.exe
.\seed\windows-x86_64\seed.exe conformance\core\cases\closure\program.td
```

## Riconoscimento esterno (richiede il maintainer)

- `LICENSE` aggiunta (MIT, 2026-10-22);
- PR a GitHub Linguist con `editors/linguist/languages.yml`;
- pubblicazione delle estensioni VS Code / Open VSX e Vim;
- eventuale registrazione del linguaggio/standard.
## Verifica finale (round 31; baseline precedente)

- Seed S0 Windows: PE 25088 byte, hash `445CB428EFF44B39C2103DF776E6D9A1D1B5BDD8904C2C93D661950321C4ED60`, dump riproducibile.
- Stage0: **Triad-Core 31/31**, **Triad-Full 12/12**.
- Seed Windows: nuova regressione `funzioni_io` verificata con stdout byte-esatto; 27/28 casi elencati nel job CI passano localmente. `if_else` termina con exit `1` (anche col PE precedente); la verifica CI ospitata resta necessaria.
- CI: hash del seed aggiornato; matrice Ubuntu/Windows per conformance e job Windows per il seed.

### Casi Core non ancora coperti dal seed

- `liste`: il seed copre costruzione, stampa e `push!` di liste di interi; indicizzazione
  standard, `length`, iterazione e valori misti restano da implementare.
- `valori`: supporto parziale; mancano valori misti e gestione completa delle stringhe.

### Distanza dall'obiettivo

L'obiettivo **non è completo**:
- S0 è un interprete in codice macchina, ma **S1 (Triad in Triad-Core) non è iniziato**, quindi non c'è ancora self-hosting;
- S2–S3 (compilatore nativo in Triad, fixed point) non iniziati;
- S4/M7 (parità conformance, port Linux ELF) non iniziati; l'artefatto E0 esiste (`seed/linux-x86_64/seed.hex`), la CI è pronta ma la parità non è iniziata;
- riconoscimento esterno: LICENSE MIT scelta; PR Linguist e pubblicazione estensioni richiedono il maintainer.

## Verifica seed Windows (round 32)

- Corretto il crash causato dalla sovrapposizione dei nomi import PE con il codice macchina:
  il generatore collocava i nomi a RVA `0x2cde`, dentro il codice che era cresciuto oltre
  tale offset. Ora i nomi iniziano a RVA `0x5000`.
- Aggiunto `liste_base`: costruzione e stampa `[1, 2, 3]`; il seed esce con codice `0`.
  Restano non supportati indexing, `push!`, `length`, iterazione e liste con elementi non interi.
- Il job locale Windows passa 28/29 casi inclusa la nuova regressione; `if_else` resta
  l'unico fallimento noto (exit `1`). La suite Julia della nuova conformance passa.
- PE rigenerato: 25.088 byte; SHA-256 del dump: `1B88C89A9D3EACD0D05594BC2CECFAA3A4B56A0B76553F904CB96339F4B3CE65`.

## Probe `get` seed Windows (round 33)

- Il generatore conteneva già il corpo di `get`, ma il dispatcher delle chiamate non
  riconosceva il nome; inoltre il corpo leggeva gli argomenti dallo stack in ordine errato.
- Aggiunto il dispatch e corretto l'accesso 0-based con controlli su tipo lista, tipo indice
  e limiti. `test_get.td` ora stampa `20` ed esce con codice `0`; il probe è verificato
  anche nel job CI Windows.
- `get(xs, i)` è un helper extra del seed e non una primitiva definita da Triad-Core.
  L'indicizzazione standard `xs[i]` resta 1-based e non è ancora implementata dal seed.
- Dump HEX riproducibile: SHA-256 `EF8EB3D7DB47B55E2C455B8D79A45351EC80F1BBA01CA8918951FF1F15D7A802`.

## Probe `push!` seed Windows (round 34)

- Collegato il builtin `push!` al dispatcher, aggiunto il suffisso `!` al parsing degli
  identificatori e corretto l'append: la lista mutata viene restituita, con limite seed di
  64 elementi.
- `test_push.td` e il nuovo caso Core `liste_push` stampano `[10, 20]`; entrambi escono con
  codice `0`. `liste_push` è incluso nella CI Windows.
- L'implementazione seed resta limitata a liste di interi; indicizzazione Core, `length`,
  iterazione e stampa di valori misti non sono implementati.
- La matrice locale seed Windows passa 29/30 casi; `if_else` è l'unico caso ancora fallito
  (exit `1`). Tutti i 33 casi Core passano sul seed.
- PE: 25.088 byte; SHA-256 del dump: `76FC146BA7E070522A5445B5CC0810997E035CBC3135911F62B9C6E6B3CB255F`.

## Seed Windows: condizionali Triad-Core (A02)

- Corretto il dispatch di `if`/`elseif`/`else`: le condizioni `elseif` vengono valutate
  in ordine, i rami annidati sono delimitati correttamente e viene eseguito solo il primo
  ramo selezionato.
- Aggiunti i casi Core `if_elseif`, `if_nested` e `if_no_else`; il seed passa questi e
  `if_else` con output byte-esatto ed exit `0`. La conformance Core Julia passa tutti i
  casi.
- PE rigenerato: 25.088 byte, codice 8315 byte; SHA-256 di `seed.hex`:
  `9987105DCD56F42A1AD73451821A281E6F24374ED6CE83993BB8CA56F5EC4822`.

## Seed Windows: fix `string()` Int conversion (A03)

- Corretto bug in `pbs_int` (conversione Int→stringa): r10 veniva usato nel loop
  per scrivere le cifre PRIMA di essere inizializzato, causando access violation (0xC0000005).
- Spostato l'inizializzazione di r10 (`lea r10, [rbp-8]`) PRIMA del loop per garantire
  che punti sempre al buffer stack valido.
- Testato: `string(42)`, `string(0)`, `string(-5)`, `string("ciao")` funzionano correttamente.
- Conformance `stringhe` passa con output corretto: `ciao Triad\n5\n42`.
- Bool/Symbol/Nothing rimangono non implementati (crashavano anche prima; ora restituiscono fail).
