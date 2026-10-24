// Generatore M3b1 (strumento di sviluppo, NON parte della catena): seed PE x86-64 che
// interpreta un programma Triad-Core minimale:
//   - statement: println(expr)
//   - expr: interi, + - *, parentesi, unario -
//   - separatori: spazi, tab, a capo, CR, ;
// Uso: node gen_seed_m3.js out.hex
'use strict';
const fs = require('fs');
const outHex = process.argv[2];

// ---------------------------------------------------------------- emitter
const code = [], labels = {}, patches = [];
function B(...xs) { for (const x of xs) code.push(x & 255); }
function B32(v) { v = v >>> 0; for (let i = 0; i < 4; i++) code.push((v >>> (8 * i)) & 255); }
function L(n) { labels[n] = code.length; }
function reloc(op, label) { B(...op); const at = code.length; B(0, 0, 0, 0); patches.push({ at, label }); }
function je(n) { reloc([0x0f, 0x84], n); }
const jz = je;
function jne(n) { reloc([0x0f, 0x85], n); }
function jb(n) { reloc([0x0f, 0x82], n); }
function jbe(n) { reloc([0x0f, 0x86], n); }
function jae(n) { reloc([0x0f, 0x83], n); }
function ja(n) { reloc([0x0f, 0x87], n); }
function jns(n) { reloc([0x0f, 0x89], n); }
function js(n) { reloc([0x0f, 0x88], n); }
function jnz(n) { reloc([0x0f, 0x85], n); }
function jmp(n) { reloc([0xe9], n); }
function callL(n) { reloc([0xe8], n); }
function callIat(idx, iat) {
  B(0xff, 0x15); const at = code.length; B(0, 0, 0, 0);
  patches.push({ at, kind: 'abs', value: (iat + idx * 8) - (0x1000 + at + 4) });
}
function movRaxMemRip(rva) {
  B(0x48, 0x8b, 0x05); const at = code.length; B(0, 0, 0, 0);
  patches.push({ at, kind: 'abs', value: rva - (0x1000 + at + 4) });
}
function movMemRipRax(rva) {
  B(0x48, 0x89, 0x05); const at = code.length; B(0, 0, 0, 0);
  patches.push({ at, kind: 'abs', value: rva - (0x1000 + at + 4) });
}
function movMemRipImm32(rva, imm) {
  B(0x48, 0xc7, 0x05); const at = code.length; B(0, 0, 0, 0); B32(imm);
  patches.push({ at, kind: 'abs', value: rva - (0x1000 + at + 4) });
}
// maschera di stop dei blocchi, in coda al buffer sorgente (r14+0xF000)
const DATA_SLOT = 0xF000;
function leaRdxR14(d) { B(0x49, 0x8d, 0x96); B32(d); }
function maskLoad() { leaRdxR14(DATA_SLOT); B(0x48, 0x8b, 0x02); }
function maskStoreRax() { leaRdxR14(DATA_SLOT); B(0x48, 0x89, 0x02); }
function maskStoreImm(v) { leaRdxR14(DATA_SLOT); B(0x48, 0xc7, 0x02); B32(v); }
function blockLoad() { leaRdxR14(0xF010); B(0x48, 0x8b, 0x02); }
function blockStoreRax() { leaRdxR14(0xF010); B(0x48, 0x89, 0x02); }
function movRaxRipIat(iat) {
  B(0x48, 0x8b, 0x05); const at = code.length; B(0, 0, 0, 0);
  patches.push({ at, kind: 'abs', value: iat - (0x1000 + at + 4) });
}
const cmpRaxImm32 = v => { B(0x48, 0x3d); B32(v); };
const movMemRdxImm32 = (d, v) => { B(0x48, 0xc7, 0x42, d & 255); B32(v); };
function leaRip(reg, label) {
  const r = { rcx: [0x48, 0x0d], rdx: [0x48, 0x15], rsi: [0x48, 0x35], rdi: [0x48, 0x3d], r8: [0x4c, 0x05], r9: [0x4c, 0x0d] }[reg];
  B(r[0], 0x8d, r[1]); const at = code.length; B(0, 0, 0, 0);
  patches.push({ at, label });
}
function leaRsp(reg, disp) {
  const hi = /^r\d+$/.test(reg) && +reg.slice(1) >= 8;
  const low = hi ? +reg.slice(1) - 8 : { rcx: 1, rdx: 2, rbx: 3, rsi: 6, rdi: 7, r8: 0, r9: 1 }[reg];
  B(hi ? 0x4c : 0x48, 0x8d, 0x84 + low * 8, 0x24); B32(disp);
}
const subRsp = v => { B(0x48, 0x81, 0xec); B32(v); };
const addRsp = v => { B(0x48, 0x81, 0xc4); B32(v); };
const movEcx = v => { B(0xb9); B32(v); };
const movEdx = v => { B(0xba); B32(v); };
const movR8d = v => { B(0x41, 0xb8); B32(v); };
const xorEcx = () => B(0x31, 0xc9);
const xorR9d = () => B(0x45, 0x31, 0xc9);
const movR12Rax = () => B(0x49, 0x89, 0xc4);
const movRsiRax = () => B(0x48, 0x89, 0xc6);
const movRbxRax = () => B(0x48, 0x89, 0xc3);
const movRcxRbx = () => B(0x48, 0x89, 0xd9);
const movRcxR12 = () => B(0x4c, 0x89, 0xe1);
const movRdxRdi = () => B(0x48, 0x89, 0xfa);
const movR9R8 = () => B(0x4d, 0x89, 0xc1);
const movR8dR9d = () => B(0x45, 0x89, 0xc8);
const movR8dR13d = () => B(0x45, 0x89, 0xe8);
const movR9dImm = v => { B(0x41, 0xb9); B32(v); };
const movR14Rax = () => B(0x49, 0x89, 0xc6);
const movRdxR14 = () => B(0x4c, 0x89, 0xf2);
const movRdiR14 = () => B(0x4c, 0x89, 0xf7);
const movRsiR14 = () => B(0x4c, 0x89, 0xf6);
const incRsi = () => B(0x48, 0xff, 0xc6);
const incRdi = () => B(0x48, 0xff, 0xc7);
const decRdi = () => B(0x48, 0xff, 0xcf);
const addRsiImm = v => { B(0x48, 0x83, 0xc6, v & 255); };
const cmpRaxM1 = () => B(0x48, 0x83, 0xf8, 0xff);
const testEax = () => B(0x85, 0xc0);
const testDl = () => B(0x84, 0xd2);
const testR8d = () => B(0x45, 0x85, 0xc0);
const testRax = () => B(0x48, 0x85, 0xc0);
const cc = v => (typeof v === 'string' ? v.charCodeAt(0) : v);
const cmpByteRsiImm = v => { B(0x80, 0x3e, cc(v) & 255); };
const cmpByteRsiDispImm = (d, v) => { B(0x80, 0x7e, d & 255, cc(v) & 255); };
const cmpEcxImm32 = v => { B(0x81, 0xf9); B32(v); };
const movEcxMemRsp = d => { B(0x8b, 0x8c, 0x24); B32(d); };
const movR13dMemRsp = d => { B(0x44, 0x8b, 0xac, 0x24); B32(d); };
const cmpR13dImm32 = v => { B(0x41, 0x81, 0xfd); B32(v); };
const addRdiR13 = () => B(0x4c, 0x01, 0xef);
const subEdxImm = v => { B(0x83, 0xea, v & 255); };
const addDlImm = v => { B(0x80, 0xc2, v & 255); };
const movPtrRdiDl = () => B(0x88, 0x17);
const movByteRdiImm = v => { B(0xc6, 0x07, v & 255); };
const movByteRdiM1Imm = v => { B(0xc6, 0x47, 0xff, v & 255); };
const movMemRspImm = (d, v) => { B(0x48, 0xc7, 0x84, 0x24); B32(d); B32(v); };
const movMemRspImm8 = (d, v) => { B(0x48, 0xc7, 0x44, 0x24, d & 255); B32(v); };
const leaRspR9 = d => { B(0x4c, 0x8d, 0x8c, 0x24); B32(d); };
const movzxEdxRsi = () => B(0x0f, 0xb6, 0x16);
const xorEdx = () => B(0x31, 0xd2);
const xorEcxEcx = () => B(0x31, 0xc9);
// --- helper M3b2 (variabili/ambiente) ---
const xorEbX = () => B(0x31, 0xdb);
const xorEdi = () => B(0x31, 0xff);
const leaR15R14 = d => { B(0x4d, 0x8d, 0xbe); B32(d); };
const movzxEaxRsi = () => B(0x0f, 0xb6, 0x06);
const orAlImm = v => { B(0x0c, v & 255); };
const cmpAlImm = v => { B(0x3c, cc(v) & 255); };
const movR8Rsi = () => B(0x49, 0x89, 0xf0);
const movR9Rcx = () => B(0x49, 0x89, 0xc9);
const movRcxR9 = () => B(0x4c, 0x89, 0xc9);
const incRcx = () => B(0x48, 0xff, 0xc1);
const decRcx = () => B(0x48, 0xff, 0xc9);
const testRcx = () => B(0x48, 0x85, 0xc9);
const cmpRcxR9 = () => B(0x4c, 0x39, 0xc9);
const cmpRdiRbx = () => B(0x48, 0x39, 0xdf);
// dup-removed movR10R8 = () => B(0x4d, 0x89, 0xc2);
const movR11MemRdx = () => B(0x4c, 0x8b, 0x1a);
const movRcxMemRdx8 = () => B(0x48, 0x8b, 0x4a, 0x08);
const movRaxMemRdx16 = () => B(0x48, 0x8b, 0x42, 0x10);
const movMemRdxRax16 = () => B(0x48, 0x89, 0x42, 0x10);
const movMemRdxR8 = () => B(0x4c, 0x89, 0x02);
const movMemRdx8R9 = () => B(0x4c, 0x89, 0x4a, 0x08);
const movAlMemR10 = () => B(0x41, 0x8a, 0x02);
const cmpAlMemR11 = () => B(0x41, 0x3a, 0x03);
const incR10 = () => B(0x49, 0xff, 0xc2);
const incR11 = () => B(0x49, 0xff, 0xc3);
const decR10 = () => B(0x49, 0xff, 0xca);
const incRbx = () => B(0x48, 0xff, 0xc3);
const leaRdxRdi3 = () => B(0x48, 0x8d, 0x14, 0x7f);
const leaRdxRbx3 = () => B(0x48, 0x8d, 0x14, 0x5b);
const shlRdx3 = () => B(0x48, 0xc1, 0xe2, 0x03);
const addRdxR15 = () => B(0x4c, 0x01, 0xfa);
const testRdx = () => B(0x48, 0x85, 0xd2);
const pushR8 = () => B(0x41, 0x50);
const pushR9 = () => B(0x41, 0x51);
const popR8 = () => B(0x41, 0x58);
const popR9 = () => B(0x41, 0x59);
// --- helper M3b2b (funzioni) ---
const pushRbx = () => B(0x53);
const popRbx = () => B(0x5b);
const pushRsi = () => B(0x56);
const popRsi = () => B(0x5e);
const pushRdx = () => B(0x52);
const popRdx = () => B(0x5a);
const movRdiRbx = () => B(0x48, 0x89, 0xdf);
const xorEbp = () => B(0x31, 0xed);
const incRbp = () => B(0x48, 0xff, 0xc5);
const decRbp = () => B(0x48, 0xff, 0xcd);
const testRbp = () => B(0x48, 0x85, 0xed);
const movRdiMemRspRbp8 = () => B(0x48, 0x8b, 0x7c, 0xec, 0x08);
const movRcxMemRdi16 = () => B(0x48, 0x8b, 0x4f, 0x10);
const cmpRcxRbp = () => B(0x48, 0x39, 0xe9);
const movRdiRdx = () => B(0x48, 0x89, 0xd7);
const addRdxRsi = () => B(0x48, 0x01, 0xf2);
const addRdxRdi = () => B(0x48, 0x01, 0xfa);
const addRdxImm = v => { B(0x48, 0x83, 0xc2, v & 255); };
const movR8MemRdx = () => B(0x4c, 0x8b, 0x02);
const movR9MemRdx8 = () => B(0x4c, 0x8b, 0x4a, 0x08);
const movRsiMemRdi24 = () => B(0x48, 0x8b, 0x77, 0x18);
const movMemRdiRsi24 = () => B(0x48, 0x89, 0x77, 0x18);
const movMemRdxRdi16 = () => B(0x48, 0x89, 0x7a, 0x10);
const movMemRdxRsi24 = () => B(0x48, 0x89, 0x72, 0x18);
const movRdiRcx = () => B(0x48, 0x89, 0xcf);
const testRdi = () => B(0x48, 0x85, 0xff);
const shlRdi7 = () => B(0x48, 0xc1, 0xe7, 0x07);
const shlRsi4 = () => B(0x48, 0xc1, 0xe6, 0x04);
const subRsiImm16 = () => B(0x48, 0x83, 0xee, 0x10);
const movRcxMemR13 = () => B(0x49, 0x8b, 0x4d, 0x00);
const leaRdxR13Rdi8 = () => B(0x49, 0x8d, 0x54, 0x3d, 0x08);
const leaRdxR13Rcx8 = () => B(0x49, 0x8d, 0x54, 0x0d, 0x08);
const shlRcx7 = () => B(0x48, 0xc1, 0xe1, 0x07);
const incQwordR13 = () => B(0x49, 0xff, 0x45, 0x00);
const movRsiRbp = () => B(0x48, 0x89, 0xee);
const decRsi = () => B(0x48, 0xff, 0xce);
const pushRdi = () => B(0x57);
const popRdi = () => B(0x5f);
const movRsiRdi = () => B(0x48, 0x89, 0xfe);
const cmpRcxRax = () => B(0x48, 0x39, 0xc1);
const sete = () => B(0x0f, 0x94, 0xc0);
const setne = () => B(0x0f, 0x95, 0xc0);
const setl = () => B(0x0f, 0x9c, 0xc0);
const setle = () => B(0x0f, 0x9e, 0xc0);
const setg = () => B(0x0f, 0x9f, 0xc0);
const setge = () => B(0x0f, 0x9d, 0xc0);
const movzxEaxAl = () => B(0x0f, 0xb6, 0xc0);
const incR8d = () => B(0x41, 0xff, 0xc0);
const decR8d = () => B(0x41, 0xff, 0xc8);
// valori taggati (2 bit): Int = n<<2, Bool false = 1, Bool true = 5, chiusura = ptr|2
const shlRax1 = () => B(0x48, 0xc1, 0xe0, 0x02);
const sarRax1 = () => B(0x48, 0xc1, 0xf8, 0x02);
const sarRcx1 = () => B(0x48, 0xc1, 0xf9, 0x02);
const incRax = () => B(0x48, 0xff, 0xc0);
const testAlImm = v => { B(0xa8, v & 255); };
const movByteRspImm = (d, v) => { B(0xc6, 0x84, 0x24); B32(d); B(cc(v) & 255); };
// operatori extra / Bool letterali
const movR8Rax = () => B(0x49, 0x89, 0xc0);
const movRaxR8 = () => B(0x4c, 0x89, 0xc0);
const movEaxMemR8 = () => B(0x41, 0x8b, 0x00);
const cmpEaxImm32 = v => { B(0x3d); B32(v); };
const movEaxImm = v => { B(0xb8); B32(v); };
const cmpByteR8DispImm = (d, v) => { B(0x41, 0x80, 0x78, d & 255, cc(v) & 255); };
const cmpR9Imm = v => { B(0x49, 0x83, 0xf9, v & 255); };
const cqo = () => B(0x48, 0x99);
const idivR8 = () => B(0x49, 0xf7, 0xf8);
const movRaxRdx = () => B(0x48, 0x89, 0xd0);
const imulR8Rcx = () => B(0x4c, 0x0f, 0xaf, 0xc1);
const decRax = () => B(0x48, 0xff, 0xc8);
const testR9d = () => B(0x45, 0x85, 0xc9);
const xorR10d = () => B(0x45, 0x31, 0xd2);
const movR10dImm = v => { B(0x41, 0xba); B32(v); };
const movRsiMemRspDisp = d => { B(0x48, 0x8b, 0x74, 0x24, d & 255); };
const movMemRspDispRsi = d => { B(0x48, 0x89, 0x74, 0x24, d & 255); };
const addRspImm24 = () => B(0x48, 0x83, 0xc4, 0x18);
// chiusure (M3b2b3e): record da 128 byte in r14+0x30000
const leaRdiR14 = d => { B(0x49, 0x8d, 0xbe); B32(d); };
const movRaxMemRdx = () => B(0x48, 0x8b, 0x02);
const movMemRdxRax = () => B(0x48, 0x89, 0x02);
const addRdiRax = () => B(0x48, 0x01, 0xc7);
const movMemRdiR8 = () => B(0x4c, 0x89, 0x07);
const movMemRdiR9_8 = () => B(0x4c, 0x89, 0x4f, 0x08);
const movMemRdiImm32 = (d, v) => { B(0x48, 0xc7, 0x47, d & 255); B32(v); };
const movMemRdiR8_32 = () => B(0x4c, 0x89, 0x47, 0x20);
const movMemRdiR9_40 = () => B(0x4c, 0x89, 0x4f, 0x28);
const addRaxImm128 = () => B(0x48, 0x05, 0x80, 0x00, 0x00, 0x00);
const orRaxImm2 = () => B(0x48, 0x83, 0xc8, 0x02);
const andRaxImmFc = () => B(0x48, 0x83, 0xe0, 0xfc);
const andRdiImmFc = () => B(0x48, 0x83, 0xe7, 0xfc);
const andRdxImmFc = () => B(0x48, 0x83, 0xe2, 0xfc);
const movRdxRax = () => B(0x48, 0x89, 0xc2);
const movRaxRdi = () => B(0x48, 0x89, 0xf8);
const xorEax = () => B(0x31, 0xc0);
// cattura dell'ambiente nelle chiusure (M3b2b3f)
function flagLoad() { leaRdxR14(0xF008); B(0x48, 0x8b, 0x02); }
function flagStoreRax() { leaRdxR14(0xF008); B(0x48, 0x89, 0x02); }
function flagStoreImm(v) { leaRdxR14(0xF008); B(0x48, 0xc7, 0x02); B32(v); }
const movRaxMemRspDisp = d => B(0x48, 0x8b, 0x44, 0x24, d & 255);
const movRcxMemRdiDisp = d => B(0x48, 0x8b, 0x4f, d & 255);
const movR8MemRdiDisp = d => B(0x4c, 0x8b, 0x47, d & 255);
const movR9MemRdiDisp = d => B(0x4c, 0x8b, 0x4f, d & 255);
const movRaxMemRdiDisp = d => B(0x48, 0x8b, 0x47, d & 255);
const movMemRdiRaxDisp = d => B(0x48, 0x89, 0x47, d & 255);
const leaRdxRcx3 = () => B(0x48, 0x8d, 0x14, 0x49);
const shlRdx3H = () => B(0x48, 0xc1, 0xe2, 0x03);
const movRaxMemRdx8 = () => B(0x48, 0x8b, 0x42, 0x08);
const testRbx = () => B(0x48, 0x85, 0xdb);
const movR11Rax = () => B(0x49, 0x89, 0xc3);
const movRaxR11 = () => B(0x4c, 0x89, 0xd8);
const movRaxR9 = () => B(0x4c, 0x89, 0xc8);
const subRaxR14 = () => B(0x4c, 0x29, 0xf0);
const andRaxRcx = () => B(0x48, 0x21, 0xc8);
const orRaxRcx = () => B(0x48, 0x09, 0xc8);
const xorRaxImm4 = () => B(0x48, 0x83, 0xf0, 0x04);
const andRcxImmFF = () => B(0x48, 0x81, 0xe1, 0xff, 0x00, 0x00, 0x00);
const testRcxImm32 = v => { B(0x48, 0xf7, 0xc1); B32(v); };
const orRdiImm32 = v => { B(0x48, 0x81, 0xcf); B32(v); };
const movR9ImmMinus1 = () => B(0x49, 0xc7, 0xc1, 0xff, 0xff, 0xff, 0xff);
const cmpRcxImmMinus1 = () => B(0x48, 0x83, 0xf9, 0xff);
const pushRcx = () => B(0x51);
const movRaxRcx = () => B(0x48, 0x89, 0xc8);
// dup-removed movRdxMemRax = () => B(0x48, 0x8b, 0x10);
const movR8MemRax8 = () => B(0x4c, 0x8b, 0x40, 0x08);
const leaRdxRax16 = () => B(0x48, 0x8d, 0x50, 0x10);
const andRcxImmFc = () => B(0x48, 0x83, 0xe1, 0xfc);
const movR8MemRcx8 = () => B(0x4c, 0x8b, 0x41, 0x08);
const movR9MemRax8 = () => B(0x4c, 0x8b, 0x48, 0x08);
// dup-removed movR10R8 = () => B(0x4d, 0x89, 0xc2);
const addR10R9 = () => B(0x4d, 0x01, 0xca);
const movRcxR10 = () => B(0x4c, 0x89, 0xd1);
const movRdxRcx = () => B(0x48, 0x89, 0xca);
const leaRaxR14 = d => { B(0x49, 0x8d, 0x86); B32(d); };
const leaR9R14 = d => { B(0x4d, 0x8d, 0x8e); B32(d); };
const leaRsiR14 = d => { B(0x49, 0x8d, 0xb6); B32(d); };
const addR9Rax = () => B(0x49, 0x01, 0xc1);
const leaR10R9_16 = () => B(0x4d, 0x8d, 0x51, 0x10);
const movMemR9Imm32 = v => { B(0x49, 0xc7, 0x01); B32(v); };
const movMemR9Rcx8 = () => B(0x49, 0x89, 0x4f, 0x08);
const movDlMemR8 = () => B(0x41, 0x8a, 0x10);
const movDlMemR10 = () => B(0x41, 0x8a, 0x12);
const movMemR9Dl = () => B(0x41, 0x88, 0x11);
const movMemRaxImm32 = v => { B(0xc7, 0x00); B32(v); };
const movR10R8 = () => B(0x4d, 0x89, 0xc2);
const movRdxMemRax = () => B(0x48, 0x8b, 0x10);
const pushR10 = () => B(0x41, 0x52);
const popR10 = () => B(0x41, 0x5a);
const leaRsiRcx16 = () => B(0x48, 0x8d, 0x71, 0x10);
const leaRsiRax16 = () => B(0x48, 0x8d, 0x70, 0x10);
const movRcxR8 = () => B(0x4c, 0x89, 0xc1);
const subR10R8 = () => B(0x4d, 0x29, 0xc2);
const movAlMemRsi = () => B(0x8a, 0x06);
const movDlMemRsi = () => B(0x8a, 0x16);
const movRdxMemRcx = () => B(0x48, 0x8b, 0x11);
// dup-removed movRdxMemRax = () => B(0x48, 0x8b, 0x10);
const movRcxRsi = () => B(0x48, 0x89, 0xf1);
const subRcxR8 = () => B(0x4c, 0x29, 0xc1);
const movMemRdiRcx8 = () => B(0x48, 0x89, 0x4f, 0x08);
const leaR10Rcx31 = () => B(0x4c, 0x8d, 0x51, 0x1f);
const andR10ImmNeg16 = () => B(0x49, 0x83, 0xe2, 0xf0);
const addRaxR10 = () => B(0x4c, 0x01, 0xd0);
const leaR9Rdi16 = () => B(0x4c, 0x8d, 0x4f, 0x10);
const movAlMemR8 = () => B(0x41, 0x8a, 0x00);
const movMemR9Al = () => B(0x41, 0x88, 0x01);
const incR8 = () => B(0x49, 0xff, 0xc0);
const incR9 = () => B(0x49, 0xff, 0xc1);
const orRaxImm3 = () => B(0x48, 0x83, 0xc8, 0x03);
const andRdxImm3 = () => B(0x48, 0x83, 0xe2, 0x03);
const cmpEdxImm3 = () => B(0x83, 0xfa, 0x03);
const movRcxMemRax8 = () => B(0x48, 0x8b, 0x48, 0x08);
const movRaxMemRsp = () => B(0x48, 0x8b, 0x04, 0x24);
const movRcxRbp = () => B(0x48, 0x89, 0xe9);
const leaR13R14 = d => { B(0x4d, 0x8d, 0xae); B32(d); };
const movMemR13Rcx = () => B(0x49, 0x89, 0x4d, 0x00);
const addRspImm8 = () => B(0x48, 0x83, 0xc4, 0x08);
const movMemRspRbp8Rsi = () => B(0x48, 0x89, 0x74, 0xec, 0x08);
const movRdiMemRspRbp = () => B(0x48, 0x8b, 0x3c, 0xec);
const movRsiMemRsp = () => B(0x48, 0x8b, 0x34, 0x24);
const movRdxMemRsp = () => B(0x48, 0x8b, 0x14, 0x24);
const addRdiImm16 = () => B(0x48, 0x83, 0xc7, 0x10);
const shrRdi4 = () => B(0x48, 0xc1, 0xef, 0x04);
const shlRdx7 = () => B(0x48, 0xc1, 0xe2, 0x07);
const leaRdxR13Rdx8 = () => B(0x49, 0x8d, 0x54, 0x15, 0x08);
const cmpRdiImm = v => { B(0x48, 0x83, 0xff, v & 255); };
const divRcx = () => B(0x48, 0xf7, 0xf1);
const negRax = () => B(0x48, 0xf7, 0xd8);
const pushRax = () => B(0x50);
const popRax = () => B(0x58);
const popRcx = () => B(0x59);
const addRaxRcx = () => B(0x48, 0x01, 0xc8);
const subRaxRcx = () => B(0x48, 0x29, 0xc8);
const imulRaxRcx = () => B(0x48, 0x0f, 0xaf, 0xc1);
const imulRcx10 = () => B(0x48, 0x6b, 0xc9, 0x0a);
const addRcxRdx = () => B(0x48, 0x01, 0xd1);
const subR9Rdi = () => B(0x49, 0x29, 0xf9);
const addRdiRcx = () => B(0x48, 0x01, 0xcf);
const pushRbp = () => B(0x55);
const popRbp = () => B(0x5d);
const movRbpRsp = () => B(0x48, 0x89, 0xe5);
const movRspRbp = () => B(0x48, 0x89, 0xec);
const andRspM16 = () => B(0x48, 0x83, 0xe4, 0xf0);
const ret = () => B(0xc3);
const subRsp8 = v => { B(0x48, 0x83, 0xec, v & 255); };
const addRsp8 = v => { B(0x48, 0x83, 0xc4, v & 255); };

