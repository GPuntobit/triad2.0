const {execFileSync} = require('child_process');
const fs = require('fs');
const path = require('path');
const base = 'c:\\Users\\xbos\\Documents\\progetti\\triad2.0\\conformance\\core\\cases';
const interp = 'c:\\Users\\xbos\\Documents\\progetti\\triad2.0\\seed\\dev\\triad_core.cjs';
const cases = fs.readdirSync(base).filter(d => fs.statSync(path.join(base,d)).isDirectory());
let pass=0, fail=0;
for (const c of cases) {
  // liste included now
  const prog = path.join(base, c, 'program.td');
  const expFile = path.join(base, c, 'expected.out');
  let out = '';
  let code = 0;
  try {
    out = execFileSync('node', [interp, prog], {encoding:'utf8', stdio:['ignore','pipe','pipe']});
  } catch (e) {
    code = e.status;
    out = (e.stdout||'') + (e.stderr||'');
  }
  let expected = '';
  if (fs.existsSync(expFile)) expected = fs.readFileSync(expFile,'utf8');
  // normalize line endings
  const norm = s => s.replace(/\r\n/g,'\n');
  const ok = norm(out) === norm(expected) && code === 0;
  if (ok) { pass++; console.log('PASS', c); }
  else {
    fail++;
    console.log('FAIL', c, 'exit', code);
    console.log('--- got ---');
    console.log(JSON.stringify(out));
    console.log('--- exp ---');
    console.log(JSON.stringify(expected));
  }
}
console.log('PASS', pass, 'FAIL', fail);
