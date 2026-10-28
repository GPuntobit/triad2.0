# Triad CLI

CLI unificata per gli strumenti di sviluppo del progetto Triad 2.0.

## Installazione

```bash
cd cli
npm install
```

Per usare la CLI da qualsiasi directory, aggiungi `bin/` al PATH e usa i launcher
`bin/triad-cli` (POSIX) o `bin\triad-cli.cmd` (Windows): al primo avvio eseguono
`npm install` in `cli/` se manca `node_modules`. In alternativa `npm link` (Linux/macOS).

### Eseguibile standalone

`triad-cli.exe` (Windows) e `triad-cli` (Linux) sono allegati alla release beta: contengono
Node.js e la CLI, quindi non serve `npm install`. Copiali nella root del repository o in
`bin/` (oppure imposta `TRIAD_HOME`): la CLI trova il progetto risalendo da `TRIAD_HOME`,
dalla posizione dell'eseguibile e dalla cartella corrente. `test`, `seed generate`
richiedono comunque `node` nel PATH, perché eseguono `conformance/run.mjs` e `seed/dev/*.js`.

Per ricostruirli (Node.js >= 20; il binario Node passato decide la piattaforma):

```bash
cd cli
npm install
npm run build:exe                         # eseguibile per la piattaforma corrente
node build-exe.mjs path/to/win/node.exe   # triad-cli.exe per Windows (anche da Linux)
```

## Comandi

### Status

Mostra lo stato del progetto e informazioni sull'ambiente:

```bash
triad-cli status
```

Output esempio:
```
Triad 2.0 CLI Status

Environment:
  Node.js: v24.22.0
  Platform: win32
  Seed: C:\Users\xbos\Documents\progetti\triad2.0\seed\windows-x86_64\seed.exe

Project:
  Root: C:\Users\xbos\Documents\progetti\triad2.0
```

### Seed Generation

Genera i seed binari per Windows o Linux:

```bash
triad-cli seed generate windows    # Genera seed Windows
triad-cli seed generate linux      # Genera seed Linux
```

Opzioni:
- `-o, --output <path>` - Percorso di output del file hex (default: `seed/<platform>-x86_64/seed.hex`)

### AI Verification

Verifica le soluzioni generate da LLM contro i test golden:

```bash
triad-cli ai verify
```

Opzioni:
- `-t, --tasks <dir>` - Directory dei task (default: `ai/tasks`)
- `-v, --verbose` - Output dettagliato

### Build Standalone

Compila l'eseguibile standalone di Triad:

```bash
triad-cli build standalone
```

### Run

Esegue un programma Triad (`.triad`/`.td`) con il runtime:

```bash
triad-cli run test_simple.td
triad-cli run prog.triad -- arg1 arg2     # argomenti al programma Triad
```

Opzioni:
- `-v, --verbose` - Output dettagliato in caso di errore
- `-n, --native` - Forza il seed in codice macchina (salta il fallback JS)

Note: su Windows usa il seed (`seed/windows-x86_64/seed.exe` o `bin/triad-native.exe`);
su Linux/Mac, finché il seed è uno stub (E0), usa l'interprete JS di riferimento
`seed/dev/triad_core.cjs`, come fa `conformance/run.mjs`.

### Estensione VS Code

Verifica la struttura dell'estensione in `editors/vscode` (package.json, grammatica,
language-configuration) e la pacchettizza in un `.vsix`:

```bash
triad-cli ext check      # validazione struttura
triad-cli ext package    # crea triad-<versione>.vsix via vsce (o npx @vscode/vsce)
```

Opzioni di `ext package`:
- `-o, --out <path>` - Percorso di output del `.vsix`

Installazione del pacchetto: `code --install-extension triad-0.2.0.vsix`


### Test

Esegue i test unitari:

```bash
triad-cli test run
```

Opzioni:
- `-v, --verbose` - Output dettagliato

Esegue la conformance suite:

```bash
triad-cli test conformance
```

Opzioni:
- `-u, --update` - Aggiorna i golden output (solo sviluppo)
- `-c, --cases <path>` - Directory specifica dei casi

## Requisiti

- **Node.js** ≥ 18.0.0
- **Seed** in codice macchina (runtime predefinito per `.triad`)

## Architettura

La CLI è strutturata in moduli:

```
cli/
├── triad-cli.mjs           # Entry point principale
├── package.json            # Dipendenze Node.js
├── lib/
│   ├── utils.mjs           # Funzioni utility (trova seed, esegui script)
│   └── commands/
│       ├── seed.mjs        # Generazione seed
│       ├── ai.mjs          # Verifica AI
│       ├── build.mjs       # Build standalone
│       ├── run.mjs         # Esecuzione programmi .triad/.td
│       ├── ext.mjs         # Estensione VS Code (check, package .vsix)
│       └── test.mjs        # Test e conformance
└── README.md               # Questa documentazione
```

## Vantaggi

- **Interfaccia unificata:** Un singolo comando per tutte le operazioni di sviluppo
- **Cross-platform:** Node.js gestisce differenze Windows/Linux/macOS
- **Estensibile:** Facile aggiungere nuovi comandi
- **Non invasivo:** Non modifica i tool esistenti, li wrappa solo

## Note

- Il runtime per eseguire programmi Triad è il seed in codice macchina (o `bin/triad-native`); usa `triad`/`triad.cmd` o `triad-cli` per le operazioni di sviluppo
