# Triad CLI

CLI unificata per gli strumenti di sviluppo del progetto Triad 2.0.

## Installazione

```bash
cd cli
npm install
```

Per usare la CLI da qualsiasi directory:

```bash
npm link    # Linux/macOS
# oppure aggiungi cli/ al PATH
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
  Julia: C:\Users\xbos\AppData\Local\Programs\Julia-1.13.1\bin\julia.exe

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

Questo comando richiede Julia e PackageCompiler installati. L'output sarà in `bin/triad-native` (o `triad-native.exe` su Windows).

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
- **Julia** ≥ 1.6 (per i comandi che wrappano script Julia)
- **PackageCompiler** (installato automaticamente dal comando build standalone)

## Architettura

La CLI è strutturata in moduli:

```
cli/
├── triad-cli.mjs           # Entry point principale
├── package.json            # Dipendenze Node.js
├── lib/
│   ├── utils.mjs           # Funzioni utility (trova Julia, esegui script)
│   └── commands/
│       ├── seed.mjs        # Generazione seed
│       ├── ai.mjs          # Verifica AI
│       ├── build.mjs       # Build standalone
│       └── test.mjs        # Test e conformance
└── README.md               # Questa documentazione
```

## Vantaggi

- **Interfaccia unificata:** Un singolo comando per tutte le operazioni di sviluppo
- **Cross-platform:** Node.js gestisce differenze Windows/Linux/macOS
- **Estensibile:** Facile aggiungere nuovi comandi
- **Non invasivo:** Non modifica i tool esistenti, li wrappa solo

## Note

- I comandi che wrappano script Julia richiedono Julia installato
- La CLI non sostituisce i launcher esistenti (`bin/triad`, `bin/triad.cmd`), ma fornisce un'interfaccia unificata per le operazioni di sviluppo
- Per eseguire programmi Triad, usa ancora i launcher standard o `julia triad.jl`
