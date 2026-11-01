/* Learning curve and threshold of Triad 2.0.
   Stages derived from TUTORIAL.md (chapter order) and MANUALE.md (corresponding chapters).
   Browser: TriadLearningCurve.render(id, opts). Node: node docs/assets/js/learning-curve.js > svg */
(function (root) {
  const STAGES = [
    { id: 'S0',  short: 'Start',       name: 'Installation and first program',              tut: '1ÔÇô3',    man: 'intro',         diff: 29, prac: 40,  group: 'core', note: 'Linux seed at stage E0, Windows seed only as a file: you start with the JS interpreter.' },
    { id: 'S1',  short: 'Lexicon',     name: 'Lexicon, values, printing',                      tut: '4ÔÇô5',    man: '1ÔÇô2',           diff: 38, prac: 90,  group: 'core', note: 'print/println rules and equality to learn by heart.' },
    { id: 'S2',  short: 'Operators',   name: 'Variables, operators, precedence',             tut: '6ÔÇô7',    man: '3ÔÇô4',           diff: 40, prac: 95,  group: 'core', note: 'Integer-only arithmetic in the JS interpreter (no / and no Float).' },
    { id: 'S3',  short: 'Flow',        name: 'Control flow',                          tut: '8',      man: '5.1ÔÇô5.3',       diff: 32, prac: 92,  group: 'core', note: 'if/elseif/else, while, break/continue, let and begin.' },
    { id: 'S4',  short: 'Functions',    name: 'Functions',                                     tut: '9',      man: '6',             diff: 37, prac: 95,  group: 'core', note: 'Three definition forms, return, recursion, !io effect.' },
    { id: 'S5',  short: 'Closures',    name: 'Lambda, closures, scope',                      tut: '10',     man: '8',             diff: 53, prac: 85,  group: 'core', note: 'Named functions do not reassign globals; the seed captures by value.' },
    { id: 'S6',  short: 'Lists',       name: 'Lists, strings, symbols',                     tut: '11ÔÇô12',  man: '9ÔÇô10',          diff: 53, prac: 55,  group: 'core', note: 'On the Windows seed, lists of integers only and get(xs, i) starting at 0.' },
    { id: 'S7',  short: 'Errors',      name: 'Runtime errors',                         tut: '14',     man: '11, 27',        diff: 33, prac: 90,  group: 'core', note: 'Errors as values in Core; structured Err only in Full.' },
    { id: 'S8',  short: 'Patterns',     name: 'Idiomatic patterns and Core exercises',          tut: '16ÔÇô17',  man: '22ÔÇô23',         diff: 56, prac: 70,  group: 'core', note: 'map/filter/reduce written by hand, records as tagged lists.' },
    { id: 'S9',  short: 'Dispatch',    name: 'Declared types, multiple dispatch, struct',   tut: '18ÔÇô20',  man: '2.2ÔÇô2.3, 7',    diff: 77, prac: 8,   group: 'full', note: 'Triad-Full: you read the specification, you do not run it.' },
    { id: 'S10', short: 'for/try',     name: 'for, range, comprehension, try, destructuring', tut: '21, 23', man: '5.4ÔÇô5.6',  diff: 64, prac: 8,   group: 'full', note: 'Familiar constructs, but not implemented by the runtime.' },
    { id: 'S11', short: 'Logic',      name: 'Logic: fact, rule, solve',                    tut: '22',     man: '16',            diff: 93, prac: 8,   group: 'full', note: 'Peak: unification with occurs-check, backtracking, solve as a value.' },
    { id: 'S12', short: 'Contracts',   name: 'Contracts, budget, traces',                    tut: '25ÔÇô27',  man: '12ÔÇô14',         diff: 73, prac: 8,   group: 'full', note: 'requires/ensures, with budget, with trace.' },
    { id: 'S13', short: 'Effects',     name: 'Declared effects !io / !state',              tut: '28',     man: '15',            diff: 76, prac: 8,   group: 'full', note: 'Err(:effect) if a pure function calls println.' },
    { id: 'S14', short: 'Macro',       name: 'Code as data, uniform tree, macro',     tut: '29',     man: '17ÔÇô18',         diff: 85, prac: 8,   group: 'full', note: 'Node(head, args), quote, macro: the biggest mind shift.' },
    { id: 'S15', short: 'Project',    name: 'Tooling and project internals',               tut: '33ÔÇô43',  man: '20ÔÇô21',         diff: 80, prac: 40,  group: 'proj', note: 'Seed in machine code, self-hosting S1, conformance, CI.' },
    { id: 'S16', short: 'Reference', name: 'Reference: grammar, glossary, FAQ',      tut: '44ÔÇô49',  man: '25ÔÇô29',         diff: 21, prac: 100, group: 'proj', note: 'Consultation material, not an obstacle.' },
  ];

  const C = { bg: '#0b1220', grid: 'rgba(148,163,184,.14)', text: '#e5e7eb', muted: '#94a3b8',
              real: '#f59e0b', theo: '#34d399', full: '#f43f5e', core: '#60a5fa', proj: '#a78bfa' };
  const FONT = 'Inter, system-ui, -apple-system, Segoe UI, Roboto, sans-serif';

  const esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  const attrs = o => Object.keys(o).map(k => `${k}="${esc(o[k])}"`).join(' ');
  const el = (tag, o, inner) => inner == null ? `<${tag} ${attrs(o)}/>` : `<${tag} ${attrs(o)}>${inner}</${tag}>`;
  const text = (x, y, s, o = {}) => el('text', Object.assign({ x, y, fill: C.muted, 'font-size': 12, 'font-family': FONT }, o), esc(s));
  const tip = s => `<title>${esc(s)}</title>`;

  function monoPath(pts) {
    const n = pts.length, dx = [], sl = [], m = [];
    for (let i = 0; i < n - 1; i++) { dx[i] = pts[i + 1][0] - pts[i][0]; sl[i] = (pts[i + 1][1] - pts[i][1]) / dx[i]; }
    m[0] = sl[0]; m[n - 1] = sl[n - 2];
    for (let i = 1; i < n - 1; i++) m[i] = sl[i - 1] * sl[i] <= 0 ? 0 : (sl[i - 1] + sl[i]) / 2;
    for (let i = 0; i < n - 1; i++) {
      if (sl[i] === 0) { m[i] = 0; m[i + 1] = 0; continue; }
      const a = m[i] / sl[i], b = m[i + 1] / sl[i], s = a * a + b * b;
      if (s > 9) { const t = 3 / Math.sqrt(s); m[i] = t * a * sl[i]; m[i + 1] = t * b * sl[i]; }
    }
    let d = `M${pts[0][0].toFixed(1)},${pts[0][1].toFixed(1)}`;
    for (let i = 0; i < n - 1; i++) {
      const h = dx[i];
      d += ` C${(pts[i][0] + h / 3).toFixed(1)},${(pts[i][1] + m[i] * h / 3).toFixed(1)}` +
           ` ${(pts[i + 1][0] - h / 3).toFixed(1)},${(pts[i + 1][1] + m[i + 1] * h / 3).toFixed(1)}` +
           ` ${pts[i + 1][0].toFixed(1)},${pts[i + 1][1].toFixed(1)}`;
    }
    return d;
  }

  /* practical_i = ╬ú diff_j┬Àprac_j / ╬ú diff ; theoretical_i = ╬ú diff_j / ╬ú diff (language stages only) */
  function model() {
    const lang = STAGES.filter(s => s.group !== 'proj');
    const total = lang.reduce((a, s) => a + s.diff, 0);
    let cd = 0, ca = 0;
    const curve = [{ id: '', E: 0, real: 0, theo: 0 }].concat(lang.map(s => {
      cd += s.diff; ca += s.diff * s.prac / 100;
      return Object.assign({}, s, { E: cd, real: 100 * ca / total, theo: 100 * cd / total });
    }));
    const lastCore = curve.filter(c => c.group === 'core').pop();
    return { total, curve, threshold: lastCore, final: curve[curve.length - 1] };
  }

  function curveSVG(opts = {}) {
    const W = 1000, H = opts.compact ? 430 : 490, P = { t: 54, r: 28, b: opts.compact ? 70 : 82, l: 58 };
    const IW = W - P.l - P.r, IH = H - P.t - P.b;
    const { total, curve, threshold, final } = model();
    const X = e => P.l + IW * e / total, Y = v => P.t + IH * (1 - v / 100);
    const out = [];
    out.push(el('rect', { x: 0, y: 0, width: W, height: H, rx: 14, fill: C.bg }));
    out.push(text(P.l, 30, 'Triad 2.0 ÔÇö learning curve and threshold', { fill: C.text, 'font-size': 17, 'font-weight': 700 }));
    out.push(text(W - P.r, 30, 'source: TUTORIAL.md + MANUALE.md', { 'text-anchor': 'end', 'font-size': 11.5 }));

    const tx = X(threshold.E);
    out.push(el('rect', { x: P.l, y: P.t, width: tx - P.l, height: IH, fill: C.core, opacity: 0.06 }));
    out.push(el('rect', { x: tx, y: P.t, width: P.l + IW - tx, height: IH, fill: C.full, opacity: 0.07 }));
    [0, 20, 40, 60, 80, 100].forEach(v => {
      out.push(el('line', { x1: P.l, x2: P.l + IW, y1: Y(v), y2: Y(v), stroke: C.grid }));
      out.push(text(P.l - 10, Y(v) + 4, v + '%', { 'text-anchor': 'end' }));
    });
    out.push(text(P.l + IW / 2, H - 18, 'cumulative effort (╬ú stage difficulty, 0ÔÇô100 each)', { 'text-anchor': 'middle' }));
    out.push(text(18, P.t + IH / 2, 'language mastery', { 'text-anchor': 'middle', transform: `rotate(-90 18 ${P.t + IH / 2})` }));

    const pT = curve.map(c => [X(c.E), Y(c.theo)]), pR = curve.map(c => [X(c.E), Y(c.real)]);
    const rev = monoPath(pR.slice().reverse());
    out.push(el('path', { d: monoPath(pT) + ' L' + rev.slice(1) + ' Z', fill: C.full, opacity: 0.16 }, tip('Tooling wall: what you study but cannot execute')));
    out.push(el('path', { d: monoPath(pT), fill: 'none', stroke: C.theo, 'stroke-width': 2.4, 'stroke-dasharray': '8 6', 'stroke-linecap': 'round' }));
    out.push(el('path', { d: monoPath(pR), fill: 'none', stroke: C.real, 'stroke-width': 3.4, 'stroke-linecap': 'round' }));

    const pl = Y(final.real);
    out.push(el('line', { x1: tx, x2: P.l + IW, y1: pl, y2: pl, stroke: C.real, 'stroke-dasharray': '2 5', opacity: 0.7 }));

    out.push(el('line', { x1: tx, x2: tx, y1: P.t - 8, y2: P.t + IH, stroke: C.full, 'stroke-width': 2, 'stroke-dasharray': '6 4' }));
    out.push(text(tx + 10, P.t + 14, 'LEARNING THRESHOLD', { fill: C.full, 'font-size': 12.5, 'font-weight': 700, 'letter-spacing': '.06em' }));
    out.push(text(tx + 10, P.t + 31, 'Triad-Full starts: +' + (curve[curve.indexOf(threshold) + 1].diff - threshold.diff) + ' difficulty points, practice at 8%', { fill: C.text, 'font-size': 12 }));
    out.push(text(tx - 10, P.t + 14, 'Triad-Core ÔÇö executable (37/37)', { 'text-anchor': 'end', fill: C.core, 'font-size': 12, 'font-weight': 600 }));
    out.push(text(tx + 10, P.t + IH - 12, 'Triad-Full ÔÇö specification (1/12 cases)', { fill: C.full, 'font-size': 12, 'font-weight': 600 }));

    curve.slice(1).forEach((c, i) => {
      const t = tip(`${c.id} ┬À ${c.name}\nTutorial ch. ${c.tut} ┬À Manual ch. ${c.man}\nDifficulty ${c.diff}/100 ┬À exercisable today ${c.prac}%\nReal mastery ${c.real.toFixed(1)}% ┬À theoretical ${c.theo.toFixed(1)}%\n${c.note}`);
      const col = c.group === 'full' ? C.full : C.core;
      out.push(el('g', { cursor: 'help' },
        t + el('circle', { cx: X(c.E), cy: Y(c.theo), r: 3.5, fill: C.bg, stroke: C.theo, 'stroke-width': 1.8 }) +
        el('circle', { cx: X(c.E), cy: Y(c.real), r: 5, fill: C.real, stroke: C.bg, 'stroke-width': 2 }) +
        el('rect', { x: X(c.E) - 14, y: P.t, width: 28, height: IH, fill: 'transparent' })));
      out.push(text(X(c.E), P.t + IH + 18, c.id, { 'text-anchor': 'middle', 'font-size': 11, fill: col }));
      if (!opts.compact) out.push(text(X(c.E), P.t + IH + (i % 2 ? 45 : 32), c.short, { 'text-anchor': 'middle', 'font-size': 10, opacity: 0.8 }));
    });

    out.push(el('circle', { cx: tx, cy: Y(threshold.real), r: 8, fill: 'none', stroke: C.full, 'stroke-width': 2 }));
    out.push(text(tx + 14, Y(threshold.real) + 26, Math.round(threshold.real) + '% at the threshold', { 'text-anchor': 'start', fill: C.real, 'font-size': 12.5, 'font-weight': 700 }));
    out.push(text(P.l + IW - 6, pl - 10, 'plateau ' + Math.round(final.real) + '% real', { 'text-anchor': 'end', fill: C.real, 'font-size': 12.5, 'font-weight': 700 }));
    out.push(text(P.l + IW - 18, Y(100) + 4, '100% theoretical', { 'text-anchor': 'end', fill: C.theo, 'font-size': 12.5, 'font-weight': 700 }));

    const lg = [[C.real, 'real mastery (today)', ''], [C.theo, 'theoretical (everything executable)', '8 6'], [C.full, 'tooling wall', 'area']];
    let lx = P.l + 12;
    lg.forEach(([c, s, d]) => {
      const y = P.t + 52;
      out.push(d === 'area' ? el('rect', { x: lx, y: y - 7, width: 22, height: 10, fill: c, opacity: 0.3 })
                            : el('line', { x1: lx, x2: lx + 22, y1: y - 2, y2: y - 2, stroke: c, 'stroke-width': 3, 'stroke-dasharray': d || 'none' }));
      out.push(text(lx + 28, y + 2, s, { fill: C.text, 'font-size': 11.5 }));
      lx += 34 + s.length * 6.4;
    });

    return el('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: `0 0 ${W} ${H}`, width: W, height: H, role: 'img',
      'aria-label': `Triad 2.0 learning curve: real mastery stops at ${Math.round(final.real)}% at the Triad-Full threshold` },
      out.join(''));
  }

  function stagesSVG() {
    const W = 1000, H = 380, P = { t: 40, r: 28, b: 92, l: 58 };
    const IW = W - P.l - P.r, IH = H - P.t - P.b, N = STAGES.length, step = IW / N, bw = step * 0.62;
    const X = i => P.l + step * (i + 0.5), Y = v => P.t + IH * (1 - v / 100);
    const out = [el('rect', { x: 0, y: 0, width: W, height: H, rx: 14, fill: C.bg })];
    out.push(text(P.l, 26, 'Difficulty per stage and share exercisable today', { fill: C.text, 'font-size': 15, 'font-weight': 700 }));
    [0, 25, 50, 75, 100].forEach(v => {
      out.push(el('line', { x1: P.l, x2: P.l + IW, y1: Y(v), y2: Y(v), stroke: C.grid }));
      out.push(text(P.l - 10, Y(v) + 4, v, { 'text-anchor': 'end' }));
    });
    const fi = STAGES.findIndex(s => s.group === 'full');
    const sx = P.l + step * fi;
    out.push(el('line', { x1: sx, x2: sx, y1: P.t - 6, y2: P.t + IH, stroke: C.full, 'stroke-width': 2, 'stroke-dasharray': '6 4' }));
    out.push(text(sx + 8, P.t + 6, 'threshold', { fill: C.full, 'font-size': 12, 'font-weight': 700 }));
    STAGES.forEach((s, i) => {
      const col = C[s.group];
      const t = tip(`${s.id} ┬À ${s.name}\nTutorial ch. ${s.tut} ┬À Manual ch. ${s.man}\nDifficulty ${s.diff}/100 ┬À exercisable today ${s.prac}%\n${s.note}`);
      out.push(el('g', { cursor: 'help' }, t +
        el('rect', { x: X(i) - bw / 2, y: Y(s.diff), width: bw, height: Y(0) - Y(s.diff), rx: 4, fill: col, opacity: 0.28 }) +
        el('rect', { x: X(i) - bw / 2, y: Y(s.diff * s.prac / 100), width: bw, height: Y(0) - Y(s.diff * s.prac / 100), rx: 4, fill: col }) +
        el('rect', { x: X(i) - step / 2, y: P.t, width: step, height: IH, fill: 'transparent' })));
      out.push(text(X(i), Y(s.diff) - 6, s.diff, { 'text-anchor': 'middle', fill: C.text, 'font-size': 11 }));
      out.push(text(X(i), P.t + IH + 14, s.id, { 'text-anchor': 'end', 'font-size': 11, fill: col, transform: `rotate(-40 ${X(i)} ${P.t + IH + 14})` }));
      out.push(text(X(i) + 4, P.t + IH + 28, s.short, { 'text-anchor': 'end', 'font-size': 10.5, transform: `rotate(-40 ${X(i) + 4} ${P.t + IH + 28})` }));
    });
    let lx = P.l + IW - 360;
    [[C.core, 'Triad-Core'], [C.full, 'Triad-Full'], [C.proj, 'project / reference']].forEach(([c, s]) => {
      out.push(el('rect', { x: lx, y: 17, width: 12, height: 12, rx: 3, fill: c }));
      out.push(text(lx + 18, 27, s, { fill: C.text, 'font-size': 11.5 }));
      lx += 30 + s.length * 6.6;
    });
    out.push(text(P.l + IW, H - 12, 'full bar = share exercisable today ┬À light bar = theory only', { 'text-anchor': 'end', 'font-size': 11 }));
    return el('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: `0 0 ${W} ${H}`, width: W, height: H, role: 'img',
      'aria-label': 'Difficulty of the 17 learning stages of Triad 2.0 and share exercisable today' }, out.join(''));
  }

  function render(id, kind, opts) {
    const node = document.getElementById(id);
    if (!node) return;
    // Parse the generated SVG as XML and move the node in with replaceChildren:
    // no innerHTML, so no part of the string can ever be interpreted as HTML.
    const svgString = kind === 'stages' ? stagesSVG() : curveSVG(opts);
    const parsed = new DOMParser().parseFromString(svgString, 'image/svg+xml');
    const svg = parsed.documentElement;
    if (parsed.getElementsByTagName('parsererror').length > 0 || svg.namespaceURI !== 'http://www.w3.org/2000/svg') return;
    svg.removeAttribute('width'); svg.removeAttribute('height');
    svg.style.width = '100%'; svg.style.height = 'auto'; svg.style.display = 'block';
    node.replaceChildren(document.importNode(svg, true));
  }

  function renderTable(id) {
    const node = document.getElementById(id);
    if (!node) return;
    // Build the table with DOM nodes and textContent only: values are inserted
    // as text, never as markup, so no escaping is needed and no XSS is possible.
    const cell = (value, tag) => {
      const c = document.createElement(tag || 'td');
      c.textContent = String(value);
      return c;
    };
    const table = document.createElement('table');
    const hr = document.createElement('tr');
    ['Stage', 'Tutorial', 'Manual', 'Difficulty', 'Exercisable', 'Profile', 'Note']
      .forEach(h => hr.appendChild(cell(h, 'th')));
    const thead = document.createElement('thead');
    thead.appendChild(hr);
    const tbody = document.createElement('tbody');
    STAGES.forEach(s => {
      const tr = document.createElement('tr');
      const stageCell = document.createElement('td');
      const b = document.createElement('b');
      b.textContent = s.id;
      stageCell.appendChild(b);
      stageCell.appendChild(document.createTextNode(' ' + s.name));
      tr.appendChild(stageCell);
      tr.appendChild(cell(s.tut));
      tr.appendChild(cell(s.man));
      tr.appendChild(cell(s.diff));
      tr.appendChild(cell(s.prac + '%'));
      tr.appendChild(cell(s.group === 'core' ? 'Core' : s.group === 'full' ? 'Full' : 'Project'));
      tr.appendChild(cell(s.note));
      tbody.appendChild(tr);
    });
    table.appendChild(thead);
    table.appendChild(tbody);
    node.replaceChildren(table);
  }

  const api = { STAGES, model, curveSVG, stagesSVG, render, renderTable };
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = api;
    if (require.main === module) process.stdout.write((process.argv[2] === 'stages' ? stagesSVG() : curveSVG()) + '\n');
  } else {
    root.TriadLearningCurve = api;
  }
})(this);
