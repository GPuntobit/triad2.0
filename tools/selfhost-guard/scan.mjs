// =====================================================================
//  scan.mjs — scanner grezzo del sorgente Triad
//
//  Non e' un parser: produce i token grezzi (identificatori, letterali,
//  numeri, operatori) con la riga, piu' i dati che l'AST non porta:
//  il testo *grezzo* dei letterali (escape, keyword cieche) e l'ultimo
//  token di codice di ogni riga (per la regola sul newline).
//
//  Le keyword "ciechi" sono quelle che il contatore di annidamento del
//  seed conta confrontando i byte grezzi del sorgente: incrementano la
//  profondita' senza una corrispondente "end".  Misurato sul seed:
//  dentro un corpo di blocco, un identificatore o un letterale che
//  contiene "if", "let", "while" o "function" rompe l'annidamento
//  (exit 1); "end" e "else" decrementano la profondita' e spostano la
//  fine del blocco (errore o semantica spostata).
// =====================================================================

/** Keyword che il seed conta in modo cieco (incrementano la profondita'). */
export const BLIND_UP = ['if', 'let', 'while', 'function'];
/** Keyword ciechi che decrementano la profondita' (spostano la fine blocco). */
export const BLIND_DOWN = ['end', 'else'];

/** Keyword Core ammessi come tali (identificatori esatti). */
export const KEYWORDS = new Set([
  'if', 'else', 'elseif', 'while', 'let', 'begin', 'end', 'function',
  'break', 'continue', 'return', 'true', 'false', 'nothing',
]);

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

/** True se l'identificatore contiene una keyword cieca del seed. */
export function blindKeywordIn(ident) {
  for (const kw of BLIND_UP) {
    if (ident.includes(kw)) return kw;
  }
  return null;
}

/** True se l'identificatore contiene una keyword cieca che decrementa. */
export function blindDownKeywordIn(ident) {
  for (const kw of BLIND_DOWN) {
    if (ident.includes(kw)) return kw;
  }
  return null;
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

/**
 * Intervalli di sorgente dei corpi dei blocchi (`if`, `while`, `let`,
 * `begin`, `function ... end`): [inizio, fine] come offset nel sorgente.
 *
 * Serve alla regola D22: il contatore di annidamento del seed e' cieco al
 * contesto *dentro un corpo di blocco* (livelello di programma non conta
 * le keyword: li confronta solo per decidere se un blocco finisce li').
 */
export function blockRanges(tokens) {
  const ranges = [];
  const stack = [];
  for (const t of tokens) {
    if (t.type !== 'ident') continue;
    const v = t.value;
    if (v === 'if' || v === 'while' || v === 'let' || v === 'begin' || v === 'function') {
      stack.push({ start: t.pos + v.length, label: v });
    } else if (v === 'end') {
      const b = stack.pop();
      if (b) ranges.push({ start: b.start, end: t.pos, label: b.label });
    }
  }
  return ranges;
}

/** true se l'offset e' dentro uno dei corpi di blocco. */
export function insideBlock(ranges, offset) {
  for (const r of ranges) {
    if (offset >= r.start && offset < r.end) return r;
  }
  return null;
}
