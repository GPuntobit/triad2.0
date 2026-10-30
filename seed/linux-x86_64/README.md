#S0 / Linux x86-64 — ELF seed (E0)
First step of the Linux port: a static **ELF64** without libc or dynamic linker, which it uses
Linux syscall and print only:
```
Triad seed Linux OK
```

and exits with `0`. It is not yet the Triad-Core interpreter: it is used to validate ELF headers, entries
`_start`, syscall and loading on CachyOS/Linux x86-64.
The hex dump is [`seed.hex`](seed.hex): it is the committed source.
## Numbers
- **ELF File:** 173 bytes (`0xAD`)
- **Machine code:** 33 bytes; message: 20 bytes
- **Base:** `0x400000`; **entry:** `0x400078`
- **Program header:** a single `PT_LOAD` R|X, offset 0, filesz/memsz `0xAD`, align `0x1000`
- **sha256 of `seed.hex`:** `AD4C9F08176D9964D5BE17D44C72230184434025980447395E7A3250F63CA5EA`
- **sha256 of the decoded ELF:** `6d504451e1d8a39c6e139a8a120bfaf03373131894292be12f0039eb8a7797f9`
## Build and test (Linux)
```sh
cd seed/linux-x86_64
xxd -r -p seed.hex seed
chmod +x seed
./seed
echo $?          # 0
```

Expected output:
```
Triad seed Linux OK
```

Optional checks with binutils:
```sh
readelf -h seed      # ELF64, ET_EXEC, entry 0x400078
readelf -l seed      # un PT_LOAD R E
objdump -d seed      # write(1,msg,20); exit(0)
```

## Reproducibility
```sh
node seed/dev/gen_seed_linux.js seed/linux-x86_64/seed.hex
```

The dump is the canonical and reproducible source; the produced ELF can be committed
along with it (it's no longer in `.gitignore`). The generator is a development tool
and is not part of the S0→S4 chain.
## Next steps
- **E1:** `_start` with argc/argv, `openat`/`read`/`write` to read a file.
- **E2:** port of the Triad-Core interpreter; target the 26 Core cases supported by the seed
  Windows.
- **E3:** Native Linux CI job without Wine.
Meanwhile the POSIX toolchain is ready: `./install.sh` decodes this seed,
install `bin/triad` and `bin/triad-cli` in `~/.local/bin` and launchers use
automatically the reference JS interpreter as long as the seed remains an E0 stub
(threshold: 4 KB). The `linux-toolchain` CI job covers launcher + install + conformance.
See [`../dev/README.md`](../dev/README.md) and [`../../BOOTSTRAP.md`](../../BOOTSTRAP.md).