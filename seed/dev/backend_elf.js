// Backend ELF del generatore del seed (decisione 02, ticket 02): formato
// dell'eseguibile (ELF64 statico, senza libc ne' dynamic linker), numeri di
// syscall Linux e emissioni os_* inline — il kernel vive solo qui. Forma (c)
// «piazzamenti ordinati» (contratto
// .scratch/seed-linux-nativo/issues/03-contratto-os-star.md): gli slot del
// corpo si mappano sui registri di syscall Linux nell'ordine della lista.
//
// Contratto os_* (issue 03, tabella):
//   os_arg(buf)        copia argv[1] (_start: [rsp+16]) nel buffer; vuoto -> usage
//   os_open(path)      openat(AT_FDCWD, path, O_RDONLY) -> handle in rbx
//   os_read(h, buf, m) loop read + close, totale in r13 (legge tutto e chiude)
//   os_write(buf, len) write(1, buf, len), nessun check (come il PE)
//   os_exit(code)      exit, mai ritorna
//   os_alloc(size)     mmap(NULL, size, RW, PRIVATE|ANON) -> base in rax
//                      (una sola chiamata, arena bump 0x40000 senza GC)
// Errori: exit 1 = fail/read/open, exit 2 = usage — stesse etichette
// condivise del PE. Diagnostica su stderr ammessa solo sull'ELF (contratto
// 03 Q4, PE muto): fuori dal contratto di parita', che copre il solo stdout.
// Clobber: rax/rdi/rsi/rdx/r8/r9/r10 + rcx/r11 (syscall); r13 solo come
// esito di os_read; r14/rbx/r12 (stato del corpo) intatti.
//
// Memory map identica al PE (decisione 02, Q5): solo l'ottenimento della
// base r14 cambia (VirtualAlloc vs mmap).
// Uso: via entry unico seed/dev/gen_seed.js <windows|linux|all> [out.hex].
// @ts-nocheck
'use strict';
const core = require('./core.js');
const {
  code, patches, BODY_FRAME, B, B32, L, je, jne, jnz, js, jz,
  movEaxImm, movEdx, movR8d, movR10dImm, xorEax, xorEdx, xorEdi, xorR9d,
  testDl, testRax, movzxEdxRsi, movPtrRdiDl, incRsi, incRdi,
  leaRsp, leaRsiRax16, movRsiRdi, movRsiR14,
  movRdiRbx, movRbxRax,
} = core;

// ---- helper di istruzione locali al backend (voci nuove dell'emettitore) ----
const movEsi = v => { B(0xbe); B32(v); };                 // mov esi, imm32
const movEdi = v => { B(0xbf); B32(v); };                 // mov edi, imm32
const movRdiM100 = () => { B(0x48, 0xc7, 0xc7); B32((-100) >>> 0); }; // mov rdi,-100
const xorR13d = () => B(0x45, 0x31, 0xed);                // xor r13d, r13d
const testRsi = () => B(0x48, 0x85, 0xf6);                // test rsi, rsi
const movRdxMemRax8 = () => B(0x48, 0x8b, 0x50, 0x08);    // mov rdx, [rax+8]
const movEdxR9d = () => B(0x44, 0x89, 0xca);              // mov edx, r9d
const addR13Rax = () => B(0x49, 0x01, 0xc5);              // add r13, rax
const addRsiRax = () => B(0x48, 0x01, 0xc6);              // add rsi, rax
const subRdxRax = () => B(0x48, 0x29, 0xc2);              // sub rdx, rax
const movR10Rsi = () => B(0x49, 0x89, 0xf2);              // mov r10, rsi
const movRsiR10 = () => B(0x49, 0x8b, 0xf2);              // mov rsi, r10
const syscall = () => B(0x0f, 0x05);
// lea rsi, [rip+label] (fixup d'etichetta, per i messaggi diagnostici)
function leaRsiRip(label) {
  B(0x48, 0x8d, 0x35);
  const at = code.length;
  B(0, 0, 0, 0);
  patches.push({ at, label });
}

// ---- costanti di sistema Linux x86-64 --------------------------------------
const SYS_WRITE = 1, SYS_CLOSE = 3, SYS_OPENAT = 257;
const SYS_MMAP = 9, SYS_EXIT = 60;
const AT_FDCWD = -100;            // openat relativo alla cwd
const PROT_RW = 3;                // PROT_READ | PROT_WRITE
const MAP_PRIVATE_ANON = 0x22;    // MAP_PRIVATE | MAP_ANONYMOUS
const STDERR = 2;

// ---- messaggi diagnostici (solo ELF: il PE e' muto, fuori parita') ----------
// Testi invariati da E1 (N15); 'fail' (esaurimento arena) e' nuovo.
// Nota: 'read_fail' copre sia errore di lettura sia sorgente >= 0xF000
// (etichetta condivisa col corpo, limite noto documentato).
const MSG = {
  usage: 'usage: seed FILE.td\n',
  open_fail: 'seed: cannot open file\n',
  read_fail: 'seed: read error\n',
  fail: 'seed: error\n',
};
const usedMsgs = new Set();

