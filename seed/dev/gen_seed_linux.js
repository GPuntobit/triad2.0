#!/usr/bin/env node
// =====================================================================
//  seed/dev/gen_seed_linux.js
//
//  Generatore di sviluppo del seed S0 Linux x86-64 (E1).
//  NON fa parte della catena S0->S4: il dump seed.hex e' la fonte
//  committata; questo script serve solo a rigenerarlo/estenderlo.
//
//  Uso:
//    node seed/dev/gen_seed_linux.js seed/linux-x86_64/seed.hex
//
//  E1: ELF64 statico (senza libc ne' dynamic linker), entry _start con
//  argc/argv e syscall openat/read/write/exit. Il seed legge il sorgente
//  indicato in argv[1] in un buffer e lo riscrive su stdout (echo).
//  L'interprete Triad-Core arriva in N17 (BOOTSTRAP.md §5).
//
//  Esiti (pari al PE, vedi .scratch/seed-linux-nativo/issues/03
//  "Contratto delle routine os_*"):
//    argc < 2 o argv[1] vuoto  -> usage su stderr,  exit 2
//    openat fallisce           -> errore su stderr, exit 1
//    read fallisce             -> errore su stderr, exit 1
//    sorgente >= 0xF000        -> errore su stderr, exit 1
//                                (slot maschera a +0xF000, parita' PE)
//  La diagnostica su stderr esiste solo sull'ELF (il PE e' muto), fuori
//  dal contratto di parita' che copre il solo stdout byte-identico.
//
//  Struttura: emissioni INLINE delle routine os_* (nessuna sottoroutine
//  macchina, come da contratto), stesse firme del PE:
//    os_arg   copia argv[1] nel buffer path; vuoto -> usage
//    os_open  openat(AT_FDCWD, path, O_RDONLY) -> handle in rbx
//    os_read  loop read + close; totale in r13
//    os_write write(1, buf, n)
//    os_exit  exit(60) con codice
//  Limiti noti invariati rispetto al PE: path <= 256 byte (copia
//  non limitata, come GetCommandLineA nel PE).
// =====================================================================
'use strict';
const fs = require('fs');
const crypto = require('crypto');

const outPath = process.argv[2];
if (!outPath) {
  console.error('uso: node seed/dev/gen_seed_linux.js OUT.hex');
  process.exit(2);
}

const BASE = 0x400000;
const EHDR = 64;
const PHDR = 56;
const CODE_OFF = EHDR + PHDR; // 120 = 0x78

// ---- emissione byte + etichette/fixup -------------------------------
const code = [];
const labels = Object.create(null);
const patches = [];
const B = (...xs) => { for (const x of xs) code.push(x & 255); };
const B32 = v => { v = v >>> 0; for (let i = 0; i < 4; i++) code.push((v >>> (8 * i)) & 255); };
const L = name => { labels[name] = code.length; };

// jmp/jcc rel32 con fixup d'etichetta (disp = target - (at+4))
function jmpL(name) { B(0xe9); const at = code.length; B32(0); patches.push({ at, name }); }
function jccL(op, name) { B(0x0f, op); const at = code.length; B32(0); patches.push({ at, name }); }
const jl  = n => jccL(0x8c, n);  // <
const je  = n => jccL(0x84, n);  // =
const jne = n => jccL(0x85, n);  // !=
const js  = n => jccL(0x88, n);  // segno (syscall < 0)
const jz  = n => jccL(0x84, n);  // = 0 (EOF)
const jae = n => jccL(0x83, n);  // >=

// istruzioni generiche usate sotto
function movEax(v) { B(0xb8); B32(v); }                 // mov eax, imm32
function movEdi(v) { B(0xbf); B32(v); }                 // mov edi, imm32
function movEdx(v) { B(0xba); B32(v); }                 // mov edx, imm32
function syscall() { B(0x0f, 0x05); }
function xorEdiEdi() { B(0x31, 0xff); }                 // xor edi, edi
function xorEaxEax() { B(0x31, 0xc0); }                 // xor eax, eax
function leaRsiRsp(disp) { B(0x48, 0x8d, 0xb4, 0x24); B32(disp); } // lea rsi,[rsp+disp]
function leaRdiRsp(disp) { B(0x48, 0x8d, 0xbc, 0x24); B32(disp); } // lea rdi,[rsp+disp]
function leaRsiRip(name) {                               // lea rsi,[rip+msg]
  B(0x48, 0x8d, 0x35); const at = code.length; B32(0); patches.push({ at, name });
}

