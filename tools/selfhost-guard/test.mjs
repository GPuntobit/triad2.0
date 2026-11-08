#!/usr/bin/env node
// =====================================================================
//  test.mjs — self-test delle guardie statiche
//
//  Ogni regola ha un fixture che la deve far scattare (tools/selfhost-
//  guard/fixtures/): il test verifica che la regola veda la violazione
//  nel fixture e che il corpus pulito non producaFindings.
//
//  Il test verifica anche il meccanismo *attivato dal contratto*: se una
//  divergenza sparisce da seed/dev/certified-subset.txt (perche' il seed
//  e' stato corretto), la regola corrispondente deve spegnersi.
//
//  Uso: node tools/selfhost-guard/test.mjs
//  Exit: 0 = tutto verde; 1 = un test fallito.
// =====================================================================
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { parseContract } from './contract.mjs';
import { checkFile } from './guard.mjs';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..', '..');
const FIXTURES = path.join(HERE, 'fixtures');
const CONTRACT = path.join(ROOT, 'seed', 'dev', 'certified-subset.txt');

/** fixture -> regola che deve scattare. */
const CASES = [
  ['d01_scope_dinamico.td', 'G-D01'],
  ['d02_cattura_per_valore.td', 'G-D02'],
  ['d03_escape.td', 'G-D03'],
  ['d04_eq_stringhe.td', 'G-D04'],
  ['d05_continue.td', 'G-D05'],
  ['d07_while_valore.td', 'G-D07'],
  ['d08_if_valore.td', 'G-D08'],
  ['d10_return.td', 'G-D10'],
  ['d11_lambda_blocco.td', 'G-D11'],
  ['d12_let_multi.td', 'G-D12'],
  ['d14_primitivi_assenti.td', 'G-D14'],
  ['d17_simbolo_operatore.td', 'G-D17'],
  ['d18_riferimento_avanti.td', 'G-D18'],
  ['d19_newline_operatore.td', 'G-D19'],
  ['d20_scope_corpo_blocco.td', 'G-D20'],
  ['d21_while_non_bool.td', 'G-D21'],
  ['d22_keyword_cieca.td', 'G-D22'],
  ['d24_composta_indice.td', 'G-D24'],
  ['e02_troppi_parametri.td', 'G-E02'],
  ['e03_lista_troppo_lunga.td', 'G-E03'],
];

const contract = parseContract(fs.readFileSync(CONTRACT, 'utf8'));

let failed = 0;
function ok(name, cond, detail) {
  if (cond) {
    console.log(`ok   ${name}`);
    return;
  }
  failed++;
  console.log(`FAIL ${name}${detail ? ' — ' + detail : ''}`);
}

for (const [fixture, rule] of CASES) {
  const file = path.join(FIXTURES, fixture);
  const findings = checkFile(file, contract);
  const hit = findings.find((f) => f.rule === rule);
  ok(`${fixture} -> ${rule}`, !!hit,
    hit ? '' : `nessuna violazione ${rule}; trovate: ${findings.map((f) => f.rule).join(', ') || 'nessuna'}`);
}

// D23 is fixed: the former rejecting fixture must now be allowed.
{
  const findings = checkFile(path.join(FIXTURES, 'd23_ternario_simbolo.td'), contract);
  ok('D23 risolta -> ternario con simbolo ammesso', !findings.some((f) => f.rule === 'G-D23'));
}

// D6, D9 e D13 sono risolte dal seed: i costrutti che erano vietati
// devono essere ammessi (nessuna guardia deve piu' scattare).
for (const [fixture, what] of [
  ['risolto_composta.td', 'D6 risolta -> `-=`/`*=` ammessi'],
  ['risolto_chiamata_finale.td', 'D9 risolta -> chiamata in posizione finale ammessa'],
  ['risolto_indicizzazione.td', 'D13 risolta -> indicizzazione `xs[i]` ammessa'],
  ['risolto_bootstrap.td', 'D16 risolta -> primitivi §8 ammessi'],
]) {
  const findings = checkFile(path.join(FIXTURES, fixture), contract);
  ok(what, findings.length === 0,
    findings.map((f) => `${f.rule}: ${f.msg}`).join(' | '));
}

// il corpus pulito non deve produrre violazioni
{
  const file = path.join(FIXTURES, 'pulito.td');
  const findings = checkFile(file, contract);
  ok('pulito.td senza violazioni', findings.length === 0,
    findings.map((f) => `${f.rule}: ${f.msg}`).join(' | '));
}

// il contratto spegne la regola quando la divergenza non c'e' piu'
{
  const contract2 = { ...contract, divergence: { ...contract.divergence } };
  delete contract2.divergence.D24;
  const file = path.join(FIXTURES, 'd24_composta_indice.td');
  const findings = checkFile(file, contract2);
  ok('D24 assente dal contratto -> regola spenta', !findings.some((f) => f.rule === 'G-D24'),
    findings.map((f) => f.rule).join(', '));
}

// ogni divergenza del contratto deve avere una regola statica oppure
// essere dichiarata "solo differenziale" (il "criterio di non
// presidabile": la violazione dipende dai tipi a runtime)
{
  const { RULES, DIFFERENTIAL_ONLY } = await import('./rules.mjs');
  const covered = new Set(RULES.map((r) => r.divergence).filter(Boolean));
  const missing = Object.keys(contract.divergence ?? {})
    .filter((d) => !covered.has(d) && !DIFFERENTIAL_ONLY.has(d));
  ok('ogni divergenza del contratto e\' presidiata', missing.length === 0,
    `senza presidio: ${missing.join(', ')}`);
}

console.log(`\n${CASES.length + 4} test, ${failed} falliti`);
process.exit(failed ? 1 : 0);
