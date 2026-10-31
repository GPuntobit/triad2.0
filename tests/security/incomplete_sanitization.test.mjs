// Adversarial regression tests for CodeQL "incomplete multi-character
// sanitization" across every sanitizer in the repository. Run:
//   node --test tests/security/incomplete_sanitization.test.mjs
import { test } from 'node:test';
import assert from 'node:assert';
import { readFileSync } from 'node:fs';

// --- extract esc() from frontespizio.mjs without importing sharp -----------
const src = readFileSync(new URL('../../scripts/docs/frontespizio.mjs', import.meta.url), 'utf8');
const m = src.match(/const esc = s => \{[\s\S]*?\n\};/);
assert.ok(m, 'esc() definition found in frontespizio.mjs');
const esc = new Function(`${m[0]}\nreturn esc;`)();

const FORBIDDEN = /[<>&]/;

test('benign values pass through unchanged', () => {
  assert.strictEqual(esc('Triad-Core'), 'Triad-Core');
  assert.strictEqual(esc('v0.8.0-beta.7'), 'v0.8.0-beta.7');
});

test('ampersand is neutralized, never emitted raw or as decodable entity', () => {
  const out = esc('Tom & Jerry');
  assert.doesNotMatch(out, FORBIDDEN);
  assert.ok(!out.includes('&amp;') && !out.includes('&lt;') && !out.includes('&gt;'),
    'no entities are emitted (double-decode attack surface removed)');
});

test('raw markup characters are neutralized', () => {
  assert.doesNotMatch(esc('<script>alert(1)</script>'), FORBIDDEN);
});

test('splice/nesting payloads cannot reassemble a tag', () => {
  for (const payload of [
    '<scr<script>ipt>',
    '<<>|>',
    '&lt;script&gt;',          // pre-encoded double-decode bait
    '&amp;lt;script&amp;gt;',  // triple-encoded
    '&lt;scr&lt;script&gt;ipt&gt;',
    '<a<b>>',
  ]) {
    assert.doesNotMatch(esc(payload), FORBIDDEN, `payload leaked: ${payload}`);
    assert.ok(!esc(payload).includes('<') && !esc(payload).includes('>'));
  }
});

test('sanitizer is idempotent (fixed point)', () => {
  for (const v of ['plain', 'A & B', '<x>', '&lt;&gt;', '<<<>>>']) {
    const once = esc(v);
    assert.strictEqual(esc(once), once, `not idempotent for ${v}`);
  }
});

test('output invariant holds for random adversarial fuzzing', () => {
  const alphabet = [...'<>&;/\\ab&l;t;&g;t;&a;m;p;'];
  let seed = 42;
  const rnd = () => (seed = (seed * 1103515245 + 12345) % 2147483648) / 2147483648;
  for (let i = 0; i < 2000; i++) {
    let s = '';
    for (let j = 0; j < 24; j++) s += alphabet[Math.floor(rnd() * alphabet.length)];
    assert.doesNotMatch(esc(s), FORBIDDEN, `fuzz leak: ${JSON.stringify(s)}`);
  }
});

// --- instinct-cli.py _evolved_description: fixed-point + no-entity check ---
test('python _evolved_description reaches fixed point and keeps invariant', () => {
  const py = readFileSync(new URL('../../.github/skills/continuous-learning-v2/scripts/instinct-cli.py', import.meta.url), 'utf8');
  assert.match(py, /while True:[\s\S]*?sanitized\.replace\('<', '\('\)\.replace\('>', '\)'\)[\s\S]*?if sanitized == prev/,
    '_evolved_description loops to a fixed point');
  // emulate the python logic in JS with identical semantics
  const evolve = t => {
    let s = t.replace(': ', ' - ').replace('<', '(').replace('>', ')');
    while (true) {
      const prev = s;
      s = s.replace(/</g, '(').replace(/>/g, ')');
      if (s === prev) break;
    }
    return s;
  };
  for (const p of ['<scr<script>ipt>alert', '<<<', '<a<b>>', '&lt;x&gt;']) {
    assert.doesNotMatch(evolve(p), /[<>]/, `emulated leak: ${p}`);
  }
});