// ---------------------------------------------------------------- PE/data layout
const IAT = 0x4000;
const DATA = 0x2700;                    // qword statico (maschera di stop dei blocchi)
const SEC_RAW = 0x6000;                 // .text 24576 byte, RVA 0x1000..0x7000
const HEADERS = 0x200, FILESZ = HEADERS + SEC_RAW;

// ---------------------------------------------------------------- main
subRsp(0x1408);                          // path [rsp+0x100], locals; il sorgente e' su VirtualAlloc
movEcx(0xfffffff5);
callIat(0, IAT);                        // GetStdHandle
movR12Rax();
callIat(1, IAT);                        // GetCommandLineA
movRsiRax();

// salta il nome del programma, estrae il primo argomento in [rsp+0x100]
cmpByteRsiImm(0x22); jne('skip_plain');
L('q_loop');
incRsi();
cmpByteRsiImm(0); je('no_arg');
cmpByteRsiImm(0x22); jne('q_loop');
incRsi(); jmp('skip_spaces');
L('skip_plain');
cmpByteRsiImm(0); je('no_arg');
cmpByteRsiImm(0x20); je('after_prog');
cmpByteRsiImm(0x09); je('after_prog');
incRsi(); jmp('skip_plain');
L('after_prog'); incRsi();
L('skip_spaces');
cmpByteRsiImm(0x20); jne('argv_start');
incRsi(); jmp('skip_spaces');
L('argv_start');
cmpByteRsiImm(0); je('no_arg');
leaRsp('rdi', 0x100);
cmpByteRsiImm(0x22); jne('copy_plain');
incRsi();
L('copy_q');
movzxEdxRsi(); testDl(); je('copy_nul');
cmpByteRsiImm(0x22); je('copy_q_end');
// copia il byte: dl -> [rdi]
B(0x88, 0x17);
incRsi(); incRdi();
jmp('copy_q');
L('copy_q_end'); incRsi(); jmp('copy_nul');
L('copy_plain');
movzxEdxRsi(); testDl(); je('copy_nul');
cmpByteRsiImm(0x20); je('copy_nul');
cmpByteRsiImm(0x09); je('copy_nul');
B(0x88, 0x17);
incRsi(); incRdi();
jmp('copy_plain');
L('copy_nul');
movByteRdiImm(0);
// path vuoto -> usage
L('path_check');
// cmp byte [rsp+0x100],0 : 80 BC 24 00 01 00 00 00
B(0x80, 0xbc, 0x24, 0x00, 0x01, 0x00, 0x00, 0x00);
je('usage');

