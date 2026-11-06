// Backend PE del generatore del seed (decisione 02, ticket 02): formato
// dell'eseguibile (PE x86-64), costanti di sistema Windows e emissioni os_*
// inline — KERNEL32 vive solo qui. Forma (c) «piazzamenti ordinati» (contratto
// .scratch/seed-linux-nativo/issues/03-contratto-os-star.md): gli slot del
// corpo si mappano sui registri di chiamata di Windows nell'ordine della lista,
// byte-identico al PE versionato per costruzione (decisione 01).
// Uso: via entry unico seed/dev/gen_seed.js <windows|linux|all> [out.hex].
// @ts-nocheck
'use strict';
const core = require('./core.js');
const {
  code, patches, B, B32, L, je, jne, jmp,
  movEcx, movEdx, movR8d, movR8dR9d, movR8MemRax8, movR13dMemRsp,
  xorEcx, xorR9d, movR12Rax, movRsiRax, movRbxRax, movRcxRbx, movRcxR12,
  movRdxRdi, movRdxR14, movR9dImm, leaRsp, leaRspR9, leaRdxRax16,
  movMemRspImm, movzxEdxRsi, testDl, testEax, testRax, cmpRaxM1,
  cmpByteRsiImm, movByteRdiImm, incRsi, incRdi,
} = core;

// ---------------------------------------------------------------- backend PE: layout + fixup
const IAT = 0x4000;
const SEC_RAW = 0x6000;                 // .text 24576 byte, RVA 0x1000..0x7000
const HEADERS = 0x200, FILESZ = HEADERS + SEC_RAW;
function callIat(idx) {
  B(0xff, 0x15); const at = code.length; B(0, 0, 0, 0);
  patches.push({ at, kind: 'abs', value: (IAT + idx * 8) - (0x1000 + at + 4) });
}

// ---------------------------------------------------------------- backend PE: os_*
// Confine completo col sistema operativo (decisione 02): KERNEL32 e costanti di
// sistema Windows vivono solo qui, in emissione inline (mai sottoroutine).
const STD_OUTPUT_HANDLE = 0xfffffff5;
const GENERIC_READ = 0x80000000;
const FILE_SHARE_READ = 1;
const OPEN_EXISTING = 3;
const FILE_ATTRIBUTE_NORMAL = 0x80;
const MEM_COMMIT_RESERVE = 0x3000;
const PAGE_READWRITE = 4;
// scratch PE di ReadFile/WriteFile (lpNumberOfBytesWritten, lpOverlapped)
const PE_WRITTEN_WRITE = 0x28, PE_WRITTEN_READ = 0x40, PE_OVERLAPPED = 0x20;

// dispatch: materializza gli slot nell'ordine della lista, poi la chiamata.
// os_arg e os_alloc hanno emissione indivisibile (le costanti PE si
// intrecciano col piazzamento degli slot): la ricetta storica è tutta dentro.
function peEmit(routine, slots, withCall) {
  if (routine === 'arg') { if (withCall) peArg(slots[0][1]); return; }
  if (routine === 'alloc') { if (withCall) peAlloc(slots[0][1]); return; }
  for (const [slot, arg] of slots) peSlot(routine, slot, arg);
  if (withCall) peCall(routine);
}

