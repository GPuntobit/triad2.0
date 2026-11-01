// HTML/SVG escaping hardened against CodeQL "incomplete multi-character
// sanitization". Two classic break techniques are closed off:
//  1. splice/nesting ("&lt;scr&lt;script&gt;ipt&gt;" -> "<script>" after one
//     naive replacement pass): we sanitize to a FIXED POINT, re-applying the
//     substitution until the string stops changing, so no fragment can be
//     reassembled into markup across passes.
//  2. double-decoding ("&amp;lt;" -> "&lt;" -> "<"): we never emit entities at
//     all — '<', '>' and '&' are replaced with safe lookalikes ('(', ')', '+'),
//     so there is nothing for a downstream decoder to turn back into markup.
// Finally we assert the invariant: the result must contain no raw '<', '>' or
// '&'. If it ever did, we reject loudly instead of writing hostile SVG.
//
// Shared by scripts/docs/frontespizio.mjs and the adversarial regression tests
// (tests/security/incomplete_sanitization.test.mjs) so the tests can import the
// real implementation instead of re-creating it through dynamic code evaluation.
export const esc = s => {
  let out = String(s);
  while (true) {
    const prev = out;
    out = out.replace(/&/g, '+').replace(/</g, '(').replace(/>/g, ')');
    if (out === prev) break;
  }
  if (/[<>&]/.test(out)) {
    throw new Error(`refusing to embed unsafe text in SVG output: ${JSON.stringify(String(s))}`);
  }
  return out;
};
