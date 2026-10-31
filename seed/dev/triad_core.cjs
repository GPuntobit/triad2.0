'use strict';
// fs is used only in CLI mode (Node); in the browser the `fs` shim avoids
// a failing require that would never be invoked anyway.
const fs = (typeof require === 'function') ? require('fs') : { readFileSync() { throw new Error('fs not available'); } };
// ---------- Value helpers ----------
const NOTHING = {t:'nothing'};
const BUILTIN_NAMES = new Set(['print','println','length','push!','Int','string','Symbol','typeof','readfile','strlen','strbyte','strsub','exit']);
function I(v){return {t:'int',v:BigInt(v)};}
function B(v){return {t:'bool',v:!!v};}
function S(v){return {t:'str',v:String(v)};}
function Y(v){return {t:'sym',v:String(v)};}
function L(v){return {t:'list',v:v};}
function F(params,body,env,isLambda){return {t:'func',params,body,env,isLambda:!!isLambda};}

const MASK64 = (1n<<64n)-1n;
function toSigned64(x){
  x = x & MASK64;
  if (x >= (1n<<63n)) x -= (1n<<64n);
  return x;
}
function wrap(x){return toSigned64(x);}

// ---------- Tokenizer ----------
function tokenize(src){
  const toks = [];
  let i = 0;
  const n = src.length;
  while (i < n) {
    const c = src[i];
    if (c === '\n' || c === '\r') {
      if (c === '\r' && src[i+1] === '\n') i++;
      toks.push({type:'SEP'});
      i++;
      continue;
    }
    if (c === ' ' || c === '\t' || c === '\f' || c === '\v') { i++; continue; }
    if (c === ';') { toks.push({type:'SEP'}); i++; continue; }
    if (c === '#') {
      if (src[i+1] === '=') {
        let j = src.indexOf('=#', i+2);
        if (j === -1) { i = n; continue; }
        i = j + 2;
        continue;
      } else {
        while (i < n && src[i] !== '\n') i++;
        continue;
      }
    }
    if (c === '"') {
      let j = i+1;
      let out = '';
      while (j < n && src[j] !== '"') {
        if (src[j] === '\\') {
          const e = src[j+1];
          if (e === 'n') { out += '\n'; j += 2; }
          else if (e === 't') { out += '\t'; j += 2; }
          else if (e === '"') { out += '"'; j += 2; }
          else if (e === '\\') { out += '\\'; j += 2; }
          else { out += src[j]; j++; }
        } else {
          out += src[j]; j++;
        }
      }
      toks.push({type:'STR', value: out});
      i = j + 1;
      continue;
    }
    if (/[0-9]/.test(c)) {
      let j = i;
      let num = '';
      while (j < n && /[0-9_]/.test(src[j])) { if (src[j] !== '_') num += src[j]; j++; }
      toks.push({type:'NUM', value: num});
      i = j;
      continue;
    }
    if (c === ':') {
      const next = src[i+1];
      if (next && /[A-Za-z_0-9!+\-*/%&|^<>=?]/.test(next)) {
        let j = i+1;
        if (/[A-Za-z_]/.test(next)) {
          while (j < n && /[A-Za-z0-9_]/.test(src[j])) j++;
          if (src[j] === '!') j++;
        } else {
          while (j < n && /[+\-*/%&|^<>=!?]/.test(src[j])) j++;
        }
        toks.push({type:'SYM', value: src.slice(i+1, j)});
        i = j;
        continue;
      }
      toks.push({type:'COLON'});
      i++;
      continue;
    }
    if (/[A-Za-z_]/.test(c)) {
      let j = i;
      while (j < n && /[A-Za-z0-9_]/.test(src[j])) j++;
      if (src[j] === '!') { j++; }
      toks.push({type:'IDENT', value: src.slice(i, j)});
      i = j;
      continue;
    }
    const two = src.slice(i, i+2);
    const twoOps = ['==','!=','<=','>=','&&','||','+=','-=','*=','->'];
    if (twoOps.includes(two)) {
      toks.push({type:'OP', value: two});
      i += 2;
      continue;
    }
    if (c === '?') { toks.push({type:'QMARK'}); i++; continue; }
    if (c === ':') { toks.push({type:'COLON'}); i++; continue; }
    if ('+-*/%&|^<>=!'.includes(c)) {
      toks.push({type:'OP', value: c});
      i++;
      continue;
    }
    if (c === '(') { toks.push({type:'LPAREN'}); i++; continue; }
    if (c === ')') { toks.push({type:'RPAREN'}); i++; continue; }
    if (c === '[') { toks.push({type:'LBRACKET'}); i++; continue; }
    if (c === ']') { toks.push({type:'RBRACKET'}); i++; continue; }
    if (c === ',') { toks.push({type:'COMMA'}); i++; continue; }
    if (c === '?') { toks.push({type:'QMARK'}); i++; continue; }
    if (c === ':') { toks.push({type:'COLON'}); i++; continue; }
    i++;
  }
  toks.push({type:'EOF'});
  return toks;
}

