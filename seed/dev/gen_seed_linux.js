#!/usr/bin/env node
// =====================================================================
//  seed/dev/gen_seed_linux.js
//
//  Generatore di sviluppo del seed S0 Linux x86-64 (E0).
//  NON fa parte della catena S0->S4: il dump seed.hex e' la fonte
//  committata; questo script serve solo a rigenerarlo/estenderlo.
//
//  Uso:
//    node seed/dev/gen_seed_linux.js seed/linux-x86_64/seed.hex
//
//  E0: ELF64 statico, entry _start, syscall write(1, msg, len) e
//  exit(0). Stampa "Triad seed Linux OK\n".
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

// ---- codice macchina -------------------------------------------------
const code = [];
const B = (...xs) => { for (const x of xs) code.push(x & 255); };
const B32 = v => { v = v >>> 0; for (let i = 0; i < 4; i++) code.push((v >>> (8 * i)) & 255); };

function movEax(v) { B(0xb8); B32(v); }          // mov eax, imm32
function movEdi(v) { B(0xbf); B32(v); }          // mov edi, imm32
function movEdx(v) { B(0xba); B32(v); }          // mov edx, imm32
function syscall() { B(0x0f, 0x05); }
function xorEdiEdi() { B(0x31, 0xff); }          // xor edi, edi

const msg = Buffer.from('Triad seed Linux OK\n', 'ascii');

movEax(1);                                        // write
movEdi(1);                                        // stdout
B(0x48, 0x8d, 0x35); const leaAt = code.length; B32(0); // lea rsi,[rip+msg]
movEdx(msg.length);
syscall();
movEax(60);                                       // exit
xorEdiEdi();
syscall();

const msgOff = CODE_OFF + code.length;
// disp32 relativo alla prossima istruzione (leaAt+4 e' fine disp; lea inizia a leaAt-3)
const leaStart = leaAt - 3;
const disp = (BASE + msgOff) - (BASE + CODE_OFF + leaStart + 7);
const patch = Buffer.alloc(4); patch.writeInt32LE(disp);
for (let i = 0; i < 4; i++) code[leaAt + i] = patch[i];

const fileSize = msgOff + msg.length;
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

// ---- codice e messaggio ---------------------------------------------
for (let i = 0; i < code.length; i++) img[CODE_OFF + i] = code[i];
msg.copy(img, msgOff);

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
console.log('sha256(ELF):', sha);
console.log('scritto', outPath);
