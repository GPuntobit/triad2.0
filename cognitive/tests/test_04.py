"""Independent proof/kernel tests; no native S1 runtime required."""
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("trid_proof04", ROOT / "tools" / "proof_04.py")
mod = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(mod)

def event(seq, prev, hypothesis, kind, payload):
    item = {"seq": seq, "prev_hash": prev, "hypothesis_id": hypothesis,
            "kind": kind, "payload": payload}
    item["hash"] = hashlib.sha256(mod.canon(item).encode("ascii")).hexdigest()
    return item

class ProofTests(unittest.TestCase):
    def setUp(self):
        self.fixture = {"edges": [
            {"domain":"family","relation":"parent","from":"mario","to":"luca","source":"book_01"},
            {"domain":"family","relation":"parent","from":"luca","to":"antonio","source":"book_02"},
            {"domain":"family","relation":"parent","from":"sara","to":"leo","source":"book_03"},
            {"domain":"family","relation":"parent","from":"leo","to":"nina","source":"book_04"}]}
        self.definition = {"definitions": [{"domain":"family","target":"grandparent",
                           "relation":"parent","shape":"chain","reference":"definition_grandparent_01"}]}
        self.payload = {"domain":"family","target":"grandparent","relation":"parent",
                        "shape":"chain","selected":True,"status":"experimental",
                        "explicit_reviews":{
                            "train_positive":[["mario","antonio","r1"]],
                            "train_negative":[["antonio","mario","r2"]],
                            "test_positive":[["sara","nina","r3"]],
                            "test_negative":[["nina","sara","r4"]]},
                        "metrics":{"train_tp":1,"train_fp":0,"train_fn":0,
                                   "test_tp":1,"test_fp":0,"test_fn":0},
                        "predicted":[["mario","antonio"],["sara","nina"]]}
        self.id = "family_grandparent_chain"
        self.events = [event(1, "0"*64, self.id, "evaluation", self.payload)]

    def add_proof(self, sources=("book_01","book_02"), via="luca"):
        p = {"status":"demonstrated","scope":"assuming_experimental_rule",
             "epistemic_truth":"unverified","rule":self.id,
             "conclusion":["mario","antonio"],"witness":{"via":via,"sources":list(sources)}}
        self.events.append(event(len(self.events)+1, self.events[-1]["hash"],
                                 self.id, "conditional_proof", p))

    def test_independent_proof_checks_source_edges(self):
        facts = mod.fixture_edges(self.fixture)
        self.assertTrue(mod.verify_ground(facts, "family","parent","chain",
                        ["mario","antonio"],{"via":"luca","sources":["book_01","book_02"]}))
        self.assertFalse(mod.verify_ground(facts,"family","parent","chain",
                        ["mario","antonio"],{"via":"luca","sources":["book_01","fabricated"]}))
        self.assertFalse(mod.verify_ground(facts,"family","parent","chain",
                        ["mario","antonio"],{"via":"sara","sources":["book_01","book_02"]}))

    def test_explicit_approval_required_for_consolidation(self):
        without = mod.project(self.fixture,self.events,self.definition)
        self.assertEqual("experimental", without["rules"][0]["state"])
        self.assertEqual([],without["claims"])
        with_approval = mod.project(self.fixture,self.events,self.definition,[self.id])
        self.assertEqual("consolidated_conditional",with_approval["rules"][0]["state"])
        self.assertEqual(2,len(with_approval["claims"]))
        self.assertTrue(all(c["state"] == "demonstrated_conditional" for c in with_approval["claims"]))

    def test_revocation_suspends_only_dependents(self):
        snapshot = mod.project(self.fixture,self.events,self.definition,[self.id],["book_02"])
        states = {tuple(x["claim"][-2:]):x["state"] for x in snapshot["claims"]}
        self.assertEqual("suspended", states["mario","antonio"])
        self.assertEqual("demonstrated_conditional", states["sara","nina"])
        snapshot = mod.project(self.fixture,self.events,self.definition,[self.id],["definition_grandparent_01"])
        self.assertEqual("suspended_dependency",snapshot["rules"][0]["state"])
        self.assertTrue(all(x["state"] == "suspended" for x in snapshot["claims"]))

    def test_explicit_counterexample_blocks_promotion(self):
        self.payload["explicit_reviews"]["train_negative"].append(["mario","antonio","r5"])
        self.payload["metrics"]["train_fp"] = 1
        self.events[0] = event(1,"0"*64,self.id,"evaluation",self.payload)
        snapshot = mod.project(self.fixture,self.events,self.definition,[self.id])
        self.assertEqual("refuted",snapshot["rules"][0]["state"])
        self.assertEqual([],snapshot["claims"])

    def test_forged_proof_is_rejected(self):
        self.add_proof(sources=("book_01","fabricated"))
        with self.assertRaises(ValueError):
            mod.project(self.fixture,self.events,self.definition,[self.id])

    def test_false_metrics_are_rejected(self):
        self.payload["metrics"]["test_fp"] = 1
        self.events[0] = event(1,"0"*64,self.id,"evaluation",self.payload)
        with self.assertRaises(ValueError):
            mod.project(self.fixture,self.events,self.definition,[self.id])

    def test_journal_tampering_detected(self):
        with tempfile.TemporaryDirectory() as td:
            path=Path(td)/"journal.jsonl"
            path.write_text(mod.canon(self.events[0])+"\n")
            self.assertEqual(1,len(mod.read_journal(path)))
            path.write_text(path.read_text().replace("experimental","refuted"))
            with self.assertRaises(ValueError):
                mod.read_journal(path)

    def test_atomic_memory_snapshot(self):
        with tempfile.TemporaryDirectory() as td:
            path=Path(td)/"memory.json"
            v=mod.project(self.fixture,self.events,self.definition,[self.id])
            mod.atomic_write(path,v)
            self.assertEqual(v,json.loads(path.read_text()))
            mod.atomic_write(path,v)
            self.assertEqual(v,json.loads(path.read_text()))

    def test_ambiguous_definitions_fail_closed(self):
        with self.assertRaises(ValueError):
            mod.project(self.fixture,self.events,{"definitions":self.definition["definitions"]*2},[self.id])

    def test_fixture_observations_must_match_journal(self):
        fixture = json.loads(json.dumps(self.fixture))
        fixture["targets"] = [{
            "domain":"family","name":"grandparent","relation":"parent",
            "train_positive":[["mario","antonio","other_source"]],
            "train_negative":[["antonio","mario","r2"]],
            "test_positive":[["sara","nina","r3"]],
            "test_negative":[["nina","sara","r4"]]
        }]
        with self.assertRaises(ValueError):
            mod.project(fixture,self.events,self.definition,[self.id])

if __name__ == "__main__":
    unittest.main()