// ---------- Parser ----------
class Parser {
  constructor(tokens){ this.toks = tokens; this.pos = 0; }
  peek(){ return this.toks[this.pos]; }
  advance(){ return this.toks[this.pos++]; }
  match(type, value){
    const t = this.peek();
    if (t.type === type && (value === undefined || t.value === value)) { this.pos++; return t; }
    return null;
  }
  expect(type, value){
    const t = this.match(type, value);
    if (!t) throw new Error('expected ' + type + ' ' + (value||''));
    return t;
  }
  skipSep(){ while (this.peek().type === 'SEP') this.pos++; }
  parseProgram(){
    this.skipSep();
    const stmts = [];
    while (this.peek().type !== 'EOF') {
      stmts.push(this.parseStmt());
      this.skipSep();
    }
    return {kind:'program', stmts};
  }
  parseStmt(){
    this.skipSep();
    if (this.peek().type === 'IDENT' && this.peek().value === 'return') {
      this.advance();
      if (this.peek().type === 'SEP' || this.peek().type === 'EOF' || this.peek().type === 'RPAREN' || this.peek().type === 'RBRACKET' || this.peek().value === 'end' || this.peek().value === 'else' || this.peek().value === 'elseif') {
        return {kind:'return', expr: null};
      }
      const e = this.parseExpr();
      return {kind:'return', expr: e};
    }
    if (this.peek().type === 'IDENT' && this.peek().value === 'break') { this.advance(); return {kind:'break'}; }
    if (this.peek().type === 'IDENT' && this.peek().value === 'continue') { this.advance(); return {kind:'continue'}; }
    if (this.peek().type === 'IDENT' && this.peek().value === 'function' && this.toks[this.pos+1] && this.toks[this.pos+1].type === 'IDENT' && this.toks[this.pos+2] && this.toks[this.pos+2].type === 'LPAREN') {
      this.advance();
      const name = this.expect('IDENT').value;
      this.expect('LPAREN');
      const params = this.parseParams();
      this.expect('RPAREN');
      while (this.peek().type === 'OP' && this.peek().value === '!') {
        this.advance();
        if (this.peek().type === 'IDENT') this.advance();
      }
      this.skipSep();
      const body = this.parseBlock(['end']);
      this.expect('IDENT', 'end');
      return {kind:'funcdef', name, params, body};
    }
    if (this.peek().type === 'IDENT' && this.toks[this.pos+1] && this.toks[this.pos+1].type === 'LPAREN') {
      let j = this.pos + 1;
      let depth = 0;
      while (j < this.toks.length) {
        if (this.toks[j].type === 'LPAREN') depth++;
        else if (this.toks[j].type === 'RPAREN') { depth--; if (depth === 0) { j++; break; } }
        j++;
      }
      while (j < this.toks.length && this.toks[j].type === 'SEP') j++;
      if (j < this.toks.length && this.toks[j].type === 'OP' && this.toks[j].value === '=') {
        const name = this.advance().value;
        this.expect('LPAREN');
        const params = this.parseParams();
        this.expect('RPAREN');
        this.expect('OP', '=');
        const expr = this.parseExpr();
        return {kind:'funcdef', name, params, body: [ {kind:'return', expr} ] , short: true};
      }
    }
    const e = this.parseExpr();
    return {kind:'exprstmt', expr: e};
  }
  parseParams(){
    const params = [];
    if (this.peek().type === 'RPAREN') return params;
    params.push(this.expect('IDENT').value);
    while (this.match('COMMA')) {
      params.push(this.expect('IDENT').value);
    }
    return params;
  }
  parseBlock(terminators){
    const stmts = [];
    this.skipSep();
    while (true) {
      if (this.peek().type === 'EOF') break;
      if (this.peek().type === 'IDENT' && (this.peek().value === 'end' || this.peek().value === 'else' || this.peek().value === 'elseif')) break;
      stmts.push(this.parseStmt());
      this.skipSep();
    }
    return stmts;
  }
  parseExpr(){ return this.parseAssign(); }
  parseAssign(){
    const left = this.parseTernary();
    if (left.kind === 'var' && this.peek().type === 'OP' && (this.peek().value === '=' || this.peek().value === '+=' || this.peek().value === '-=' || this.peek().value === '*=')) {
      const op = this.advance().value;
      const val = this.parseAssign();
      return {kind:'assign', name: left.name, op, value: val};
    }
    if (left.kind === 'index' && this.peek().type === 'OP' && (this.peek().value === '=' || this.peek().value === '+=' || this.peek().value === '-=' || this.peek().value === '*=')) {
      const op = this.advance().value;
      const val = this.parseAssign();
      return {kind:'indexassign', target: left.target, index: left.index, op, value: val};
    }
    return left;
  }
}