// CreateFileA(path, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, NORMAL, NULL)
leaRsp('rcx', 0x100);
movEdx(0x80000000);
movR8d(1);
xorR9d();
movMemRspImm(0x20, 3);
movMemRspImm(0x28, 0x80);
movMemRspImm(0x30, 0);
callIat(2, IAT);
cmpRaxM1(); je('open_fail');
movRbxRax();

// VirtualAlloc(NULL, 0x40000, MEM_COMMIT|MEM_RESERVE, PAGE_READWRITE)
xorEcx();
movEdx(0x40000);
movR8d(0x3000);
movR9dImm(4);
callIat(7, IAT);
testRax(); je('fail');
movR14Rax();

// ReadFile(hFile, buf, 0x10000, &count, NULL)
movRcxRbx();
movRdxR14();
movR8d(0x10000);
leaRspR9(0x40);
movMemRspImm(0x20, 0);
callIat(3, IAT);
testEax(); je('read_fail');
movR13dMemRsp(0x40);                    // r13 = byte letti
movRcxRbx(); callIat(5, IAT);           // CloseHandle
cmpR13dImm32(0xF000); jae('read_fail');// file troppo grande (slot maschera a +0xF000)
movRdiR14(); addRdiR13(); movByteRdiImm(0);
xorEbX();                               // rbx = numero di variabili in ambiente
leaR15R14(0x10000);                     // r15 = base ambiente (dopo i 64 KiB di sorgente)
leaR13R14(0x20000);                     // r13 = base tabella funzioni
xorEcx(); movMemR13Rcx();               // funzioni = 0
leaRdxR14(0x30000); xorEax(); movMemRdxRax(); // heap chiusure: bump = 0
movRsiR14();
maskStoreImm(0);                        // maschera di stop dei blocchi
flagStoreImm(0);                        // dentro una funzione/chiusura?
leaRdxR14(0xF028); movMemRdxImm32(0, 0); // modalità di stampa inline
callL('parse_program');
xorEcx(); callIat(6, IAT);