// ---- costanti di layout ---------------------------------------------
const PATH_OFF = 0x100;      // buffer path sullo stack ([rsp+0x100], come il PE)
const SRC_OFF = 0x200;       // buffer sorgente sullo stack
const SRC_MAX = 0x10000;     // lettura massima (come ReadFile nel PE)
const SRC_LIMIT = 0xF000;    // slot maschera: sorgente >= limite -> exit 1

// ---- messaggi diagnostici (solo ELF, il PE e' muto) -----------------
const MSG = {
  msg_usage: 'usage: seed FILE.td\n',
  msg_open:  'seed: cannot open file\n',
  msg_read:  'seed: read error\n',
  msg_large: 'seed: file too large\n',
};

// ---- emissioni inline delle routine os_* ----------------------------
// os_write(fd, msg, len) per le sole diagnostiche d'errore
function osWriteMsg(msgName, len, fd) {
  movEax(1);                 // sys_write
  movEdi(fd);
  leaRsiRip(msgName);
  movEdx(len);
  syscall();
}
// os_exit(code)
function osExit(code) {
  movEax(60);                // sys_exit
  if (code === 0) xorEdiEdi(); else movEdi(code);
  syscall();
}

// ---------------------------------------------------------------- main
// argc/argv da _start: [rsp]=argc, [rsp+8]=argv[0], [rsp+16]=argv[1]
B(0x48, 0x8b, 0x04, 0x24);              // mov rax, [rsp]   ; argc
B(0x48, 0x83, 0xf8, 0x02);              // cmp rax, 2
jl('usage');                             // argc < 2 -> usage
B(0x48, 0x8b, 0x74, 0x24, 0x10);        // mov rsi, [rsp+16]; argv[1]

// ---- os_arg: copia argv[1] nel buffer path, vuoto -> usage ----------
B(0x48, 0x81, 0xec); B32(SRC_OFF + SRC_MAX + PATH_OFF); // sub rsp, 0x10300
leaRdiRsp(PATH_OFF);
L('copy_loop');
B(0x0f, 0xb6, 0x06);                    // movzx eax, byte [rsi]
B(0x88, 0x07);                          // mov [rdi], al
B(0x48, 0xff, 0xc6);                    // inc rsi
B(0x48, 0xff, 0xc7);                    // inc rdi
B(0x84, 0xc0);                          // test al, al
jne('copy_loop');
B(0x80, 0xbc, 0x24); B32(PATH_OFF); B(0x00); // cmp byte [rsp+0x100], 0
je('usage');                             // path vuoto -> usage (parita' PE)

// ---- os_open: openat(AT_FDCWD, path, O_RDONLY) ---------------------
movEax(257);                             // sys_openat
B(0x48, 0xc7, 0xc7); B32((-100) >>> 0); // mov rdi, -100 (AT_FDCWD)
leaRsiRsp(PATH_OFF);
B(0x31, 0xd2);                          // xor edx, edx   ; O_RDONLY
syscall();
B(0x48, 0x85, 0xc0);                    // test rax, rax
js('open_fail');
B(0x48, 0x89, 0xc3);                    // mov rbx, rax   ; handle

// ---- os_read: loop read + close (legge tutto e chiude) -------------
B(0x4d, 0x31, 0xed);                    // xor r13, r13   ; totale = 0
L('read_loop');
xorEaxEax();                             // sys_read
B(0x48, 0x89, 0xdf);                    // mov rdi, rbx
leaRsiRsp(SRC_OFF);
B(0x4c, 0x01, 0xee);                    // add rsi, r13
B(0x48, 0xc7, 0xc2); B32(SRC_MAX);      // mov rdx, 0x10000
B(0x4c, 0x29, 0xea);                    // sub rdx, r13
syscall();
B(0x48, 0x85, 0xc0);                    // test rax, rax
js('read_fail');
jz('read_done');
B(0x49, 0x01, 0xc5);                    // add r13, rax
jmpL('read_loop');
L('read_done');
movEax(3);                              // sys_close
B(0x48, 0x89, 0xdf);                    // mov rdi, rbx
syscall();
B(0x49, 0x81, 0xfd); B32(SRC_LIMIT);    // cmp r13, 0xF000
jae('too_large');                        // troppo grande (parita' PE)

// ---- os_write: echo del sorgente su stdout -------------------------
movEax(1);                              // sys_write
movEdi(1);                              // stdout
leaRsiRsp(SRC_OFF);
B(0x4c, 0x89, 0xea);                    // mov rdx, r13
syscall();

// ---- os_exit(0) ----------------------------------------------------
osExit(0);

