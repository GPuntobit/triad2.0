#!/usr/bin/env python3
"""TRID 0.4 independent ground-proof verifier and dependency-aware memory projection.

Reference implementation, Python 3 stdlib; no imports from the 0.3 generator.
All proof results are conditional on provided source facts and definitions.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import sys
import tempfile

ATOM = re.compile(r'^[a-z][a-z0-9_]*$')
SHAPES = {
    'chain': (('X', 'Y'), ('Y', 'Z')),
    'reverse_chain': (('Y', 'X'), ('Z', 'Y')),
    'common_source': (('Y', 'X'), ('Y', 'Z')),
    'common_target': (('X', 'Y'), ('Z', 'Y')),
}


def canon(obj):
    return json.dumps(obj, sort_keys=True, separators=(',', ':'), ensure_ascii=True)


def check_atom(v):
    if not isinstance(v, str) or not ATOM.fullmatch(v):
        raise ValueError('Invalid atom: %r' % (v,))
    return v


def read_journal(path):
    """Read and authenticate *internal consistency* of the hash-chained journal."""
    result, previous = [], '0' * 64
    for line in path.read_text(encoding='utf-8').splitlines():
        raw = json.loads(line)
        if not isinstance(raw, dict) or 'hash' not in raw:
            raise ValueError('Malformed journal event')
        digest = raw['hash']
        e = {k: v for k, v in raw.items() if k != 'hash'}
        if (not isinstance(digest, str) or
            hashlib.sha256(canon(e).encode('ascii')).hexdigest() != digest or
            e.get('prev_hash') != previous or e.get('seq') != len(result) + 1):
            raise ValueError('Journal integrity failure')
        result.append(raw)
        previous = digest
    return result


def verify_ground(facts, domain, relation, shape, pair, witness):
    """Independently check substitutions and both actual source-labelled edges."""
    for item in (domain, relation, shape, *pair, witness.get('via', ''), *witness.get('sources', [])):
        check_atom(item)
    if shape not in SHAPES or len(pair) != 2 or pair[0] == pair[1]:
        return False
    if set(witness) != {'via', 'sources'} or len(witness['sources']) != 2:
        return False
    assignments = {'X': pair[0], 'Y': witness['via'], 'Z': pair[1]}
    for (left, right), src in zip(SHAPES[shape], witness['sources']):
        expected = (domain, relation, assignments[left], assignments[right], src)
        if expected not in facts:
            return False
    return True


def fixture_edges(data):
    facts = set()
    for e in data['edges']:
        if set(e) != {'domain', 'relation', 'from', 'to', 'source'}:
            raise ValueError('Bad fixture edge')
        facts.add(tuple(check_atom(e[k]) for k in ('domain', 'relation', 'from', 'to', 'source')))
    return facts


def evaluations(events):
    """Latest evaluation per hypothesis; history remains in original lab journal."""
    latest = {}
    proof_events = {}
    for e in events:
        ident = check_atom(e['hypothesis_id'])
        if e['kind'] == 'evaluation':
            latest[ident] = e['payload']
        elif e['kind'] == 'conditional_proof':
            proof_events.setdefault(ident, []).append(e['payload'])
    return latest, proof_events


def validate_reviews(data, item, facts):
    """Recompute TP/FP/FN and candidate predictions from fixture, no generator import."""
    domain, rel, shape = item['domain'], item['relation'], item['shape']
    for v in (domain, rel, shape, item['target']):
        check_atom(v)
    if shape not in SHAPES:
        raise ValueError('Unsupported shape')
    pattern = SHAPES[shape]
    edges = [f for f in sorted(facts) if f[0] == domain and f[1] == rel]
    predicted = {}
    for a in edges:
        for b in edges:
            subs = {}
            ok = True
            for (left, right), edge in ((pattern[0], a), (pattern[1], b)):
                for var, value in ((left, edge[2]), (right, edge[3])):
                    if var in subs and subs[var] != value:
                        ok = False
                    subs[var] = value
            if ok and subs['X'] != subs['Z']:
                key = (subs['X'], subs['Z'])
                predicted.setdefault(key, []).append({'via': subs['Y'], 'sources': [a[4], b[4]]})
    actual = set(predicted)
    examples = {}
    for key in ('train_positive', 'train_negative', 'test_positive', 'test_negative'):
        values = item['explicit_reviews'][key]
        if not all(len(x) == 3 for x in values):
            raise ValueError('Malformed example')
        examples[key] = {(check_atom(x[0]), check_atom(x[1])) for x in values}
    metrics = {
        'train_tp': len(actual & examples['train_positive']),
        'train_fp': len(actual & examples['train_negative']),
        'train_fn': len(examples['train_positive'] - actual),
        'test_tp': len(actual & examples['test_positive']),
        'test_fp': len(actual & examples['test_negative']),
        'test_fn': len(examples['test_positive'] - actual),
    }
    if metrics != item['metrics'] or [list(p) for p in sorted(actual)] != item['predicted']:
        raise ValueError('Stale or tampered candidate evaluation')
    return predicted, metrics, examples


def project(fixture, journal_events, definitions, approved=(), revoked=()):
    """Build a derived projection; cannot rewrite experimental journal records.

    `approved` is a deliberate human gate, NOT independent evidence of truth.
    """
    facts = fixture_edges(fixture)
    latest, proof_events = evaluations(journal_events)
    target_index = {}
    for target in fixture.get('targets', []):
        identity = (target['domain'], target['name'], target['relation'])
        if identity in target_index:
            raise ValueError('Duplicate supervised target')
        target_index[identity] = target
    defs = {}
    for d in definitions['definitions']:
        if set(d) != {'domain', 'target', 'relation', 'shape', 'reference'}:
            raise ValueError('Malformed formal definition')
        for value in d.values():
            check_atom(value)
        if d['shape'] not in SHAPES:
            raise ValueError('Unknown definition shape')
        key = (d['domain'], d['target'], d['relation'])
        if key in defs:
            raise ValueError('Ambiguous certified definition')
        defs[key] = d
    approved = set(approved)
    revoked = set(revoked)
    for atom in approved | revoked:
        check_atom(atom)
    if approved - set(latest):
        raise ValueError('Approval refers to unknown hypothesis')
    outcomes, claims = [], []
    for ident, item in sorted(latest.items()):
        predicted, metric, examples = validate_reviews(fixture, item, facts)
        shape = item['shape']
        key = (item['domain'], item['target'], item['relation'])
        if target_index:
            expected = target_index.get(key)
            if expected is None or any(item['explicit_reviews'].get(k) != expected[k] for k in
                ('train_positive', 'train_negative', 'test_positive', 'test_negative')):
                raise ValueError('Journal observations do not match supervised fixture')
        definition = defs.get(key)
        contradictions = any(examples[k] & examples[k.replace('positive', 'negative')]
                             for k in ('train_positive', 'test_positive'))
        refuted = bool(metric['train_fp'] or metric['test_fp'] or contradictions)
        # Explicitly check all claims in the 0.3 conditional_proof log.
        for p in proof_events.get(ident, []):
            if (p.get('status') != 'demonstrated' or
                p.get('scope') != 'assuming_experimental_rule' or
                p.get('epistemic_truth') != 'unverified' or p.get('rule') != ident or
                not verify_ground(facts, item['domain'], item['relation'], shape, p['conclusion'], p['witness'])):
                raise ValueError('Invalid independent ground-proof verification: ' + ident)
        # Promotions never occur from high training scores alone.
        gate = (ident in approved and item.get('selected') is True and
                not refuted and metric['train_fn'] == 0 and metric['test_fn'] == 0 and
                metric['train_tp'] > 0 and metric['test_tp'] > 0 and
                definition is not None and definition['shape'] == shape)
        state = ('refuted' if refuted else
                 ('suspended_dependency' if gate and definition['reference'] in revoked else
                  ('consolidated_conditional' if gate else 'experimental')))
        outcomes.append({'id': ident, 'state': state,
                         'definition_reference': definition['reference'] if gate else None,
                         'reason': 'explicit_definition_and_approval' if gate else
                                   ('explicit_counterexample' if refuted else 'no_promotion')})
        if gate:
            for pair, witnesses in sorted(predicted.items()):
                for witness in witnesses:
                    if not verify_ground(facts, item['domain'], item['relation'], shape, pair, witness):
                        raise ValueError('Invalid witness')
                    deps = sorted(set(witness['sources'] + [definition['reference']]))
                    invalid = bool(set(deps) & revoked)
                    claims.append({'claim': [item['domain'], item['target'], *pair],
                                   'derived_by': ident,
                                   'state': 'suspended' if invalid else 'demonstrated_conditional',
                                   'premise_sources': witness['sources'],
                                   'definition_source': definition['reference'],
                                   'depends_on': deps,
                                   'proof': {'shape': shape, 'via': witness['via']},
                                   'retracted_sources': sorted(set(deps) & revoked)})
    return {'schema_version': 1, 'rules': outcomes, 'claims': claims,
            'revoked_sources': sorted(revoked), 'note': 'No claim of external truth; all demonstrations assume source-labelled premises and accepted definitions.'}


def atomic_write(path, data):
    """Write a derived snapshot; the immutable experimental journal is elsewhere."""
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix='.trid04-', dir=path.parent)
    try:
        with os.fdopen(fd, 'w', encoding='utf-8') as fh:
            fh.write(canon(data) + '\n')
            fh.flush()
            os.fsync(fh.fileno())
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--fixture', type=Path, required=True)
    ap.add_argument('--journal', type=Path, required=True)
    ap.add_argument('--definitions', type=Path, required=True)
    ap.add_argument('--memory', type=Path, required=True)
    ap.add_argument('--approve', action='append', default=[])
    ap.add_argument('--revoke-source', action='append', default=[])
    args = ap.parse_args()
    data = json.loads(args.fixture.read_text(encoding='utf-8'))
    defs = json.loads(args.definitions.read_text(encoding='utf-8'))
    snapshot = project(data, read_journal(args.journal), defs, args.approve, args.revoke_source)
    atomic_write(args.memory, snapshot)
    print(canon({'rules': len(snapshot['rules']), 'claims': len(snapshot['claims']),
                 'suspended': sum(c['state'] == 'suspended' for c in snapshot['claims'])}))


if __name__ == '__main__':
    try:
        main()
    except (ValueError, KeyError, TypeError, OSError, json.JSONDecodeError) as exc:
        print('TRID 0.4: ' + str(exc), file=sys.stderr)
        sys.exit(1)
