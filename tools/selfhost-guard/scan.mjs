// =====================================================================
//  scan.mjs — scanner grezzo del sorgente Triad
//
//  Non e' un parser: produce i token grezzi (identificatori, letterali,
//  numeri, operatori) con la riga, piu' i dati che l'AST non porta:
//  il testo *grezzo* dei letterali (escape) e l'ultimo token di codice
//  di ogni riga (per la regola sul newline).
//
//  Nota storica: il seed contava le parole chiave confrontando i byte
//  grezzi del sorgente, quindi un identificatore che inizia con una
//  keyword o un letterale che contiene "if" rompevano l'annidamento dei
//  blocchi (divergenza D22).  Il seed e' stato corretto (2026-11-09):
//  le keyword sono token *esatti* e il testo di un letterale non conta.
//  Le helper che servivano a presidiare D22 sono state rimosse.
// =====================================================================

const TWO_CHAR_OPS = new Set(['==', '!=', '<=', '>=', '&&', '||', '+=', '-=', '*=', '->']);
const ONE_CHAR_OPS = new Set('+-*/%^=<>!&|?:');

/**
 * Scanner del sorgente Triad.
 * Restituisce { tokens, strings, errors } dove:
 *  - tokens: [{type,value,line,raw}]  type in ident|string|number|op|punct
 *  - strings: [{line,raw,value,hasEscape}]  value = contenuto *grezzo*
 *  - errors: [{line,msg}]
 */
export function scanSource(src) {
  const tokens = [];
  const strings = [];
  const errors = [];
  let i = 0;
  let line = 1;
  const n = src.length;
  while (i < n) {
    const c = src[i];
    if (c === '\n') { line++; i++; continue; }
    if (c === ' ' || c === '\t' || c === '\r' || c === '\f' || c === '\v') { i++; continue; }
    if (c === ';') { i++; continue; }
    if (c === '#') {
      if (src.startsWith('#=', i)) {
        const end = src.indexOf('=#', i + 2);
        if (end < 0) { errors.push({ line, msg: 'commento di blocco #= non chiuso' }); break; }
        for (const ch of src.slice(i, end)) if (ch === '\n') line++;
        i = end + 2;
      } else {
        while (i < n && src[i] !== '\n') i++;
      }
      continue;
    }
    if (c === '"') {
      const startLine = line;
      let j = i + 1;
      let raw = '';
      let closed = false;
      let hasEscape = false;
      while (j < n) {
        if (src[j] === '\\') {
          hasEscape = true;
          raw += src[j] + (src[j + 1] ?? '');
          j += 2;
          continue;
        }
        if (src[j] === '"') { closed = true; j++; break; }
        if (src[j] === '\n') line++;
        raw += src[j++];
      }
      if (!closed) errors.push({ line: startLine, msg: 'stringa non chiusa' });
      const tok = { type: 'string', value: raw, line: startLine, raw: src.slice(i, j), pos: i };
      tokens.push(tok);
      strings.push({ line: startLine, raw, hasEscape, pos: i });
      i = j;
      continue;
    }
    if (/[0-9]/.test(c)) {
      let j = i;
      while (j < n && /[0-9_]/.test(src[j])) j++;
      tokens.push({ type: 'number', value: src.slice(i, j), line, raw: src.slice(i, j) });
      i = j;
      continue;
    }
    if (/[A-Za-z_]/.test(c)) {
      let j = i;
      while (j < n && /[A-Za-z0-9_]/.test(src[j])) j++;
      if (src[j] === '!' && src[j + 1] !== '=') j++;
      const value = src.slice(i, j);
      tokens.push({ type: 'ident', value, line, raw: value, pos: i });
      i = j;
      continue;
    }
    const two = src.slice(i, i + 2);
    if (TWO_CHAR_OPS.has(two)) {
      tokens.push({ type: 'op', value: two, line, raw: two });
      i += 2;
      continue;
    }
    if (ONE_CHAR_OPS.has(c)) {
      tokens.push({ type: 'op', value: c, line, raw: c });
      i++;
      continue;
    }
    tokens.push({ type: 'punct', value: c, line, raw: c });
    i++;
  }
  return { tokens, strings, errors };
}

/**
 * Ultimo token di codice di ogni riga fisica (serve alla regola sul
 * newline: una riga che finisce con un operatore binario fa proseguire
 * l'espressione nel seed, mentre SPEC-CORE.md §2 fa del newline un
 * separatore).
 * Restituisce Map<linea, token>.
 */
export function lastCodeTokenPerLine(tokens) {
  const last = new Map();
  for (const t of tokens) {
    if (t.type === 'string') { last.set(t.line, t); continue; }
    last.set(t.line, t);
  }
  return last;
}

/** Operatori binari (il seed continua l'espressione dopo questi). */
export const BINARY_OPS = new Set([
  '+', '-', '*', '%', '^', '==', '!=', '<', '<=', '>', '>=', '&&', '||',
]);
