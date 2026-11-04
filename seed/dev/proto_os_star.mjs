#!/usr/bin/env node
// =====================================================================
//  PROTOTYPE — GETTABILE. NON fa parte della catena S0->S4. DA NON
//  COMMITTARE IN MAIN (finisce su un branch throwaway a decisione presa).
//
//  Spike del confine `os_*` per il ticket
//  ".scratch/seed-linux-nativo/issues/03-contratto-os-star.md"
//  ("03 — Contratto delle routine os_*").
//
//  Domanda: quale FORMA ha il contratto `os_*` che il corpo condiviso del
//  codegen può usare identico su PE ed ELF senza toccare un byte del PE?
//
//  Assunzione dichiarata: le branche HTML della skill "prototype" (demo di
//  stato / varianti UI) non si applicano a codice macchina x86-64; la forma
//  dello spike è quella prescritta dal ticket stesso — il confine `os_*`
//  dietro call site REALI del PE (verifica byte) + micro-ELF che lo usa
//  nativamente (esecuzione reale su Linux).
//
//  Cosa fa:
//   1. Racchiude i call site WriteFile reali di gen_seed.js in candidate
//      funzioni-generatore `os_*` e misura, sito per sito, se la forma
//      "canonica" riproduce gli identici byte del PE (politica byte-imm.
//      di "01 — Politica dei byte del PE nella rifattorizzazione").
//   2. Costruisce una micro-ELF con le STESSE funzioni `os_*` (braccio
//      Linux nativo: syscalls inline) e la esegue: os_alloc + os_write +
//      os_exit.
//
//  Uso:  node seed/dev/proto_os_star.mjs
// =====================================================================
import { writeFileSync, unlinkSync } from 'node:fs';
import { execFileSync } from 'node:child_process';

// ---------------------------------------------------------------- emettitore x86-64
// Codifiche copiate 1:1 da seed/dev/gen_seed.js (gettabile: duplicazione tollerata).
function mk() {
  const code = [];
  const B = (...xs) => { for (const x of xs) code.push(x & 255); };
  const B32 = v => { v = v >>> 0; for (let i = 0; i < 4; i++) code.push((v >>> (8 * i)) & 255); };
  return { code, B, B32 };
}
const { code: C, B, B32 } = mk();
const cc = c => (typeof c === 'string' ? c.charCodeAt(0) : c);   // come in gen_seed.js
const reset = () => { C.length = 0; };
const hex = () => C.map(b => b.toString(16).padStart(2, '0')).join('');

// helper condivisi (stesse emissioni di gen_seed.js)
const movRcxR12 = () => B(0x4c, 0x89, 0xe1);
const movRdxRdi = () => B(0x48, 0x89, 0xfa);
const movR8dR9d = () => B(0x45, 0x89, 0xc8);
const movR8d = v => { B(0x41, 0xb8); B32(v); };
const movR8MemRax8 = () => B(0x4c, 0x8b, 0x40, 0x08);
const leaRdxRax16 = () => B(0x48, 0x8d, 0x50, 0x10);
const movByteRspImm = (d, v) => { B(0xc6, 0x84, 0x24); B32(d); B(cc(v) & 255); };
const movMemRspImm = (d, v) => { B(0x48, 0xc7, 0x84, 0x24); B32(d); B32(v); };
const leaRspR9 = d => { B(0x4c, 0x8d, 0x8c, 0x24); B32(d); };
function leaRsp(reg, disp) {
  const hi = /^r\d+$/.test(reg) && +reg.slice(1) >= 8;
  const low = hi ? +reg.slice(1) - 8 : { rcx: 1, rdx: 2, rbx: 3, rsi: 6, rdi: 7, r8: 0, r9: 1 }[reg];
  B(hi ? 0x4c : 0x48, 0x8d, 0x84 + low * 8, 0x24); B32(disp);
}
function callIat(idx) { B(0xff, 0x15); B32(0); }   // disp32 = reloc posizionale, omesso
const andRspM16 = () => B(0x48, 0x83, 0xe4, 0xf0);
const movEcx = v => { B(0xb9); B32(v); };