// parser expr methods
// We'll add methods via prototype? Instead make them methods inside class impossible now. 
// We'll instead wrap: reopen class? Can't. So we'll convert approach: implement parse methods on Parser.prototype.
Parser.prototype.parseTernary = function(){
  const cond = this.parseOr();
  if (this.peek().type === 'QMARK') {
    this.advance();
    const then = this.parseExpr();
    this.expect('COLON');
    const els = this.parseExpr();
    return {kind:'ternary', cond, then, else: els};
  }
  return cond;
};
Parser.prototype.parseOr = function(){
  let left = this.parseAnd();
  while (this.peek().type === 'OP' && this.peek().value === '||') {
    this.advance();
    const right = this.parseAnd();
    left = {kind:'binary', op:'||', left, right};
  }
  return left;
};
Parser.prototype.parseAnd = function(){
  let left = this.parseCmp();
  while (this.peek().type === 'OP' && this.peek().value === '&&') {
    this.advance();
    const right = this.parseCmp();
    left = {kind:'binary', op:'&&', left, right};
  }
  return left;
};
Parser.prototype.parseCmp = function(){
  let left = this.parseSum();
  while (this.peek().type === 'OP' && ['==','!=','<','<=','>','>='].includes(this.peek().value)) {
    const op = this.advance().value;
    const right = this.parseSum();
    left = {kind:'binary', op, left, right};
  }
  return left;
};
Parser.prototype.parseSum = function(){
  let left = this.parseMul();
  while (this.peek().type === 'OP' && (this.peek().value === '+' || this.peek().value === '-')) {
    const op = this.advance().value;
    const right = this.parseMul();
    left = {kind:'binary', op, left, right};
  }
  return left;
};
Parser.prototype.parseMul = function(){
  let left = this.parsePow();
  while (this.peek().type === 'OP' && (this.peek().value === '*' || this.peek().value === '%')) {
    const op = this.advance().value;
    const right = this.parsePow();
    left = {kind:'binary', op, left, right};
  }
  return left;
};
Parser.prototype.parsePow = function(){
  const base = this.parseUnary();
  if (this.peek().type === 'OP' && this.peek().value === '^') {
    this.advance();
    const exp = this.parsePow();
    return {kind:'binary', op:'^', left: base, right: exp};
  }
  return base;
};
Parser.prototype.parseUnary = function(){
  if (this.peek().type === 'OP' && (this.peek().value === '-' || this.peek().value === '!')) {
    const op = this.advance().value;
    const operand = this.parseUnary();
    return {kind:'unary', op, operand};
  }
  return this.parsePostfix();
};
Parser.prototype.parsePostfix = function(){
  let node = this.parsePrimary();
  while (true) {
    if (this.peek().type === 'LPAREN') {
      this.advance();
      const args = this.parseArgs();
      this.expect('RPAREN');
      node = {kind:'call', callee: node, args};
    } else if (this.peek().type === 'LBRACKET') {
      this.advance();
      const idx = this.parseExpr();
      this.expect('RBRACKET');
      node = {kind:'index', target: node, index: idx};
    } else break;
  }
  return node;
};
Parser.prototype.parseArgs = function(){
  const args = [];
  if (this.peek().type === 'RPAREN') return args;
  args.push(this.parseExpr());
  while (this.match('COMMA')) args.push(this.parseExpr());
  return args;
};

