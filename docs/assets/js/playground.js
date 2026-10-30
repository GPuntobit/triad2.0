// playground.js — Triad in the browser. Use window.TriadCore (see seed/dev/triad_core.cjs).
(function () {
  'use strict';
const EXAMPLES = {
    'Welcome': '# Your first Triad program\nprintln("Hello from Triad!")\n',
    'Functions & ternary': [
      '# short form: definition with expression',
      'sum(a, b) = a + b',
      'square(x) = x * x',
      'println(sum(2, 3))',
      'println(square(4))',
      '',
      '# recursion with ternary',
      'factorial(n) = n < 2 ? 1 : n * factorial(n - 1)',
      'fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)',
      'println(factorial(5))',
      'println(fib(10))',
    ].join('\n'),
    'Lambdas & closures': [
      'double = x -> x * 2',
      'apply = f -> f(3)',
      'println(double(5))',
      'println(apply(x -> x * x))',
      '',
      'function add(n)',
      'x -> x + n',
      'end',
      'f = add(10)',
      'println(f(5))',
    ].join('\n'),
    'Lists & push!': [
      '#lists: functional push (push! returns new list)',
      'lst = []',
      'lst = push!(lst, 10)',
      'lst = push!(lst, 20)',
      'println(lst)',
      'println(length(lst))',
    ].join('\n'),
    'Control & scope': [
      'x = 0',
      'while x < 3',
      'println(x)',
      'x += 1',
      'end',
      '',
      'if x == 3',
      ' println("three")',
      'elseif x > 3',
      ' println("more")',
      'else',
      ' println("minus")',
      'end',
    ].join('\n'),
    'Strings & symbols': [
      '# strings are byte-indexed (positions start at 1)',
      's = "Triad"',
      'println(strlen(s))',
      'println(strsub(s, 1, 3))',
      'println(strbyte(s, 1))',
      '',
      '# symbols: interned names, printed without the colon',
      'p = :alice',
      'println(p)',
      'println(typeof(:sym))',
      'println(Int("42"))',
    ].join('\n'),
    'Blocks & functions': [
      'function greet(name)',
      'println("hello ", name)',
      'end',
      'greet(:world)',
      '',
      '# higher-order: a function that returns a closure',
      'add(n) = x -> x + n',
      'inc = add(1)',
      'println(inc(41))',
    ].join('\n'),
    'Math & operators': [
      '# / is integer division; % follows the sign of the dividend',
      'a = 7 % 2',
      'println(a)',
      'c = -3',
      'println(c % 2)',
      '',
      '# ^ is exponentiation',
      'n = 2',
      'println(n ^ 10)',
      '',
      '# precedence: parentheses make intent explicit',
      'println(1 + 2 * 3)',
      'println((1 + 2) * 3)',
    ].join('\n'),
  };
const editor = document.getElementById('pg-editor');
  const output = document.getElementById('pg-output');
  const btnRun = document.getElementById('pg-run');
  const selExample = document.getElementById('pg-example');
  const statusEl = document.getElementById('pg-status');
if (!editor || !btnRun) return;
// Populate the select with examples.
  for (const name of Object.keys(EXAMPLES)) {
    const opt = document.createElement('option');
    opt.value = name;
    opt.textContent = name;
    selExample.appendChild(opt);
  }
  editor.value = EXAMPLES['Welcome'];
  selExample.addEventListener('change', () => {
    if (selExample.value) editor.value = EXAMPLES[selExample.value];
  });
// Tab in textarea inserts 4 spaces.
  editor.addEventListener('keydown', (e) => {
    if (e.key === 'Tab') {
      e.preventDefault();
      const s = editor.selectionStart;
      editor.value = editor.value.slice(0, s) + ' ' + editor.value.slice(editor.selectionEnd);
      editor.selectionStart = editor.selectionEnd = s + 4;
    }
    if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') { e.preventDefault(); run(); }
  });
function setStatus(msg) { statusEl.textContent = msg; }
function run() {
    const C = window.TriadCore;
    output.classList.remove('err');
    output.textContent = '';
    if (!C) { output.textContent = 'Error: Triad engine not loaded (triad_core.js missing).'; return; }
const src = editor.value;
    // Output hook: core writes with process.stdout.write; the shim browser
    // (triad_core.cjs) redirects writes to window.__TRIAD_OUT__.
    const lines = [];
try {
      const tokens = C.tokenize(src);
      const parser = new C.Parser(tokens);
      const ast = parser.parseProgram();
const globalEnv = C.makeFrame(null, null, false);
      globalEnv.owner = null;
      globalEnv.isLambda = false;
      globalEnv.bindings.set('ARGS', C.L([]));
window.__TRIAD_OUT__ = lines;
const t0 = performance.now();
      for (const s of ast.stmts) C.evalStmt(s, globalEnv);
      const ms = Math.round(performance.now() - t0);
output.textContent = lines.join('') || '(no output)';
      setStatus('OK — completed in ' + ms + ' ms');
    } catch (e) {
      const partial = lines.join('');
      output.classList.add('err');
      output.textContent = partial + (partial ? '\n' : '') + '⛔ ' + (e && e.message ? e.message : String(e));
      setStatus('Error');
    } finally {
      window.__TRIAD_OUT__ = null;
    }
  }
btnRun.addEventListener('click', run);
})();