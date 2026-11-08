import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';
const root = fileURLToPath(new URL('../', import.meta.url));
for (const [name, source, expected] of [
  ['typed method', 'area(n::Int) = :intero', 'logic'],
  ['facts', 'fact parent(:a,:b)', 'logic'],
  ['query', 'println(solve ?x = 1)', 'logic'],
  ['struct', 'struct Point\nx\nend', 'logic'],
  ['strings', 'println("fact p(:a) rule r solve q")', 'core'],
  ['escaped quotes', 'println("a \\" fact p \\" b")', 'core'],
  ['line comment', '# fact p(:a)\nprintln(1)', 'core'],
  ['nested comments', '#= fact p #= solve q =# rule q =#\nprintln(1)', 'core'],
  ['names', 'fact = 1\nsolve = 2\nx = :fact\nx.rule', 'core'],
  ['multiline literal', 'x = "a\nfact parent(:a,:b)\nb"', 'core'],
  ['real after comment', '#= solve q =#\nrule p(?x) :- q(?x)', 'logic'],
]) {
  test(`automatic profile: ${name}`, () => {
    const dir = mkdtempSync(path.join(os.tmpdir(), 'triad profile '));
    try {
      const file = path.join(dir, 'input.triad');
      writeFileSync(file, source);
      const r = spawnSync('sh', [path.join(root, 'scripts/detect-profile.sh'), file], { encoding: 'utf8', timeout: 5000 });
      assert.equal(r.status, 0, r.stderr);
      assert.equal(r.stdout.trim(), expected);
    } finally { rmSync(dir, { recursive: true, force: true }); }
  });
}
