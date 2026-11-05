#!/usr/bin/env node
// =====================================================================
//  seed/dev/gen_seed.js — entry unico del generatore del seed
//
//  Generatore di sviluppo del seed S0 x86-64 (PE Windows + ELF Linux).
//  NON fa parte della catena S0->S4: il dump seed.hex e' la fonte
//  committata; questo script serve solo a rigenerarlo/estenderlo.
//
//  Struttura (decisione "Architettura del codegen per due piattaforme",
//  .scratch/seed-linux-nativo/issues/02-architettura-codegen.md, Q8):
//    - core.js       core del codegen condiviso (emettitore neutro,
//                    memoria, confine os_*, corpo dell'interprete);
//    - backend_pe.js backend PE (KERNEL32 inline, builder PE);
//    - backend_elf.js backend ELF (syscall Linux inline, builder ELF).
//
//  Uso:
//    node seed/dev/gen_seed.js <windows|linux|all> [out.hex]
//
//    windows  rigenera il PE  -> seed/windows-x86_64/seed.hex (default)
//    linux    rigenera l'ELF -> seed/linux-x86_64/seed.hex  (default)
//    all      rigenera entrambi nei path canonici (out.hex non ammesso)
//
//  Formato hex: invariato per artefatto (PE 32 byte/riga, ELF 16
//  byte/riga come E1), xxd-compatibile.
//
//  Immutabilita' del PE (decisione 01): il dump PE rigenerato deve
//  restare byte-identico al versionato (cmp + hash in CI).
// =====================================================================
'use strict';
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const core = require('./core.js');
const backendPe = require('./backend_pe.js');
const backendElf = require('./backend_elf.js');

const TARGETS = {
  windows: { backend: backendPe, out: path.join(__dirname, '..', 'windows-x86_64', 'seed.hex') },
  linux: { backend: backendElf, out: path.join(__dirname, '..', 'linux-x86_64', 'seed.hex') },
};

function usage() {
  console.error('uso: node seed/dev/gen_seed.js <windows|linux|all> [out.hex]');
  process.exit(1);
}

const [target, outArg] = process.argv.slice(2);
if (!target || !Object.prototype.hasOwnProperty.call(TARGETS, target)) {
  if (target !== 'all') usage();
}
if (target === 'all' && outArg) usage();

// dump hex: width byte per riga, minuscule, newline finale (come gli
// artifact versionati; xxd -r -p li rilegge entrambi).
function toHex(img, width) {
  let out = '';
  for (let o = 0; o < img.length; o += width) {
    let line = '';
    for (let j = 0; j < width && o + j < img.length; j++) {
      line += img[o + j].toString(16).padStart(2, '0');
    }
    out += line + '\n';
  }
  return out;
}

function generate(name) {
  const { backend, out } = TARGETS[name];
  const outPath = outArg || out;
  core.emitProgram(backend);
  const { img, hexWidth } = backend.build();
  const hex = toHex(img, hexWidth);
  fs.writeFileSync(outPath, hex, 'ascii');
  const sha = crypto.createHash('sha256').update(img).digest('hex');
  const shaHex = crypto.createHash('sha256').update(hex).digest('hex');
  console.log(name + ': file bytes:', img.length, '->', outPath);
  console.log('  sha256(bin):', sha);
  console.log('  sha256(hex):', shaHex);
}

if (target === 'all') {
  generate('windows');
  generate('linux');
} else {
  generate(target);
}
