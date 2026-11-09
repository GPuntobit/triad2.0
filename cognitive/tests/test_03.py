"""TRID 0.3 reference-tool tests; no GitHub or S1 runtime required."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("trid_discover03", ROOT / "tools" / "discover_03.py")
mod = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(mod)


class DiscoveryTests(unittest.TestCase):
    def setUp(self):
        self.data = json.loads((ROOT / "fixtures" / "discovery_03.json").read_text())

    def test_correct_patterns_learned_from_training(self):
        results = mod.search(self.data)
        picked = {r["target"]: r for r in results if r.get("selected")}
        self.assertEqual({"grandparent", "sibling"}, set(picked))
        self.assertEqual("chain", picked["grandparent"]["shape"])
        self.assertEqual("common_source", picked["sibling"]["shape"])
        self.assertTrue(all(r["heldout_pass"] for r in picked.values()))
        self.assertTrue(all(r["status"] == "experimental" for r in picked.values()))

    def test_negative_evidence_refutes_candidate_but_not_erased(self):
        results = mod.search(self.data)
        r = next(r for r in results if r["id"] == "family_grandparent_reverse_chain")
        self.assertEqual("refuted", r["status"])
        self.assertGreater(r["metrics"]["train_fp"] + r["metrics"]["test_fp"], 0)
        self.assertTrue(r["explicit_reviews"]["train_negative"])

    def test_missing_observation_is_not_negative_evidence(self):
        no_neg = json.loads(json.dumps(self.data))
        for item in no_neg["targets"]:
            item["train_negative"] = []
            item["test_negative"] = []
        results = mod.search(no_neg)
        self.assertTrue(all(r["status"] != "refuted" for r in results))

    def test_persistent_idempotent_integrity_and_history(self):
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / "journal.jsonl"
            self.assertTrue(mod.record_event(path, "h1", "evaluation", {"status": "experimental"}))
            self.assertFalse(mod.record_event(path, "h1", "evaluation", {"status": "experimental"}))
            self.assertTrue(mod.record_event(path, "h1", "evaluation", {"status": "refuted"}))
            self.assertEqual(2, len(path.read_text().splitlines()))
            records = [json.loads(line) for line in path.read_text().splitlines()]
            self.assertEqual("experimental", records[0]["payload"]["status"])
            self.assertEqual("refuted", records[1]["payload"]["status"])
            lines = path.read_text().splitlines()
            lines[0] = lines[0].replace("experimental", "falsified")
            path.write_text("\n".join(lines) + "\n")
            with self.assertRaises(ValueError):
                mod.record_event(path, "h1", "evaluation", {"status": "refuted"})

    def test_generated_s1_is_bounded_and_safe(self):
        selected = [r for r in mod.search(self.data) if r.get("selected")]
        for candidate in selected:
            code = mod.triad_program(self.data, candidate)
            self.assertIn("rule inferred(?x, ?z) :-", code)
            self.assertIn("?x != ?z", code)
            self.assertEqual(1, code.count("rule inferred"))
            self.assertLess(len(code.encode()), 65536)
        self.data["edges"][0]["source"] = "bad); println(:injected)"
        with self.assertRaises(ValueError):
            mod.validate_fixture(self.data)

    def test_separate_domains_and_witness_provenance(self):
        data = json.loads(json.dumps(self.data))
        data["edges"].append({"domain": "other", "relation": "parent", "from": "antonio", "to": "marco", "source": "other_book"})
        result = next(r for r in mod.search(data) if r["id"] == "family_grandparent_chain")
        self.assertNotIn(["mario", "marco"], result["predicted"])
        witness = next(p for p in result["proofs"] if p["pair"] == ["mario", "antonio"])["witnesses"][0]
        self.assertEqual("luca", witness["via"])
        self.assertEqual(["book_01", "book_02"], witness["sources"])


if __name__ == "__main__":
    unittest.main()
