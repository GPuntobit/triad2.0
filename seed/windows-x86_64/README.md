#S0 / Windows x86-64 — seed with Triad-Core interpreter: elseif (M3b2b3q)
PE32+ executable of **25088 bytes**, without runtime and without libc: imports only `KERNEL32.dll`.
Reads the file indicated by the first argument and interprets a subset of Triad-Core:
- statement `println(expr)`, `NAME = expr`, functions `f(x, y) = expr` and block form `function f(x) … end` with **multi-statement body**, `!io` annotation ignored by seed, `if`/`elseif`/`else`/`end`, `while`/`end`, **`let name = expr … end`**;
  `while`/`end` (nested);
- expressions with integers, variables, calls, `+ - * % ^`, parentheses, `-` unary,
  comparisons, ternary, `true`/`false` literals and **one-parameter lambda** `x -> expr`;
- one-parameter lambdas, also passed as arguments and returned by functions; capture of closures postponed;
- `!`, `&&`, `||` (bitwise on Bool tags) and compound assignment `+=`; `string(x)` conversion to string;
- 2-bit tagged values: `Int=n<<2`, `Bool false=1`/`true=5`, `closure=ptr|2`; `println`
prints integers, Bools, heap strings and `nothing`.
The hex dump is [`seed.hex`](seed.hex).
- **Usage:** `seed.exe FILE`
- **Output:** for each `println(expr)` the value in decimal/string + newline
- **Exit:** `0` success; `1` error (syntax, undefined variable/function, arity,
  reading); `2` without argument
