# Capitolo 3 — L'ambiente e il primo programma

È il momento di scrivere codice. Prima, però, bisogna sapere *dove* farlo girare, perché oggi
Triad ha due esecutori diversi, ognuno con il suo ruolo.

## 3.1 Due esecutori

Il primo è il **seed Windows**, `seed/windows-x86_64/seed.exe`: l'interprete in codice macchina,
il vero anello S0 della catena. Gira solo su Windows x86-64 e non ha bisogno di nient'altro.

Il secondo è l'**interprete di riferimento** in JavaScript, `seed/dev/triad_core.cjs`. È un
interprete completo di Triad-Core in un solo file, senza dipendenze, che richiede Node.js (dalla
versione 18; la CI usa la 20). È lo strumento con cui la CI verifica la conformità su Linux ed è
il modo più comodo per sperimentare su qualsiasi sistema.

> **Quale usare?** Per imparare, l'interprete di riferimento: implementa tutto Triad-Core e
> stampa messaggi d'errore leggibili. Il seed è più limitato (il capitolo 12 elenca le
> differenze) ma è il runtime "vero": se il tuo codice deve girare sul seed, come quello di
> `selfhost/`, provalo anche lì.

## 3.2 Preparare il terreno

Si parte clonando il repository:

```sh
git clone https://github.com/GPuntobit/triad2.0.git
cd triad2.0
```

Su Linux o macOS basta avere Node.js installato. Su Windows, per usare il seed, si materializza
l'eseguibile dal dump esadecimale:

```powershell
Remove-Item seed\windows-x86_64\seed.exe -ErrorAction SilentlyContinue
certutil -decodehex seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe
```

Questo passaggio merita un momento di attenzione, perché racchiude la filosofia del progetto:
l'eseguibile non è scaricato né compilato, è *decodificato* da un testo che fa parte del
repository e la cui impronta SHA-256 è verificata dalla CI. Chiunque può controllare che i byte
siano quelli dichiarati.

## 3.3 Il primo programma

Crea un file `ciao.triad` con questo contenuto:

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

ed eseguilo:

```sh
node seed/dev/triad_core.cjs ciao.triad          # Linux, macOS (o Windows con Node)
```

```cmd
seed\windows-x86_64\seed.exe ciao.triad          # Windows, con il seed
```

Leggiamolo riga per riga.

La prima riga, `#!/usr/bin/env triad`, è uno **shebang**: sui sistemi Unix permette di rendere il
file eseguibile direttamente. Per Triad è semplicemente un commento, perché inizia con `#`, e
viene ignorata.

La seconda riga è un commento vero e proprio: tutto ciò che segue `#` fino a fine riga è ignorato.

`nome = "Triad"` crea una variabile. Non c'è una parola chiave come `let` o `var`, né un tipo da
dichiarare: il primo assegnamento crea il nome, i successivi lo aggiornano.

`println("ciao, " * nome)` stampa una riga. Qui c'è la prima piccola sorpresa per chi viene da
altri linguaggi: le stringhe si concatenano con `*`, non con `+`. È una scelta ereditata da
Julia, che ragiona così: la concatenazione non è commutativa (`"ab"` non è `"ba"`), come la
moltiplicazione nelle algebre non commutative, mentre `+` di solito lo è.

`println(6 * 7)` stampa il risultato di un'espressione. Non serve convertire il numero in
stringa: `println` sa stampare ogni tipo di valore.

Infine, nota ciò che **manca**: non c'è una funzione `main`, non c'è nessun `import`. Un
programma Triad è una sequenza di istruzioni eseguite dall'alto in basso.

## 3.4 Argomenti e codici di uscita

Un programma riceve gli argomenti della riga di comando nella variabile `ARGS`, una lista di
stringhe che **non** comprende il nome del programma:

```sh
printf 'println(ARGS)\nprintln(length(ARGS))\n' > args.triad
node seed/dev/triad_core.cjs args.triad uno due
# [uno, due]
# 2
```

Quando un programma termina, comunica al sistema un **codice di uscita**. Triad ne usa tre, e
conviene impararli subito perché la suite di conformità li controlla tanto quanto l'output:

| codice | significato |
|---|---|
| `0` | il programma è terminato normalmente |
| `1` | errore: sintassi non valida, errore durante l'esecuzione, file illeggibile |
| `2` | uso scorretto dell'interprete, per esempio nessun file indicato |

Con l'interprete di riferimento puoi anche passare il programma dallo standard input, usando
`-` al posto del nome del file:

```sh
echo 'println(1 + 2)' | node seed/dev/triad_core.cjs -      # 3
```

## 3.5 Il launcher e la CLI di sviluppo

Nella cartella `bin/` ci sono due **launcher**: `triad` (per sistemi POSIX) e `triad.cmd` (per
Windows). Se aggiungi `bin/` al `PATH`, puoi scrivere semplicemente `triad file.triad`. Il
launcher cerca prima un eseguibile nativo `bin/triad-native` (che arriverà con il compilatore,
negli stadi S2–S3) e poi il seed della tua piattaforma. Su Linux il seed è ancora allo stadio
iniziale, che stampa solo un messaggio di prova: lì conviene usare direttamente l'interprete di
riferimento.

Lo standard prevede per `triad` un'interfaccia più ricca (un REPL, l'opzione `-E` per valutare
un'espressione, `--tree` per vedere l'albero sintattico e altre), descritta nel capitolo 17. Oggi
nessun runtime la implementa: il seed esegue solo file.

Accanto al launcher c'è `triad-cli`, la **CLI di sviluppo**, che riunisce gli strumenti per chi
lavora al progetto:

```sh
bin/triad-cli status                 # ambiente e seed trovato (Windows: bin\triad-cli.cmd)
bin/triad-cli test conformance       # esegue la suite Triad-Core
```

La incontreremo di nuovo nel capitolo 22.

## 3.6 Dove trovare altri programmi

Il modo migliore per imparare un linguaggio è leggere programmi che funzionano. In Triad ce n'è
una raccolta pronta: i casi di conformità Core, in `conformance/core/cases/*/program.td`. Ognuno
è un programma breve, centrato su un aspetto del linguaggio, accompagnato dall'output esatto che
deve produrre. L'appendice [Catalogo conformance Core](Catalogo-conformance-Core) li raccoglie
tutti, con codice e output.

```sh
node seed/dev/triad_core.cjs conformance/core/cases/ricorsione/program.td
```

## Riepilogo

- Oggi Triad si esegue con l'interprete di riferimento (`node seed/dev/triad_core.cjs`) o, su
  Windows, con il seed in codice macchina.
- Un programma è una sequenza di istruzioni; le variabili nascono al primo assegnamento; le
  stringhe si concatenano con `*`.
- `ARGS` contiene gli argomenti; i codici di uscita sono 0, 1 e 2.
- I casi di conformità Core sono la miglior raccolta di esempi eseguibili.

## Esercizi

1. Scrivi un programma che stampi il tuo nome e, sulla riga successiva, il numero dei suoi
   caratteri (suggerimento: `length`).
2. Esegui un programma che contiene un errore di battitura in un nome di variabile e osserva il
   messaggio e il codice di uscita (`echo $?` su Linux, `echo %ERRORLEVEL%` su Windows).
3. Apri tre casi a caso nel catalogo della conformità Core e prova a prevederne l'output prima di
   leggerlo.
<!-- nav -->

---

← [Capitolo 2 — Due profili e una catena](Libro-02-Profili-e-bootstrap) · [Sommario](Home) · [Capitolo 4 — Le parole del linguaggio](Libro-04-Lessico) →