// ---------------------------------------------------------------- parser
L('parse_program');
L('pp_loop');
callL('skip_ws');
cmpByteRsiImm(0); je('pp_eof');
// stop su 'end' se maschera bit 1
maskLoad(); testAlImm(1); jz('pp_no_end');
cmpByteRsiImm('e'); jne('pp_no_end');
cmpByteRsiDispImm(1, 'n'); jne('pp_no_end');
cmpByteRsiDispImm(2, 'd'); jne('pp_no_end');
ret();
L('pp_no_end');
// stop su 'else' se maschera bit 2
maskLoad(); testAlImm(2); jz('pp_no_else');
cmpByteRsiImm('e'); jne('pp_no_else');
cmpByteRsiDispImm(1, 'l'); jne('pp_no_else');
cmpByteRsiDispImm(2, 's'); jne('pp_no_else');
cmpByteRsiDispImm(3, 'e'); jne('pp_no_else');
ret();
L('pp_no_else');
// statement begin
cmpByteRsiImm('b'); jne('pp_not_begin');
cmpByteRsiDispImm(1, 'e'); jne('pp_not_begin');
cmpByteRsiDispImm(2, 'g'); jne('pp_not_begin');
cmpByteRsiDispImm(3, 'i'); jne('pp_not_begin');
cmpByteRsiDispImm(4, 'n'); jne('pp_not_begin');
jmp('st_begin');
L('pp_not_begin');
// statement let
cmpByteRsiImm('l'); jne('pp_not_let');
cmpByteRsiDispImm(1, 'e'); jne('pp_not_let');
cmpByteRsiDispImm(2, 't'); jne('pp_not_let');
jmp('st_let');
L('pp_not_let');
// statement while
cmpByteRsiImm('w'); jne('pp_not_while');
cmpByteRsiDispImm(1, 'h'); jne('pp_not_while');
cmpByteRsiDispImm(2, 'i'); jne('pp_not_while');
cmpByteRsiDispImm(3, 'l'); jne('pp_not_while');
cmpByteRsiDispImm(4, 'e'); jne('pp_not_while');
jmp('st_while');
L('pp_not_while');
// statement if
cmpByteRsiImm('i'); jne('pp_not_if');
cmpByteRsiDispImm(1, 'f'); jne('pp_not_if');
jmp('st_if');
L('pp_not_if');
cmpByteRsiImm('f'); jne('pp_not_function');
cmpByteRsiDispImm(1, 'u'); jne('pp_not_function');
cmpByteRsiDispImm(2, 'n'); jne('pp_not_function');
cmpByteRsiDispImm(3, 'c'); jne('pp_not_function');
cmpByteRsiDispImm(4, 't'); jne('pp_not_function');
cmpByteRsiDispImm(5, 'i'); jne('pp_not_function');
cmpByteRsiDispImm(6, 'o'); jne('pp_not_function');
cmpByteRsiDispImm(7, 'n'); jne('pp_not_function');
jmp('st_function');
L('pp_not_function');
cmpByteRsiDispImm(0, 'p'); jne('stmt_assign');
cmpByteRsiDispImm(1, 'r'); jne('stmt_assign');
cmpByteRsiDispImm(2, 'i'); jne('stmt_assign');
cmpByteRsiDispImm(3, 'n'); jne('stmt_assign');
cmpByteRsiDispImm(4, 't'); jne('stmt_assign');
cmpByteRsiDispImm(5, 'l'); jne('stmt_assign');
cmpByteRsiDispImm(6, 'n'); jne('stmt_assign');
addRsiImm(7);
callL('skip_ws');
cmpByteRsiImm('('); jne('fail');
incRsi();
callL('parse_expr');
callL('skip_ws');
cmpByteRsiImm(')'); jne('fail');
incRsi();
callL('print_int');
jmp('pp_loop');
L('stmt_assign');
pushRsi();                        // inizio statement (per expression statement)
cmpByteRsiImm('_'); je('st_name');
cmpByteRsiImm('a'); jb('st_expr_plain');
cmpByteRsiImm('z'); ja('st_expr_plain');
L('st_name');
callL('parse_ident');
pushR8(); pushR9();
callL('skip_ws');
cmpByteRsiImm('='); je('st_assign_eq');
cmpByteRsiImm('('); je('st_func');
cmpByteRsiImm('+'); je('st_add_check');
jmp('st_expr');
L('st_add_check');
cmpByteRsiDispImm(1, '='); jne('st_expr');
addRsiImm(2); callL('skip_ws'); callL('parse_expr');
popR9(); popR8(); pushRax();
callL('env_lookup'); popRcx();
sarRax1(); sarRcx1(); addRaxRcx(); shlRax1();
callL('env_assign'); addRspImm8(); jmp('pp_loop');

L('st_assign_eq');
incRsi();
callL('skip_ws');
callL('parse_expr');
popR9(); popR8();
callL('env_assign');
addRspImm8();
jmp('pp_loop');

L('st_expr');
popR9(); popR8(); popRsi();
callL('parse_expr');
blockStoreRax();
jmp('pp_loop');
L('st_expr_plain');
popRsi();
callL('parse_expr');
blockStoreRax();
jmp('pp_loop');

L('st_func');
movRcxMemR13(); shlRcx7(); leaRdxR13Rcx8();   // entry = r13+8+count*128
popR9(); popR8();
movMemRdxR8(); movMemRdx8R9();
movMemRdxImm32(0x60, 0);
pushRdx();                                      // entry ptr
xorEdi();                                       // offset parametri
incRsi(); callL('skip_ws');
cmpByteRsiImm(')'); je('st_func_endparams');
L('st_func_param');
cmpRdiImm(64); jae('fail');
callL('parse_ident');
movRdxMemRsp(); addRdxRdi(); addRdxImm(32);
movMemRdxR8(); movMemRdx8R9();
addRdiImm16();
callL('skip_ws');
cmpByteRsiImm(','); je('st_func_comma');
cmpByteRsiImm(')'); je('st_func_endparams');
jmp('fail');
L('st_func_comma');
incRsi(); callL('skip_ws'); jmp('st_func_param');
L('st_func_endparams');
incRsi(); callL('skip_ws');
cmpByteRsiImm('='); jne('fail');
incRsi(); callL('skip_ws');
movRdxMemRsp(); movMemRdxRsi24();               // body ptr
shrRdi4(); movRdxMemRsp(); movMemRdxRdi16();    // numero parametri
popRdx();
incQwordR13();
L('st_func_skip');
cmpByteRsiImm(0); je('st_func_done');
cmpByteRsiImm(0x0a); je('st_func_done');
cmpByteRsiImm(0x3b); je('st_func_done');
incRsi(); jmp('st_func_skip');
L('st_func_done');
addRspImm8();
jmp('pp_loop');

// scan_end: da rsi all' 'end'/'else' di chiusura a profondità 0.
// r9d != 0: si ferma anche su 'else'; output r10d=1 se else, 0 se end.
L('scan_end');
xorEdi();
L('sc_loop');
cmpByteRsiImm(0); je('fail');
cmpByteRsiImm('#'); je('sc_comment');
cmpByteRsiImm('l'); jne('sc_try_fn');
cmpByteRsiDispImm(1, 'e'); jne('sc_try_fn');
cmpByteRsiDispImm(2, 't'); jne('sc_try_fn');
incRdi(); addRsiImm(3); jmp('sc_loop');
L('sc_try_fn');
cmpByteRsiImm('f'); jne('sc_try_while');
cmpByteRsiDispImm(1, 'u'); jne('sc_try_while');
cmpByteRsiDispImm(2, 'n'); jne('sc_try_while');
cmpByteRsiDispImm(3, 'c'); jne('sc_try_while');
cmpByteRsiDispImm(4, 't'); jne('sc_try_while');
cmpByteRsiDispImm(5, 'i'); jne('sc_try_while');
cmpByteRsiDispImm(6, 'o'); jne('sc_try_while');
cmpByteRsiDispImm(7, 'n'); jne('sc_try_while');
incRdi(); addRsiImm(8); jmp('sc_loop');
L('sc_try_while');
cmpByteRsiImm('w'); jne('sc_try_if');
cmpByteRsiDispImm(1, 'h'); jne('sc_try_if');
cmpByteRsiDispImm(2, 'i'); jne('sc_try_if');
cmpByteRsiDispImm(3, 'l'); jne('sc_try_if');
cmpByteRsiDispImm(4, 'e'); jne('sc_try_if');
incRdi(); addRsiImm(5); jmp('sc_loop');
L('sc_try_if');
cmpByteRsiImm('i'); jne('sc_try_end');
cmpByteRsiDispImm(1, 'f'); jne('sc_try_end');
incRdi(); addRsiImm(2); jmp('sc_loop');
L('sc_try_end');
cmpByteRsiImm('e'); jne('sc_adv');
cmpByteRsiDispImm(1, 'n'); jne('sc_try_else');
cmpByteRsiDispImm(2, 'd'); jne('sc_try_else');
testRdi(); jz('sc_end_found');
decRdi(); addRsiImm(3); jmp('sc_loop');
L('sc_try_else');
cmpByteRsiDispImm(1, 'l'); jne('sc_adv');
cmpByteRsiDispImm(2, 's'); jne('sc_adv');
cmpByteRsiDispImm(3, 'e'); jne('sc_adv');
testRdi(); jnz('sc_adv');
testR9d(); jz('sc_adv');
movR10dImm(1); ret();
L('sc_end_found'); xorR10d(); ret();
L('sc_adv'); incRsi(); jmp('sc_loop');
L('sc_comment');
incRsi();
cmpByteRsiImm(0); je('fail');
cmpByteRsiImm(0x0a); jne('sc_comment');
incRsi(); jmp('sc_loop');

// if cond <blocco> [else <blocco>] end
L('st_if');
addRsiImm(2);
callL('skip_ws');
callL('parse_expr');
callL('skip_ws');
pushRax();                               // condizione
pushRsi();                               // inizio blocco vero
movR9dImm(1); callL('scan_end');
popRdi(); popRax();
cmpRaxImm32(5); jne('st_if_false');
movRsiRdi();
maskLoad(); pushRax(); maskStoreImm(3);
callL('parse_program');
popRax(); maskStoreRax();
L('st_if_elseif_loop');
cmpByteRsiImm('e'); jne('st_if_true_end');
cmpByteRsiDispImm(1, 'l'); jne('st_if_true_end');
cmpByteRsiDispImm(2, 's'); jne('st_if_true_end');
cmpByteRsiDispImm(3, 'e'); jne('st_if_true_end');  // elseif
addRsiImm(6); callL('skip_ws');
callL('parse_expr'); callL('skip_ws');  // condizione elseif
pushRax(); pushRsi(); movR9dImm(1); callL('scan_end');
popRdi(); popRax();
cmpRaxImm32(5); jne('st_elseif_false');
movRsiRdi();
maskLoad(); pushRax(); maskStoreImm(3);
callL('parse_program');
popRax(); maskStoreRax();
jmp('st_if_elseif_loop');
L('st_elseif_false');
addRsiImm(4); callL('skip_ws');
maskLoad(); pushRax(); maskStoreImm(1);
callL('parse_program');
popRax(); maskStoreRax();
jmp('st_if_done');
L('st_if_true_end');
cmpByteRsiImm('e'); jne('st_if_true_noelse');
cmpByteRsiDispImm(1, 'l'); jne('st_if_true_noelse');
addRsiImm(4); callL('skip_ws');
movR9dImm(0); callL('scan_end');
addRsiImm(3); jmp('st_if_done');
L('st_if_true_noelse');
addRsiImm(3); jmp('st_if_done');
L('st_if_false');
cmpByteRsiImm('e'); jne('st_if_false_end');
cmpByteRsiDispImm(1, 'l'); jne('st_if_false_end');
addRsiImm(4); callL('skip_ws');
maskLoad(); pushRax(); maskStoreImm(1);
callL('parse_program');
popRax(); maskStoreRax();
addRsiImm(3); jmp('st_if_done');
L('st_if_false_end');
addRsiImm(3);
L('st_if_done');
jmp('pp_loop');

// while cond <blocco> end
L('st_while');
addRsiImm(5);
callL('skip_ws');
pushRsi();                               // cond_start
callL('parse_expr');
callL('skip_ws');
pushRsi();                               // body_start
movR9dImm(0); callL('scan_end');
pushRsi();                               // end
L('wh_loop');
movRsiMemRspDisp(0x10);
callL('parse_expr');
callL('skip_ws');
movMemRspDispRsi(0x08);
cmpRaxImm32(5); jne('wh_done');
movRsiMemRspDisp(0x08);
maskLoad(); pushRax(); maskStoreImm(1);
callL('parse_program');
popRax(); maskStoreRax();
jmp('wh_loop');
L('wh_done');
movRsiMemRspDisp(0x00);
addRsiImm(3);
addRspImm24();
jmp('pp_loop');

