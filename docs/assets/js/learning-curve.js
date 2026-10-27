/* Curva e soglia di apprendimento di Triad 2.0.
   Fasi ricavate da TUTORIAL.md (ordine dei capitoli) e MANUALE.md (capitoli corrispondenti).
   Browser: TriadLearningCurve.render(id, opts). Node: node docs/assets/js/learning-curve.js > svg */
(function (root) {
  const STAGES = [
    { id: 'S0',  short: 'Avvio',       name: 'Installazione e primo programma',              tut: '1–3',    man: 'intro',         diff: 29, prac: 40,  group: 'core', note: 'Seed Linux allo stadio E0, seed Windows solo su file: si parte con l\'interprete JS.' },
    { id: 'S1',  short: 'Lessico',     name: 'Lessico, valori, stampa',                      tut: '4–5',    man: '1–2',           diff: 38, prac: 90,  group: 'core', note: 'Regole di print/println e uguaglianza da imparare a memoria.' },
    { id: 'S2',  short: 'Operatori',   name: 'Variabili, operatori, precedenza',             tut: '6–7',    man: '3–4',           diff: 40, prac: 95,  group: 'core', note: 'Aritmetica solo intera nell\'interprete JS (niente / né Float).' },
    { id: 'S3',  short: 'Flusso',      name: 'Controllo di flusso',                          tut: '8',      man: '5.1–5.3',       diff: 32, prac: 92,  group: 'core', note: 'if/elseif/else, while, break/continue, let e begin.' },
    { id: 'S4',  short: 'Funzioni',    name: 'Funzioni',                                     tut: '9',      man: '6',             diff: 37, prac: 95,  group: 'core', note: 'Tre forme di definizione, return, ricorsione, effetto !io.' },
    { id: 'S5',  short: 'Chiusure',    name: 'Lambda, chiusure, scope',                      tut: '10',     man: '8',             diff: 53, prac: 85,  group: 'core', note: 'Le funzioni con nome non riassegnano globali; il seed cattura per valore.' },
    { id: 'S6',  short: 'Liste',       name: 'Liste, stringhe, simboli',                     tut: '11–12',  man: '9–10',          diff: 53, prac: 55,  group: 'core', note: 'Sul seed Windows liste solo di interi e get(xs, i) da 0.' },
    { id: 'S7',  short: 'Errori',      name: 'Errori di esecuzione',                         tut: '14',     man: '11, 27',        diff: 33, prac: 90,  group: 'core', note: 'Errori come valori in Core; Err strutturato solo in Full.' },
    { id: 'S8',  short: 'Pattern',     name: 'Pattern idiomatici ed esercizi Core',          tut: '16–17',  man: '22–23',         diff: 56, prac: 70,  group: 'core', note: 'map/filter/reduce scritti a mano, record come liste taggate.' },
    { id: 'S9',  short: 'Dispatch',    name: 'Tipi dichiarati, multiple dispatch, struct',   tut: '18–20',  man: '2.2–2.3, 7',    diff: 77, prac: 8,   group: 'full', note: 'Triad-Full: si legge la specifica, non si esegue.' },
    { id: 'S10', short: 'for/try',     name: 'for, range, comprehension, try, destrutturazione', tut: '21, 23', man: '5.4–5.6',  diff: 64, prac: 8,   group: 'full', note: 'Costrutti familiari, ma non implementati dal runtime.' },
    { id: 'S11', short: 'Logica',      name: 'Logica: fact, rule, solve',                    tut: '22',     man: '16',            diff: 93, prac: 8,   group: 'full', note: 'Picco: unificazione con occurs-check, backtracking, solve come valore.' },
    { id: 'S12', short: 'Contratti',   name: 'Contratti, budget, tracce',                    tut: '25–27',  man: '12–14',         diff: 73, prac: 8,   group: 'full', note: 'requires/ensures, with budget, with trace.' },
    { id: 'S13', short: 'Effetti',     name: 'Effetti dichiarati !io / !state',              tut: '28',     man: '15',            diff: 76, prac: 8,   group: 'full', note: 'Err(:effect) se una funzione pura chiama println.' },
    { id: 'S14', short: 'Macro',       name: 'Codice come dato, albero uniforme, macro',     tut: '29',     man: '17–18',         diff: 85, prac: 8,   group: 'full', note: 'Node(head, args), quote, macro: il salto di mentalità più grande.' },
    { id: 'S15', short: 'Progetto',    name: 'Tooling e interni del progetto',               tut: '33–43',  man: '20–21',         diff: 80, prac: 40,  group: 'proj', note: 'Seed in codice macchina, self-hosting S1, conformance, CI.' },
    { id: 'S16', short: 'Riferimento', name: 'Riferimento: grammatica, glossario, FAQ',      tut: '44–49',  man: '25–29',         diff: 21, prac: 100, group: 'proj', note: 'Materiale di consultazione, non un ostacolo.' },
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
           ` ${(pts[i + 1][0] - h / 3).toFixed(1)},${(pts[i + 1][1] - m[i + 1] * h / 3).toFixed(1)}` +
           ` ${pts[i + 1][0].toFixed(1)},${pts[i + 1][1].toFixed(1)}`;
    }
    return d;
  }

  /* padronanza_i = Σ diff_j·prac_j / Σ diff ; teorica_i = Σ diff_j / Σ diff (solo fasi del linguaggio) */
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
    out.push(text(P.l, 30, 'Triad 2.0 — curva e soglia di apprendimento', { fill: C.text, 'font-size': 17, 'font-weight': 700 }));
    out.push(text(W - P.r, 30, 'fonte: TUTORIAL.md + MANUALE.md', { 'text-anchor': 'end', 'font-size': 11.5 }));

    const tx = X(threshold.E);
    out.push(el('rect', { x: P.l, y: P.t, width: tx - P.l, height: IH, fill: C.core, opacity: 0.06 }));
    out.push(el('rect', { x: tx, y: P.t, width: P.l + IW - tx, height: IH, fill: C.full, opacity: 0.07 }));
    [0, 20, 40, 60, 80, 100].forEach(v => {
      out.push(el('line', { x1: P.l, x2: P.l + IW, y1: Y(v), y2: Y(v), stroke: C.grid }));
      out.push(text(P.l - 10, Y(v) + 4, v + '%', { 'text-anchor': 'end' }));
    });
    out.push(text(P.l + IW / 2, H - 18, 'fatica cumulata (Σ difficoltà delle fasi, 0–100 ciascuna)', { 'text-anchor': 'middle' }));
    out.push(text(18, P.t + IH / 2, 'padronanza del linguaggio', { 'text-anchor': 'middle', transform: `rotate(-90 18 ${P.t + IH / 2})` }));

    const pT = curve.map(c => [X(c.E), Y(c.theo)]), pR = curve.map(c => [X(c.E), Y(c.real)]);
    const rev = monoPath(pR.slice().reverse());
    out.push(el('path', { d: monoPath(pT) + ' L' + rev.slice(1) + ' Z', fill: C.full, opacity: 0.16 }, tip('Muro del tooling: ciò che si studia ma non si può eseguire')));
    out.push(el('path', { d: monoPath(pT), fill: 'none', stroke: C.theo, 'stroke-width': 2.4, 'stroke-dasharray': '8 6', 'stroke-linecap': 'round' }));
    out.push(el('path', { d: monoPath(pR), fill: 'none', stroke: C.real, 'stroke-width': 3.4, 'stroke-linecap': 'round' }));

    const pl = Y(final.real);
    out.push(el('line', { x1: tx, x2: P.l + IW, y1: pl, y2: pl, stroke: C.real, 'stroke-dasharray': '2 5', opacity: 0.7 }));

    out.push(el('line', { x1: tx, x2: tx, y1: P.t - 8, y2: P.t + IH, stroke: C.full, 'stroke-width': 2, 'stroke-dasharray': '6 4' }));
    out.push(text(tx + 10, P.t + 14, 'SOGLIA DI APPRENDIMENTO', { fill: C.full, 'font-size': 12.5, 'font-weight': 700, 'letter-spacing': '.06em' }));
    out.push(text(tx + 10, P.t + 31, 'inizio Triad-Full: +' + (curve[curve.indexOf(threshold) + 1].diff - threshold.diff) + ' pt di difficoltà, pratica all\'8%', { fill: C.text, 'font-size': 12 }));
    out.push(text(tx - 10, P.t + 14, 'Triad-Core — eseguibile (37/37)', { 'text-anchor': 'end', fill: C.core, 'font-size': 12, 'font-weight': 600 }));
    out.push(text(tx + 10, P.t + IH - 12, 'Triad-Full — specifica (1/12 casi)', { fill: C.full, 'font-size': 12, 'font-weight': 600 }));

    curve.slice(1).forEach((c, i) => {
      const t = tip(`${c.id} · ${c.name}\nTutorial cap. ${c.tut} · Manuale cap. ${c.man}\nDifficoltà ${c.diff}/100 · praticabile oggi ${c.prac}%\nPadronanza reale ${c.real.toFixed(1)}% · teorica ${c.theo.toFixed(1)}%\n${c.note}`);
      const col = c.group === 'full' ? C.full : C.core;
      out.push(el('g', { cursor: 'help' },
        t + el('circle', { cx: X(c.E), cy: Y(c.theo), r: 3.5, fill: C.bg, stroke: C.theo, 'stroke-width': 1.8 }) +
        el('circle', { cx: X(c.E), cy: Y(c.real), r: 5, fill: C.real, stroke: C.bg, 'stroke-width': 2 }) +
        el('rect', { x: X(c.E) - 14, y: P.t, width: 28, height: IH, fill: 'transparent' })));
      out.push(text(X(c.E), P.t + IH + 18, c.id, { 'text-anchor': 'middle', 'font-size': 11, fill: col }));
      if (!opts.compact) out.push(text(X(c.E), P.t + IH + (i % 2 ? 45 : 32), c.short, { 'text-anchor': 'middle', 'font-size': 10, opacity: 0.8 }));
    });

    out.push(el('circle', { cx: tx, cy: Y(threshold.real), r: 8, fill: 'none', stroke: C.full, 'stroke-width': 2 }));
    out.push(text(tx + 14, Y(threshold.real) + 26, Math.round(threshold.real) + '% alla soglia', { 'text-anchor': 'start', fill: C.real, 'font-size': 12.5, 'font-weight': 700 }));
    out.push(text(P.l + IW - 6, pl - 10, 'plateau ' + Math.round(final.real) + '% reale', { 'text-anchor': 'end', fill: C.real, 'font-size': 12.5, 'font-weight': 700 }));
    out.push(text(P.l + IW - 18, Y(100) + 4, '100% teorico', { 'text-anchor': 'end', fill: C.theo, 'font-size': 12.5, 'font-weight': 700 }));

    const lg = [[C.real, 'padronanza reale (oggi)', ''], [C.theo, 'teorica (tutto eseguibile)', '8 6'], [C.full, 'muro del tooling', 'area']];
    let lx = P.l + 12;
    lg.forEach(([c, s, d]) => {
      const y = P.t + 52;
      out.push(d === 'area' ? el('rect', { x: lx, y: y - 7, width: 22, height: 10, fill: c, opacity: 0.3 })
                            : el('line', { x1: lx, x2: lx + 22, y1: y - 2, y2: y - 2, stroke: c, 'stroke-width': 3, 'stroke-dasharray': d || 'none' }));
      out.push(text(lx + 28, y + 2, s, { fill: C.text, 'font-size': 11.5 }));
      lx += 34 + s.length * 6.4;
    });

    return el('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: `0 0 ${W} ${H}`, width: W, height: H, role: 'img',
      'aria-label': `Curva di apprendimento di Triad 2.0: la padronanza reale si ferma al ${Math.round(final.real)}% alla soglia di Triad-Full` },
      out.join(''));
  }

  function stagesSVG() {
    const W = 1000, H = 380, P = { t: 40, r: 28, b: 92, l: 58 };
    const IW = W - P.l - P.r, IH = H - P.t - P.b, N = STAGES.length, step = IW / N, bw = step * 0.62;
    const X = i => P.l + step * (i + 0.5), Y = v => P.t + IH * (1 - v / 100);
    const out = [el('rect', { x: 0, y: 0, width: W, height: H, rx: 14, fill: C.bg })];
    out.push(text(P.l, 26, 'Difficoltà per fase e quota esercitabile oggi', { fill: C.text, 'font-size': 15, 'font-weight': 700 }));
    [0, 25, 50, 75, 100].forEach(v => {
      out.push(el('line', { x1: P.l, x2: P.l + IW, y1: Y(v), y2: Y(v), stroke: C.grid }));
      out.push(text(P.l - 10, Y(v) + 4, v, { 'text-anchor': 'end' }));
    });
    const fi = STAGES.findIndex(s => s.group === 'full');
    const sx = P.l + step * fi;
    out.push(el('line', { x1: sx, x2: sx, y1: P.t - 6, y2: P.t + IH, stroke: C.full, 'stroke-width': 2, 'stroke-dasharray': '6 4' }));
    out.push(text(sx + 8, P.t + 6, 'soglia', { fill: C.full, 'font-size': 12, 'font-weight': 700 }));
    STAGES.forEach((s, i) => {
      const col = C[s.group];
      const t = tip(`${s.id} · ${s.name}\nTutorial cap. ${s.tut} · Manuale cap. ${s.man}\nDifficoltà ${s.diff}/100 · praticabile oggi ${s.prac}%\n${s.note}`);
      out.push(el('g', { cursor: 'help' }, t +
        el('rect', { x: X(i) - bw / 2, y: Y(s.diff), width: bw, height: Y(0) - Y(s.diff), rx: 4, fill: col, opacity: 0.28 }) +
        el('rect', { x: X(i) - bw / 2, y: Y(s.diff * s.prac / 100), width: bw, height: Y(0) - Y(s.diff * s.prac / 100), rx: 4, fill: col }) +
        el('rect', { x: X(i) - step / 2, y: P.t, width: step, height: IH, fill: 'transparent' })));
      out.push(text(X(i), Y(s.diff) - 6, s.diff, { 'text-anchor': 'middle', fill: C.text, 'font-size': 11 }));
      out.push(text(X(i), P.t + IH + 14, s.id, { 'text-anchor': 'end', 'font-size': 11, fill: col, transform: `rotate(-40 ${X(i)} ${P.t + IH + 14})` }));
      out.push(text(X(i) + 4, P.t + IH + 28, s.short, { 'text-anchor': 'end', 'font-size': 10.5, transform: `rotate(-40 ${X(i) + 4} ${P.t + IH + 28})` }));
    });
    let lx = P.l + IW - 360;
    [[C.core, 'Triad-Core'], [C.full, 'Triad-Full'], [C.proj, 'progetto / riferimento']].forEach(([c, s]) => {
      out.push(el('rect', { x: lx, y: 17, width: 12, height: 12, rx: 3, fill: c }));
      out.push(text(lx + 18, 27, s, { fill: C.text, 'font-size': 11.5 }));
      lx += 30 + s.length * 6.6;
    });
    out.push(text(P.l + IW, H - 12, 'barra piena = quota esercitabile oggi · barra chiara = solo teoria', { 'text-anchor': 'end', 'font-size': 11 }));
    return el('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: `0 0 ${W} ${H}`, width: W, height: H, role: 'img',
      'aria-label': 'Difficoltà delle 17 fasi di apprendimento di Triad 2.0 e quota esercitabile oggi' }, out.join(''));
  }

  function render(id, kind, opts) {
    const node = document.getElementById(id);
    if (!node) return;
    node.innerHTML = kind === 'stages' ? stagesSVG() : curveSVG(opts);
    const svg = node.querySelector('svg');
    svg.removeAttribute('width'); svg.removeAttribute('height');
    svg.style.width = '100%'; svg.style.height = 'auto'; svg.style.display = 'block';
  }

  function renderTable(id) {
    const node = document.getElementById(id);
    if (!node) return;
    const rows = STAGES.map(s => `<tr><td><b>${s.id}</b> ${esc(s.name)}</td><td>${s.tut}</td><td>${s.man}</td>` +
      `<td>${s.diff}</td><td>${s.prac}%</td><td>${s.group === 'core' ? 'Core' : s.group === 'full' ? 'Full' : 'Progetto'}</td><td>${esc(s.note)}</td></tr>`).join('');
    node.innerHTML = `<table><thead><tr><th>Fase</th><th>Tutorial</th><th>Manuale</th><th>Difficoltà</th><th>Esercitabile</th><th>Profilo</th><th>Nota</th></tr></thead><tbody>${rows}</tbody></table>`;
  }

  const api = { STAGES, model, curveSVG, stagesSVG, render, renderTable };
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = api;
    if (require.main === module) process.stdout.write((process.argv[2] === 'stages' ? stagesSVG() : curveSVG()) + '\n');
  } else {
    root.TriadLearningCurve = api;
  }
})(this);