Parser.prototype.parsePrimary = function(){
  const t = this.peek();
  if (t.type === 'NUM') { this.advance(); return {kind:'num', value: t.value}; }
  if (t.type === 'STR') { this.advance(); return {kind:'str', value: t.value}; }
  if (t.type === 'SYM') { this.advance(); return {kind:'sym', value: t.value}; }
  if (t.type === 'IDENT' && (t.value === 'true' || t.value === 'false')) { this.advance(); return {kind:'bool', value: t.value === 'true'}; }
  if (t.type === 'IDENT' && t.value === 'nothing') { this.advance(); return {kind:'nothing'}; }
  if (t.type === 'LPAREN') {
    this.advance();
    // lambda?
    if (this.peek().type === 'IDENT') {
      const saved = this.pos;
      const params = [];
      let ok = true;
      try {
        params.push(this.expect('IDENT').value);
        while (this.match('COMMA')) params.push(this.expect('IDENT').value);
        this.expect('RPAREN');
        if (this.peek().type === 'OP' && this.peek().value === '->') {
          this.advance();
          const body = this.parseExpr();
          return {kind:'lambda', params, body: body};
        }
      } catch(e) { ok = false; }
      this.pos = saved;
    }
    const e = this.parseExpr();
    this.expect('RPAREN');
    return e;
  }
  if (t.type === 'LBRACKET') {
    this.advance();
    const elems = [];
    if (this.peek().type !== 'RBRACKET') {
      elems.push(this.parseExpr());
      while (this.match('COMMA')) elems.push(this.parseExpr());
    }
    this.expect('RBRACKET');
    return {kind:'list', elements: elems};
  }
  if (t.type === 'IDENT' && t.value === 'if') {
    this.advance();
    const cond = this.parseExpr();
    this.skipSep();
    const thenb = this.parseBlock(['elseif','else','end']);
    const elseifs = [];
    while (this.peek().type === 'IDENT' && this.peek().value === 'elseif') {
      this.advance();
      const c = this.parseExpr();
      this.skipSep();
      const b = this.parseBlock(['elseif','else','end']);
      elseifs.push({cond: c, body: b});
    }
    let elseb = null;
    if (this.peek().type === 'IDENT' && this.peek().value === 'else') {
      this.advance();
      this.skipSep();
      elseb = this.parseBlock(['end']);
    }
    this.expect('IDENT', 'end');
    return {kind:'if', cond, then: thenb, elseifs, else: elseb};
  }
  if (t.type === 'IDENT' && t.value === 'while') {
    this.advance();
    const cond = this.parseExpr();
    this.skipSep();
    const body = this.parseBlock(['end']);
    this.expect('IDENT', 'end');
    return {kind:'while', cond, body};
  }
  if (t.type === 'IDENT' && t.value === 'let') {
    this.advance();
    const bindings = [];
    if (this.peek().type === 'IDENT' && this.toks[this.pos+1] && this.toks[this.pos+1].type === 'OP' && this.toks[this.pos+1].value === '=') {
      while (true) {
        const name = this.expect('IDENT').value;
        this.expect('OP', '=');
        const val = this.parseExpr();
        bindings.push({name, value: val});
        if (!this.match('COMMA')) break;
      }
    }
    this.skipSep();
    const body = this.parseBlock(['end']);
    this.expect('IDENT', 'end');
    return {kind:'let', bindings, body};
  }
  if (t.type === 'IDENT' && t.value === 'begin') {
    this.advance();
    this.skipSep();
    const body = this.parseBlock(['end']);
    this.expect('IDENT', 'end');
    return {kind:'begin', body};
  }
  if (t.type === 'IDENT' && t.value === 'function') {
    this.advance();
    this.expect('LPAREN');
    const params = this.parseParams();
    this.expect('RPAREN');
    while (this.peek().type === 'OP' && this.peek().value === '!') {
      this.advance();
      if (this.peek().type === 'IDENT') this.advance();
    }
    this.skipSep();
    const body = this.parseBlock(['end']);
    this.expect('IDENT', 'end');
    return {kind:'lambda', params, body: body, block: true};
  }
  if (t.type === 'IDENT' && this.toks[this.pos+1] && this.toks[this.pos+1].type === 'OP' && this.toks[this.pos+1].value === '->') {
    const param = t.value;
    this.advance();
    this.advance();
    const body = this.parseExpr();
    return {kind:'lambda', params:[param], body};
  }
  if (t.type === 'IDENT') { this.advance(); return {kind:'var', name: t.value}; }
  throw new Error('unexpected token ' + JSON.stringify(t));
};

// ---------- Environment ----------
function makeFrame(parent, owner, isLambda){
  return {bindings: new Map(), parent, owner: owner===undefined?null:owner, isLambda: !!isLambda};
}
function lookup(env, name){
  let cur = env;
  while (cur) {
    if (cur.bindings.has(name)) return cur.bindings.get(name);
    cur = cur.parent;
  }
  return undefined;
}
function currentOwner(env){
  let cur = env;
  while (cur) {
    if (cur.owner !== null || cur.owner === null) {
      // owner may be null for global; return marker object? use cur itself as global owner
    }
    // We'll store owner as frame for global? Instead use a symbol: global owner = null.
    break;
  }
  // walk until a frame with defined ownerProperty
  let c = env;
  while (c) {
    if (Object.prototype.hasOwnProperty.call(c, 'owner')) return c.owner;
    c = c.parent;
  }
  return null;
}
function isLambdaFrame(env){
  let c = env;
  while (c) {
    if (Object.prototype.hasOwnProperty.call(c, 'owner')) return !!c.isLambda;
    c = c.parent;
  }
  return false;
}

// ---------- Evaluation ----------
class ReturnSignal { constructor(v){ this.v = v; } }
class BreakSignal {}
class ContinueSignal {}

function evalBlock(stmts, env){
  let last = NOTHING;
  for (const s of stmts) {
    last = evalStmt(s, env);
  }
  return last;
}
function evalStmt(stmt, env){
  switch (stmt.kind) {
    case 'funcdef': {
      const f = F(stmt.params, stmt.body, env, false);
      f.name = stmt.name;
      env.bindings.set(stmt.name, f);
      return f;
    }
    case 'return': {
      const v = stmt.expr ? evalExpr(stmt.expr, env) : NOTHING;
      throw new ReturnSignal(v);
    }
    case 'break': throw new BreakSignal();
    case 'continue': throw new ContinueSignal();
    case 'exprstmt': return evalExpr(stmt.expr, env);
  }
  return NOTHING;
}