// function f(x, ...) <espressione> end
L('st_function');
addRsiImm(8);
callL('skip_ws');
callL('parse_ident');
pushR8(); pushR9();
movRcxMemR13(); shlRcx7(); leaRdxR13Rcx8();
popR9(); popR8();
movMemRdxR8(); movMemRdx8R9();
movMemRdxImm32(0x60, 0);
pushRdx();
xorEdi();
callL('skip_ws');
cmpByteRsiImm('('); jne('fail');
incRsi(); callL('skip_ws');
cmpByteRsiImm(')'); je('sf_params_end');
L('sf_param');
cmpRdiImm(64); jae('fail');
callL('parse_ident');
movRdxMemRsp(); addRdxRdi(); addRdxImm(32);
movMemRdxR8(); movMemRdx8R9();
addRdiImm16();
callL('skip_ws');
cmpByteRsiImm(','); je('sf_param_comma');
cmpByteRsiImm(')'); je('sf_params_end');
jmp('fail');
L('sf_param_comma');
incRsi(); callL('skip_ws'); jmp('sf_param');
L('sf_params_end');
incRsi();
callL('skip_ws');
cmpByteRsiImm('!'); jne('sf_no_effect');
L('sf_effect');
incRsi(); callL('skip_ws'); callL('parse_ident'); callL('skip_ws');
cmpByteRsiImm(','); jne('sf_no_effect');
incRsi(); callL('skip_ws'); jmp('sf_effect');
L('sf_no_effect');
movRdxMemRsp(); movMemRdxRsi24();
shrRdi4(); orRdiImm32(0x100); movRdxMemRsp(); movMemRdxRdi16();
popRdx();
incQwordR13();
movR9dImm(0); callL('scan_end');
addRsiImm(3);
L('sf_skip');
cmpByteRsiImm(0); je('sf_done');
cmpByteRsiImm(0x0a); je('sf_done');
cmpByteRsiImm(0x3b); je('sf_done');
incRsi(); jmp('sf_skip');
L('sf_done');
jmp('pp_loop');

// let name = expr <blocco> end
L('st_let');
addRsiImm(3);
callL('skip_ws');
pushRbx();
callL('parse_ident'); pushR8(); pushR9();
callL('skip_ws');
cmpByteRsiImm('='); jne('fail');
incRsi(); callL('skip_ws');
callL('parse_expr'); pushRax();
xorR8dBits(); movR9ImmMinus1(); xorEax(); callL('env_store');
popRax(); popR9(); popR8(); callL('env_store');
callL('skip_ws');
maskLoad(); pushRax(); maskStoreImm(1);
callL('parse_program');
popRax(); maskStoreRax();
addRsiImm(3);
L('let_skip');
cmpByteRsiImm(0); je('let_done');
cmpByteRsiImm(0x0a); je('let_done');
cmpByteRsiImm(0x3b); je('let_done');
incRsi(); jmp('let_skip');
L('let_done');
popRbx(); jmp('pp_loop');

// begin <blocco> end
L('st_begin');
addRsiImm(5);
callL('skip_ws');
maskLoad(); pushRax(); maskStoreImm(1);
callL('parse_program');
popRax(); maskStoreRax();
addRsiImm(3);
L('bg_skip');
cmpByteRsiImm(0); je('bg_done');
cmpByteRsiImm(0x0a); je('bg_done');
cmpByteRsiImm(0x3b); je('bg_done');
incRsi(); jmp('bg_skip');
L('bg_done');
jmp('pp_loop');

L('pp_eof');
maskLoad(); testRax(); jnz('fail');
L('pp_done'); ret();

L('skip_ws');
L('sw_loop');
cmpByteRsiImm(0x20); je('sw_adv');
cmpByteRsiImm(0x09); je('sw_adv');
cmpByteRsiImm(0x0a); je('sw_adv');
cmpByteRsiImm(0x0d); je('sw_adv');
cmpByteRsiImm(0x3b); je('sw_adv');
cmpByteRsiImm('#'); je('sw_hash');
ret();
L('sw_adv'); incRsi(); jmp('sw_loop');
L('sw_hash');
incRsi();
cmpByteRsiImm(0); je('sw_end');
cmpByteRsiImm(0x0a); je('sw_adv');
jmp('sw_hash');
L('sw_end'); ret();

// logica: && e || (bitwise sui tag Bool: 1=false, 5=true)
L('parse_or');
callL('parse_and'); pushRax();
L('po_loop');
callL('skip_ws');
cmpByteRsiImm('|'); jne('po_done');
cmpByteRsiDispImm(1, '|'); jne('po_done');
addRsiImm(2); callL('parse_and'); popRcx(); orRaxRcx(); pushRax(); jmp('po_loop');
L('po_done'); popRax(); ret();
L('parse_and');
callL('parse_cmp'); pushRax();
L('pa_loop');
callL('skip_ws');
cmpByteRsiImm('&'); jne('pa_done');
cmpByteRsiDispImm(1, '&'); jne('pa_done');
addRsiImm(2); callL('parse_cmp'); popRcx(); andRaxRcx(); pushRax(); jmp('pa_loop');
L('pa_done'); popRax(); ret();

// confronti: == != < <= > >= producono 0/1
L('parse_cmp');
callL('parse_sum');
pushRax();
L('pc_loop');
callL('skip_ws');
cmpByteRsiImm('='); je('pc_eq');
cmpByteRsiImm('!'); je('pc_ne');
cmpByteRsiImm('<'); je('pc_lt');
cmpByteRsiImm('>'); je('pc_gt');
popRax(); ret();
L('pc_eq');
cmpByteRsiDispImm(1, '='); jne('fail');
addRsiImm(2); callL('parse_sum'); popRcx(); sarRax1(); sarRcx1(); cmpRcxRax(); sete(); movzxEaxAl(); shlRax1(); incRax(); pushRax(); jmp('pc_loop');
L('pc_ne');
cmpByteRsiDispImm(1, '='); jne('fail');
addRsiImm(2); callL('parse_sum'); popRcx(); sarRax1(); sarRcx1(); cmpRcxRax(); setne(); movzxEaxAl(); shlRax1(); incRax(); pushRax(); jmp('pc_loop');
L('pc_lt');
cmpByteRsiDispImm(1, '='); je('pc_le');
incRsi(); callL('parse_sum'); popRcx(); sarRax1(); sarRcx1(); cmpRcxRax(); setl(); movzxEaxAl(); shlRax1(); incRax(); pushRax(); jmp('pc_loop');
L('pc_le');
addRsiImm(2); callL('parse_sum'); popRcx(); sarRax1(); sarRcx1(); cmpRcxRax(); setle(); movzxEaxAl(); shlRax1(); incRax(); pushRax(); jmp('pc_loop');
L('pc_gt');
cmpByteRsiDispImm(1, '='); je('pc_ge');
incRsi(); callL('parse_sum'); popRcx(); sarRax1(); sarRcx1(); cmpRcxRax(); setg(); movzxEaxAl(); shlRax1(); incRax(); pushRax(); jmp('pc_loop');
L('pc_ge');
addRsiImm(2); callL('parse_sum'); popRcx(); sarRax1(); sarRcx1(); cmpRcxRax(); setge(); movzxEaxAl(); shlRax1(); incRax(); pushRax(); jmp('pc_loop');

// ternario con valutazione corta (scansiona il ramo non scelto senza valutarlo)
L('parse_expr');
L('parse_ternary');
callL('parse_or');
callL('skip_ws');
cmpByteRsiImm('?'); je('pt_tern');
ret();
L('pt_tern');
incRsi();
callL('skip_ws');
pushRsi();                               // inizio ramo vero
xorEdi(); xorR8dBits();                  // depth, qdepth
L('pt_scan');
cmpByteRsiImm(0); je('fail');
cmpByteRsiImm('('); je('pt_open');
cmpByteRsiImm('['); je('pt_open');
cmpByteRsiImm('{'); je('pt_open');
cmpByteRsiImm(')'); je('pt_close');
cmpByteRsiImm(']'); je('pt_close');
cmpByteRsiImm('}'); je('pt_close');
testRdi(); jnz('pt_adv');
cmpByteRsiImm('?'); je('pt_q');
cmpByteRsiImm(':'); je('pt_colon');
L('pt_adv'); incRsi(); jmp('pt_scan');
L('pt_open'); incRdi(); incRsi(); jmp('pt_scan');
L('pt_close'); testRdi(); jz('fail'); decRdi(); incRsi(); jmp('pt_scan');
L('pt_q'); incR8d(); incRsi(); jmp('pt_scan');
L('pt_colon'); testR8d(); jz('pt_found'); decR8d(); incRsi(); jmp('pt_scan');
L('pt_found');
pushRsi();                               // puntatore al ':'
cmpRaxImm32(5); jne('pt_false');
popRdi(); popRsi(); pushRdi();           // colon in rdi, true_start in rsi
callL('parse_ternary');
popRdi(); movRsiRdi(); incRsi(); xorEdi();
L('pt_skip');
cmpByteRsiImm(0); je('pt_done');
cmpByteRsiImm('('); je('pt_inskip');
cmpByteRsiImm('['); je('pt_inskip');
cmpByteRsiImm('{'); je('pt_inskip');
cmpByteRsiImm(')'); je('pt_close2');
cmpByteRsiImm(']'); je('pt_close2');
cmpByteRsiImm('}'); je('pt_close2');
testRdi(); jnz('pt_skipadv');
cmpByteRsiImm(','); je('pt_done');
cmpByteRsiImm(';'); je('pt_done');
cmpByteRsiImm(0x0a); je('pt_done');
L('pt_skipadv'); incRsi(); jmp('pt_skip');
L('pt_inskip'); incRdi(); incRsi(); jmp('pt_skip');
L('pt_close2'); testRdi(); jz('pt_done'); decRdi(); incRsi(); jmp('pt_skip');
L('pt_done'); ret();
L('pt_false');
popRsi(); popRdi();
incRsi(); callL('skip_ws'); callL('parse_ternary'); ret();

L('parse_sum');
callL('parse_term');
pushRax();
L('pe_loop');
callL('skip_ws');
cmpByteRsiImm('+'); je('pe_add');
cmpByteRsiImm('-'); je('pe_sub');
popRax(); ret();
L('pe_add');
incRsi(); callL('parse_term'); popRcx(); sarRax1(); sarRcx1(); addRaxRcx(); shlRax1(); pushRax(); jmp('pe_loop');
L('pe_sub');
incRsi(); callL('parse_term'); popRcx(); sarRax1(); sarRcx1(); B(0x48, 0x29, 0xc1); movRaxRcx(); shlRax1(); pushRax(); jmp('pe_loop');

