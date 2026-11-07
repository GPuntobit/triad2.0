# Triad CLI

La toolchain a riga di comando di Triad 2.0 è divisa in due livelli
(decisione *CLI e toolchain senza Node*, N18):

- **`bin/triad-cli`** — CLI **POSIX, senza Node**, per il percorso utente:
  `run` / `test` / `status`, pura delega su `bin/triad` e sugli harness
  (`conformance/gate.sh`, `conformance/run.sh`, `tests/probes/run_probes.sh`,
  `verify.sh`).
- **`cli/triad-cli.mjs`** — CLI **Node di sviluppo**, solo comandi dev:
  `seed generate`, `ai verify`, `ext check|package`.

## Percorso utente (senza Node)

Installazione (wrapper a percorso assoluto in `~/.local/bin`):

```bash
./install.sh                      # oppure: ./install.sh --prefix DIR
```

Comandi (`bin/triad-cli`, invocabile da qualunque directory):

```bash
triad-cli run <file> [-- args]     # esegue un programma Triad (.triad/.td)
triad-cli test conformance        # suite Core (39 casi; gap noti esclusi, vedi conformance/gate.sh)
triad-cli test conformance --strict   # oracle puro: fallisce su QUALSIASI caso non verde
triad-cli test conformance --update   # rigenera i golden (uso dev)
triad-cli test probes              # probe ok_*/test_*/bad_* + golden
triad-cli test all                 # gate completo (verify.sh)
triad-cli status                   # stato della toolchain e dell'ambiente
```

Exit code = quello del comando delegato; exit 2 = errori d'uso.

Esempio di output di `status` (deterministico, senza colori):

```
 _______  _____  ___   ___  ______
|__   __||  ___||   \\ /   ||  ____|
  | |   | |__  | |\\ V /| || |__
  | |   |  __| | | \\_/ | ||  __|
  | |   | |___ | |     | || |____
  |_|   |_____||_|     |_||______|
Triad toolchain status
  root: /home/user/triad2.0
  system: Linux x86_64
  seed: /home/user/triad2.0/seed/linux-x86_64/seed (eseguibile)
  install-path: /home/user/.local/bin (nel PATH)
```

## Comandi di sviluppo (Node.js ≥ 18)

```bash
cd cli && npm install              # dipendenze della CLI dev
```

Si invocano come `node cli/triad-cli.mjs <comando>` (oppure, su Windows,
`bin\triad-cli.cmd`):

```bash
node ../cli/triad-cli.mjs seed generate windows   # rigenera il dump PE
node ../cli/triad-cli.mjs seed generate linux     # rigenera il dump ELF
node ../cli/triad-cli.mjs ai verify               # verifica soluzioni AI
node ../cli/triad-cli.mjs ext check               # valida l'estensione VS Code
node ../cli/triad-cli.mjs ext package             # crea triad-<versione>.vsix
```

`seed generate` opzioni:
- `-o, --output <path>` — percorso del file hex (default: `seed/<piattaforma>-x86_64/seed.hex`)

`ai verify` opzioni:
- `-t, --tasks <dir>` — directory dei task (default: `ai/tasks`)
- `-v, --verbose` — output dettagliato

`ext package` opzioni:
- `-o, --out <path>` — percorso del `.vsix`

## Esecutabile standalone

`triad-cli.exe` (Windows) e `triad-cli` (Linux) allegati alla beta release
contengono Node.js e la CLI dev: copiarli nella radice del repository o in
`bin/` (oppure impostare `TRIAD_HOME`). Per ricompilarli (Node.js ≥ 20):

```bash
cd cli
npm install
npm run build:exe                         # piattaforma corrente
node build-exe.mjs path/to/win/node.exe   # triad-cli.exe (anche da Linux)
```

## Interfaccia desktop Windows

`TriadDesktop.exe` apre una finestra grafica e invoca i comandi della CLI
(`triad-cli.exe` in `cli\dist`, `bin` o radice del progetto). Per compilarla
con il compilatore .NET Framework:

```powershell
.\cli\windows-gui\build.ps1
```

## Requisiti

- **Percorso utente**: nessuna dipendenza oltre a una shell POSIX e il seed
  in codice macchina (promessa zero-install, `./install.sh`).
- **Comandi dev**: **Node.js** ≥ 18 (fuori dalla promessa zero-install).

## Architettura

```
bin/
├── triad                  # launcher POSIX: exec sempre del seed
├── triad-cli              # CLI POSIX senza Node (run/test/status)
├── triad.cmd              # launcher Windows (invariato)
└── triad-cli.cmd          # CLI dev Windows (invariato)
cli/
├── triad-cli.mjs          # CLI Node di sviluppo (seed/ai/ext)
├── package.json           # dipendenze Node.js
├── lib/
│   ├── utils.mjs          # utility (projectPath, runNode, fileExists)
│   └── commands/
│       ├── seed.mjs       # generazione seed (dev)
│       ├── ai.mjs         # verifica AI (dev)
│       └── ext.mjs        # estensione VS Code: check, package .vsix (dev)
└── README.md              # questa documentazione
```

## Note

- Il runtime per eseguire programmi Triad è il **seed in codice macchina**
  (`seed/linux-x86_64/seed` su Linux, `seed/windows-x86_64/seed.exe` su
  Windows): `bin/triad` lo esegue sempre, senza fallback JS né logica di
  stub. Il riferimento JS (`seed/dev/triad_core.cjs`) resta solo nel
  tooling di sviluppo.
