import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, writeFileSync, existsSync, rmSync } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const root = fileURLToPath(new URL('../', import.meta.url));
const launch = (args, input) => spawnSync(path.join(root, 'bin/triad'), args,
  { cwd: os.tmpdir(), input, encoding: 'utf8', timeout: 10000 });
const sample = 'fact p(:a)\nprintln([s.x for s in solve p(?x)])\n';

test('S1 logic executes stdin through the native seed', () => {
  const r = launch(['--logic', '-'], sample);
  assert.equal(r.status, 0, r.stderr);
  assert.equal(r.stdout, '[:a]\n');
});
test('byte transport preserves paths with spaces and does not evaluate shell text', () => {
  const dir = mkdtempSync(path.join(os.tmpdir(), 'triad logic '));
  try {
    const sentinel = path.join(dir, 'unexpected');
    const file = path.join(dir, 'input with spaces.triad');
    writeFileSync(file, '# $(touch "' + sentinel + '")\n' + sample);
    const r = launch(['--logic', file]);
    assert.equal(r.status, 0, r.stderr);
    assert.equal(r.stdout, '[:a]\n');
    assert.equal(existsSync(sentinel), false);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
test('S1 rejects invalid syntax and source beyond its explicit capacity', () => {
  const syntax = launch(['--logic', '-'], 'fact (\n');
  assert.equal(syntax.status, 1);
  assert.match(syntax.stdout, /SYNTAX ERROR/);
  const large = launch(['--logic', '-'], ' '.repeat(4095));
  assert.equal(large.status, 1);
  assert.match(large.stderr, /source limit/);
  assert.equal(launch(['--logic']).status, 2);
});