- **Entry point:** RVA `0x1000`
- **Section:** `.text`, RVA `0x1000`, file offset `0x200`, 24576 bytes, characteristics `0xE0000020`
- **Image:** base `0x140000000`, `SizeOfImage` `0x7000`, header `0x200`, subsystem console, ASLR disabled
- **Code:** 8315 bytes
- **sha256 of `seed.hex`:** `9987105DCD56F42A1AD73451821A281E6F24374ED6CE83993BB8CA56F5EC4822`
## File layout
| offset/RVA | what |
|---|---|
| `0x000` | DOS header: `MZ`, `e_lfanew = 0x40` |
| `0x040` | signature `PE\0\0` |
| `0x044` | COFF: machine `0x8664`, 1 section, `SizeOfOptionalHeader = 0xF0`, features `0x0022` |
| `0x058` | optional header PE32+, entry `0x1000`, base `0x140000000` |
| `0x0D0` | data directory import: RVA `0x40A0`, size `0x28` |
| `0x148` | section header `.text` (VirtualSize/RawSize `0x2400`) |
| file `0x200` / RVA `0x1000` | code (8315 bytes) |
| RVA `0x4000` (file `0x3200`) | IAT, 8 slots + null |
| RVA `0x4050` (file `0x3250`) | ILT, 8 slots + null |
| RVA `0x40A0` (file `0x32A0`) | import descriptor + terminator |
| RVA `0x40D0` (file `0x32D0`) | `KERNEL32.dll` |
| RVA `0x5000` (file `0x4200`) | hint/name of the 8 functions |
Section mapping: `file offset = 0x200 + (RVA - 0x1000)`.
## Memory (`VirtualAlloc` 192 KiB, base `r14`)
| offset | what |
|---|---|
| `+0x00000` | Triad source (max 60 KiB; at `+0xF000` is the block stop mask) |
| `+0x10000` | environment variables (`r15`): `rbx` counter, 24 byte entries (`+0` ptr name, `+8` len, `+16` value) |
| `+0x20000` | function table (`r13`): qword counter at `[r13]`, 128 byte entries at `r13+8+i*128` |
| `+0x30000` | shared heap: bump pointer qword; 128 byte closing record from `+0x30008`; strings `[type=1][len][byte…]` (data at `+16`) |
`VirtualAlloc` reserves 256 KiB. A close is a record with the same form as an entry
function (parameter name/len, n=1, body, parameter); the value is `record|2`. The record has
also a capture: `+0x60` count, `+0x68` ptr name, `+0x70` len, `+0x78` value.
Capture was expected when the lambda is created inside a function body (flag a
`r14+0xF008`) and copies the latest environment binding, usually the parameter; at the time of
called, but the mechanism was not reliable: sent back to AST/bytecode.
Entry function: `+0` ptr name, `+8` len name, `+16` number of parameters, `+24` body ptr in
source, `+32` parameters (max 4, each ptr to `+0`, len to `+8`).
Assignment uses `env_assign`: looks for the latest variable and updates it; if it doesn't exist
create. The function parameters are bound with `env_store` (append) and the environment is truncated
upon return; in this way a loop updates the variables instead of creating one entry per loop.
## Code (map to labels, offset from start of code)
| offset | label | what it does |
|---|---|---|
| `0x000` | — | prologue, `GetStdHandle`, `GetCommandLineA`, parsing path |
| `0xEE` | `path_check` | empty path → exit 2 |
| — | — | `CreateFileA`; `VirtualAlloc(0,0x40000,…)`; `ReadFile`; `CloseHandle`; NUL; initialize environment, functions and heap closures |
| `0x220` | `parse_program` | loop statement: `println`, assignment, function, `if`, `while` |
| `0x40D` | `stmt_assign` | name; `=` → assignment, `(` → function |
| `0x4E4` | `st_func` | definition: entry, parameters (max 4), `=`, body, jump to end of line |
| `0x598` | `st_func_skip` | advances to LF/`;`/EOF after the body |
| `0x5C4` | `scan_end` | depth scan: find `elseif`/`else`/`end` with nesting |
| `0x7A7` | `st_if` | select the first true branch between `if`/`elseif`, otherwise `else` |
| `0x8E5` | `st_while` | `while cond … end`: reevaluate condition, execute body |
| `0x96B` | `st_function` | `function f(x) <expression> end`: definition with body of an expression |
| `0xBA0` | `pp_eof` | EOF: error if inside a block (mask ≠ 0) |
| `0xBB4` | `skip_ws` | spaces, tabs, LF, CR, `;`, comments `#` |
| `0xC74` | `parse_cmp` | comparisons, result Bool |
| `0xDBB` | `parse_ternary` | `cmp ? a : b` with scan of unchosen branch |
| `0xF36` | `parse_sum` | `term { (+\|-) term }` |
| `0xF94` | `parse_term` | `factor { (*\|%) factor }` |
| `0x10F6` | `parse_factor` | unary `-` or power |
| `0x1192` | `parse_primary` | integer, Bool, variable, call, `( expr )` |
| `0x14BD` | `pf_lambda` | `x -> expr`: record close + capture (1 binding) |
| `0x1561` | `skip_text` | jumps the body of the lambda up to a | delimiter
| `0x185D` | `pf_call` | named or closing call, arguments, capture, binding, body |
| `0x19F9` | `pf_call_nocap` | continues without capture |
| `0x1AFB` | `fn_find` | search for a function by name |
| `0x1B57` | `parse_ident` | identifier |
| `0x1BC3` | `env_find` | search for a variable (from the most recent) |
| `0x1C32` | `env_store` | adds a new parameter/variable |
| `0x1C4C` | `env_assign` | update the latest variable (or create it) |
| `0x164D` | `print_int` | Int decimal, `true`/`false`, `fun` |
| `0x11BD` … | `fail`, `read_fail`, `open_fail`, `usage` | exits |
### Function call (stack)
`push rbx` (env count), `push rbp` (argc), return cursor slot, `push entry`,
then the evaluated arguments, then the cursor after `)`. Bind the parameters in reverse order
with `env_store`, execute the body with `rsi` on the body, restore cursor and `rbx`
(the environment becomes truncated again). `r13` = function table, `r15` = environment, `rbx` = counter
variables, `r12` = stdout, `r14` = VirtualAlloc base.
## Import
`GetStdHandle`, `GetCommandLineA`, `CreateFileA`, `ReadFile`, `WriteFile`, `CloseHandle`,
`ExitProcess`, `VirtualAlloc` (IAT indices 0–7; IAT at RVA `0x4000`).
## Build and verify
```powershell
Remove-Item seed.exe -ErrorAction SilentlyContinue
certutil -decodehex seed.hex seed.exe

$out = Join-Path $env:TEMP 'out.txt'
$p = Start-Process .\seed.exe -ArgumentList 'conformance\core\cases\simboli_base\program.td' `
       -NoNewWindow -Wait -PassThru -RedirectStandardOutput $out
$p.ExitCode                                                       # 0
((Get-Content $out -Raw) -eq (Get-Content '..\..\conformance\core\cases\simboli_base\expected.out' -Raw))  # True

.\seed.exe ; $LASTEXITCODE                                        # 2
.\seed.exe non_esiste.td ; $LASTEXITCODE                          # 1
```

Also checked: `strings`, `concat_strings`, `nothing_base`, `base_strings`, `begin_block`, `closure`, `closures`, `scope`, `block_functions`, `io_functions`, `functions`, `arithmetic`, `lambda`, `while_loop`, `control` (elseif), `operators`, `comparisons`, `recursion`
(120/55), `simple_functions`, `variables`, `integers`; closure that captures the parameter
(`f=create(10); f(5)=15`) and two independent closures (`g=create(100)`); arity error → exit 1.
## Current limits
- closure capture: covers the last binding of the frame; multi-binding capture remains to be done (AST/bytecode);
- lambda only to **one parameter**; body of a function: maximum 4 parameters;
- the seed does not statically check the effects: `!io` is accepted to perform output in function bodies;
- lists are missing (cases `lists` and `values`);
- `string()` covers Int and String; Bool/Symbol/Nothing not implemented;
- `elseif` ✅ implemented;
- Windows PE only; `os_*` and ELF are from the M7 port.