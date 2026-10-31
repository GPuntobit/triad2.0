# Riferimento dei builtin Triad-Core

Le primitive di Triad-Core una per una: firma, comportamento ed errori. Le fonti sono
[`SPEC-CORE.md`](https://github.com/GPuntobit/triad2.0/blob/main/SPEC-CORE.md) §7–§8 e
l'implementazione di riferimento `callBuiltin` in
[`seed/dev/triad_core.cjs`](https://github.com/GPuntobit/triad2.0/blob/main/seed/dev/triad_core.cjs).
Dove l'interprete JS va oltre la specifica (comportamento non normativo), è indicato.
Differenze con il seed Windows: [Parte II §15](Parte-II-Triad-Core#cap-15).

| nome | categoria |
|---|---|
| [`print`, `println`](#print-println) | I/O |
| [`length`](#length) | liste, stringhe |
| [`push!`](#push) | liste |
| [`xs[i]`, `xs[i] = v`](#indicizzazione) | liste |
| [`Int`](#int) | conversioni |
| [`string`](#string) | conversioni |
| [`Symbol`](#symbol) | conversioni |
| [`typeof`](#typeof) | introspezione |
| [`ARGS`](#args) | ambiente |
| [`readfile`](#readfile) | bootstrap |
| [`strlen`](#strlen) | bootstrap |
| [`strbyte`](#strbyte) | bootstrap |
| [`strsub`](#strsub) | bootstrap |
| [`exit`](#exit) | bootstrap |
| [operatori](#operatori) | aritmetica, confronto, logica |

I nomi dei builtin sono riservati: nell'interprete JS un builtin viene risolto **prima** delle
variabili, quindi `length = 3` non ridefinisce `length`.

## print, println

`print(a, b, …)` / `println(a, b, …)` → `nothing`

- Scrivono gli argomenti su stdout **senza separatori**; `println` aggiunge `\n`; `println()` stampa solo un a capo.
- Formato: `Int` decimale; `Bool` `true`/`false`; `String` così com'è; `Nothing` `nothing`;
  `Symbol` senza `:` se passato direttamente, con `:` dentro una lista; `List` `[a, b]` (stringhe interne senza virgolette).
- Funzioni: l'interprete JS stampa `#lambda(x)`, il seed `fun` (non normativo).

```julia
println("n = ", 3, " ", :a, " ", [:a, "s", 1])   # n = 3 a [:a, s, 1]
```

## length

`length(x)` → `Int`

- Lista: numero di elementi. Stringa: numero di **byte** UTF-8 (`length("é") == 2`).
- Errori: arità diversa da 1 → `length arity`; altro tipo → `length type`.

## push!

`push!(xs, v)` → `xs`

- Aggiunge `v` in coda alla lista **mutandola** e restituisce la lista stessa (stesso riferimento).
- Errori: arità diversa da 2 → `push! arity`; primo argomento non lista → `push! type`.
- Seed Windows: solo interi, massimo 64 elementi.

## Indicizzazione

`xs[i]`, `xs[i] = v`, `xs[i] += v` (anche `-=`, `*=`)

- Indici da **1**; `i` deve essere `Int`, `xs` una lista.
- Errori: `index target not list`, `index not int`, `index out of range`.
- Seed Windows: non supportata; esiste l'helper non standard `get(xs, i)` da **0**.

## Int

`Int(x)` → `Int`

- `String`: interpretata come intero decimale (`Int("42") == 42`).
- `Int`: restituito invariato. `Bool`: `false → 0`, `true → 1`.
- Interprete JS, non normativo: una stringa non numerica dà `0` (`Int("abc") == 0`); un simbolo numerico viene convertito.
- Errori: arità → `Int arity`; altri tipi → `Int type`.

## string

`string(x)` → `String`

- Qualsiasi valore: `string(42) == "42"`, `string(true) == "true"`, `string(:a) == "a"`,
  `string(nothing) == "nothing"`, `string([1, :a]) == "[1, :a]"`.
- Errori: arità → `string arity`.
- Seed Windows: solo `Int` e `String`.

## Symbol

`Symbol(s)` → `Symbol`

- Da `String` (`Symbol("ciao") == :ciao`); un `Symbol` è restituito invariato.
- Errori: arità → `Symbol arity`; altri tipi → `Symbol type`.

## typeof

`typeof(x)` → `Symbol`

- Uno tra `:Int`, `:Bool`, `:String`, `:Symbol`, `:List`, `:Function`, `:Nothing`.
- Si confronta con un simbolo: `typeof(xs) == :List`. Stampato senza `:` (`println(typeof(1))` → `Int`).

## ARGS

`ARGS` → `List` di `String`

- Gli argomenti dopo il nome del file (`node seed/dev/triad_core.cjs prog.triad a b` → `["a", "b"]`), senza il nome del programma.
- È una variabile, non una funzione: `ARGS()` → errore.

## readfile

`readfile(path)` → `String` — primitivo di bootstrap (non in Triad-Full).

- Contenuto del file come testo UTF-8. Errore se l'argomento non è una stringa o il file non è leggibile.

## strlen

`strlen(s)` → `Int` — bootstrap. Numero di byte di `s`.

## strbyte

`strbyte(s, i)` → `Int` (0–255) — bootstrap.

- Byte alla posizione `i`, da **1**. Errori: `strbyte type`, `strbyte range` (fuori da `1..strlen(s)`).

```julia
strbyte("Ab", 1)   # 65
```

## strsub

`strsub(s, a, b)` → `String` — bootstrap.

- Byte da `a` a `b` **inclusi**, da 1. Errori: `strsub type`, `strsub range` (`a < 1`, `b < a`, `b > strlen(s)`).

```julia
strsub("Triad", 2, 4)   # "ria"
```

## exit

`exit(n)` → non ritorna — bootstrap. Termina il processo con codice `n` (`Int`).

## Operatori

| operatore | operandi | risultato | errori |
|---|---|---|---|
| `+ - *` | `Int, Int` | `Int` (wrap a 64 bit) | `+ type error`, … |
| `*` | `String, String` | concatenazione | `* type error` |
| `%` | `Int, Int` | resto con il segno del dividendo | `div by zero`, `% type error` |
| `^` | `Int, Int` (esponente ≥ 0) | `Int` | `negative exponent`, `^ type error` |
| `- x` (unario) | `Int` | `Int` | `unary -` |
| `== !=` | qualsiasi | `Bool` (liste elemento per elemento, funzioni per identità) | — |
| `< <= > >=` | `Int, Int` | `Bool` | `< type error`, … |
| `&& \|\|` | `Bool` | `Bool`, cortocircuito | `&& expects bool`, `\|\| expects bool` |
| `!` | `Bool` | `Bool` | `!` |
| `c ? a : b` | `c` `Bool` | `a` o `b` | `ternary cond` |

Non esistono in Core: `/`, `Float`, `map`, `filter`, `reduce`, `sum`, `sort`, `div`, `mod`
(si scrivono in Core: [Parte II §16](Parte-II-Triad-Core#cap-16)).