function evalExpr(node, env){
  switch (node.kind) {
    case 'num': return I(node.value);
    case 'str': return S(node.value);
    case 'sym': return Y(node.value);
    case 'bool': return B(node.value);
    case 'nothing': return NOTHING;
    case 'var': {
      if (BUILTIN_NAMES.has(node.name)) return {t:'builtin', name: node.name};
      const v = lookup(env, node.name);
      if (v === undefined) throw new Error('undefined variable ' + node.name);
      return v;
    }
    case 'list': {
      const elems = node.elements.map(e => evalExpr(e, env));
      return L(elems);
    }
    case 'lambda': {
      const body = Array.isArray(node.body) ? node.body : [ {kind:'return', expr: node.body} ];
      return F(node.params, body, env, true);
    }
    case 'assign': {
      const val = evalExpr(node.value, env);
      let finalVal = val;
      if (node.op !== '=') {
        const cur = lookup(env, node.name);
        if (cur === undefined) throw new Error('undefined variable ' + node.name);
        const a = cur, b = val;
        let res;
        if (node.op === '+=') {
          if (a.t === 'int' && b.t === 'int') res = I(wrap(a.v + b.v));
          else if (a.t === 'str' && b.t === 'str') res = S(a.v + b.v);
          else if (a.t === 'list' && b.t === 'list') { res = L(a.v.concat(b.v)); }
          else throw new Error('+= type error');
        } else if (node.op === '-=') {
          if (a.t === 'int' && b.t === 'int') res = I(wrap(a.v - b.v));
          else throw new Error('-= type error');
        } else if (node.op === '*=') {
          if (a.t === 'int' && b.t === 'int') res = I(wrap(a.v * b.v));
          else throw new Error('*= type error');
        }
        finalVal = res;
      }
      writeVar(node.name, finalVal, env);
      return finalVal;
    }
    case 'indexassign': {
      const target = evalExpr(node.target, env);
      const idx = evalExpr(node.index, env);
      const val = evalExpr(node.value, env);
      if (target.t !== 'list') throw new Error('index target not list');
      if (idx.t !== 'int') throw new Error('index not int');
      const i = Number(idx.v);
      if (i < 1 || i > target.v.length) throw new Error('index out of range');
      let finalVal = val;
      if (node.op !== '=') {
        const cur = target.v[i-1];
        const a = cur, b = val;
        let res;
        if (node.op === '+=') {
          if (a.t === 'int' && b.t === 'int') res = I(wrap(a.v + b.v));
          else if (a.t === 'str' && b.t === 'str') res = S(a.v + b.v);
          else if (a.t === 'list' && b.t === 'list') { res = L(a.v.concat(b.v)); }
          else throw new Error('+= type error');
        } else if (node.op === '-=') {
          if (a.t === 'int' && b.t === 'int') res = I(wrap(a.v - b.v));
          else throw new Error('-= type error');
        } else if (node.op === '*=') {
          if (a.t === 'int' && b.t === 'int') res = I(wrap(a.v * b.v));
          else throw new Error('*= type error');
        }
        finalVal = res;
      }
      target.v[i-1] = finalVal;
      return finalVal;
    }
    default: return evalExprBinary(node, env);
  }
}
function evalExprBinary(node, env){
  if (node.kind !== 'binary') return evalExprRest(node, env);
  const op = node.op;
  if (op === '&&') {
    const l = evalExpr(node.left, env);
    if (l.t !== 'bool') throw new Error('&& expects bool');
    if (!l.v) return B(false);
    const r = evalExpr(node.right, env);
    if (r.t !== 'bool') throw new Error('&& expects bool');
    return B(r.v);
  }
  if (op === '||') {
    const l = evalExpr(node.left, env);
    if (l.t !== 'bool') throw new Error('|| expects bool');
    if (l.v) return B(true);
    const r = evalExpr(node.right, env);
    if (r.t !== 'bool') throw new Error('|| expects bool');
    return B(r.v);
  }
  const l = evalExpr(node.left, env);
  const r = evalExpr(node.right, env);
  switch (op) {
    case '+':
      if (l.t==='int' && r.t==='int') return I(wrap(l.v + r.v));
      throw new Error('+ type error');
    case '-':
      if (l.t==='int' && r.t==='int') return I(wrap(l.v - r.v));
      throw new Error('- type error');
    case '*':
      if (l.t==='int' && r.t==='int') return I(wrap(l.v * r.v));
      if (l.t==='str' && r.t==='str') return S(l.v + r.v);
      throw new Error('* type error');
    case '%':
      if (l.t==='int' && r.t==='int') {
        if (r.v === 0n) throw new Error('div by zero');
        return I(wrap(l.v % r.v));
      }
      throw new Error('% type error');
    case '^':
      if (l.t==='int' && r.t==='int') {
        let base = l.v, exp = r.v;
        if (exp < 0n) throw new Error('negative exponent');
        let res = 1n;
        let b = base;
        let e = exp;
        while (e > 0n) {
          if (e & 1n) res = wrap(res * b);
          b = wrap(b * b);
          e >>= 1n;
        }
        return I(res);
      }
      throw new Error('^ type error');
    case '==': return B(equals(l,r));
    case '!=': return B(!equals(l,r));
    case '<':
      if (l.t==='int' && r.t==='int') return B(l.v < r.v);
      if (l.t==='str' && r.t==='str') return B(l.v < r.v);
      throw new Error('< type error');
    case '<=':
      if (l.t==='int' && r.t==='int') return B(l.v <= r.v);
      throw new Error('<= type error');
    case '>':
      if (l.t==='int' && r.t==='int') return B(l.v > r.v);
      throw new Error('> type error');
    case '>=':
      if (l.t==='int' && r.t==='int') return B(l.v >= r.v);
      throw new Error('>= type error');
  }
  throw new Error('unknown op ' + op);
}