// ---- uscite d'errore: write(2, msg, len) + exit --------------------
L('usage');     osWriteMsg('msg_usage', MSG.msg_usage.length, 2); osExit(2);
L('open_fail'); osWriteMsg('msg_open',  MSG.msg_open.length,  2); osExit(1);
L('read_fail'); osWriteMsg('msg_read',  MSG.msg_read.length,  2); osExit(1);
L('too_large'); osWriteMsg('msg_large', MSG.msg_large.length, 2); osExit(1);

// ---- messaggi -------------------------------------------------------
for (const [name, s] of Object.entries(MSG)) {
  L(name);
  for (const ch of Buffer.from(s, 'ascii')) code.push(ch);
}

// ---- risolvi patch --------------------------------------------------
for (const p of patches) {
  const target = labels[p.name];
  if (target === undefined) throw new Error('etichetta sconosciuta: ' + p.name);
  const buf = Buffer.alloc(4);
  buf.writeInt32LE(target - (p.at + 4));
  for (let i = 0; i < 4; i++) code[p.at + i] = buf[i];
}

const fileSize = CODE_OFF + code.length;
if (fileSize >= 4096) {
  throw new Error('E1 deve restare sotto la soglia stub di 4 KB: ' + fileSize);
}
const img = Buffer.alloc(fileSize);

// ---- ELF header ------------------------------------------------------
img[0] = 0x7f; img[1] = 0x45; img[2] = 0x4c; img[3] = 0x46; // \x7fELF
img[4] = 2; // ELFCLASS64
img[5] = 1; // ELFDATA2LSB
img[6] = 1; // EV_CURRENT
img[7] = 0; // ELFOSABI_SYSV
img.writeUInt16LE(2, 0x10);        // ET_EXEC
img.writeUInt16LE(62, 0x12);       // EM_X86_64
img.writeUInt32LE(1, 0x14);        // version
img.writeBigUInt64LE(BigInt(BASE + CODE_OFF), 0x18); // e_entry
img.writeBigUInt64LE(BigInt(EHDR), 0x20);            // e_phoff
img.writeBigUInt64LE(0n, 0x28);                      // e_shoff
img.writeUInt32LE(0, 0x30);        // flags
img.writeUInt16LE(EHDR, 0x34);     // e_ehsize
img.writeUInt16LE(PHDR, 0x36);     // e_phentsize
img.writeUInt16LE(1, 0x38);        // e_phnum
img.writeUInt16LE(0, 0x3a);        // e_shentsize
img.writeUInt16LE(0, 0x3c);        // e_shnum
img.writeUInt16LE(0, 0x3e);        // e_shstrndx

// ---- program header (un solo PT_LOAD R+X che copre header+code) ------
const ph = EHDR;
img.writeUInt32LE(1, ph + 0);          // PT_LOAD
img.writeUInt32LE(5, ph + 4);          // R|X
img.writeBigUInt64LE(0n, ph + 8);      // p_offset
img.writeBigUInt64LE(BigInt(BASE), ph + 16);
img.writeBigUInt64LE(BigInt(BASE), ph + 24);
img.writeBigUInt64LE(BigInt(fileSize), ph + 32);
img.writeBigUInt64LE(BigInt(fileSize), ph + 40);
img.writeBigUInt64LE(0x1000n, ph + 48);

// ---- codice e messaggi ---------------------------------------------
for (let i = 0; i < code.length; i++) img[CODE_OFF + i] = code[i];

// ---- output hex (16 byte per riga, compatibile con xxd -r -p) --------
const lines = [];
for (let i = 0; i < img.length; i += 16) {
  lines.push(img.subarray(i, i + 16).toString('hex'));
}
fs.writeFileSync(outPath, lines.join('\n') + '\n');

// ---- sanity + report -------------------------------------------------
const check = fs.readFileSync(outPath, 'utf8').replace(/\s+/g, '');
const round = Buffer.from(check, 'hex');
if (round.length !== fileSize) throw new Error('round-trip hex fallito');
if (round.readUInt32LE(0) !== 0x464c457f) throw new Error('magic ELF errata');
if (round.readUInt16LE(0x12) !== 62) throw new Error('e_machine errata');
if (round.readBigUInt64LE(0x18) !== BigInt(BASE + CODE_OFF)) throw new Error('entry errata');

const sha = crypto.createHash('sha256').update(img).digest('hex');
const shaHex = crypto.createHash('sha256').update(fs.readFileSync(outPath)).digest('hex');
console.log('sha256(ELF):', sha);
console.log('sha256(hex):', shaHex);
console.log('dimensione:', fileSize, 'byte (soglia stub 4096)');
console.log('scritto', outPath);