// dispatch: materializza gli slot nell'ordine della lista, poi la chiamata.
// os_arg, os_alloc e os_exit hanno emissione indivisibile (le costanti e la
// diagnostica si intrecciano col piazzamento degli slot): la ricetta e' tutta
// dentro, come peEmit per os_arg/os_alloc sul PE.
// os_write con chiamata e' avvolto dalla salvezza di rsi: il cursore del corpo
// vive in rsi e il PE (Win64) lo preserva per ABI (callee-saved) — il contratto
// 03 Q2 elenca rsi fra i volatili, ma vale per le chiamate iniziali
// (os_arg/os_open/os_read/os_alloc): os_write deve preservarlo o la parita'
// col PE decade (sanatoria in issue 03). Scratch di salvezza: r10 (volatile su
// entrambe le piattaforme, non toccato da syscall).
function elfEmit(routine, slots, withCall, ctx) {
  if (routine === 'arg') { if (withCall) elfArg(slots[0][1]); return; }
  if (routine === 'alloc') { if (withCall) elfAlloc(slots[0][1]); return; }
  if (routine === 'exit') { if (withCall) elfExit(slots, ctx); return; }
  if (routine === 'write' && withCall) {
    movR10Rsi();
    for (const [slot, arg] of slots) elfSlot(routine, slot, arg);
    elfCall(routine);
    movRsiR10();
    return;
  }
  for (const [slot, arg] of slots) elfSlot(routine, slot, arg);
  if (withCall) elfCall(routine);
}

// piazzamento di uno slot sui registri di chiamata di Linux
function elfSlot(routine, slot, arg) {
  switch (routine + ':' + slot) {
    // handle stdout: fd 1, posizionato nella call step DOPO le altre
    // materializzazioni (se fosse un slot a meta', mov edi,1 distruggerebbe
    // rdi prima che 'buf', quando arg e' reg('rdi'), lo copi in rsi)
    case 'write:handle': return;
    case 'write:buf':
      if (arg.kind === 'rsp') return leaRsp('rsi', arg.d);
      if (arg.kind === 'reg' && arg.r === 'rdi') return movRsiRdi();
      if (arg.kind === 'm16') return leaRsiRax16();
      break;
    case 'write:len':
      if (arg.kind === 'imm') return movEdx(arg.v);
      if (arg.kind === 'reg' && arg.r === 'r9d') return movEdxR9d();
      if (arg.kind === 'm8') return movRdxMemRax8();
      break;
    case 'write:nwritten': return;                // nessuno scratch: write non torna n
    case 'write:overlapped': return;              // slot solo PE (lpOverlapped)
    case 'read:handle': if (arg.kind === 'reg' && arg.r === 'rbx') return movRdiRbx(); break;
    case 'read:buf': if (arg.kind === 'reg' && arg.r === 'r14') return movRsiR14(); break;
    case 'read:max': return movEdx(arg.v);
    case 'read:nwritten': return xorR13d();       // esito: totale byte letti in r13
    case 'read:overlapped': return;               // slot solo PE
    case 'open:path': return leaRsp('rsi', arg.d);
    case 'exit:code': return arg.v === 0 ? xorEdi() : movEdi(arg.v);
  }
  throw new Error('slot os_* ELF non mappato: ' + routine + ':' + slot);
}

// chiamata + coda della primitiva (numeri di syscall, esiti, chiusure)
function elfCall(routine) {
  switch (routine) {
    case 'write':                                 // write(1, buf, len), nessun check
      movEdi(1);                                  // fd stdout (slot handle)
      movEaxImm(SYS_WRITE);
      syscall();
      return;
    case 'read':                                  // loop read + close (contratto 03)
      L('elf_read_loop');
      xorEax();                                   // sys_read(handle, buf, max)
      syscall();
      testRax();
      js('read_fail');                            // errore -> exit 1 (come il PE)
      jz('elf_read_done');                        // EOF
      addR13Rax();                                // totale += n
      addRsiRax();                                // buf += n
      subRdxRax();                                // max -= n
      jnz('elf_read_loop');                       // buffer pieno -> chiudi
      L('elf_read_done');
      movEaxImm(SYS_CLOSE);                       // os_read chiude l'handle
      syscall();                                  // rdi = handle ancora impostato
      return;
    case 'open':                                  // openat(AT_FDCWD, path, O_RDONLY)
      movEaxImm(SYS_OPENAT);
      movRdiM100();
      xorEdx();                                   // O_RDONLY
      syscall();
      testRax();
      js('open_fail');
      movRbxRax();                                // esito: handle in rbx
      return;
  }
  throw new Error('chiamata os_* ELF non mappata: ' + routine);
}

