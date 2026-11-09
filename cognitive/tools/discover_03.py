#!/usr/bin/env python3
"""Bounded ILP-style rule search and append-only lab for TRID 0.3.

Development/reference tool (Python stdlib), NOT self-hosted Triad cognition.
S1 remains the independent executor of generated .triad programs.
"""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import sys

ATOM = re.compile(r"^[a-z][a-z0-9_]*$")
# Two-link connected, range-restricted Horn-clause bodies over (X,Y,Z).
# Search enumerates *structures*, not pre-programmed domain predicates.
SHAPES = {
    "chain": (("X", "Y"), ("Y", "Z")),
    "reverse_chain": (("Y", "X"), ("Z", "Y")),
    "common_source": (("Y", "X"), ("Y", "Z")),
    "common_target": (("X", "Y"), ("Z", "Y")),
}


def canonical(x):
    return json.dumps(x, ensure_ascii=True, sort_keys=True, separators=(",", ":"))


def require_atom(value):
    if not isinstance(value, str) or not ATOM.fullmatch(value):
        raise ValueError(f"Invalid Triad atom: {value!r}")
    return value


def validate_fixture(data):
    if not isinstance(data, dict) or set(data) != {"edges", "targets"}:
        raise ValueError("Fixture requires exactly edges and targets")
    for row in data["edges"]:
        if set(row) != {"domain", "relation", "from", "to", "source"}:
            raise ValueError("Invalid edge fields")
        for val in row.values():
            require_atom(val)
    for row in data["targets"]:
        if set(row) != {"domain", "name", "relation", "train_positive", "train_negative", "test_positive", "test_negative"}:
            raise ValueError("Invalid target fields")
        for key in ("domain", "name", "relation"):
            require_atom(row[key])
        for field in ("train_positive", "train_negative", "test_positive", "test_negative"):
            for pair in row[field]:
                if not isinstance(pair, list) or len(pair) != 3:
                    raise ValueError("Every example must be [from,to,review_source]")
                for val in pair:
                    require_atom(val)
        if not row["train_positive"] or not row["test_positive"]:
            raise ValueError("Require independent train/test positive examples")
    if not data["targets"]:
        raise ValueError("At least one target required")


def evaluate_shape(edges, relation, shape):
    """Enumerate all grounded proofs and preserve intermediate witness/sources."""
    first, second = SHAPES[shape]
    relevant = [e for e in edges if e["relation"] == relation]
    proofs = {}
    for a in relevant:
        for b in relevant:
            values = {}
            consistent = True
            for (left, right), edge in ((first, a), (second, b)):
                for var, val in ((left, edge["from"]), (right, edge["to"])):
                    if var in values and values[var] != val:
                        consistent = False
                        break
                    values[var] = val
                if not consistent:
                    break
            if not consistent or values["X"] == values["Z"]:
                continue
            pair = (values["X"], values["Z"])
            witness = {"via": values["Y"], "sources": [a["source"], b["source"]]}
            proofs.setdefault(pair, [])
            if witness not in proofs[pair]:
                proofs[pair].append(witness)
    return proofs


def assess(proofs, row):
    predicted = set(proofs)
    examples = {key: {(p[0], p[1]) for p in row[key]} for key in
                ("train_positive", "train_negative", "test_positive", "test_negative")}
    return {"train_tp": len(predicted & examples["train_positive"]),
            "train_fp": len(predicted & examples["train_negative"]),
            "train_fn": len(examples["train_positive"] - predicted),
            "test_tp": len(predicted & examples["test_positive"]),
            "test_fp": len(predicted & examples["test_negative"]),
            "test_fn": len(examples["test_positive"] - predicted)}


def search(data):
    results = []
    for target in data["targets"]:
        edges = [e for e in data["edges"] if e["domain"] == target["domain"]]
        candidates = []
        for shape in sorted(SHAPES):
            proofs = evaluate_shape(edges, target["relation"], shape)
            metrics = assess(proofs, target)
            # Selection depends on TRAIN only; held-out data never chooses model.
            score = 3 * metrics["train_tp"] - 5 * metrics["train_fp"] - 2 * metrics["train_fn"]
            candidate_id = f"{target['domain']}_{target['name']}_{shape}"
            status = "refuted" if metrics["train_fp"] or metrics["test_fp"] else "experimental"
            candidates.append({"id": candidate_id, "domain": target["domain"],
                "target": target["name"], "relation": target["relation"],
                "shape": shape, "score": score, "status": status,
                "metrics": metrics, "explicit_reviews": {key: target[key] for key in ("train_positive", "train_negative", "test_positive", "test_negative")}, "predicted": [list(p) for p in sorted(proofs)],
                "proofs": [{"pair": list(p), "witnesses": proofs[p]} for p in sorted(proofs)]})
        candidates.sort(key=lambda c: (-c["score"], c["id"]))
        best = candidates[0]
        # A learned rule is not proven even with excellent train/held-out scores.
        best["selected"] = True
        best["heldout_pass"] = best["metrics"]["test_tp"] == len(target["test_positive"]) and best["metrics"]["test_fp"] == 0
        if best["metrics"]["train_tp"] == 0 or best["metrics"]["train_fp"]:
            best["selected"] = False
        results.extend(candidates)
    return results


