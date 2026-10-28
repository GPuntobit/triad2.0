// playground.js — Triad nel browser. Usa window.TriadCore (vedi seed/dev/triad_core.cjs).
(function () {
  'use strict';

  const EXAMPLES = {
    'Benvenuto': '# Il tuo primo programma Triad\nprintln("Ciao da Triad!")\n',
    'Funzioni & ternario': [
      '# forma breve: definizione con espressione',
      'somma(a, b) = a + b',
      'quadrato(x) = x * x',
      'println(somma(2, 3))',
      'println(quadrato(4))',
      '',
      '# ricorsione con ternario',
      'fattoriale(n) = n < 2 ? 1 : n * fattoriale(n - 1)',
      'fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)',
      'println(fattoriale(5))',
      'println(fib(10))',
    ].join('\n'),
    'Lambda & chiusure': [
      'doppio = x -> x * 2',
      'applica = f -> f(3)',
      'println(doppio(5))',
      'println(applica(x -> x * x))',
      '',
      'function add(n)',
      '    x -> x + n',
      'end',
      'f = add(10)',
      'println(f(5))',
    ].join('\n'),
    'Liste & push!': [
      '# liste: spinta funzionale (push! restituisce la nuova lista)',
      'lst = []',
      'lst = push!(lst, 10)',
      'lst = push!(lst, 20)',
      'println(lst)',
      'println(length(lst))',
    ].join('\n'),
    'Controllo & scope': [
      'x = 0',
      'while x < 3',
      '    println(x)',
      '    x += 1',
      'end',
      '',
      'if x == 3',
      '    println("tre")',
      'elseif x > 3',
      '    println("più")',
      'else',
      '    println("meno")',
      'end',
    ].join('\n'),
  };

  const editor = document.getElementById('pg-editor');
  const output = document.getElementById('pg-output');
  const btnRun = document.getElementById('pg-run');
  const selExample = document.getElementById('pg-example');
  const statusEl = document.getElementById('pg-status');

  if (!editor || !btnRun) return;

  // Popola la select degli esempi.
  for (const name of Object.keys(EXAMPLES)) {
    const opt = document.createElement('option');
    opt.value = name;
    opt.textContent = name;
    selExample.appendChild(opt);
  }
  editor.value = EXAMPLES['Benvenuto'];
  selExample.addEventListener('change', () => {
    if (selExample.value) editor.value = EXAMPLES[selExample.value];
  });

  // Tab nel textarea inserisce 4 spazi.
  editor.addEventListener('keydown', (e) => {
    if (e.key === 'Tab') {
      e.preventDefault();
      const s = editor.selectionStart;
      editor.value = editor.value.slice(0, s) + '    ' + editor.value.slice(editor.selectionEnd);
      editor.selectionStart = editor.selectionEnd = s + 4;
    }
    if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') { e.preventDefault(); run(); }
  });

  function setStatus(msg) { statusEl.textContent = msg; }

  function run() {
    const C = window.TriadCore;
    output.classList.remove('err');
    output.textContent = '';
    if (!C) { output.textContent = 'Errore: motore Triad non caricato (triad_core.js mancante).'; return; }

    const src = editor.value;
    // Hook di output: il core scrive con process.stdout.write; lo shim browser
    // (triad_core.cjs) redirige le scritture su window.__TRIAD_OUT__.
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

      output.textContent = lines.join('') || '(nessun output)';
      setStatus('OK — completato in ' + ms + ' ms');
    } catch (e) {
      const partial = lines.join('');
      output.classList.add('err');
      output.textContent = partial + (partial ? '\n' : '') + '⛔ ' + (e && e.message ? e.message : String(e));
      setStatus('Errore');
    } finally {
      window.__TRIAD_OUT__ = null;
    }
  }

  btnRun.addEventListener('click', run);
})();
