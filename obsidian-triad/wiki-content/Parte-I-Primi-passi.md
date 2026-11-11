<a id="parte-1"></a>

# Parte I — Primi passi

<a id="cap-1"></a>

## 1. Cos'è Triad

Triad è un linguaggio di programmazione autonomo che unisce tre paradigmi in una sintassi a
blocchi:

| influenza | idea ripresa in Triad |
|---|---|
| Julia | `function … end`, `struct`, tipi con `::`, multiple dispatch, operatori come funzioni, `if`/`for`/`while`/`let` |
| Prolog | `fact`, `rule`, unificazione con occurs-check, backtracking, `solve` con variabili logiche `?x` |
| Lisp | codice come dato (`Node`), `:( … )`/`quote` con `$`, macro |

A questi si aggiungono, come parte del linguaggio e non di una libreria: **errori come dati**
(`Err`), **contratti** (`requires`/`ensures`), **budget** (`with budget`), **tracce**
(`with trace`) ed **effetti dichiarati** (`!io`, `!state`).

### 1.1 Due profili: Core e Full

Lo standard definisce due profili di conformità (SPEC §16.1):

- **Triad-Core** ([`SPEC-CORE.md`](https://github.com/GPuntobit/triad2.0/blob/main/SPEC-CORE.md)): interi, Bool, stringhe, simboli, `nothing`,
  liste, funzioni, lambda e chiusure, `if`/`elseif`/`else`, `while`, `let`, `begin`, ternario,
  `return`/`break`/`continue`, più alcuni primitivi di bootstrap. È abbastanza piccolo da
  essere implementato in codice macchina scritto a mano e abbastanza espressivo da scriverci
  l'interprete di tutto Triad.
- **Triad-Full** ([`SPEC.md`](https://github.com/GPuntobit/triad2.0/blob/main/SPEC.md)): tutto il linguaggio.

Ogni programma Triad-Core (esclusi i primitivi di bootstrap) è anche un programma Triad-Full
valido e deve comportarsi allo stesso modo.

### 1.2 La catena di bootstrap

Triad non vuole dipendere da nessun linguaggio ospite. Il piano ([`BOOTSTRAP.md`](https://github.com/GPuntobit/triad2.0/blob/main/BOOTSTRAP.md)):

```
S0  seed: interprete Triad-Core in codice macchina x86-64 (dump esadecimale nel repo)
S1  interprete di tutto Triad scritto in Triad-Core      (selfhost/, in corso)
S2  compilatore nativo scritto in Triad                  (non iniziato)
S3  compilatore self-hosted: S2 compilato da S2          (non iniziato)
S4  Triad completo: REPL, CLI, tooling, parità Linux     (non iniziato)
```

Gli strumenti in Node.js (`seed/dev/*.js`, `conformance/run.mjs`, `cli/`) sono **strumenti di
sviluppo**: aiutano a generare e verificare, ma non fanno parte della catena S0→S4.

---

<a id="cap-2"></a>

## 2. Installare ed eseguire

### 2.1 Requisiti

- **Node.js ≥ 18** (la CI usa Node 20) per l'interprete JS, il runner di conformance e la CLI.
- Su Windows, nient'altro per il seed: `seed.exe` si ottiene decodificando `seed.hex` con
  `certutil`.
- Git per clonare il repository: `git clone https://github.com/GPuntobit/triad2.0.git`.

### 2.2 Eseguire un file

| piattaforma | comando |
|---|---|
| Linux / macOS | `node seed/dev/triad_core.cjs file.triad arg1 arg2` |
| Windows (seed) | `seed\windows-x86_64\seed.exe file.triad` oppure `bin\triad.cmd file.triad` |
| qualsiasi (stdin, interprete JS) | `echo 'println(7 * 6)' \| node seed/dev/triad_core.cjs -` |

Esempi pronti che girano oggi: tutti i `conformance/core/cases/*/program.td`.

```sh
node seed/dev/triad_core.cjs conformance/core/cases/ricorsione/program.td   # 120, 55
```

```cmd
bin\triad.cmd conformance\core\cases\ricorsione\program.td
```

### 2.3 Materializzare il seed

Il sorgente del seed è il dump esadecimale; l'eseguibile si ottiene con un decodificatore di
sistema:

```powershell
Remove-Item seed\windows-x86_64\seed.exe -ErrorAction SilentlyContinue
certutil -decodehex seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe
```

```sh
# Linux: seed ELF allo stadio E0 (stampa solo "Triad seed Linux OK")
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed && chmod +x seed/linux-x86_64/seed
```

### 2.4 Launcher `bin/triad` e `bin/triad.cmd`

Aggiungendo `bin/` al `PATH` si usa `triad file.triad`. I launcher cercano, in ordine:

1. `bin/triad-native` (eseguibile standalone, **non ancora prodotto**: arriverà con S2–S3);
2. `seed/<piattaforma>/seed` (su Windows `seed\windows-x86_64\seed.exe`).

Su Linux il launcher trova il seed ELF E0, che **non interpreta ancora programmi**: per
eseguire codice su Linux usa direttamente l'interprete JS. `triad --build` stampa un messaggio
ed esce con codice 2.

### 2.5 Codici di uscita

| codice | significato |
|---|---|
| `0` | successo |
| `1` | errore di parsing o di esecuzione (messaggio su stderr), file non leggibile |
| `2` | uso non valido (es. nessun file) |

Le opzioni di SPEC §14 (`-e`, `-E`, `-l`, `-i`, `--tree`, `--help`, REPL) **non sono ancora
implementate**: il seed Windows esce con codice 0 senza output, l'interprete JS le tratta come
nome di file.

### 2.6 La CLI di sviluppo in breve

```sh
bin/triad-cli status                 # ambiente e seed trovato (Windows: bin\triad-cli.cmd)
bin/triad-cli test conformance       # conformance Core
bin/triad-cli ai verify -v           # verifica le soluzioni di ai/tasks/
bin/triad-cli seed generate windows  # rigenera seed.hex e stampa lo SHA-256
node conformance/run.mjs             # runner di conformance diretto (Core)
```

I launcher `bin/triad-cli*` eseguono `npm install` in `cli/` al primo avvio. In alternativa si
usa l'eseguibile standalone `triad-cli.exe` / `triad-cli` allegato alla
[release beta](https://github.com/GPuntobit/triad2.0/releases). Dettagli nel
[capitolo 39](Parte-IV-Codice-del-progetto#cap-39).

---

<a id="cap-3"></a>

## 3. Il primo programma

Crea `ciao.triad`:

```julia
#!/usr/bin/env triad
# il mio primo programma Triad
nome = "Triad"
println("ciao, " * nome)
println(6 * 7)
```

Output:

```text
ciao, Triad
42
```

Eseguilo:

```sh
node seed/dev/triad_core.cjs ciao.triad          # Linux/macOS
```

```cmd
seed\windows-x86_64\seed.exe ciao.triad          # Windows
```

Cosa notare:

- la prima riga `#!` (shebang) è ignorata: inizia con `#`, quindi è un commento;
- `println` stampa i suoi argomenti **senza separatori** e aggiunge un a capo;
- `*` tra stringhe è la **concatenazione** (non `+`);
- non c'è una funzione `main`: le istruzioni al top level si eseguono in ordine.

### 3.1 Argomenti da riga di comando

Gli argomenti dopo il nome del file sono in `ARGS`, una lista di stringhe (senza il nome del
programma). Esempio con l'interprete JS:

```sh
printf 'println(ARGS)\nprintln(length(ARGS))\n' > args.triad
node seed/dev/triad_core.cjs args.triad uno due      # [uno, due]  poi  2
```

> Il seed Windows documenta solo l'uso `seed.exe FILE`: `ARGS` non è tra le funzionalità
> elencate in `seed/windows-x86_64/README.md`. Usa l'interprete JS per i programmi con argomenti.

### 3.2 Il ciclo di lavoro consigliato

1. scrivi il programma usando solo Triad-Core (Parte II);
2. eseguilo con l'interprete JS (`node seed/dev/triad_core.cjs`);
3. se deve girare anche sul seed Windows, controlla la tabella del [capitolo 15](Parte-II-Triad-Core#cap-15);
4. se è un comportamento del linguaggio da fissare, trasformalo in un caso di conformance
   ([capitolo 38](Parte-IV-Codice-del-progetto#cap-38)).

---

[Home](Home) · [Parte II Triad Core](Parte-II-Triad-Core) →