L('parse_term');
callL('parse_factor');
pushRax();
L('pt_loop');
callL('skip_ws');
cmpByteRsiImm('*'); je('pt_mul');
cmpByteRsiImm('%'); je('pt_mod');
popRax(); ret();
L('pt_mul');
incRsi(); callL('parse_factor'); popRcx();
movRdxRcx(); andRdxImm3(); cmpEdxImm3(); jne('pt_mul_num');
movRdxRax(); andRdxImm3(); cmpEdxImm3(); jne('pt_mul_num');
andRcxImmFc(); andRaxImmFc();
movRdxMemRcx(); B(0x48,0x83,0xfa,0x01); jne('fail');
movRdxMemRax(); B(0x48,0x83,0xfa,0x01); jne('fail');
pushRsi(); pushRcx(); pushRax(); movR8MemRcx8(); movR9MemRax8(); movR10R8(); addR10R9(); pushR10();
leaRdxR14(0x30000); movRaxMemRdx();
leaRdiR14(0x30008); addRdiRax();
movMemRdiImm32(0, 1); movRcxR10(); movMemRdiRcx8();
leaR10Rcx31(); andR10ImmNeg16(); addRaxR10(); movMemRdxRax();
popR10(); popRax(); popRcx();
leaR9Rdi16();
leaRsiRcx16(); movRcxR8();
L('pt_c1'); testRcx(); jz('pt_c1d'); movDlMemRsi(); movMemR9Dl(); incRsi(); incR9(); decRcx(); jmp('pt_c1');
L('pt_c1d');
leaRsiRax16(); subR10R8(); movRcxR10();
L('pt_c2'); testRcx(); jz('pt_c2d'); movDlMemRsi(); movMemR9Dl(); incRsi(); incR9(); decRcx(); jmp('pt_c2');
L('pt_c2d');
popRsi(); movRaxRdi(); orRaxImm3(); pushRax(); jmp('pt_loop');
L('pt_mul_num');
sarRax1(); sarRcx1(); imulRaxRcx(); shlRax1(); pushRax(); jmp('pt_loop');
sarRax1(); sarRcx1(); imulRaxRcx(); shlRax1(); pushRax(); jmp('pt_loop');
L('pt_mod');
incRsi(); callL('parse_factor'); popRcx(); sarRax1(); sarRcx1();
movR8Rax(); movRaxRcx(); cqo(); idivR8(); movRaxRdx(); shlRax1(); pushRax(); jmp('pt_loop');

// unario / potenza / primario
L('parse_factor');
callL('parse_unary'); ret();
L('parse_unary');
callL('skip_ws');
cmpByteRsiImm('-'); je('pf_neg2');
cmpByteRsiImm('!'); je('pf_not');
callL('parse_power'); ret();
L('pf_not'); incRsi(); callL('parse_unary'); xorRaxImm4(); ret();
L('pf_neg2');
incRsi(); callL('parse_unary'); sarRax1(); negRax(); shlRax1(); ret();
L('parse_power');
callL('parse_primary');
pushRax();
L('ppow_loop');
callL('skip_ws');
cmpByteRsiImm('^'); je('ppow_op');
popRax(); ret();
L('ppow_op');
incRsi(); callL('parse_unary'); popRcx(); sarRax1(); sarRcx1();
testRax(); js('fail');
movR8d(1);
L('ppow_mul');
testRax(); jz('ppow_done');
imulR8Rcx(); decRax(); jmp('ppow_mul');
L('ppow_done');
movRaxR8(); shlRax1(); pushRax(); jmp('ppow_loop');

L('parse_primary');
callL('skip_ws');
cmpByteRsiImm('['); je('pf_list');
cmpByteRsiImm(':'); je('pf_symbol');
cmpByteRsiImm('"'); je('pf_string');
cmpByteRsiImm('('); je('pf_paren');
cmpByteRsiImm('0'); jb('pf_ident');
cmpByteRsiImm('9'); jbe('pf_number');
jmp('pf_ident');
L('pf_list');
incRsi(); callL('skip_ws');
leaRdxR14(0x30000); movRaxMemRdx();
leaRdiR14(0x30008); addRdiRax();
movMemRdiImm32(0, 2); movMemRdiImm32(8, 0);
B(0x48, 0x05, 0x10, 0x02, 0x00, 0x00); // 64 valori da 8 byte + header
leaRdxR14(0x30000); movMemRdxRax();
movRaxRdi(); orRaxImm3(); pushRax();
cmpByteRsiImm(']'); je('pf_list_empty');
L('pf_list_loop');
callL('parse_expr');
pushRax();
B(0x48, 0x8b, 0x7c, 0x24, 0x08); // header lista sotto il valore
andRdiImmFc();
movRcxMemRdiDisp(8);
B(0x48, 0x83, 0xf9, 64); jae('fail');
popRax();
B(0x48, 0x89, 0x44, 0xcf, 0x10); // [header + 16 + index*8] = valore
incRcx(); movMemRdiRcx8();
callL('skip_ws');
cmpByteRsiImm(']'); je('pf_list_done');
cmpByteRsiImm(','); jne('fail');
incRsi(); callL('skip_ws'); jmp('pf_list_loop');
L('pf_list_done');
incRsi(); popRax(); ret();
L('pf_list_empty');
incRsi(); popRax();
ret();
L('pf_number');
xorEcxEcx();
L('pf_num_loop');
cmpByteRsiImm('0'); jb('pf_num_done');
cmpByteRsiImm('9'); ja('pf_num_done');
imulRcx10();
movzxEdxRsi();
subEdxImm(0x30);
addRcxRdx();
incRsi();
jmp('pf_num_loop');
L('pf_num_done');
movRaxRcx(); shlRax1(); ret();
L('pf_paren');
incRsi(); callL('parse_expr'); callL('skip_ws');
cmpByteRsiImm(')'); jne('fail');
incRsi(); ret();
// stringa letterale: oggetto heap [tipo=1][len][byte...], valore ptr|3
// simbolo :nome -> oggetto stringa (tipo 1) con il nome, stampa senza ':'
L('pf_symbol');
incRsi();
pushRsi();
L('sym_scan');
cmpByteRsiImm('_'); je('sym_adv');
cmpByteRsiImm('a'); jb('sym_digit');
cmpByteRsiImm('z'); jbe('sym_adv');
cmpByteRsiImm('A'); jb('sym_digit');
cmpByteRsiImm('Z'); jbe('sym_adv');
jmp('sym_end');
L('sym_digit');
cmpByteRsiImm('0'); jb('sym_end');
cmpByteRsiImm('9'); ja('sym_end');
L('sym_adv');
incRsi(); jmp('sym_scan');
L('sym_end');
movRcxRsi(); popR8(); subRcxR8();
pushRsi();
leaRdxR14(0x30000); movRaxMemRdx();
leaRdiR14(0x30008); addRdiRax();
movMemRdiImm32(0, 1); movMemRdiRcx8();
leaR10Rcx31(); andR10ImmNeg16(); addRaxR10(); movMemRdxRax();
leaR9Rdi16();
L('sym_copy');
testRcx(); jz('sym_done');
movDlMemR8(); movMemR9Dl(); incR8(); incR9(); decRcx(); jmp('sym_copy');
L('sym_done');
movRaxRdi(); orRaxImm3(); popRsi(); ret();

L('pf_string');
incRsi();
pushRsi();
L('ps_scan');
cmpByteRsiImm(0); je('fail');
cmpByteRsiImm('"'); je('ps_found');
incRsi(); jmp('ps_scan');
L('ps_found');
movRcxRsi(); popR8(); subRcxR8(); incRsi(); pushRsi();
leaRdxR14(0x30000); movRaxMemRdx();
leaRdiR14(0x30008); addRdiRax();
movMemRdiImm32(0, 1);
movMemRdiRcx8();
leaR10Rcx31(); andR10ImmNeg16(); addRaxR10(); movMemRdxRax();
leaR9Rdi16();
L('ps_copy');
testRcx(); jz('ps_done');
movAlMemR8(); movMemR9Al(); incR8(); incR9(); decRcx(); jmp('ps_copy');
L('ps_done');
movRaxRdi(); orRaxImm3(); popRsi(); ret();
L('pf_ident');
callL('parse_ident');
callL('skip_ws');
cmpByteRsiImm('-'); jne('pf_no_lambda');
cmpByteRsiDispImm(1, '>'); jne('pf_no_lambda');
jmp('pf_lambda');
L('pf_no_lambda');
// letterali Bool
cmpR9Imm(4); jne('pf_false_check');
movEaxMemR8(); cmpEaxImm32(0x65757274); jne('pf_not_bool');
movEaxImm(5); ret();
L('pf_false_check');
cmpR9Imm(5); jne('pf_not_bool');
movEaxMemR8(); cmpEaxImm32(0x736c6166); jne('pf_not_bool');
cmpByteR8DispImm(4, 'e'); jne('pf_not_bool');
movEaxImm(1); ret();
L('pf_not_bool');
cmpR9Imm(7); jne('pf_not_nothing');
movEaxMemR8(); cmpEaxImm32(0x68746f6e); jne('pf_not_nothing');
cmpByteR8DispImm(4, 'i'); jne('pf_not_nothing');
cmpByteR8DispImm(5, 'n'); jne('pf_not_nothing');
cmpByteR8DispImm(6, 'g'); jne('pf_not_nothing');
leaRaxR14(0xF020); movMemRaxImm32(4); orRaxImm3(); ret();
L('pf_not_nothing');
callL('skip_ws');
cmpByteRsiImm('('); je('pf_call');
callL('env_lookup');
ret();

// lambda a un parametro: x -> expr (chiusura con ambiente dinamico)
L('pf_lambda');
addRsiImm(2);
callL('skip_ws');
leaRdxR14(0x30000); movRaxMemRdx();      // bump
leaRdiR14(0x30008); addRdiRax();         // record
movMemRdiR8(); movMemRdiR9_8();          // nome parametro
movMemRdiImm32(0x10, 1);                 // param count
movMemRdiRsi24();                        // body
movMemRdiR8_32(); movMemRdiR9_40();      // parametro
addRaxImm128(); movMemRdxRax();          // bump aggiornato
movMemRdiImm32(0x60, 0);
flagLoad(); testRax(); jz('pf_lambda_nocap');
testRbx(); jz('pf_lambda_nocap');
movRcxRbx(); decRcx(); leaRdxRcx3(); shlRdx3H(); addRdxR15();
movRaxMemRdx(); movMemRdiRaxDisp(0x68);
movRaxMemRdx8(); movMemRdiRaxDisp(0x70);
movRaxMemRdx16(); movMemRdiRaxDisp(0x78);
movMemRdiImm32(0x60, 1);
L('pf_lambda_nocap');
movRaxRdi(); orRaxImm2(); pushRax();
callL('skip_text');
popRax(); ret();

