// =====================================================================
//  rules.mjs — le guardie statiche sulla sorgente di S1
//
//  Una regola = una divergenza del seed presidiata.  Ogni regola e'
//  attiva solo se la divergenza corrispondente e' ancora presente nel
//  contratto del seed (seed/dev/certified-subset.txt): quando il seed
//  viene corretto, la divergenza sparisce dal contratto e la regola si
//  spegne da sola.
//
//  Tipi di guardia:
//    - rumorosa (il seed esce con 1): il costrutto e' *vietato* nella
//      sorgente di S1 (error);
//    - silenziosa (risultato sbagliato senza errore): il costrutto e'
//      *vietato* solo quando la divergenza e' decidibile dall'AST
//      (error); quando la violazione dipende dai tipi a runtime la
//      guardia non puo' decidere e il presidio passa al gate
//      differenziale seed<->JS (differential.mjs).
//
//  Le regole statiche NON sostituiscono il gate differenziale: sono il
//  complemento che (a) da un diagnostico preciso prima dell'esecuzione
//  e (b) coprono i casi che il differenziale non può vedere (scope dei
//  corpi di blocco per i nomi già legati, limiti dell'arena).
// =====================================================================

import {
  BLIND_UP,
  KEYWORDS,
  BINARY_OPS,
  blindKeywordIn,
  blindDownKeywordIn,
  blockRanges,
  insideBlock,
  lastCodeTokenPerLine,
} from './scan.mjs';
import { seedLocalsOf, isStringExpr, isBoolExpr, boundIn } from './analysis.mjs';
import { isAvailable } from './contract.mjs';

/** Operatori che il seed rifiuta (`:+` e simili). */
const OPERATOR_SYMBOL = /^[+\-*/%&|^<>=!?]+$/;

/** Nomi dei costrutti vietati (rumorosi) che il seed non implementa. */
const FORBIDDEN_BUILTINS = {
  typeof: 'D14',
  Int: 'D14',
  Symbol: 'D14',
};

/**
 * true se l'espressione contiene un simbolo a profondita' zero (fuori da
 * parentesi, liste e indici): e' il caso che fa fallire il seed (D23).
 * Lo scanner del ternario del seed cerca il separatore `:` contando solo
 * le parentesi tonde, quadre e graffe: un `:` di simbolo a profondita' zero
 * viene scambiato per il separatore (SPEC.md §1: il separatore del ternario
 * e' un `:` circondato da spazi).
 */
function hasTopLevelSymbol(node) {
  if (!node || typeof node !== 'object') return false;
  switch (node.kind) {
    case 'sym': return true;
    case 'binary': return hasTopLevelSymbol(node.left) || hasTopLevelSymbol(node.right);
    case 'unary': return hasTopLevelSymbol(node.operand);
    case 'assign': return hasTopLevelSymbol(node.value);
    case 'ternary':
      return hasTopLevelSymbol(node.cond) || hasTopLevelSymbol(node.then) ||
        hasTopLevelSymbol(node.else);
    // call / list / index / lambda: il `:` e' dentro parentesi o quadre
    default: return false;
  }
}

/** Primitivi §8 assenti (la loro disponibilita' e' nel contratto). */
const BOOTSTRAP_PRIMITIVES = ['readfile', 'strlen', 'strbyte', 'strsub'];

function callName(node) {
  if (!node || node.kind !== 'call') return null;
  if (node.callee && node.callee.kind === 'var') return node.callee.name;
  return null;
}

/**
 * Divergenze che NON possono essere presidiate da una regola statica:
 * la violazione dipende dai tipi a runtime (non e' decidibile dall'AST).
 * Il loro presidio e' il gate differenziale seed<->JS
 * (tools/selfhost-guard/differential.mjs); se il differenziale rileva una
 * differenza, la risposta e' la chirurgia nel seed.
 */
export const DIFFERENTIAL_ONLY = new Set(['D15']);

