# 03 — Contratto delle routine `os_*`

Type: prototype
Status: open
Blocked by: 02

## Question

`BOOTSTRAP.md` §4 nomina 4–5 routine (`os_open`, `os_read`, `os_write`, `os_exit`,
`os_alloc`): qual è il contratto concreto che il corpo dell'interprete può usare
**identico** su PE ed ELF?

Da firmare: registri/parametri e convenzione di chiamata; chi apre e chiude i file;
gestione errori (exit code, stderr); `os_alloc` (arena bump vs heap) e i suoi limiti;
quanto serve al caricamento del sorgente (`argv`, buffer) previsto da N15 in `TASK.md`.

Si risolve con uno **spike a bassa fedeltà** (prototipo gettabile): il confine `os_*`
dietro una chiamata già esistente del PE **e** una micro-ELF che lo usa nativamente, per
reagire alla forma del contratto prima di scriverlo nelle slice di `TASK.md`. Input utile
ma non bloccante: [05 — Ricerca: come altri seed scritti a mano isolano il confine
OS](05-ricerca-confine-os.md).

## Comments
