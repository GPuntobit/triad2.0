# Capitolo 2 — Due profili e una catena

Il capitolo precedente ha descritto un linguaggio ricco: tipi, dispatch, logica, macro, garanzie.
Il seed in codice macchina, invece, deve essere piccolo. Come si conciliano le due cose? Con una
distinzione che attraversa tutto il progetto e tutto questo libro: quella tra **Triad-Core** e
**Triad-Full**.

## 2.1 Triad-Full: il linguaggio intero

Triad-Full è il linguaggio descritto da `SPEC.md`: tutto ciò che il capitolo 1 ha elencato. È il
linguaggio che un programmatore userà a regime, e il bersaglio di ogni implementazione completa.

## 2.2 Triad-Core: il minimo indispensabile

Triad-Core, definito in `SPEC-CORE.md`, è un sottoinsieme scelto con due criteri, che conviene
leggere con attenzione perché spiegano quasi ogni limite che incontreremo nella parte seconda.

Il primo criterio è che Core deve essere **implementabile in codice macchina scritto a mano**.
Ogni costrutto in più è codice x86-64 in più da scrivere, provare e correggere senza un
compilatore. Per questo Core ha pochi tipi (interi, booleani, stringhe, simboli, liste, funzioni,
`nothing`), nessun numero in virgola mobile, nessuna macro, nessuna risoluzione logica, nessun
dispatch sui tipi.

Il secondo criterio è che Core deve essere **abbastanza espressivo da scriverci l'interprete di
tutto Triad**. Per questo, nonostante la sua povertà, Core ha ciò che serve a un interprete:
valori dinamici, liste mutabili, stringhe, funzioni di prima classe con chiusure, ricorsione, e
alcuni **primitivi di bootstrap** (`readfile`, `strlen`, `strbyte`, `strsub`, `exit`) che
permettono di leggere un file sorgente e analizzarlo byte per byte.

La regola che lega i due profili è semplice e importante: **ogni programma Core, esclusi i
primitivi di bootstrap, è anche un programma Full valido, e deve comportarsi allo stesso modo**.
Scrivere in Core non è scrivere in un altro linguaggio: è scrivere in Triad usando solo una parte
del vocabolario.

> **Perché i primitivi di bootstrap sono esclusi da Full?** Perché servono solo a costruire
> l'implementazione, non ai programmi degli utenti. In Full la lettura di file e la
> manipolazione di stringhe avranno la loro forma definitiva; `strbyte` e compagni sono
> impalcature, utili finché si costruisce l'edificio.

## 2.3 La catena di bootstrap

Con questi due profili, il piano di `BOOTSTRAP.md` diventa una catena di cinque anelli:

```
S0  seed: interprete Triad-Core in codice macchina x86-64
     │  esegue
S1  interprete di tutto Triad, scritto in Triad-Core
     │  include
S2  compilatore nativo scritto in Triad
     │  compila S1 e poi se stesso
S3  compilatore self-hosted (il seed non serve più)
     │  costruisce
S4  Triad completo: REPL, riga di comando, strumenti, parità su più piattaforme
```

Conviene fermarsi su ogni anello.

**S0, il seed**, è un eseguibile scritto byte per byte. Nel repository non c'è un sorgente in un
altro linguaggio: c'è un **dump esadecimale** (`seed.hex`) che si trasforma nell'eseguibile con un
semplice decodificatore di sistema (`certutil` su Windows, `xxd` su Linux). Oggi esiste un seed
per Windows che interpreta gran parte di Triad-Core, e un seed Linux allo stadio iniziale.

**S1** è il primo grande traguardo: un interprete di Triad-Full scritto in Triad-Core ed eseguito
dal seed. Quando S1 funzionerà, tutti gli esempi di `examples/` gireranno. I primi prototipi sono
nella cartella `selfhost/`.

**S2 e S3** chiudono il cerchio: un compilatore scritto in Triad compila S1, poi compila se
stesso. Quando l'output della compilazione di se stesso è stabile (il cosiddetto *punto fisso*),
la catena non ha più bisogno del seed.

**S4** è la maturità: REPL, interfaccia a riga di comando completa, strumenti, e la stessa
conformità su Windows e Linux.

## 2.4 Strumenti di sviluppo: fuori dalla catena

C'è un dettaglio che può confondere chi esplora il repository: accanto al codice macchina e al
codice Triad ci sono file JavaScript. Il generatore del seed (`seed/dev/gen_seed.js`), il runner
della conformità (`conformance/run.mjs`), l'interprete di riferimento (`seed/dev/triad_core.cjs`)
e la CLI di sviluppo (`cli/`) sono scritti per Node.js.

Non è una contraddizione. Sono **strumenti di sviluppo**: aiutano a generare, verificare e
provare, ma nessuno di essi è necessario per *usare* Triad o per *ricostruire* la catena S0→S4.
Il seed si materializza dal dump esadecimale senza Node; i golden della conformità sono file di
testo statici. La regola, scritta in `BOOTSTRAP.md`, è che nessuno strumento di sviluppo entri
nella catena.

> **Nota.** Il generatore del seed esiste perché scrivere migliaia di byte a mano, senza alcun
> aiuto, è impraticabile e fragile: il codice macchina, una volta perso il modo di rigenerarlo,
> non si può più estendere. È già successo una volta nella storia del progetto, ed è il motivo
> per cui il generatore è versionato.

## 2.5 Che cosa gira oggi

Riassumendo, lo stato che fa da sfondo a tutto il libro è questo:

| profilo | definito in | eseguibile oggi |
|---|---|---|
| Triad-Core | `SPEC-CORE.md` | sì: interprete di riferimento JS (tutti i 37 casi Core) e, in gran parte, il seed Windows (33 casi verificati dalla CI) |
| Triad-Full | `SPEC.md` | no: dei 12 casi Full passa solo `errore`, che verifica un errore non gestito |

Per questo la parte seconda del libro usa solo Core e mostra output verificati, mentre la parte
terza descrive Full come specifica.

## Riepilogo

- Triad-Core è il sottoinsieme piccolo abbastanza per il codice macchina e ricco abbastanza per
  scriverci un interprete; Triad-Full è il linguaggio intero.
- Un programma Core (senza primitivi di bootstrap) è un programma Full con lo stesso
  comportamento.
- La catena S0→S4 parte dal seed in codice macchina e arriva a un compilatore che compila se
  stesso.
- Gli strumenti in Node.js servono allo sviluppo e restano fuori dalla catena.
<!-- nav -->

---

← [Capitolo 1 — Perché Triad](Libro-01-Perche-Triad) · [Sommario](Home) · [Capitolo 3 — L'ambiente e il primo programma](Libro-03-Primo-programma) →