function evalExprRest(node, env){
  switch (node.kind) {
    case 'unary': {
      const v = evalExpr(node.operand, env);
      if (node.op === '-') {
        if (v.t !== 'int') throw new Error('unary -');
        return I(wrap(-v.v));
      }
      if (node.op === '!') {
        if (v.t !== 'bool') throw new Error('!');
        return B(!v.v);
      }
      throw new Error('unknown unary');
    }
    case 'ternary': {
      const c = evalExpr(node.cond, env);
      if (c.t !== 'bool') throw new Error('ternary cond');
      if (c.v) return evalExpr(node.then, env);
      return evalExpr(node.else, env);
    }
    case 'call': {
      const callee = evalExpr(node.callee, env);
      const args = node.args.map(a => evalExpr(a, env));
      if (callee.t === 'func') {
        const f = callee;
        if (args.length !== f.params.length) throw new Error('arity mismatch');
        const frame = makeFrame(f.env, f, f.isLambda);
        frame.owner = f;
        frame.isLambda = f.isLambda;
        for (let i = 0; i < f.params.length; i++) frame.bindings.set(f.params[i], args[i]);
        try {
          let last = NOTHING;
          for (const s of f.body) {
            last = evalStmt(s, frame);
          }
          return last;
        } catch (e) {
          if (e instanceof ReturnSignal) return e.v;
          throw e;
        }
      }
      if (callee.t === 'builtin') return callBuiltin(callee.name, args, env);
      throw new Error('not a function');
    }
    case 'index': {
      const target = evalExpr(node.target, env);
      const idx = evalExpr(node.index, env);
      if (target.t !== 'list') throw new Error('index target not list');
      if (idx.t !== 'int') throw new Error('index not int');
      const i = Number(idx.v);
      if (i < 1 || i > target.v.length) throw new Error('index out of range');
      return target.v[i-1];
    }
    default: return evalExprBlocks(node, env);
  }
}
function evalExprBlocks(node, env){
  switch (node.kind) {
    case 'if': {
      const c = evalExpr(node.cond, env);
      if (c.t !== 'bool') throw new Error('if cond');
      const owner = currentOwner(env);
      const lam = isLambdaFrame(env);
      if (c.v) {
        const frame = makeFrame(env, owner, false);
        frame.owner = owner;
        frame.isLambda = lam;
        return evalBlock(node.then, frame);
      }
      for (const ei of node.elseifs) {
        const cc = evalExpr(ei.cond, env);
        if (cc.t !== 'bool') throw new Error('elseif cond');
        if (cc.v) {
          const frame = makeFrame(env, owner, false);
          frame.owner = owner;
          frame.isLambda = lam;
          return evalBlock(ei.body, frame);
        }
      }
      if (node.else) {
        const frame = makeFrame(env, owner, false);
        frame.owner = owner;
        frame.isLambda = lam;
        return evalBlock(node.else, frame);
      }
      return NOTHING;
    }
    case 'while': {
      let last = NOTHING;
      const owner = currentOwner(env);
      const lam = isLambdaFrame(env);
      while (true) {
        const c = evalExpr(node.cond, env);
        if (c.t !== 'bool') throw new Error('while cond');
        if (!c.v) break;
        const frame = makeFrame(env, owner, false);
        frame.owner = owner;
        frame.isLambda = lam;
        try {
          last = evalBlock(node.body, frame);
        } catch (e) {
          if (e instanceof BreakSignal) break;
          if (e instanceof ContinueSignal) continue;
          throw e;
        }
      }
      return last;
    }
    case 'let': {
      const owner = currentOwner(env);
      const lam = isLambdaFrame(env);
      const frame = makeFrame(env, owner, false);
      frame.owner = owner;
      frame.isLambda = lam;
      for (const b of node.bindings) {
        const v = evalExpr(b.value, env);
        frame.bindings.set(b.name, v);
      }
      return evalBlock(node.body, frame);
    }
    case 'begin': {
      const owner = currentOwner(env);
      const lam = isLambdaFrame(env);
      const frame = makeFrame(env, owner, false);
      frame.owner = owner;
      frame.isLambda = lam;
      return evalBlock(node.body, frame);
    }
  }
  throw new Error('unknown node ' + node.kind);
}
// evalBlock(stmts, env) original above