export const RULES = [
  // ---------------------------------------------------------------- D1
  {
    id: 'G-D01',
    divergence: 'D1',
    title: 'scope dinamico: un globale letto in una funzione non deve essere locale in un\'altra',
    level: 'error',
    check(ctx) {
      const out = [];
      const { analysis } = ctx;
      if (!analysis) return out;
      const localsOf = new Map();
      for (const f of analysis.functions) localsOf.set(f, seedLocalsOf(f.scope));
      for (const r of analysis.reads) {
        // la lettura deve risolversi sul GLOBAL: e' il caso in cui il seed
        // (scope dinamico) puo' trovare invece un locale del chiamante
        const bound = boundIn(r.scope, r.name);
        if (bound !== analysis.fileScope) continue;
        const owner = r.scope.functionScope();
        // il livello di file e' il frame piu' esterno: non puo' essere
        // ombreggiato dallo scope dinamico
        if (!owner) continue;
        for (const g of analysis.functions) {
          if (g.scope === owner) continue;
          if (!localsOf.get(g).has(r.name)) continue;
          out.push({
            line: null,
            msg: `il globale \`${r.name}\` letto in una funzione e' locale in \`${g.name}\`: ` +
              'il seed ha scope DINAMICO (il callee vede i locali del chiamante) e leggerebbe ' +
              `\`${r.name}\` sbagliato`,
          });
          break;
        }
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D2
  {
    id: 'G-D02',
    divergence: 'D2',
    title: 'cattura per valore: un nome assegnato dentro una chiusura non deve essere assegnato anche fuori',
    level: 'error',
    check(ctx) {
      const out = [];
      const { analysis } = ctx;
      if (!analysis) return out;
      for (const lam of analysis.lambdas) {
        // nomi catturati dalla chiusura: letti dentro, legati fuori
        const captured = new Set();
        for (const r of analysis.reads) {
          if (!lam.scope.contains(r.scope)) continue;
          if (lam.params.includes(r.name)) continue;
          const bound = boundIn(r.scope, r.name);
          if (!bound) continue;                       // lettura libera: errore in ogni runtime
          if (lam.scope.contains(bound)) continue;   // legato dentro: non e' una cattura
          captured.add(r.name);
        }
        for (const name of captured) {
          const outside = analysis.assigns.some((a) => a.name === name && !lam.scope.contains(a.scope));
          if (!outside) continue;
          out.push({
            line: null,
            msg: `\`${name}\` e' catturato dalla chiusura e riassegnato fuori: il seed cattura per ` +
              'VALORE (la mutazione successiva non si vede), SPEC-CORE.md §5 la cattura per riferimento',
          });
        }
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D3
  {
    id: 'G-D03',
    divergence: 'D3',
    title: 'escape non interpretati: nessun backslash nei letterali',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const s of ctx.scan.strings) {
        if (!s.hasEscape) continue;
        out.push({
          line: s.line,
          msg: 'escape in un letterale: il seed NON interpreta gli escape e stampa i due caratteri ' +
            '(SPEC-CORE.md §2 li interpreta). Sposta i caratteri speciali fuori dal letterale',
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D4
  {
    id: 'G-D04',
    divergence: 'D4',
    title: 'confronto fra stringhe: `==`/`!=` solo su valori dimostrabilmente non-stringa',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'binary') continue;
        if (node.op !== '==' && node.op !== '!=') continue;
        if (!isStringExpr(node.left) && !isStringExpr(node.right)) continue;
        out.push({
          line: null,
          msg: `confronto \`${node.op}\` con un operando stringa: il seed confronta le stringhe ` +
            'sempre per falso (SPEC-CORE.md §5 le confronta per valore)',
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D5
  {
    id: 'G-D05',
    divergence: 'D5',
    title: '`continue` non esiste nel seed',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'continue') continue;
        out.push({ line: null, msg: '`continue` non e\' implementato dal seed (exit 1)' });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D6
  {
    id: 'G-D06',
    divergence: 'D6',
    title: '`-=` e `*=` non esistono nel seed',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'assign' && node.kind !== 'indexassign') continue;
        if (node.op !== '-=' && node.op !== '*=') continue;
        out.push({
          line: null,
          msg: `l'assegnazione composta \`${node.op}\` non e' implementata dal seed (exit 1): ` +
            'riscrivila come `x = x - y` / `x = x * y`',
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D7
  {
    id: 'G-D07',
    divergence: 'D7',
    title: '`while` come valore: il seed non ha il while-espressione',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node, statementPosition } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'while') continue;
        if (statementPosition) continue;
        out.push({
          line: null,
          msg: '`while` usato come valore: il seed non implementa il while-espressione (exit 1). ' +
            'Il `while` puo\' essere solo un statement',
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D8
  {
    id: 'G-D08',
    divergence: 'D8',
    title: '`if` come valore: il seed non ha il if-espressione',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node, statementPosition } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'if') continue;
        if (statementPosition) continue;
        out.push({
          line: null,
          msg: '`if` usato come valore: il seed non implementa l\'if-espressione (exit 1). ' +
            'L\'`if` puo\' essere solo uno statement (o la prima parte di una catena `if`/`elseif`)',
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D9
  {
    id: 'G-D09',
    divergence: 'D9',
    title: 'chiamata in posizione finale: non e\' valutata dal seed',
    level: 'error',
    check(ctx) {
      const out = [];
      const ast = ctx.ast;
      if (!ast) return out;
      const checkTail = (stmts, where) => {
        if (!stmts || !stmts.length) return;
        const last = stmts[stmts.length - 1];
        if (last.kind !== 'exprstmt') return;
        if (!last.expr || last.expr.kind !== 'call') return;
        // `println` e' l'unica chiamata ammessa in posizione finale: il seed
        // la tratta come uno statement (gli altri builtin e le funzioni
        // utente no: misurato, exit 1).
        if (callName(last.expr) === 'println') return;
        out.push({
          line: null,
          msg: `chiamata in posizione finale (${where}): il seed non la valuta (exit 1). ` +
            'Assegna il risultato a una variabile e restituisci la variabile',
        });
      };
      checkTail(ast.stmts, 'programma');
      for (const f of ctx.analysis?.functions ?? []) {
        if (f.short) continue;
        checkTail(f.node.body, `corpo di \`${f.name}\``);
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D10
  {
    id: 'G-D10',
    divergence: 'D10',
    title: '`return` non esiste nel seed',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'return') continue;
        out.push({
          line: null,
          msg: '`return` non e\' implementato dal seed nelle funzioni a blocco (exit 1): ' +
            'il valore della funzione e\' l\'ultima espressione del corpo',
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D11
  {
    id: 'G-D11',
    divergence: 'D11',
    title: 'blocco-lambda `function (x) ... end` non esiste nel seed',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'lambda' || !node.block) continue;
        out.push({
          line: null,
          msg: 'lambda a blocco (`function (x) ... end`) non implementata dal seed (exit 1): ' +
            'usa la forma breve `x -> espressione`',
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D12
  {
    id: 'G-D12',
    divergence: 'D12',
    title: '`let` con piu\' di un binding non esiste nel seed',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'let') continue;
        if ((node.bindings || []).length <= 1) continue;
        out.push({
          line: null,
          msg: '`let` con piu\' binding: il seed ne supporta uno solo (exit 1)',
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D13
  {
    id: 'G-D13',
    divergence: 'D13',
    title: 'indicizzazione `xs[i]` non esiste nel seed',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'index') continue;
        out.push({
          line: null,
          msg: 'indicizzazione `xs[i]` non implementata dal seed (exit 1): ' +
            'usa il primitivo bootstrap `get(xs, i)` (indice 0-based, SPEC-CORE.md §8)',
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D14
  {
    id: 'G-D14',
    divergence: 'D14',
    title: '`typeof`, `Int()`, `Symbol()` non esistono nel seed',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node } of ctx.analysis?.nodes ?? []) {
        const name = callName(node);
        if (!name) continue;
        if (!FORBIDDEN_BUILTINS[name]) continue;
        out.push({
          line: null,
          msg: `\`${name}\` non e' implementato dal seed (exit 1)`,
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D16
  {
    id: 'G-D16',
    divergence: 'D16',
    title: 'primitivi §8 assenti nel seed',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node } of ctx.analysis?.nodes ?? []) {
        const name = callName(node);
        if (!name) continue;
        if (!BOOTSTRAP_PRIMITIVES.includes(name)) continue;
        if (isAvailable(ctx.contract, name)) continue;
        out.push({
          line: null,
          msg: `\`${name}\` (SPEC-CORE.md §8) non e' ancora implementato dal seed (exit 1): ` +
            'il contratto del seed lo dichiara assente',
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D17
  {
    id: 'G-D17',
    divergence: 'D17',
    title: 'simboli operatore (`:+`) rifiutati dal seed',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'sym') continue;
        if (!OPERATOR_SYMBOL.test(node.value)) continue;
        out.push({
          line: null,
          msg: `simbolo operatore \`:${node.value}\`: il seed lo rifiuta (exit 1)`,
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D18
  {
    id: 'G-D18',
    divergence: 'D18',
    title: 'riferimento in avanti a una funzione: non risolto dal seed',
    level: 'error',
    check(ctx) {
      const out = [];
      const ast = ctx.ast;
      if (!ast) return out;
      // ordine delle definizioni di funzione al livello del file
      const defIndex = new Map();
      ast.stmts.forEach((s, i) => {
        if (s.kind === 'funcdef' && !defIndex.has(s.name)) defIndex.set(s.name, i);
      });
      for (const { node, scope, topIdx } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'call') continue;
        const name = callName(node);
        if (!name || !defIndex.has(name)) continue;
        const defAt = defIndex.get(name);
        // il seed risolve i riferimenti in avanti *fra funzioni* (la tabella
        // delle funzioni e' completa prima dell'esecuzione): il caso che
        // il seed rifiuta e' la chiamata a livello di file che precede la
        // definizione (le dichiarazioni di file sono eseguite in ordine).
        if (scope.kind !== 'file') continue;
        if (defAt > topIdx) {
          out.push({
            line: null,
            msg: `chiamata a \`${name}\` a livello di file, definita dopo: il seed la rifiuta ` +
              '(exit 1) — le dichiarazioni di file sono eseguite in ordine',
          });
        }
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D19
  {
    id: 'G-D19',
    divergence: 'D19',
    title: 'newline dopo un operatore: il seed continua l\'espressione',
    level: 'error',
    check(ctx) {
      const out = [];
      const last = lastCodeTokenPerLine(ctx.scan.tokens);
      for (const [line, tok] of [...last.entries()].sort((a, b) => a[0] - b[0])) {
        if (tok.type !== 'op') continue;
        if (!BINARY_OPS.has(tok.value)) continue;
        out.push({
          line,
          msg: `la riga finisce con l'operatore \`${tok.value}\`: il seed continua l'espressione ` +
            'oltre il newline, mentre SPEC-CORE.md §2 fa del newline un separatore di statement',
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D20
  {
    id: 'G-D20',
    divergence: 'D20',
    title: 'scope dei corpi di blocco: un nome creato in `if`/`while` non deve essere letto fuori',
    level: 'error',
    check(ctx) {
      const out = [];
      const { analysis } = ctx;
      if (!analysis) return out;
      // nomi creati nei corpi di `if`/`while` (il seed non crea l'ambiente:
      // il nome resta visibile nel frame che li contiene)
      const created = new Map();   // scope -> Set(nomi)
      for (const scope of analysis.scopes) {
        if (scope.kind !== 'block-if' && scope.kind !== 'block-while') continue;
        const visible = new Set();
        for (let s = scope.parent; s; s = s.parent) {
          for (const n of s.names) visible.add(n);
        }
        created.set(scope, new Set([...scope.names].filter((n) => !visible.has(n))));
      }
      for (const r of analysis.reads) {
        // lettura libera: nel riferimento JS il nome non e' legato
        if (boundIn(r.scope, r.name)) continue;
        const owner = r.scope.functionScope();
        for (const [scope, names] of created) {
          if (!names.has(r.name)) continue;
          if (scope.functionScope() !== owner) continue;
          out.push({
            line: null,
            msg: `\`${r.name}\` e' creato nel corpo di \`${scope.label}\` e letto fuori: ` +
              'nel seed il corpo non ha un ambiente proprio e il nome resta visibile fuori ' +
              '(SPEC-CORE.md §5: `if`/`while` introducono un ambiente)',
          });
          break;
        }
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D21
  {
    id: 'G-D21',
    divergence: 'D21',
    title: 'condizione di `while` non-Bool: il seed salta il corpo in silenzio',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'while') continue;
        if (isBoolExpr(node.cond)) continue;
        out.push({
          line: null,
          msg: 'condizione di `while` non dimostrabilmente Bool: il seed salta il corpo in silenzio ' +
            '(SPEC-CORE.md §5: solo Bool, nessuna truthiness). Scrivi un confronto esplicito',
        });
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D22
  {
    id: 'G-D22',
    divergence: 'D22',
    title: 'keyword cieche del seed: identificatore che inizia con una keyword, o keyword dentro un corpo di blocco',
    level: 'error',
    check(ctx) {
      const out = [];
      const ranges = blockRanges(ctx.scan.tokens);
      // (a) posizione di statement: un identificatore che *inizia* con una
      //     keyword viene scambiato dal seed per il costrutto (misurato:
      //     `ifx = 1` fallisce con exit 1)
      // (b) dentro un corpo di blocco: il contatore di annidamento del seed
      //     e' cieco e conta le keyword confrontando i byte grezzi; a
      //     livello di programma invece non le conta (misurato)
      for (const t of ctx.scan.tokens) {
        if (t.type === 'ident') {
          if (KEYWORDS.has(t.value)) continue;
          const head = BLIND_UP.find((kw) => t.value.startsWith(kw));
          if (head) {
            out.push({
              line: t.line,
              msg: `l'identificatore \`${t.value}\` inizia con \`${head}\`: il seed lo scambia per ` +
                'il costrutto e la sua esecuzione fallisce (exit 1)',
            });
            continue;
          }
          const up = blindKeywordIn(t.value);
          if (up) {
            const at = t.pos + t.value.indexOf(up);
            const blk = insideBlock(ranges, at);
            if (!blk) continue;
            out.push({
              line: t.line,
              msg: `l'identificatore \`${t.value}\` contiene \`${up}\` dentro un corpo di ` +
                `\`${blk.label}\`: il seed conta le keyword confrontando i byte grezzi e sbaglia ` +
                "l'annidamento dei blocchi (exit 1)",
            });
            continue;
          }
          const down = blindDownKeywordIn(t.value);
          if (down) {
            const at = t.pos + t.value.indexOf(down);
            const blk = insideBlock(ranges, at);
            if (!blk) continue;
            out.push({
              line: t.line,
              level: 'warn',
              msg: `l'identificatore \`${t.value}\` contiene \`${down}\` dentro un corpo di ` +
                `\`${blk.label}\`: il seed conta anche le keyword che chiudono un blocco e puo' ` +
                'spostare la fine del blocco',
            });
          }
          continue;
        }
        if (t.type === 'string') {
          const up = blindKeywordIn(t.value);
          if (up) {
            const at = t.pos + 1 + t.value.indexOf(up);
            const blk = insideBlock(ranges, at);
            if (!blk) continue;
            out.push({
              line: t.line,
              msg: `il letterale contiene \`${up}\` dentro un corpo di \`${blk.label}\`: il seed ` +
                "conta le keyword confrontando i byte grezzi e sbaglia l'annidamento dei blocchi " +
                '(exit 1)',
            });
            continue;
          }
          const down = blindDownKeywordIn(t.value);
          if (down) {
            const at = t.pos + 1 + t.value.indexOf(down);
            const blk = insideBlock(ranges, at);
            if (!blk) continue;
            out.push({
              line: t.line,
              level: 'warn',
              msg: `il letterale contiene \`${down}\` dentro un corpo di \`${blk.label}\`: il seed ` +
                "puo' spostare la fine del blocco",
            });
          }
        }
      }
      return out;
    },
  },

  // ---------------------------------------------------------------- D23
  {
    id: 'G-D23',
    divergence: 'D23',
    title: 'ternario con un simbolo nel ramo *then*: il seed lo rifiuta',
    level: 'error',
    check(ctx) {
      const out = [];
      for (const { node } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'ternary') continue;
        if (!hasTopLevelSymbol(node.then)) continue;
        out.push({
          line: null,
          msg: 'ternario con un simbolo nel ramo *then*: il seed prende il `:` del simbolo ' +
            'come separatore e rifiuta il programma (exit 1). ' +
            "SPEC.md §1: il separatore del ternario e' un `:` circondato da spazi",
        });
      }
      return out;
    },
  },

  // ------------------------------------------------------------ envelope
  {
    id: 'G-E01',
    divergence: null,
    title: 'il sorgente deve stare nel buffer sorgente del seed',
    level: 'error',
    check(ctx) {
      const out = [];
      const max = ctx.envelope?.sourceMaxBytes ?? 0;
      if (!max) return out;
      const size = Buffer.byteLength(ctx.src, 'utf8');
      if (size <= max) return out;
      out.push({
        line: null,
        msg: `il sorgente e' di ${size} byte e il buffer del seed ne contiene ${max}: ` +
          'la lettura del file fallisce (`seed: read error`)',
      });
      return out;
    },
  },
  {
    id: 'G-E02',
    divergence: null,
    title: 'numero di parametri entro il record funzione del seed',
    level: 'error',
    check(ctx) {
      const out = [];
      const max = ctx.envelope?.functionMaxParams ?? 0;
      if (!max) return out;
      for (const f of ctx.analysis?.functions ?? []) {
        if (f.params.length <= max) continue;
        out.push({
          line: null,
          msg: `\`${f.name}\` ha ${f.params.length} parametri e il seed ne regge al massimo ${max}`,
        });
      }
      for (const l of ctx.analysis?.lambdas ?? []) {
        if (l.params.length <= max) continue;
        out.push({
          line: null,
          msg: `una chiusura ha ${l.params.length} parametri e il seed ne regge al massimo ${max}`,
        });
      }
      return out;
    },
  },
  {
    id: 'G-E03',
    divergence: null,
    title: 'letterale di lista entro il blocco fisso del seed',
    level: 'error',
    check(ctx) {
      const out = [];
      const max = ctx.envelope?.listMaxItems ?? 0;
      if (!max) return out;
      for (const { node } of ctx.analysis?.nodes ?? []) {
        if (node.kind !== 'list') continue;
        const n = (node.elements || []).length;
        if (n <= max) continue;
        out.push({
          line: null,
          msg: `un letterale di lista ha ${n} elementi e il seed ne regge al massimo ${max} ` +
            '(il chunking delle liste e\' un problema di S1)',
        });
      }
      return out;
    },
  },
];

/** Indice delle regole per id. */
export const RULE_BY_ID = new Map(RULES.map((r) => [r.id, r]));
