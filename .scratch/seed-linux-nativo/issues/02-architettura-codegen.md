# 02 — Architettura del codegen per due piattaforme

Type: grilling
Status: open
Blocked by: 01

## Question

Oggi `seed/dev/gen_seed.js` genera il PE mescolando il corpo dell'interprete e le chiamate
KERNEL32; `seed/dev/gen_seed_linux.js` contiene solo lo stub E0. Come si organizza il
codegen per sostenere due piattaforme senza duplicare l'interprete?

- (a) **Un generatore, due backend `os_*`**: il codegen del corpo è condiviso, due
  emettitori proprietari di formato/sistema (PE + KERNEL32, ELF + syscall) — coerente con
  `BOOTSTRAP.md` §4.
- (b) **Due generatori paralleli** che condividono il corpo dell'interprete in qualche
  forma strutturata (macro/concatenazione), ciascuno proprietario del proprio formato.

Sotto-domanda della stessa sessione: dove vivono header ELF/PE, i fixup e le costanti di
syscall. La decisione è vincolata da [01 — Politica dei byte del PE nella
rifattorizzazione](01-byte-pe.md); input utile ma non bloccante:
[05 — Ricerca: come altri seed scritti a mano isolano il confine OS](05-ricerca-confine-os.md).

## Comments
