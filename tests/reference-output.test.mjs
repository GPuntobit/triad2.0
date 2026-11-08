import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { mkdtemp, writeFile, rm } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const root = fileURLToPath(new URL('../', import.meta.url));
const reference = path.join(root, 'seed/dev/triad_core.cjs');
const line = 'abcdefghijklmnopqrstuvwxyz0123456789'.repeat(4);
const program = `i = 0\nwhile i < 4096\n println("${line}")\n i += 1\nend\n`;
const expected = (line + '\n').repeat(4096);

// A slow pipe reader exposes data discarded by process.exit() even when
// small golden programs happen to fit in the operating system's pipe buffer.
async function run(args, input) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, args, { cwd: root, stdio: ['pipe', 'pipe', 'pipe'] });
    const out = [], err = [];
    child.stdout.on('data', chunk => out.push(chunk));
    child.stdout.pause();
    const resume = setTimeout(() => child.stdout.resume(), 100);
    child.stderr.on('data', chunk => err.push(chunk));
    child.on('error', reject);
    child.on('close', code => {
      clearTimeout(resume);
      resolve({ code, out: Buffer.concat(out).toString(), err: Buffer.concat(err).toString() });
    });
    child.stdin.end(input);
  });
}

for (const [name, suffix, code, diagnostic] of [
  ['normal completion', '', 0, ''],
  ['explicit exit stops evaluation', 'exit(7)\nprintln("unreachable")\n', 7, ''],
  ['runtime error', 'println(undefined_name)\n', 1, 'error:'],
]) {
  test(`reference drains stdout on ${name}`, { timeout: 10000 }, async () => {
    const result = await run([reference, '-'], program + suffix);
    assert.equal(result.code, code);
    assert.equal(result.out.length, expected.length);
    assert.ok(result.out === expected, 'stdout must match byte for byte');
    if (diagnostic) assert.match(result.err, /error:/);
    else assert.equal(result.err, '');
  });
}

test('preloaded .td entry point drains stdout', { timeout: 10000 }, async () => {
  const dir = await mkdtemp(path.join(os.tmpdir(), 'triad-output-'));
  try {
    const file = path.join(dir, 'output.td');
    await writeFile(file, program);
    const result = await run(['--require', reference, file]);
    assert.equal(result.code, 0);
    assert.equal(result.out.length, expected.length);
    assert.ok(result.out === expected, 'stdout must match byte for byte');
    assert.equal(result.err, '');
  } finally { await rm(dir, { recursive: true, force: true }); }
});

test('reference preserves CLI error codes and diagnostics', async () => {
  assert.deepEqual(await run([reference]), { code: 2, out: '', err: 'usage: triad FILE [ARG...]\n' });
  const parse = await run([reference, '-'], 'println(\n');
  assert.equal(parse.code, 1);
  assert.equal(parse.out, '');
  assert.match(parse.err, /^parse error:/);
});