// os_arg(buf): copia argv[1] nel buffer; vuoto -> usage (exit 2).
// ELF: copia da [rsp+16] del _start — il corpo ha gia' eseguito
// subRsp(BODY_FRAME), quindi argv[1] e' a [rsp + BODY_FRAME + 16].
// Il PE estrae l'argomento da GetCommandLineA (peArg): stessa semantica
// per gli argomenti non quotati; la gestione delle virgolette e' un
// limite noto del parsing PE, il kernel Linux consegna gia' argv[1].
function elfArg(buf) {
  B(0x48, 0x8b, 0xb4, 0x24); B32(BODY_FRAME + 16); // mov rsi, [rsp+FRAME+16]
  testRsi();
  jz('no_arg');                                    // argc < 2 -> usage
  leaRsp('rdi', buf.d);
  L('elf_arg_copy');
  movzxEdxRsi(); movPtrRdiDl(); incRsi(); incRdi();
  testDl();
  jne('elf_arg_copy');
  // path vuoto -> usage (parita' PE)
  B(0x80, 0xbc, 0x24); B32(buf.d); B(0x00);        // cmp byte [rsp+buf.d], 0
  je('usage');
}

// os_alloc(size) -> rax: una sola chiamata, arena bump senza GC (contratto 03
// Q5); esaurimento -> exit 1. Il corpo sposta la base in r14.
function elfAlloc(size) {
  xorEdi();                                      // addr = NULL
  movEsi(size.v);                                // length
  movEdx(PROT_RW);                               // PROT_READ | PROT_WRITE
  movR10dImm(MAP_PRIVATE_ANON);                  // MAP_PRIVATE | MAP_ANONYMOUS
  movR8d(-1);                                    // fd = -1
  xorR9d();                                      // offset = 0
  movEaxImm(SYS_MMAP);
  syscall();
  testRax();
  js('fail');
}

// os_exit(code): terminale, mai ritorna. Con ctx.diag scrive il messaggio
// diagnostico su stderr prima di uscire (solo ELF, fuori parita'): la
// diagnostica precede il piazzamento di 'exit:code' perche' usa rdi.
function elfExit(slots, ctx) {
  const codeArg = slots.find(s => s[0] === 'code');
  const code = codeArg[1].v;
  if (code !== 0 && ctx && ctx.diag) {
    const msg = MSG[ctx.diag];
    usedMsgs.add(ctx.diag);
    movEaxImm(SYS_WRITE);
    movEdi(STDERR);
    leaRsiRip('elf_msg_' + ctx.diag);
    movEdx(msg.length);
    syscall();
  }
  for (const [slot, arg] of slots) elfSlot('exit', slot, arg);
  movEaxImm(SYS_EXIT);
  syscall();
}

// dati finali del backend: messaggi diagnostici dopo il codice
function elfEmitTrailer() {
  for (const key of usedMsgs) {
    L('elf_msg_' + key);
    for (const ch of Buffer.from(MSG[key], 'ascii')) B(ch);
  }
}

// ---------------------------------------------------------------- builder ELF
// ELF64 statico, un solo PT_LOAD R|X che copre header+codice+messaggi
// (layout di E1, N15): nessuna relocation, entry all'inizio del corpo.
function elfBuild() {
  const BASE = 0x400000;
  const EHDR = 64;
  const PHDR = 56;
  const CODE_OFF = EHDR + PHDR; // 120 = 0x78
  const fileSize = CODE_OFF + code.length;
  const img = Buffer.alloc(fileSize);

  // ---- ELF header ----
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

  // ---- program header (un solo PT_LOAD R|X che copre header+code) ----
  const ph = EHDR;
  img.writeUInt32LE(1, ph + 0);          // PT_LOAD
  img.writeUInt32LE(5, ph + 4);          // R|X
  img.writeBigUInt64LE(0n, ph + 8);      // p_offset
  img.writeBigUInt64LE(BigInt(BASE), ph + 16);
  img.writeBigUInt64LE(BigInt(BASE), ph + 24);
  img.writeBigUInt64LE(BigInt(fileSize), ph + 32);
  img.writeBigUInt64LE(BigInt(fileSize), ph + 40);
  img.writeBigUInt64LE(0x1000n, ph + 48);

  // ---- codice e messaggi ----
  for (let i = 0; i < code.length; i++) img[CODE_OFF + i] = code[i];

  // ---- sanity (come E1) ----
  if (img.readUInt32LE(0) !== 0x464c457f) throw new Error('magic ELF errata');
  if (img.readUInt16LE(0x12) !== 62) throw new Error('e_machine errata');
  if (img.readBigUInt64LE(0x18) !== BigInt(BASE + CODE_OFF)) throw new Error('entry errata');
  return { img, hexWidth: 16 };
}

module.exports = {
  name: 'linux',
  emitOs: elfEmit,
  emitTrailer: elfEmitTrailer,
  reset() { usedMsgs.clear(); },
  build: elfBuild,
};