// piazzamento di uno slot sui registri di chiamata di Windows
function peSlot(routine, slot, arg) {
  switch (routine + ':' + slot) {
    case 'write:handle': return movRcxR12();       // handle stdout (stato r12)
    case 'write:buf':
      if (arg.kind === 'rsp') return leaRsp('rdx', arg.d);
      if (arg.kind === 'reg' && arg.r === 'rdi') return movRdxRdi();
      if (arg.kind === 'm16') return leaRdxRax16();
      break;
    case 'write:len':
      if (arg.kind === 'imm') return movR8d(arg.v);
      if (arg.kind === 'reg' && arg.r === 'r9d') return movR8dR9d();
      if (arg.kind === 'm8') return movR8MemRax8();
      break;
    case 'write:nwritten': return leaRspR9(PE_WRITTEN_WRITE);
    case 'write:overlapped': return movMemRspImm(PE_OVERLAPPED, 0);
    case 'read:handle': if (arg.kind === 'reg' && arg.r === 'rbx') return movRcxRbx(); break;
    case 'read:buf': if (arg.kind === 'reg' && arg.r === 'r14') return movRdxR14(); break;
    case 'read:max': return movR8d(arg.v);
    case 'read:nwritten': return leaRspR9(PE_WRITTEN_READ);
    case 'read:overlapped': return movMemRspImm(PE_OVERLAPPED, 0);
    case 'open:path': return leaRsp('rcx', arg.d);
    case 'exit:code': return arg.v === 0 ? xorEcx() : movEcx(arg.v);
  }
  throw new Error('slot os_* non mappato: ' + routine + ':' + slot);
}

// chiamata + coda della primitiva (costanti di sistema, esiti, chiusure)
function peCall(routine) {
  switch (routine) {
    case 'write': return callIat(4);               // WriteFile
    case 'exit': return callIat(6);                // ExitProcess
    case 'open':
      movEdx(GENERIC_READ); movR8d(FILE_SHARE_READ); xorR9d();
      movMemRspImm(0x20, OPEN_EXISTING); movMemRspImm(0x28, FILE_ATTRIBUTE_NORMAL);
      movMemRspImm(0x30, 0);
      callIat(2);                                  // CreateFileA
      cmpRaxM1(); je('open_fail');
      movRbxRax();                                 // esito: handle in rbx
      return;
    case 'read':
      callIat(3);                                  // ReadFile
      testEax(); je('read_fail');
      movR13dMemRsp(PE_WRITTEN_READ);              // esito: byte letti in r13
      movRcxRbx(); callIat(5);                     // CloseHandle: os_read chiude
      return;
  }
  throw new Error('chiamata os_* non mappata: ' + routine);
}

// os_arg(buf): copia argv[1] nel buffer; vuoto -> usage (exit 2).
// PE: parsing di GetCommandLineA dentro os_arg (contratto 03), compresa
// l'acquisizione dell'handle stdout in r12 (stato del corpo, Q2) che su ELF
// non serve: è l'unica volta che si tocca lo std handle.
function peArg(buf) {
  movEcx(STD_OUTPUT_HANDLE);
  callIat(0);                                    // GetStdHandle
  movR12Rax();
  callIat(1);                                    // GetCommandLineA
  movRsiRax();

  // salta il nome del programma, estrae il primo argomento nel buffer buf
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
  leaRsp('rdi', buf.d);
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
  // cmp byte [rsp+buf.d],0 : 80 BC 24 disp32 00
  B(0x80, 0xbc, 0x24); B32(buf.d); B(0x00);
  je('usage');
}

// os_alloc(size) -> rax: una sola chiamata, arena bump senza GC (contratto 03
// Q5); esaurimento -> exit 1. Il corpo sposta la base in r14.
function peAlloc(size) {
  xorEcx();                                      // lpAddress = NULL
  movEdx(size.v);
  movR8d(MEM_COMMIT_RESERVE);
  movR9dImm(PAGE_READWRITE);
  callIat(7);                                    // VirtualAlloc
  testRax(); je('fail');
}

// ---------------------------------------------------------------- backend PE: builder dell'eseguibile
function peBuild() {
  if (code.length > IAT - 0x1000) throw new Error('codice troppo grande: ' + code.length);
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
  return { img, hexWidth: 32 };
}

module.exports = {
  name: 'windows',
  // os_* PE: la ctx (diagnostica ELF) è ignorata — byte-identico per costruzione
  emitOs(routine, slots, withCall) { peEmit(routine, slots, withCall); },
  build: peBuild,
};
