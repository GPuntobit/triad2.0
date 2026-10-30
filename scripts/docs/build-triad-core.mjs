#!/usr/bin/env node
// =====================================================================
//  build-triad-core.mjs — browser bundle of the Triad-Core interpreter
//
//  Usage:
//    node scripts/docs/build-triad-core.mjs
//
//  Source of truth : seed/dev/triad_core.cjs
//  Generated file  : docs/assets/js/triad-core.js
//
//  The website Playground needs the reference interpreter as a classic
//  browser script. The interpreter already detects a browser environment
//  and publishes itself as window.TriadCore; the only missing piece in
//  the browser is Node's Buffer, used by the strlen / strbyte / strsub
//  builtins. This script therefore generates the bundle as:
//
//    'use strict'
//    <UTF-8 Buffer polyfill>
//    <seed/dev/triad_core.cjs, minus its own 'use strict' directive>
//
//  Keeping the bundle generated (instead of hand-written) guarantees
//  that the Playground and the conformance suite run the very same
//  interpreter.
// =====================================================================

import { readFileSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..', '..');
const SRC = path.join(ROOT, 'seed', 'dev', 'triad_core.cjs');
const OUT = path.join(ROOT, 'docs', 'assets', 'js', 'triad-core.js');

const HEADER = `// =====================================================================
//  triad-core.js — GENERATED FILE, do not edit by hand.
//
//  Source of truth : seed/dev/triad_core.cjs
//  Rebuild         : node scripts/docs/build-triad-core.mjs
//
//  This is the Triad-Core reference interpreter packaged for the
//  browser: the same interpreter that runs the conformance suite.
// =====================================================================

'use strict';
`;

// --- Minimal UTF-8 Buffer polyfill ---------------------------------
// Node's Buffer is not available in the browser. Only the three APIs
// used by the interpreter are implemented: byteLength(), from() and the
// byte indexing / slicing / toString() of the returned buffer.
const POLYFILL = `
// ---------- Buffer polyfill (UTF-8, browser) -------------------------
(function () {
  if (typeof globalThis.Buffer === 'function' && globalThis.Buffer.from) return;

  function encodeUtf8(s) {
    s = String(s);
    if (typeof TextEncoder !== 'undefined') return new TextEncoder().encode(s);
    var out = [], i, c;
    for (i = 0; i < s.length; i++) {
      c = s.codePointAt(i);
      if (c > 0xffff) i++;
      if (c < 0x80) out.push(c);
      else if (c < 0x800) out.push(0xc0 | (c >> 6), 0x80 | (c & 0x3f));
      else if (c < 0x10000) out.push(0xe0 | (c >> 12), 0x80 | ((c >> 6) & 0x3f), 0x80 | (c & 0x3f));
      else out.push(0xf0 | (c >> 18), 0x80 | ((c >> 12) & 0x3f), 0x80 | ((c >> 6) & 0x3f), 0x80 | (c & 0x3f));
    }
    return new Uint8Array(out);
  }

  function decodeUtf8(bytes) {
    var u8 = (bytes instanceof Uint8Array) ? bytes : new Uint8Array(bytes);
    if (typeof TextDecoder !== 'undefined') return new TextDecoder('utf-8').decode(u8);
    var out = '', i = 0;
    while (i < u8.length) {
      var b = u8[i], n, cp;
      if (b < 0x80) { n = 0; cp = b; }
      else if (b < 0xe0) { n = 1; cp = b & 0x1f; }
      else if (b < 0xf0) { n = 2; cp = b & 0x0f; }
      else { n = 3; cp = b & 0x07; }
      i++;
      for (var k = 0; k < n; k++) { cp = (cp << 6) | (u8[i++] & 0x3f); }
      if (cp > 0xffff) {
        cp -= 0x10000;
        out += String.fromCharCode(0xd800 + (cp >> 10), 0xdc00 + (cp & 0x3ff));
      } else {
        out += String.fromCharCode(cp);
      }
    }
    return out;
  }

  // A buffer is a plain array of byte values: it supports .length,
  // byte indexing, .slice() and .toString('utf8'), which is all the
  // interpreter needs from Node's Buffer.
  function TriadBuffer(bytes) {
    var arr = Array.prototype.slice.call(bytes);
    arr.toString = function () { return decodeUtf8(arr); };
    arr.slice = function (a, b) { return TriadBuffer(Array.prototype.slice.call(arr, a, b)); };
    return arr;
  }

  var Shim = {
    byteLength: function (s) { return encodeUtf8(s).length; },
    from: function (s) { return new TriadBuffer(encodeUtf8(s)); },
    isBuffer: function () { return false; },
  };

  if (typeof globalThis !== 'undefined') globalThis.Buffer = Shim;
})();
`;

// --- Transform the interpreter --------------------------------------
const raw = readFileSync(SRC, 'utf8');

// The interpreter opens with its own 'use strict' directive: drop it,
// the generated file declares it once, at the very top.
let body = raw.replace(/^\s*'use strict';\s*\r?\n/, '');

// `require` must not exist in the browser: guard the fs import on the
// CommonJS module object as well, so a stray global cannot break it.
body = body.replace(
  "const fs = (typeof require === 'function')",
  "const fs = (typeof require === 'function' && typeof module !== 'undefined')"
);

const bundle = HEADER + POLYFILL + body;

writeFileSync(OUT, bundle, { encoding: 'utf8' });

const bytes = Buffer.byteLength(bundle, 'utf8');
console.log('wrote ' + path.relative(ROOT, OUT) + ' (' + bytes + ' bytes)');
