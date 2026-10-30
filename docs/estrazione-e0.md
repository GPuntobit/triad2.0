# Extract E0 — `seed/linux-x86_64/README.md`
- **Reference document:** [`seed/linux-x86_64/README.md`](../seed/linux-x86_64/README.md)
- **Drawing date:** 2026-10-22
- **Note:** the E0 README has been updated after this extraction (the seed binaries are now publishable, see `.gitignore`); the table reflects the original text.
- **Method:** ANCHOR / PENALTY / RADAR / MIRROR kit
- **Result:** basis confirmed by the user (document and fields); values ​​extracted from the document, no data added.
Rule applied: extract only values ​​explicitly declared in the document; If a value is ambiguous or absent, leave the field blank and indicate why.
## 1. Basis of extraction
- **Document:** chosen by the agent with explicit authorization ("Document: you choose") and confirmed by the user ("I confirm!"). The choice itself is not in the document: Source **Inferred**.
- **Fields:** 21 lines, of which 19 are filled in and 2 are left blank (License, Release Date) because they are absent in the document. The list of fields was not provided by the user: proposed by the agent by reading the sections of the document (Source **Inferred**) and confirmed.
## 2. Table (STILL + RADAR)
| Field | Value | Section | Reason (if blank) | Source | Evidence |
|---|---|---|---|---|---|
| Title/Artifact | `S0 / Linux x86-64 — seed ELF (E0)` | Title | — | Extract | — |
| Platform | `Linux x86-64`; try on `CachyOS/Linux x86-64` | Title; Introduction | — | Extract | — |
| Format | `ELF64 static` | Introduction | — | Extract | — |
| Runtime dependencies | «without libc or dynamic linker»; «Linux syscall only» | Introduction; §Build and Test (Linux) | — | Extract | — |
| ELF Size | `173 bytes (0xAD)` | §Numbers | — | Extract | — |
| Machine Code | `33 bytes` | §Numbers | — | Extract | — |
| Message | `20 bytes` | §Numbers | — | Extract | — |
| Loading Base | `0x400000` | §Numbers | — | Extract | — |
| Entry point | `0x400078` | §Numbers | — | Extract | — |
| Segments | a single `PT_LOAD` R\|X, offset 0, filesz/memsz `0xAD`, align `0x1000` | §Numbers | — | Extract | — |
| sha256 of `seed.hex` | `AD4C9F08176D9964D5BE17D44C72230184434025980447395E7A3250F63CA5EA` | §Numbers | — | Extract | — |
| sha256 by ELF | `6d504451e1d8a39c6e139a8a120bfaf03373131894292be12f0039eb8a7797f9` | §Numbers | — | Extract | — |
| Output stdout | `Triad seed Linux OK` | Introduction; §Build and Test (Linux) | — | Extract | — |
| Exit code | `0` | Introduction; §Build and Test (Linux) | — | Extract | — |
| Build commands | `xxd -r -p seed.hex seed`; `chmod +x seed`; `./seed` | §Build and Test (Linux) | — | Extract | — |
| Regeneration | `node seed/dev/gen_seed_linux.js seed/linux-x86_64/seed.hex` | §Reproducibility | — | Extract | — |
| What is committed | just `seed.hex` (dump); the ELF is not committed | Introduction; §Reproducibility | — | Extract | — |
| Status / what is not yet | «It is not yet the Triad-Core interpreter»; E0 = first port step | Title; Introduction | — | Extract | — |
| Next steps | E1 (`argc/argv`, `openat`/`read`/`write`); E2 (interpreter port, 25 Core cases); E3 (Native Linux CI without Wine) | §Next steps | — | Extract | — |
| License | *(empty)* | — | The document does not name any licenses. | — | — |
| Release Date | *(empty)* | — | No date is stated in the document. | — | — |
## 3. Inferred Voices (RADAR)
All fields in the table have Source **Extract**. The only **Inferred** items are outside the document:
| Voice | Source | Evidence |
|---|---|---|
| Selected document | Inferred | "you choose" authorizes the choice, but no criteria are declared; the README of the E0 artifact was chosen for recency and verifiability. |
| List of fields | Inferred | The list was never provided; it was derived from the sections of the document, so the selection is up to the agent. |
| Draw date | Inferred | Taken from the system clock, not from the document. |
## 4. MIRROR — quality control
1. **Non-explicit assumptions:** the document was chosen by the agent (Inferred, then confirmed) and the list of fields was proposed by the agent (Inferred, then confirmed).
2. **Values ​​​​​​that can be interpreted differently:** `173 bytes` of file versus `33 + 20` bytes of code and message may seem inconsistent (the rest is header/padding, but the document doesn't explain it: it wasn't added); «E0» can be read as a complete state or as the start of the port; `exit 0` is declared, not checked by running the ELF.
3. **Calculations between different sections:** none; no sum, no recalculated hash, no combined value.
4. **Reliability per line:** see §4.2.
### 4.2 Problem fields
| Field | Reliability | Why |
|---|---|---|
| Selected document | Average | Arbitrary choice (although authorized); no explicit criteria in the document. |
| List of fields | Low | Never provided by the user; derived from the agent, possible oriented selection. |
| Output stdout / Exit code | Average | Literals in the document, but not executed in this session (Windows environment). |
| sha256 `seed.hex` / ELF | Average | Literally copied, not recalculated. |
| License / Release Date | High | Fields confirmed and correctly empty: absence verified in the document. |
| Other fields (title, numbers, commands, next steps) | High | Literals, cited section. |
## 5. Limits stated
- The Linux ELF was not run in this session: output and exit code are values declared by the document, not checked here.
- Hashes are copied character by character, not recalculated.
- License and issue date remain blank due to absence in the document, not due to forgetfulness.