def record_event(store, hypothesis, kind, payload):
    """Append-only, sha256-chained, locked and deduplicated event journal."""
    store.parent.mkdir(parents=True, exist_ok=True)
    with open(store, "a+", encoding="utf-8") as stream:
        fcntl.flock(stream, fcntl.LOCK_EX)
        stream.seek(0)
        history = []
        prev = "0" * 64
        for line in stream:
            e = json.loads(line)
            claimed = e.pop("hash")
            digest = hashlib.sha256(canonical(e).encode("ascii")).hexdigest()
            if digest != claimed or e["prev_hash"] != prev or e["seq"] != len(history) + 1:
                raise ValueError("Event journal corruption detected")
            e["hash"] = claimed
            history.append(e)
            prev = claimed
        if any(e["kind"] == kind and e["hypothesis_id"] == hypothesis and e["payload"] == payload for e in history):
            return False
        e = {"seq": len(history) + 1, "kind": kind, "hypothesis_id": hypothesis,
             "payload": payload, "prev_hash": prev}
        e["hash"] = hashlib.sha256(canonical(e).encode("ascii")).hexdigest()
        stream.seek(0, os.SEEK_END)
        stream.write(canonical(e) + "\n")
        stream.flush()
        os.fsync(stream.fileno())
        return True


def triad_program(data, candidate):
    if candidate["status"] == "refuted" or not candidate.get("selected"):
        raise ValueError("Refuse to export a rejected or non-selected candidate")
    variables = {"X": "?x", "Y": "?y", "Z": "?z"}
    expressions = []
    for left, right in SHAPES[candidate["shape"]]:
        expressions.append(f"edge(:{candidate['domain']}, :{candidate['relation']}, {variables[left]}, {variables[right]}, ?src{len(expressions)+1})")
    lines = ["# Generated by TRID 0.3 development tool; schema remains an unproven hypothesis."]
    for e in data["edges"]:
        lines.append(f"fact edge(:{e['domain']}, :{e['relation']}, :{e['from']}, :{e['to']}, :{e['source']})")
    lines.append(f"rule inferred(?x, ?z) :- {', '.join(expressions)}, ?x != ?z")
    lines.append("println([s.z for s in solve inferred(?x, ?z)])")
    result = "\n".join(lines) + "\n"
    if len(result.encode("utf-8")) > 65535:
        raise ValueError("Generated S1 program exceeds 65535 bytes")
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--fixture", type=Path, required=True)
    parser.add_argument("--store", type=Path, required=True)
    parser.add_argument("--generated-dir", type=Path, required=True)
    args = parser.parse_args()
    data = json.loads(args.fixture.read_text(encoding="utf-8"))
    validate_fixture(data)
    candidates = search(data)
    args.generated_dir.mkdir(parents=True, exist_ok=True)
    for item in candidates:
        payload = {k: v for k, v in item.items() if k != "id"}
        record_event(args.store, item["id"], "evaluation", payload)
        if item.get("selected") and item["status"] != "refuted":
            # A proof establishes a ground derivation *conditional on this
            # experimental schema*. It does not certify the schema as true.
            for proof in item["proofs"]:
                for witness in proof["witnesses"]:
                    record_event(args.store, item["id"], "conditional_proof", {
                        "status": "demonstrated", "scope": "assuming_experimental_rule",
                        "conclusion": proof["pair"], "witness": witness,
                        "rule": item["id"], "epistemic_truth": "unverified"})
            program = triad_program(data, item)
            (args.generated_dir / (item["domain"] + "_" + item["target"] + ".triad")).write_text(program, encoding="utf-8")
    print(canonical([{"id": c["id"], "status": c["status"], "selected": c.get("selected", False), "heldout_pass": c.get("heldout_pass", False)} for c in candidates]))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError) as err:
        print(f"TRID 0.3: {err}", file=sys.stderr)
        sys.exit(1)