// helper braccio Linux
const movEax = v => { B(0xb8); B32(v); };
const movEdi = v => { B(0xbf); B32(v); };
const movEdx = v => { B(0xba); B32(v); };
const movEsi = v => { B(0xbe); B32(v); };
const syscall = () => B(0x0f, 0x05);
const xorEdiEdi = () => B(0x31, 0xff);
const movR14Rax = () => B(0x49, 0x89, 0xc6);
const movRsiR14 = () => B(0x4c, 0x89, 0xf6);
const movByteR14Imm = (d, v) => { B(0x41, 0xc6, 0x46, d & 255); B(cc(v) & 255); };

// ---------------------------------------------------------------- CONTRATTO os_* (candidato)
// Forma canonica: ogni routine è funzione-generatore che emette INLINE
// (mai call machine-code). Parametri astratti (buf, len, code...) → il
// backend di piattaforma decide operandi e ordine. Stato del corpo (da
// convenzione, ticket 02): r14 = base regione 0x40000; r12 = handle stdout
// (SOLO PE — su ELF è inutilizzato); rbx = handle file; r13 = conteggio.
// Registri volatili che os_* può sporcacciare: rcx,rdx,rsi,rdi,r8,r9,r11.

// os_write(buf, len) — scrive len byte da buf su stdout, nessun check (come oggi)
function os_write(plat, buf, len) {
  if (plat === 'pe') {
    movRcxR12();                 // handle stdout (stato r12)
    place('rdx', buf);
    place('r8d', len);
    leaRspR9(0x28);              // lpNumberOfBytesWritten = &[rsp+0x28]
    movMemRspImm(0x20, 0);       // lpOverlapped = NULL
    callIat(4);                  // WriteFile
  } else {
    movEdi(1);                   // fd = stdout
    place('rsi', buf);
    place('rdx', len);
    movEax(1);                   // sys_write
    syscall();
  }
}
// os_exit(code) — terminale, mai ritorna
function os_exit(plat, code) {
  if (plat === 'pe') { andRspM16(); movEcx(code); callIat(6); }       // ExitProcess
  else { movEdi(code); movEax(60); syscall(); }                        // sys_exit
}
// os_alloc(size) -> rax = base (il corpo la sposta in r14, identico ovunque)
function os_alloc(plat, size) {
  if (plat === 'pe') {
    B(0x31, 0xc9);               // xor ecx,ecx          lpAddress = NULL
    movEdx(size);
    B(0x41, 0xb8); B32(0x3000);  // MEM_COMMIT|MEM_RESERVE
    B(0x41, 0xb9); B32(4);       // PAGE_READWRITE
    callIat(7);                  // VirtualAlloc
  } else {
    xorEdiEdi();                 // addr = NULL
    movEsi(size);
    movEdx(3);                   // PROT_READ|PROT_WRITE
    B(0x41, 0xba); B32(0x22);    // MAP_PRIVATE|MAP_ANONYMOUS
    B(0x49, 0xc7, 0xc0); B32(-1);// fd = -1
    B(0x45, 0x31, 0xc9);         // xor r9d,r9d          offset = 0
    movEax(9);                   // sys_mmap
    syscall();
  }
}
// piazzamento operandi astratto → registro piattaforma
function place(dst, src) {
  if (src.kind === 'imm') {
    if (dst === 'r8d') movR8d(src.v);
    else if (dst === 'rdx') movEdx(src.v);
    else movEsi(src.v);
  } else if (src.kind === 'rsp') {
    leaRsp(dst, src.d);
  } else if (src.kind === 'm16') {
    if (dst !== 'rdx') throw new Error('m16 solo per rdx');
    leaRdxRax16();               // buf = [rax+16] (stringa in pi_object)
  } else if (src.kind === 'reg') {
    const m = {
      'rdx<-rdi': () => movRdxRdi(), 'r8d<-r9d': () => movR8dR9d(),
      'rsi<-r14': () => movRsiR14(),
    }[`${dst}<-${src.r}`];
    if (!m) throw new Error(`place non implementato: ${dst} <- ${src.r}`);
    m();
  } else if (src.kind === 'm8') {
    // mov r8, [rax+8] — il solo caso di len da memoria nei call site reali
    if (dst !== 'r8d') throw new Error('m8 solo per r8d');
    movR8MemRax8();
  }
}