function writeVar(name, value, env){
  // find binding in same function owner
  let cur = env;
  let sameOwnerFrame = null;
  let outerFrame = null;
  const owner = currentOwner(env);
  const lam = isLambdaFrame(env);
  while (cur) {
    if (cur.bindings.has(name)) {
      if (cur.owner === owner) { sameOwnerFrame = cur; break; }
      if (!outerFrame) outerFrame = cur;
    }
    cur = cur.parent;
  }
  if (sameOwnerFrame) { sameOwnerFrame.bindings.set(name, value); return; }
  if (outerFrame && lam) { outerFrame.bindings.set(name, value); return; }
  if (owner === null) {
    env.bindings.set(name, value);
    return;
  }
  // named function or no outer: create local in current frame
  env.bindings.set(name, value);
}
function equals(a,b){
  if (a.t !== b.t) return false;
  switch (a.t) {
    case 'int': return a.v === b.v;
    case 'bool': return a.v === b.v;
    case 'str': return a.v === b.v;
    case 'sym': return a.v === b.v;
    case 'nothing': return true;
    case 'list': {
      if (a.v.length !== b.v.length) return false;
      for (let i=0;i<a.v.length;i++) if (!equals(a.v[i], b.v[i])) return false;
      return true;
    }
    case 'func': return a === b;
  }
  return false;
}
// (duplicates removed)


function callBuiltin(name, args, env){
  if (name === 'print' || name === 'println') {
    let out = '';
    for (const a of args) out += printValue(a, true);
    if (name === 'println') out += '\n';
    process.stdout.write(out);
    return NOTHING;
  }
  if (name === 'length') {
    if (args.length !== 1) throw new Error('length arity');
    const v = args[0];
    if (v.t === 'list') return I(v.v.length);
    if (v.t === 'str') return I(Buffer.byteLength(v.v, 'utf8'));
    throw new Error('length type');
  }
  if (name === 'push!') {
    if (args.length !== 2) throw new Error('push! arity');
    const xs = args[0];
    if (xs.t !== 'list') throw new Error('push! type');
    xs.v.push(args[1]);
    return xs;
  }
  if (name === 'Int') {
    if (args.length !== 1) throw new Error('Int arity');
    const v = args[0];
    if (v.t === 'str') return I(parseInt(v.v,10) || 0);
    if (v.t === 'int') return v;
    if (v.t === 'bool') return I(v.v ? 1n : 0n);
    if (v.t === 'sym') { const n = parseInt(v.v,10); return I(isNaN(n)?0n:n); }
    throw new Error('Int type');
  }
  if (name === 'string') {
    if (args.length !== 1) throw new Error('string arity');
    return S(stringOf(args[0]));
  }
  if (name === 'Symbol') {
    if (args.length !== 1) throw new Error('Symbol arity');
    const v = args[0];
    if (v.t === 'str') return Y(v.v);
    if (v.t === 'sym') return v;
    throw new Error('Symbol type');
  }
  if (name === 'typeof') {
    if (args.length !== 1) throw new Error('typeof arity');
    const map = {int:'Int', bool:'Bool', str:'String', sym:'Symbol', list:'List', func:'Function', nothing:'Nothing'};
    return Y(map[args[0].t]);
  }
  if (name === 'ARGS') {
    throw new Error('ARGS is not a function');
  }
  // bootstrap
  if (name === 'readfile') {
    if (args.length !== 1 || args[0].t !== 'str') throw new Error('readfile');
    const content = fs.readFileSync(args[0].v, 'utf8');
    return S(content);
  }
  if (name === 'strlen') {
    if (args.length !== 1 || args[0].t !== 'str') throw new Error('strlen');
    return I(Buffer.byteLength(args[0].v, 'utf8'));
  }
  if (name === 'strbyte') {
    if (args.length !== 2) throw new Error('strbyte');
    const s = args[0], i = args[1];
    if (s.t !== 'str' || i.t !== 'int') throw new Error('strbyte type');
    const buf = Buffer.from(s.v, 'utf8');
    const idx = Number(i.v);
    if (idx < 1 || idx > buf.length) throw new Error('strbyte range');
    return I(buf[idx-1]);
  }
  if (name === 'strsub') {
    if (args.length !== 3) throw new Error('strsub');
    const s = args[0], a = args[1], b = args[2];
    if (s.t !== 'str' || a.t !== 'int' || b.t !== 'int') throw new Error('strsub type');
    const buf = Buffer.from(s.v, 'utf8');
    const start = Number(a.v), end = Number(b.v);
    if (start < 1 || end < start || end > buf.length) throw new Error('strsub range');
    return S(buf.slice(start-1, end).toString('utf8'));
  }
  if (name === 'exit') {
    if (args.length !== 1 || args[0].t !== 'int') throw new Error('exit');
    process.exit(Number(args[0].v));
  }
  throw new Error('unknown function ' + name);
}
function stringOf(v){
  switch (v.t) {
    case 'int': return v.v.toString();
    case 'bool': return v.v ? 'true' : 'false';
    case 'str': return v.v;
    case 'sym': return v.v;
    case 'nothing': return 'nothing';
    case 'list': return '[' + v.v.map(x => (x.t === 'sym' ? ':' + x.v : stringOf(x))).join(', ') + ']';
    case 'func': return '#lambda(' + (v.params||[]).join(',') + ')';
  }
  return '?';
}
function printValue(v, topLevel){
  switch (v.t) {
    case 'int': return v.v.toString();
    case 'bool': return v.v ? 'true' : 'false';
    case 'str': return v.v;
    case 'sym': return topLevel ? v.v : (':' + v.v);
    case 'nothing': return 'nothing';
    case 'list': return '[' + v.v.map(x => printValue(x, false)).join(', ') + ']';
    case 'func': return '#lambda(' + (v.params||[]).join(',') + ')';
  }
  return '?';
}