// skip_text: salta un'espressione fino a un delimitatore a profondità 0
L('skip_text');
xorEdi();
L('skt_loop');
cmpByteRsiImm(0); je('skt_done');
cmpByteRsiImm('#'); je('skt_comment');
cmpByteRsiImm('('); je('skt_open');
cmpByteRsiImm('['); je('skt_open');
cmpByteRsiImm('{'); je('skt_open');
cmpByteRsiImm(')'); je('skt_close');
cmpByteRsiImm(']'); je('skt_close');
cmpByteRsiImm('}'); je('skt_close');
testRdi(); jnz('skt_adv');
cmpByteRsiImm(','); je('skt_done');
cmpByteRsiImm(';'); je('skt_done');
cmpByteRsiImm(0x0a); je('skt_done');
L('skt_adv'); incRsi(); jmp('skt_loop');
L('skt_open'); incRdi(); incRsi(); jmp('skt_loop');
L('skt_close'); testRdi(); jz('skt_done'); decRdi(); incRsi(); jmp('skt_loop');
L('skt_comment');
incRsi();
cmpByteRsiImm(0); je('skt_done');
cmpByteRsiImm(0x0a); jne('skt_comment');
jmp('skt_loop');
L('skt_done'); ret();

L('pf_builtin_length');
incRsi(); callL('skip_ws'); callL('parse_expr'); callL('skip_ws');
cmpByteRsiImm(')'); jne('fail'); incRsi();
movRdxRax(); andRdxImm3(); cmpEdxImm3(); jne('fail');
andRaxImmFc(); movRcxMemRax8(); movRaxRcx(); shlRax1(); ret();

L('pf_builtin_string');
incRsi(); callL('skip_ws'); callL('parse_expr'); callL('skip_ws');
cmpByteRsiImm(')'); jne('fail'); incRsi();
movRdxRax(); andRdxImm3(); cmpEdxImm3(); je('pbs_str');  // stringa: identity
testAlImm(0); jz('pbs_int');  // Int conversion
jmp('fail');  // Bool/Symbol/Nothing non supportati per ora

L('pf_builtin_get');
incRsi(); callL('skip_ws'); callL('parse_expr'); callL('skip_ws'); pushRax();
cmpByteRsiImm(','); jne('fail'); incRsi(); callL('skip_ws'); callL('parse_expr'); callL('skip_ws');
cmpByteRsiImm(')'); jne('fail'); incRsi();
movR8Rax(); popRax();
movRdxRax(); andRdxImm3(); cmpEdxImm3(); jne('fail');
andRaxImmFc(); movRdxMemRax(); B(0x48,0x83,0xfa,0x02); jne('fail');
B(0x49, 0x89, 0xc2); movRcxMemRax8();
movRaxR8(); testAlImm(3); jne('fail');
sarRax1(); testRax(); js('fail');
B(0x48, 0x39, 0xc8); jae('fail');
B(0x49, 0x8b, 0x44, 0xc2, 0x10);
ret();

L('pf_builtin_push');
incRsi(); callL('skip_ws'); callL('parse_expr'); callL('skip_ws'); pushRax();
cmpByteRsiImm(','); jne('fail'); incRsi(); callL('skip_ws'); callL('parse_expr'); callL('skip_ws');
cmpByteRsiImm(')'); jne('fail'); incRsi();
popRcx(); popRax();
andRaxImmFc(); B(0x48,0x83,0xfa,0x02); jne('fail');
B(0x48,0x8b,0x10); B(0x48,0x83,0xfa,0x02); jne('fail');
B(0x48, 0x8b, 0x40, 0x08);
B(0x48, 0x83, 0xf9, 64); jae('fail');
sarRcx1(); B(0x49, 0x89, 0x44, 0xc2, 0x10);
B(0x48, 0x8b, 0x40, 0x08);
B(0x48, 0x83, 0xc0, 0x01);
B(0x48, 0x89, 0x40, 0x08);
ret();

L('pbs_str');
ret();

L('pbs_int');
// Int in decimale: usa buffer stack, poi alloca heap
pushRbp(); movRbpRsp(); subRsp(0x20);
sarRax1(); B(0x48, 0x8d, 0x7d, 0xf0); B(0x45, 0x31, 0xc0); testRax(); jns('pbs_pos');
negRax(); movR8d(1);
L('pbs_pos');
movEcx(10); B(0x4c, 0x8d, 0x55, 0xf8);
L('pbs_loop');
xorEdx(); divRcx(); addDlImm(0x30); decR10(); B(0x41, 0x88, 0x12); testRax(); jnz('pbs_loop');  // mov [r10], dl (store della cifra)
testR8d(); je('pbs_neg'); decR10(); B(0x41, 0xc6, 0x02, 0x2d);
L('pbs_neg');
B(0x48, 0x8d, 0x7d, 0xf8); B(0x4c, 0x29, 0xd7); B(0x48, 0x89, 0xf9);  // rdi=rbp-8; sub rdi,r10; mov rcx,rdi (len)
leaRdxR14(0x30000); movRaxMemRdx(); leaRdiR14(0x30008); addRdiRax();
movMemRdiImm32(0, 1); movMemRdiRcx8(); leaR10Rcx31(); andR10ImmNeg16(); addRaxR10(); movMemRdxRax();
leaR9Rdi16(); B(0x4c, 0x8d, 0x55, 0xf8); B(0x49, 0x29, 0xca);  // r10 = (rbp-8)-len = inizio cifre
L('pbs_copy');
testRcx(); jz('pbs_done'); movDlMemR10(); movMemR9Dl(); incR10(); incR9(); decRcx(); jmp('pbs_copy');
L('pbs_done');
movRaxRdi(); orRaxImm3(); movRspRbp(); popRbp(); ret();

L('pf_call');
cmpR9Imm(3); jne('pfc_len');
cmpByteR8DispImm(0, 'g'); jne('pfc_norm');
cmpByteR8DispImm(1, 'e'); jne('pfc_norm');
cmpByteR8DispImm(2, 't'); jne('pfc_norm');
jmp('pf_builtin_get');
L('pfc_len');
cmpR9Imm(6); jne('pfc_norm');
movEaxMemR8(); cmpEaxImm32(0x676e656c); jne('pfc_str');
cmpByteR8DispImm(4, 't'); jne('pfc_str');
cmpByteR8DispImm(5, 'h'); jne('pfc_str');
jmp('pf_builtin_length');
L('pfc_str');
movEaxMemR8(); cmpEaxImm32(0x69727473); jne('pfc_norm');
cmpByteR8DispImm(4, 'n'); jne('pfc_norm');
cmpByteR8DispImm(5, 'g'); jne('pfc_norm');
jmp('pf_builtin_string');
L('pfc_norm');
callL('fn_find');
testRdx(); jnz('pf_call_entry');
callL('env_lookup');                     // variabile che contiene una chiusura
testAlImm(2); jz('fail');
testAlImm(1); jnz('fail');
andRaxImmFc();
movRdxRax();
L('pf_call_entry');
pushRbx(); pushRbp(); subRsp8(8); pushRdx();
incRsi(); callL('skip_ws');
xorEbp();
cmpByteRsiImm(')'); je('pf_call_zero');
L('pf_call_arg');
callL('parse_expr');
pushRax(); incRbp();
callL('skip_ws');
cmpByteRsiImm(','); je('pf_call_comma');
cmpByteRsiImm(')'); je('pf_call_args');
jmp('fail');
L('pf_call_comma');
incRsi(); callL('skip_ws'); jmp('pf_call_arg');
L('pf_call_zero');
incRsi(); jmp('pf_call_ready');
L('pf_call_args');
incRsi();
L('pf_call_ready');
movMemRspRbp8Rsi();
movRdiMemRspRbp();

movRcxMemRdi16(); andRcxImmFF(); cmpRcxRbp(); jne('fail');
xorR8dBits(); movR9ImmMinus1(); xorEax(); callL('env_store');
movRcxMemRdiDisp(0x60); testRcx; jz('pf_call_nocap');
movR8MemRdiDisp(0x68); movR9MemRdiDisp(0x70); movRaxMemRdiDisp(0x78);
callL('env_store');
L('pf_call_nocap');
testRbp(); jz('pf_call_bind_done');
movRsiRbp(); decRsi(); shlRsi4();
L('pf_call_bind');
popRax();
movRdxRdi(); addRdxRsi(); addRdxImm(32);
movR8MemRdx(); movR9MemRdx8();
callL('env_store');
subRsiImm16(); decRbp(); testRbp(); jnz('pf_call_bind');
L('pf_call_bind_done');
addRspImm8();
movRcxMemRdi16(); testRcxImm32(0x100); jnz('pf_call_block');
flagLoad(); pushRax();
flagStoreImm(1);
movRsiMemRdi24();
callL('parse_expr');
movR11Rax();
movRaxMemRsp(); flagStoreRax();
addRspImm8();
movRaxR11();
jmp('pf_call_tail');
L('pf_call_block');
maskLoad(); pushRax(); maskStoreImm(1);
flagLoad(); pushRax(); flagStoreImm(1);
movRsiMemRdi24();
callL('parse_program');
movRaxMemRsp(); flagStoreRax(); addRspImm8();
movRaxMemRsp(); maskStoreRax(); addRspImm8();
blockLoad();
L('pf_call_tail');
movRsiMemRsp();
addRspImm8();
popRbp(); popRbx();
ret();

// fn_find: r8=ptr nome, r9=len -> rdx = entry funzione oppure 0
L('fn_find');
movRcxMemR13();
movRdiRcx();
L('ff_loop');
testRdi(); jz('ff_none');
decRdi();
movRdxRdi(); shlRdx7(); leaRdxR13Rdx8();
movRcxMemRdx8(); cmpRcxR9(); jne('ff_loop');
movR10R8(); movR11MemRdx(); movRcxR9();
L('ff_cmp');
testRcx(); jz('ff_found');
movAlMemR10(); cmpAlMemR11(); jne('ff_loop');
incR10(); incR11(); decRcx(); jmp('ff_cmp');
L('ff_found'); ret();
L('ff_none'); xorEdx(); ret();

// ---------------------------------------------------------------- ambiente (variabili)
L('parse_ident');
movR8Rsi();
xorEcxEcx();
movzxEaxRsi();
cmpAlImm('_'); je('ident_ok');
orAlImm(0x20);
cmpAlImm('a'); jb('fail');
cmpAlImm('z'); ja('fail');
L('ident_ok');
L('ident_loop');
movzxEaxRsi();
cmpAlImm('_'); je('ident_inc');
cmpAlImm('0'); jb('ident_alpha');
cmpAlImm('9'); jbe('ident_inc');
L('ident_alpha');
orAlImm(0x20);
cmpAlImm('a'); jb('ident_done');
cmpAlImm('z'); ja('ident_done');
L('ident_inc');
incRsi(); incRcx(); jmp('ident_loop');
L('ident_done');
movR9Rcx();
ret();