// ---------------------------------------------------------------- 1. verifica byte sui call site reali
// Ogni sito: la sequenza STORICA di gen_seed.js (commento = riga) contro la
// stessa azione passata per il contratto canónico (setup contenuto buffer +
// os_write('pe', ...)). Il disp32 del callIat è omesso in entrambi (reloc
// posizionale, identico per posizione).
const sites = [
  {
    name: 'pi_bool_write (len carico PRIMA del branch)',
    note: 'gen_seed.js ~1530 — movR8d(6/5/4/8) è sopra i jmp: fuori dal blocco',
    legacy: () => {
      movRcxR12(); leaRsp('rdx', 0x30); leaRspR9(0x28); movMemRspImm(0x20, 0); callIat(4);
    },
    formB: () => {
      // il contratto vorrebbe len dentro os_write → byte in più nel blocco
      os_write('pe', { kind: 'rsp', d: 0x30 }, { kind: 'imm', v: 6 });
    },
  },
  {
    name: 'pi_int_write (buf=rdi, len=r9d)',
    note: 'gen_seed.js ~1558 — [rsp+0x20]=0 PRIMA di lea r9',
    legacy: () => {
      movRcxR12(); movRdxRdi(); movR8dR9d(); movMemRspImm(0x20, 0); leaRspR9(0x28); callIat(4);
    },
    formB: () => {
      os_write('pe', { kind: 'reg', r: 'rdi' }, { kind: 'reg', r: 'r9d' });
    },
  },
  {
    name: 'pi_object stringa (len da [rax+8])',
    note: 'gen_seed.js ~1570 — argomenti PRIMA di movRcxR12',
    legacy: () => {
      movR8MemRax8(); leaRdxRax16(); movRcxR12(); leaRspR9(0x28); movMemRspImm(0x20, 0); callIat(4);
    },
    formB: () => {
      os_write('pe', { kind: 'm16' }, { kind: 'm8' });   // buf=[rax+16], len=[rax+8]
    },
  },
  {
    name: "pi_list '['",
    note: 'gen_seed.js ~1579 — forma piena: handle, buf, len, tail',
    legacy: () => {
      movByteRspImm(0x30, '['); movRcxR12(); leaRsp('rdx', 0x30); movR8d(1);
      leaRspR9(0x28); movMemRspImm(0x20, 0); callIat(4);
    },
    formB: () => {
      movByteRspImm(0x30, '[');                                     // setup corpo
      os_write('pe', { kind: 'rsp', d: 0x30 }, { kind: 'imm', v: 1 });
    },
  },
  {
    name: "pi_list ', '",
    note: 'gen_seed.js ~1585',
    legacy: () => {
      movRcxR12(); leaRsp('rdx', 0x30); movR8d(2); leaRspR9(0x28); movMemRspImm(0x20, 0); callIat(4);
    },
    formB: () => {
      os_write('pe', { kind: 'rsp', d: 0x30 }, { kind: 'imm', v: 2 });
    },
  },
  {
    name: 'pi_object newline',
    note: 'gen_seed.js ~1571',
    legacy: () => {
      movByteRspImm(0x30, 10); movRcxR12(); leaRsp('rdx', 0x30); movR8d(1);
      leaRspR9(0x28); movMemRspImm(0x20, 0); callIat(4);
    },
    formB: () => {
      movByteRspImm(0x30, 10);
      os_write('pe', { kind: 'rsp', d: 0x30 }, { kind: 'imm', v: 1 });
    },
  },
  {
    name: "pi_list ']\\n'",
    note: 'gen_seed.js ~1597',
    legacy: () => {
      movByteRspImm(0x30, ']'); movByteRspImm(0x31, 10); movRcxR12(); leaRsp('rdx', 0x30);
      movR8d(2); leaRspR9(0x28); movMemRspImm(0x20, 0); callIat(4);
    },
    formB: () => {
      movByteRspImm(0x30, ']'); movByteRspImm(0x31, 10);
      os_write('pe', { kind: 'rsp', d: 0x30 }, { kind: 'imm', v: 2 });
    },
  },
];

