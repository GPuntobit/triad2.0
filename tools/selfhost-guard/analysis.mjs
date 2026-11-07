// =====================================================================
//  analysis.mjs — analisi del programma Triad per le guardie statiche
//
//  L'AST e' quello del *riferimento JS* (seed/dev/triad_core.cjs), che
//  e' l'autorita' semantica di sviluppo: il guard non implementa un
//  secondo parser, ma riusa quello che gia' conosce il linguaggio.
//
//  L'analisi costruisce l'albero degli ambienti (scope) con i nomi
//  legati, e annota ogni lettura e ogni assegnazione con lo scope in
//  cui avvengono.  Le regole (rules.mjs) usano questa informazione
//  per le divergenze che riguardano i nomi:
//    - D1 scope dinamico (il callee vede i locali del chiamante),
//    - D2 cattura per valore delle chiusure,
//    - D20 scope dei corpi di blocco (if/while).
//
//  Nota sugli scope: il seed non crea un ambiente per i corpi di `if`
//  e `while` (misurato: un nome creato li dentro resta visibile fuori),
//  mentre `let` e `begin` lo fanno.  Da qui i tipi di scope distinti.
// =====================================================================

import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const { tokenize, Parser } = require('../../seed/dev/triad_core.cjs');

/** Scope: ambiente lessicale con i nomi legati. */
export class Scope {
  constructor(kind, parent, label) {
    this.kind = kind;            // file | func | lambda | block-if | block-while | block-let | block-begin
    this.parent = parent;
    this.label = label;
    this.names = new Set();
    this.children = [];
    if (parent) parent.children.push(this);
  }

  /** true se `other` e' questo scope o un suo discendente. */
  contains(other) {
    let s = other;
    while (s) {
      if (s === this) return true;
      s = s.parent;
    }
    return false;
  }

  /** scope della funzione (o lambda) che contiene questo scope. */
  functionScope() {
    let s = this;
    while (s) {
      if (s.kind === 'func' || s.kind === 'lambda') return s;
      s = s.parent;
    }
    return null;
  }
}

/** Parsa il sorgente con il parser del riferimento JS. */
export function parseTriad(src) {
  const parser = new Parser(tokenize(src));
  return parser.parseProgram();
}

/**
 * Analisi del programma.
 * Restituisce:
 *   ast, fileScope, globals:Set, functions:[], reads:[], assigns:[],
 *   nodes:[{node,scope,statementPosition}]
 */
