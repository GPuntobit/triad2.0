import { runNode, projectPath, fileExists } from '../utils.mjs';
import fs from 'node:fs';
import path from 'node:path';

export async function verifyAISolutions(options = {}) {
  const tasksDir = options.tasks || projectPath('ai', 'tasks');
  const runner = projectPath('conformance', 'run.mjs'); // not used; we run seed directly
  // find runtime
  const isWin = process.platform === 'win32';
  const runtimeCandidates = isWin
    ? [projectPath('bin', 'triad-native.exe'), projectPath('seed', 'windows-x86_64', 'seed.exe')]
    : [projectPath('bin', 'triad-native'), projectPath('seed', 'linux-x86_64', 'seed')];
  const runtime = runtimeCandidates.find(p => fs.existsSync(p));
  if (!runtime) throw new Error('runtime seed non trovato');

  const dirs = fs.readdirSync(tasksDir, { withFileTypes: true })
    .filter(d => d.isDirectory() && fs.existsSync(path.join(tasksDir, d.name, 'task.md')))
    .map(d => path.join(tasksDir, d.name))
    .sort();

  // allow single task dir
  const targetDirs = fs.existsSync(path.join(tasksDir, 'task.md')) ? [tasksDir] : dirs;

  let fails = 0, missing = 0;
  for (const dir of targetDirs) {
    const name = path.basename(dir);
    const sol = path.join(dir, 'solution.triad');
    if (!fs.existsSync(sol)) {
      console.log('SKIP  ' + name + '  (manca solution.triad)');
      missing++;
      continue;
    }
    const { spawnSync } = await import('node:child_process');
    const res = spawnSync(runtime, [sol], { encoding: 'utf8', cwd: projectPath() });
    const code = res.status === null ? 1 : res.status;
    const out = (res.stdout || '').replace(/\r\n/g, '\n');

    const eoutPathPrimary = path.join(dir, 'expected.out');
    const eoutPathFallback = path.join(dir, 'expected.golden');
    const eoutPath = fs.existsSync(eoutPathPrimary) ? eoutPathPrimary : eoutPathFallback;
    const ecodePath = path.join(dir, 'expected.code');
    const expectedOut = fs.existsSync(eoutPath) ? fs.readFileSync(eoutPath, 'utf8') : '';
    const expectedCode = fs.existsSync(ecodePath) ? parseInt(fs.readFileSync(ecodePath, 'utf8').trim(), 10) : 0;

    const ok = code === expectedCode && out === expectedOut.replace(/\r\n/g, '\n');
    if (ok) console.log('PASS  ' + name);
    else {
      fails++;
      console.log('FAIL  ' + name + '  (exit ' + code + ', atteso ' + expectedCode + '; stdout ' + Buffer.byteLength(out, 'utf8') + ' byte, attesi ' + Buffer.byteLength(expectedOut, 'utf8') + ')');
      if (options.verbose) {
        console.log('--- stdout ottenuto ---'); process.stdout.write(out);
        console.log('--- stdout atteso ---'); process.stdout.write(expectedOut);
        console.log('----------------------');
      }
    }
  }
  console.log('');
  console.log('task: ' + targetDirs.length + '  pass: ' + (targetDirs.length - fails - missing) + '  fail: ' + fails + '  skip: ' + missing);
  return fails === 0;
}

export async function handleAIVerify(options) {
  try { return await verifyAISolutions(options); }
  catch (error) { console.error(`Errore durante la verifica: ${error.message}`); return false; }
}

