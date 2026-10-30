import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtemp, mkdir, readFile, rm, symlink, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const runner = fileURLToPath(new URL('./run.mjs', import.meta.url));

test('golden update refuses symlink outputs without changing their targets', async (t) => {
  const scratch = await mkdtemp(path.join(tmpdir(), 'triad-golden-symlink-'));
  t.after(() => rm(scratch, { recursive: true, force: true }));

  for (const name of ['expected.out', 'expected.golden', 'expected.code']) {
    const cases = path.join(scratch, name.replaceAll('.', '-'));
    const caseDir = path.join(cases, 'case');
    await mkdir(caseDir, { recursive: true });
    await writeFile(path.join(caseDir, 'program.td'), 'println(1)\n');
    const target = path.join(scratch, `${name}.sentinel`);
    await writeFile(target, 'outside content must remain unchanged');
    try {
      await symlink(target, path.join(caseDir, name), 'file');
    } catch (error) {
      if (['EPERM', 'EACCES', 'UNKNOWN'].includes(error.code)) {
        t.skip(`Creating file symlinks is not permitted: ${error.code}`);
        return;
      }
      throw error;
    }

    const result = spawnSync(process.execPath, [runner, '--cases', cases, '--update'], {
      encoding: 'utf8',
    });

    assert.notEqual(result.status, 0, `${name} symlink was unexpectedly accepted`);
    assert.match(result.stderr, /Rifiutato golden non regolare/);
    assert.equal(await readFile(target, 'utf8'), 'outside content must remain unchanged');
  }
});

test('golden update still creates regular output files', async (t) => {
  const scratch = await mkdtemp(path.join(tmpdir(), 'triad-golden-regular-'));
  t.after(() => rm(scratch, { recursive: true, force: true }));
  const cases = path.join(scratch, 'cases');
  const caseDir = path.join(cases, 'simple');
  await mkdir(caseDir, { recursive: true });
  await writeFile(path.join(caseDir, 'program.td'), 'println(1)\n');

  const result = spawnSync(process.execPath, [runner, '--cases', cases, '--update'], {
    encoding: 'utf8',
  });

  assert.equal(result.status, 0, result.stderr);
  assert.equal(await readFile(path.join(caseDir, 'expected.out'), 'utf8'), '1\n');
  assert.equal(await readFile(path.join(caseDir, 'expected.golden'), 'utf8'), '1\n');
  assert.equal(await readFile(path.join(caseDir, 'expected.code'), 'utf8'), '0');
});