export function analyzeProgram(ast) {
  const fileScope = new Scope('file', null, '<file>');
  const st = {
    ast,
    fileScope,
    globals: new Set(),
    functions: [],
    lambdas: [],
    reads: [],
    assigns: [],
    nodes: [],
    scopes: [fileScope],
  };

  function newScope(kind, parent, label) {
    const s = new Scope(kind, parent, label);
    st.scopes.push(s);
    return s;
  }

  function walkStmtList(stmts, scope, topIdx) {
    (stmts || []).forEach((s, i) => walkStmt(s, scope, topIdx === undefined ? i : topIdx));
  }

  function walkStmt(stmt, scope, topIdx) {
    if (!stmt) return;
    st.nodes.push({ node: stmt, scope, statementPosition: false, topIdx });
    switch (stmt.kind) {
      case 'funcdef': {
        const fscope = newScope('func', scope, stmt.name);
        for (const p of stmt.params) fscope.names.add(p);
        st.functions.push({
          name: stmt.name,
          scope: fscope,
          params: stmt.params.slice(),
          node: stmt,
          short: !!stmt.short,
          topIdx,
        });
        walkStmtList(stmt.body, fscope, topIdx);
        return;
      }
      case 'exprstmt': {
        walkExpr(stmt.expr, scope, { statementPosition: true }, topIdx);
        return;
      }
      case 'assign': {
        st.assigns.push({ name: stmt.name, scope });
        scope.names.add(stmt.name);
        walkExpr(stmt.value, scope, { statementPosition: false }, topIdx);
        return;
      }
      case 'indexassign': {
        walkExpr(stmt.target, scope, { statementPosition: false }, topIdx);
        walkExpr(stmt.index, scope, { statementPosition: false }, topIdx);
        walkExpr(stmt.value, scope, { statementPosition: false }, topIdx);
        return;
      }
      case 'return':
      case 'break':
      case 'continue': {
        if (stmt.expr) walkExpr(stmt.expr, scope, { statementPosition: false }, topIdx);
        return;
      }
      default: {
        walkExpr(stmt, scope, { statementPosition: false }, topIdx);
      }
    }
  }

  function walkExpr(node, scope, opts, topIdx) {
    if (!node || typeof node !== 'object') return;
    if (Array.isArray(node)) {
      for (const n of node) walkExpr(n, scope, opts, topIdx);
      return;
    }
    const statementPosition = !!(opts && opts.statementPosition);
    st.nodes.push({ node, scope, statementPosition, topIdx });

    switch (node.kind) {
      case 'var': {
        st.reads.push({ name: node.name, scope });
        return;
      }
      case 'assign': {
        st.assigns.push({ name: node.name, scope });
        scope.names.add(node.name);
        walkExpr(node.value, scope, { statementPosition: false }, topIdx);
        return;
      }
      case 'indexassign': {
        walkExpr(node.target, scope, { statementPosition: false }, topIdx);
        walkExpr(node.index, scope, { statementPosition: false }, topIdx);
        walkExpr(node.value, scope, { statementPosition: false }, topIdx);
        return;
      }
      case 'call': {
        walkExpr(node.callee, scope, { statementPosition: false }, topIdx);
        for (const a of node.args) walkExpr(a, scope, { statementPosition: false }, topIdx);
        return;
      }
      case 'index': {
        walkExpr(node.target, scope, { statementPosition: false }, topIdx);
        walkExpr(node.index, scope, { statementPosition: false }, topIdx);
        return;
      }
      case 'list': {
        for (const e of node.elements) walkExpr(e, scope, { statementPosition: false }, topIdx);
        return;
      }
      case 'binary': {
        walkExpr(node.left, scope, { statementPosition: false }, topIdx);
        walkExpr(node.right, scope, { statementPosition: false }, topIdx);
        return;
      }
      case 'unary': {
        walkExpr(node.operand, scope, { statementPosition: false }, topIdx);
        return;
      }
      case 'ternary': {
        walkExpr(node.cond, scope, { statementPosition: false }, topIdx);
        walkExpr(node.then, scope, { statementPosition: false }, topIdx);
        walkExpr(node.else, scope, { statementPosition: false }, topIdx);
        return;
      }
      case 'if': {
        walkExpr(node.cond, scope, { statementPosition: false }, topIdx);
        const thenScope = newScope('block-if', scope, 'if');
        walkStmtList(node.then, thenScope, topIdx);
        for (const ei of node.elseifs || []) {
          walkExpr(ei.cond, scope, { statementPosition: false }, topIdx);
          const eiScope = newScope('block-if', scope, 'elseif');
          walkStmtList(ei.body, eiScope, topIdx);
        }
        if (node.else) {
          const elseScope = newScope('block-if', scope, 'else');
          walkStmtList(node.else, elseScope, topIdx);
        }
        return;
      }
      case 'while': {
        walkExpr(node.cond, scope, { statementPosition: false }, topIdx);
        const bodyScope = newScope('block-while', scope, 'while');
        walkStmtList(node.body, bodyScope, topIdx);
        return;
      }
      case 'let': {
        const letScope = newScope('block-let', scope, 'let');
        for (const b of node.bindings || []) {
          walkExpr(b.value, scope, { statementPosition: false }, topIdx);
          letScope.names.add(b.name);
        }
        walkStmtList(node.body, letScope, topIdx);
        return;
      }
      case 'begin': {
        const beginScope = newScope('block-begin', scope, 'begin');
        walkStmtList(node.body, beginScope, topIdx);
        return;
      }
      case 'lambda': {
        const lscope = newScope('lambda', scope, node.params.join(','));
        for (const p of node.params) lscope.names.add(p);
        st.lambdas.push({ scope: lscope, params: node.params.slice(), node });
        if (Array.isArray(node.body)) walkStmtList(node.body, lscope, topIdx);
        else walkExpr(node.body, lscope, { statementPosition: false }, topIdx);
        return;
      }
      default: {
        return;
      }
    }
  }

  walkStmtList(ast.stmts, fileScope);
  for (const n of st.assigns) {
    if (n.scope === fileScope) st.globals.add(n.name);
  }
  return st;
}

/**
 * Nomi locali di una funzione *secondo il seed*: i parametri e le
 * assegnazioni che finiscono nel suo frame.  Nel seed i corpi di `if` e
 * `while` non creano un ambiente: un nome assegnato li dentro resta nel
 * frame della funzione (misurato), quindi conta come locale.
 */
export function seedLocalsOf(fnScope) {
  const names = new Set(fnScope.names);
  const stack = [...fnScope.children];
  while (stack.length) {
    const s = stack.pop();
    if (s.kind === 'func' || s.kind === 'lambda') continue;   // funzione annidata: frame proprio
    if (s.kind === 'block-if' || s.kind === 'block-while') {
      for (const n of s.names) names.add(n);
    }
    stack.push(...s.children);
  }
  return names;
}

/**
 * Scope in cui il nome e' legato, oppure null se il nome e' *libero*
 * (nel riferimento JS una lettura libera e' un errore: "undefined
 * variable").  E' la nozione su cui poggia la regola D20: nel seed il
 * nome che "esce" da un corpo di blocco resterebbe legato (il seed non
 * crea l'ambiente), mentre nel riferimento JS la lettura sarebbe libera.
 */
export function boundIn(scope, name) {
  let s = scope;
  while (s) {
    if (s.names.has(name)) return s;
    s = s.parent;
  }
  return null;
}

/** true se l'espressione e' dimostrabilmente una stringa. */
export function isStringExpr(node) {
  if (!node) return false;
  switch (node.kind) {
    case 'str': return true;
    case 'binary':
      if (node.op !== '+') return false;
      return isStringExpr(node.left) || isStringExpr(node.right);
    default: return false;
  }
}

/** true se l'espressione e' dimostrabilmente un Bool. */
export function isBoolExpr(node) {
  if (!node) return false;
  switch (node.kind) {
    case 'bool': return true;
    case 'binary': {
      if (['==', '!=', '<', '<=', '>', '>='].includes(node.op)) return true;
      if (node.op === '&&' || node.op === '||') {
        return isBoolExpr(node.left) && isBoolExpr(node.right);
      }
      return false;
    }
    case 'unary': return node.op === '!' && isBoolExpr(node.operand);
    case 'ternary': {
      return isBoolExpr(node.cond) && isBoolExpr(node.then) && isBoolExpr(node.else);
    }
    default: return false;
  }
}