// env_find: r8=ptr nome, r9=len -> rdx = entry oppure 0 (cerca dalla più recente)
L('env_find');
movRdiRbx();
L('ef_loop');
testRdi(); jz('ef_none');
decRdi();
leaRdxRdi3(); shlRdx3(); addRdxR15();
movRcxMemRdx8(); cmpRcxR9(); jne('ef_next');
movR10R8(); movR11MemRdx(); movRcxR9();
L('ef_cmp');
testRcx(); jz('ef_found');
movAlMemR10(); cmpAlMemR11(); jne('ef_next');
incR10(); incR11(); decRcx(); jmp('ef_cmp');
L('ef_next');
jmp('ef_loop');
L('ef_found'); ret();
L('ef_none'); xorEdx(); ret();

L('env_lookup');
callL('env_find');
testRdx(); jz('fail');
movRaxMemRdx16();
ret();

L('env_store');
leaRdxRbx3(); shlRdx3(); addRdxR15();
movMemRdxR8(); movMemRdx8R9(); movMemRdxRax16();
incRbx();
ret();

// env_assign: aggiorna la variabile più recente se esiste, altrimenti la crea
L('env_assign');
pushRax();
movRdiRbx();
L('ea_loop');
testRdi(); jz('ea_append');
decRdi();
leaRdxRdi3(); shlRdx3(); addRdxR15();
movRcxMemRdx8();
cmpRcxImmMinus1(); je('ea_append');
cmpRcxR9(); jne('ea_next');
movR10R8(); movR11MemRdx(); movRcxR9();
L('ea_cmp');
testRcx(); jz('ea_found');
movAlMemR10(); cmpAlMemR11(); jne('ea_next');
incR10(); incR11(); decRcx(); jmp('ea_cmp');
L('ea_next'); jmp('ea_loop');
L('ea_found'); popRax(); movMemRdxRax16(); ret();
L('ea_append'); popRax(); callL('env_store'); ret();

// print_int: stampa rax in decimale + newline, poi torna
L('print_int');
pushRbp(); movRbpRsp(); andRspM16(); subRsp(0x70);
movRdxRax(); andRdxImm3(); cmpEdxImm3(); je('pi_object');
// Bool: false=1, true=5; Int = n<<2; chiusura = ptr|2
testAlImm(1); jz('pi_int');
cmpRaxImm32(5); je('pi_true');
movByteRspImm(0x30, 'f'); movByteRspImm(0x31, 'a'); movByteRspImm(0x32, 'l');
movByteRspImm(0x33, 's'); movByteRspImm(0x34, 'e'); movByteRspImm(0x35, 10);
movR8d(6); jmp('pi_bool_write');
L('pi_true');
movByteRspImm(0x30, 't'); movByteRspImm(0x31, 'r'); movByteRspImm(0x32, 'u');
movByteRspImm(0x33, 'e'); movByteRspImm(0x34, 10);
movR8d(5);
L('pi_bool_write');
movRcxR12(); leaRsp('rdx', 0x30); leaRspR9(0x28); movMemRspImm(0x20, 0);
callIat(4, IAT);
movRspRbp(); popRbp(); ret();
L('pi_int');
testAlImm(2); jnz('pi_fun');
sarRax1();
leaRsp('rdi', 0x50);
movByteRdiM1Imm(10);                   // newline in fondo
decRdi();                              // rdi -> newline; cifre in [rdi-1]...
xorR8dBits();
testRax(); jns('pi_abs');
negRax(); movR8d(1);
L('pi_abs');
movEcx(10);
L('pi_loop');
xorEdx(); divRcx();
addDlImm(0x30);
decRdi(); movPtrRdiDl();
testRax(); jnz('pi_loop');
testR8d(); je('pi_sign_done');
decRdi(); movByteRdiImm(0x2d);          // '-'
L('pi_sign_done');
leaRsp('r8', 0x50); movR9R8(); subR9Rdi();
leaRdxR14(0xF028); movRaxMemRdx(); testRax(); jz('pi_int_write');
B(0x49, 0xff, 0xc9);
L('pi_int_write');
movRcxR12(); movRdxRdi(); movR8dR9d();
movMemRspImm(0x20, 0);
leaRspR9(0x28);
callIat(4, IAT);                        // WriteFile
movRspRbp(); popRbp(); ret();
L('pi_fun');
movByteRspImm(0x30, 'f'); movByteRspImm(0x31, 'u'); movByteRspImm(0x32, 'n');
movByteRspImm(0x33, 10);
movR8d(4); jmp('pi_bool_write');
L('pi_object');
andRaxImmFc();
B(0x48,0x8b,0x10); B(0x48,0x83,0xfa,0x04); je('pi_nothing');
B(0x48,0x83,0xfa,0x02); je('pi_list');
B(0x48,0x83,0xfa,0x01); jne('fail');
movR8MemRax8(); leaRdxRax16();
movRcxR12(); leaRspR9(0x28); movMemRspImm(0x20, 0); callIat(4, IAT);
movByteRspImm(0x30,10); movRcxR12(); leaRsp('rdx',0x30); movR8d(1); leaRspR9(0x28); movMemRspImm(0x20,0); callIat(4, IAT);
movRspRbp(); popRbp(); ret();
L('pi_list');
B(0x48, 0x89, 0x45, 0xf8);                // header pointer
movRcxMemRax8(); B(0x48, 0x89, 0x4d, 0xf0); // list length
B(0x48, 0xc7, 0x45, 0xe8, 0, 0, 0, 0);   // index = 0
movByteRspImm(0x30, '[');
movRcxR12(); leaRsp('rdx', 0x30); movR8d(1); leaRspR9(0x28);
movMemRspImm(0x20, 0); callIat(4, IAT);
L('pi_list_loop');
B(0x48, 0x8b, 0x4d, 0xe8); B(0x48, 0x3b, 0x4d, 0xf0); jae('pi_list_done');
testRcx(); je('pi_list_item');
movByteRspImm(0x30, ','); movByteRspImm(0x31, ' ');
movRcxR12(); leaRsp('rdx', 0x30); movR8d(2); leaRspR9(0x28);
movMemRspImm(0x20, 0); callIat(4, IAT);
L('pi_list_item');
B(0x48, 0x8b, 0x55, 0xf8); B(0x48, 0x8b, 0x4d, 0xe8);
B(0x48, 0x8b, 0x44, 0xca, 0x10);          // valore all'indice corrente
testAlImm(3); jne('fail');                 // elementi interi nel seed
leaRdxR14(0xF028); movMemRdxImm32(0, 1);
callL('print_int');
leaRdxR14(0xF028); movMemRdxImm32(0, 0);
B(0x48, 0xff, 0x45, 0xe8); jmp('pi_list_loop');
L('pi_list_done');
movByteRspImm(0x30, ']'); movByteRspImm(0x31, 10);
movRcxR12(); leaRsp('rdx', 0x30); movR8d(2); leaRspR9(0x28);
movMemRspImm(0x20, 0); callIat(4, IAT);
movRspRbp(); popRbp(); ret();
L('pi_nothing');
movByteRspImm(0x30,'n'); movByteRspImm(0x31,'o'); movByteRspImm(0x32,'t'); movByteRspImm(0x33,'h');
movByteRspImm(0x34,'i'); movByteRspImm(0x35,'n'); movByteRspImm(0x36,'g'); movByteRspImm(0x37,10);
movR8d(8); jmp('pi_bool_write');

// helper: xor r8d,r8d (non definito sopra)
function xorR8dBits() { B(0x45, 0x31, 0xc0); }

// ---------------------------------------------------------------- exit labels
L('fail');      andRspM16(); movEcx(1); callIat(6, IAT);
L('read_fail'); andRspM16(); movEcx(1); callIat(6, IAT);
L('open_fail'); andRspM16(); movEcx(1); callIat(6, IAT);
L('usage');     andRspM16(); movEcx(2); callIat(6, IAT);
L('no_arg');    jmp('usage');

// risolvi patch
for (const p of patches) {
  const v = p.kind === 'abs' ? p.value : labels[p.label] - (p.at + 4);
  const buf = Buffer.alloc(4); buf.writeInt32LE(v);
  for (let i = 0; i < 4; i++) code[p.at + i] = buf[i];
}
if (code.length > IAT - 0x1000) throw new Error('codice troppo grande: ' + code.length);
console.log('labels', JSON.stringify(labels));
console.log('code bytes:', code.length);

// ---------------------------------------------------------------- PE builder
const img = Buffer.alloc(FILESZ);
const u16 = (o, v) => img.writeUInt16LE(v & 0xffff, o);
const u32 = (o, v) => img.writeUInt32LE(v >>> 0, o);
const u64 = (o, v) => img.writeBigUInt64LE(BigInt(v), o);
const str = (o, s) => img.write(s, o, 'ascii');

u16(0x00, 0x5a4d); u32(0x3c, 0x40);
str(0x40, 'PE\0\0');
u16(0x44, 0x8664); u16(0x46, 1); u16(0x54, 0xf0); u16(0x56, 0x22);
u16(0x58, 0x20b);
u32(0x5c, SEC_RAW);
u32(0x68, 0x1000);
u32(0x6c, 0x1000);
u64(0x70, 0x140000000);
u32(0x78, 0x1000); u32(0x7c, 0x200);
u16(0x80, 6); u16(0x88, 6);
u32(0x90, 0x7000);
u32(0x94, 0x200);
u16(0x9c, 3);
u64(0xa0, 0x100000); u64(0xa8, 0x1000);
u64(0xb0, 0x100000); u64(0xb8, 0x1000);
u32(0xc4, 16);
u32(0xd0, 0x40a0); u32(0xd4, 0x28);
str(0x148, '.text');
u32(0x150, SEC_RAW); u32(0x154, 0x1000); u32(0x158, SEC_RAW); u32(0x15c, HEADERS);  // VirtualSize=RawSize=SEC_RAW
u32(0x16c, 0xe0000020);
img.set(Buffer.from(code), HEADERS);

const fo = rva => HEADERS + (rva - 0x1000);
const ilt = 0x4050, desc = 0x40a0, dll = 0x40d0;
const entries = ['GetStdHandle', 'GetCommandLineA', 'CreateFileA', 'ReadFile', 'WriteFile', 'CloseHandle', 'ExitProcess', 'VirtualAlloc'];
const hints = [];
let rva = 0x5000;
for (const n of entries) { hints.push(rva); rva += 2 + n.length + 1; if (rva & 1) rva++; }
for (let i = 0; i < entries.length; i++) { u64(fo(IAT + i * 8), hints[i]); u64(fo(ilt + i * 8), hints[i]); }
u32(fo(desc), ilt); u32(fo(desc + 12), dll); u32(fo(desc + 16), IAT);
str(fo(dll), 'KERNEL32.dll\0');
for (let i = 0; i < entries.length; i++) {
  const o = fo(hints[i]); img.writeUInt16LE(0, o); img.write(entries[i] + '\0', o + 2, 'ascii');
}
let out = '';
for (let o = 0; o < img.length; o += 32) {
  let line = '';
  for (let j = 0; j < 32; j++) line += img[o + j].toString(16).padStart(2, '0');
  out += line + '\n';
}
fs.writeFileSync(outHex, out, 'ascii');
console.log('file bytes:', img.length, '->', outHex);