function runTriadSource(src, filename, scriptArgs) {
  const tokens = tokenize(src);
  const parser = new Parser(tokens);
  let ast;
  try { ast = parser.parseProgram(); }
  catch (e) { process.stderr.write('parse error: ' + e.message + '\n'); process.exit(1); }
  const globalEnv = makeFrame(null, null, false);
  globalEnv.owner = null;
  globalEnv.isLambda = false;
  globalEnv.bindings.set('ARGS', L((scriptArgs || []).map(s => S(s))));
  try {
    for (const s of ast.stmts) evalStmt(s, globalEnv);
  } catch (e) {
    if (e instanceof ReturnSignal) { }
    else if (e instanceof BreakSignal || e instanceof ContinueSignal) { }
    else {
      process.stderr.write('error: ' + (e && e.message ? e.message : e) + '\n');
      process.exit(1);
    }
  }
  process.exit(0);
}

function runTriadFile(file, scriptArgs) {
  let src;
  if (file === '-') {
    src = fs.readFileSync(0, 'utf8');
  } else {
    try { src = fs.readFileSync(file, 'utf8'); }
    catch (e) { process.stderr.write('cannot read file: ' + file + '\n'); process.exit(1); }
  }
  runTriadSource(src, file, scriptArgs);
}

function main() {
  const args = process.argv.slice(2);
  if (args.length === 0) { process.stderr.write('usage: triad FILE [ARG...]\n'); process.exit(2); }
  const file = args[0];
  const scriptArgs = args.slice(1);
  runTriadFile(file, scriptArgs);
}

// Direct execution support for .td / .triad files via Node's module system.
// Allows: node --require ./seed/dev/triad_core.cjs nome-file.td [arg...]
function triadModuleLoader(module, filename) {
  // When loaded as the program entry, the program arguments follow the file
  // name in process.argv. Normalize them so ARGS is populated correctly.
  // The program arguments always follow the entry file in process.argv.
  const scriptArgs = process.argv.slice(2);
  runTriadFile(filename, scriptArgs);
  module.exports = {};
}


// Browser support: when loaded in a web page (no Node CLI), expose the
// interpreter as window.TriadCore so the playground can run programs.
if (typeof module !== 'undefined' && typeof module.exports !== 'undefined') {
  if (typeof require === 'function' && require.extensions) {
    require.extensions['.td'] = triadModuleLoader;
    require.extensions['.triad'] = triadModuleLoader;
  }
  module.exports = { tokenize, Parser, evalStmt, makeFrame, L, S, I, B, Y, stringOf };
  if (require.main === module) main();
} else if (typeof window !== 'undefined') {
  // Minimal process shim: stdout/stderr write into window.__TRIAD_OUT__
  // (an array of strings provided by the playground); exit throws a
  // catchable signal instead of killing the tab.
  const shim = {
    argv: [],
    stdout: { write(s) { if (window.__TRIAD_OUT__) window.__TRIAD_OUT__.push(String(s)); } },
    stderr: { write(s) { if (window.__TRIAD_OUT__) window.__TRIAD_OUT__.push(String(s)); } },
    exit(code) { throw new Error('exit(' + code + ')'); },
  };
  window.process = window.process || shim;
  window.TriadCore = { tokenize, Parser, evalStmt, makeFrame, L, S, I, B, Y, stringOf };
}