console.log('=== 1. Contratto os_write: forma canónica vs byte storici del PE ===\n');
let exact = 0;
for (const s of sites) {
  reset(); s.legacy(); const a = hex();
  reset(); s.formB(); const b = hex();
  const ok = a === b;
  if (ok) exact++;
  console.log(`${ok ? 'BYTE-IDENTICO ' : 'DIVERGE      '} ${s.name}`);
  console.log(`               ${s.note}`);
  if (!ok) {
    // primo offset divergente + dimensione diff
    let i = 0; while (i < Math.min(a.length, b.length) && a[i] === b[i]) i++;
    console.log(`               legacy: ${a}`);
    console.log(`               formB : ${b}`);
    console.log(`               primo byte divergente: nibble ${i} (byte ${i >> 1})`);
  }
  console.log('');
}
console.log(`Esito: ${exact}/${sites.length} call site byte-identici con la forma canónica.\n`);

// ---------------------------------------------------------------- 2. micro-ELF nativa (braccio Linux)
// Stesse funzioni os_*: os_alloc(0x40000) -> r14, scrive "OK\n" nel buffer,
// os_write, os_exit(7). Il corpo è quello condiviso (ticket 02): sposta la
// base in r14 e basta; tutto il resto vive nelle primitive.
reset();
os_alloc('elf', 0x40000);
movR14Rax();                       // corpo: base regione -> r14 (identico su PE)
movByteR14Imm(0, 'O'); movByteR14Imm(1, 'K'); movByteR14Imm(2, 10);
os_write('elf', { kind: 'reg', r: 'r14' }, { kind: 'imm', v: 3 });
os_exit('elf', 7);
const codeBuf = Buffer.from(C);

// framing ELF64 minimo (identico a gen_seed_linux.js E0: ET_EXEC, 1 PT_LOAD R|X)
const BASE = 0x400000, EHDR = 64, PHDR = 56, CODE_OFF = EHDR + PHDR;
const fileSize = CODE_OFF + codeBuf.length;
const img = Buffer.alloc(fileSize);
img[0] = 0x7f; img[1] = 0x45; img[2] = 0x4c; img[3] = 0x46;
img[4] = 2; img[5] = 1; img[6] = 1; img[7] = 0;
img.writeUInt16LE(2, 0x10); img.writeUInt16LE(62, 0x12); img.writeUInt32LE(1, 0x14);
img.writeBigUInt64LE(BigInt(BASE + CODE_OFF), 0x18);
img.writeBigUInt64LE(BigInt(EHDR), 0x20); img.writeBigUInt64LE(0n, 0x28);
img.writeUInt32LE(0, 0x30); img.writeUInt16LE(EHDR, 0x34); img.writeUInt16LE(PHDR, 0x36);
img.writeUInt16LE(1, 0x38); img.writeUInt16LE(0, 0x3a); img.writeUInt16LE(0, 0x3c); img.writeUInt16LE(0, 0x3e);
img.writeUInt32LE(1, EHDR); img.writeUInt32LE(5, EHDR + 4);
img.writeBigUInt64LE(0n, EHDR + 8); img.writeBigUInt64LE(BigInt(BASE), EHDR + 16);
img.writeBigUInt64LE(BigInt(BASE), EHDR + 24);
img.writeBigUInt64LE(BigInt(fileSize), EHDR + 32); img.writeBigUInt64LE(BigInt(fileSize), EHDR + 40);
img.writeBigUInt64LE(0x1000n, EHDR + 48);
codeBuf.copy(img, CODE_OFF);

const elfPath = '/tmp/PROTO-os-star.elf';   // PROTOTYPE, wipe me
console.log('=== 2. Micro-ELF nativa: stesse os_* su syscalls Linux ===\n');
console.log('codice (os_alloc -> r14; [r14]="OK\\n"; os_write; os_exit(7)):');
console.log('  ' + codeBuf.toString('hex').replace(/(.{32})/g, '$1\n  ').trimEnd());
writeFileSync(elfPath, img, { mode: 0o755 });
let stdout = '', code1 = null, err = '';
try {
  stdout = execFileSync(elfPath, { encoding: 'utf8' });
} catch (e) {
  stdout = e.stdout ?? ''; code1 = e.status; err = String(e.stderr ?? '');
}
if (code1 === null) code1 = 0;
console.log(`\nesecuzione: ${elfPath}`);
console.log(`  stdout   : ${JSON.stringify(stdout)}`);
console.log(`  exit code: ${code1}`);
console.log(`  verdict  : ${stdout === 'OK\n' && code1 === 7 ? 'PASS — contratto usabile nativamente' : 'FAIL'}`);
if (err) console.log(`  stderr   : ${err}`);
unlinkSync(elfPath);
