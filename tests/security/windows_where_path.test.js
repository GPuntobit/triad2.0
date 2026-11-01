// Verifica (suggerimento Codacy/CodeQL): la rilevazione comandi Windows non può
// eseguire un where.exe controllato dal repository. Test eseguito forzando il
// ramo win32 su Linux con path POSIX: se mai venisse invocato un eseguibile,
// deve essere quello sotto la directory di sistema fidata, mai uno dalla CWD.
const test = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');

const SRC = path.join(__dirname, '..', '..', '.github', 'ecc', 'scripts', 'lib', 'utils.js');
const tmpDir = fs.mkdtempSync('/tmp/ecc-win-test-');

// copia isolata del modulo, forzata a win32 e con fallback root portabile
let src = fs.readFileSync(SRC, 'utf8');
src = src.replace("process.platform === 'win32'", 'true');
const patched = "const DEFAULT_WINDOWS_SYSTEM_ROOT = '" + path.join(tmpDir, 'fakeSystemRoot') + "';";
assert.ok(src.includes("const DEFAULT_WINDOWS_SYSTEM_ROOT = 'C:\\\\WINDOWS';"), 'fallback constant not found');
src = src.replace("const DEFAULT_WINDOWS_SYSTEM_ROOT = 'C:\\\\WINDOWS';", patched);
// join win32 -> posix per rendere eseguibili i fake su Linux (solo harness)
src = src.replace("path.win32.join(getWindowsSystemDir(), 'where.exe')",
                  "path.posix.join(getWindowsSystemDir().replace(/\\\\/g,'/'), 'where.exe')");
for (const f of fs.readdirSync(path.dirname(SRC))) {
  if (f.endsWith('.js')) fs.copyFileSync(path.join(path.dirname(SRC), f), path.join(tmpDir, f));
}
fs.writeFileSync(path.join(tmpDir, 'utils.js'), src);

// where.exe fidato che logga l'invocazione
const trustedDir = path.join(tmpDir, 'fakeSystemRoot', 'System32');
fs.mkdirSync(trustedDir, { recursive: true });
const logFile = path.join(tmpDir, 'invocations.log');
fs.writeFileSync(path.join(trustedDir, 'where.exe'), `#!/bin/sh\necho "$0" >> ${logFile}\nexit 0\n`);
fs.chmodSync(path.join(trustedDir, 'where.exe'), 0o755);

// where.exe malevolo nella "project dir" (CWD)
const projDir = path.join(tmpDir, 'projdir');
fs.mkdirSync(projDir, { recursive: true });
fs.writeFileSync(path.join(projDir, 'where.exe'), `#!/bin/sh\necho MALICIOUS >> ${logFile}\nexit 0\n`);
fs.chmodSync(path.join(projDir, 'where.exe'), 0o755);

process.chdir(projDir);
// The harness must load the patched copy of utils.js written above into the
// test's own mkdtempSync directory (it forces the win32 branch and a portable
// system root). No external input reaches this path: it is derived only from
// the fresh temp dir created by this test.
// codacy-disable-next-line
const utils = require(path.join(tmpDir, 'utils.js'));

const evilSystemRoots = [
  undefined,                       // non impostata -> fallback fisso
  'System32',                      // relativa
  '.\\System32',                   // relativa alla CWD
  'C:\\..\\Users\\attacker',       // traversal
  '\\\\evil\\share\\windows',      // UNC
  'C:\\Program Files\\Windows',    // annidata/non-standard
];

for (const value of evilSystemRoots) {
  test(`SystemRoot=${JSON.stringify(value)}: only trusted where.exe runs`, () => {
    fs.writeFileSync(logFile, '');
    if (value === undefined) delete process.env.SystemRoot;
    else process.env.SystemRoot = value;
    utils.commandExists('node');
    const log = fs.readFileSync(logFile, 'utf8');
    assert.ok(!log.includes('MALICIOUS'), 'project-controlled where.exe was executed!');
    assert.strictEqual(log.trim(), path.join(trustedDir, 'where.exe'));
  });
}
