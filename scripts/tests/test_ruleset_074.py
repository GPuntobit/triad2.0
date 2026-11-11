#!/usr/bin/env python3
"""Offline TRID-074 regression: verify fail-closed ruleset checks."""
import copy
import importlib.util
import pathlib
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parents[1] / "trid_ruleset_074.py"
spec = importlib.util.spec_from_file_location("trid_ruleset_074", SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def fixtures(approvals=0):
    ruleset = module.requested_configuration(approvals)
    ruleset["id"] = module.RULESET_ID
    effective = [dict(copy.deepcopy(x), ruleset_id=module.RULESET_ID)
                 for x in ruleset["rules"]]
    return ruleset, effective


class RulesetTests(unittest.TestCase):
    def test_required_six_actions_checks(self):
        ruleset, effective = fixtures()
        module.validate_ruleset(ruleset, effective)

    def test_independent_review_mode(self):
        ruleset, effective = fixtures(1)
        module.validate_ruleset(ruleset, effective)

    def test_disabled_fails(self):
        ruleset, effective = fixtures()
        ruleset["enforcement"] = "disabled"
        with self.assertRaisesRegex(RuntimeError, "not active"):
            module.validate_ruleset(ruleset, effective)

    def test_bypass_actor_fails(self):
        ruleset, effective = fixtures()
        ruleset["bypass_actors"] = [{"actor_type": "RepositoryRole", "actor_id": 5}]
        with self.assertRaisesRegex(RuntimeError, "bypass"):
            module.validate_ruleset(ruleset, effective)

    def test_no_main_target_fails(self):
        ruleset, effective = fixtures()
        ruleset["conditions"]["ref_name"]["include"] = ["refs/heads/dev"]
        with self.assertRaisesRegex(RuntimeError, "main is not targeted"):
            module.validate_ruleset(ruleset, effective)

    def test_each_missing_check_fails(self):
        for context in module.CHECKS:
            with self.subTest(context=context):
                ruleset, effective = fixtures()
                status = next(r for r in ruleset["rules"]
                              if r["type"] == "required_status_checks")["parameters"]
                status["required_status_checks"] = [
                    r for r in status["required_status_checks"]
                    if r["context"] != context
                ]
                with self.assertRaisesRegex(RuntimeError, "all six"):
                    module.validate_ruleset(ruleset, effective)

    def test_wrong_source_fails(self):
        ruleset, effective = fixtures()
        status = next(r for r in ruleset["rules"]
                      if r["type"] == "required_status_checks")["parameters"]
        status["required_status_checks"][0]["integration_id"] = None
        with self.assertRaisesRegex(RuntimeError, "source-pinned"):
            module.validate_ruleset(ruleset, effective)

    def test_missing_effective_rules_fail(self):
        ruleset, effective = fixtures()
        effective.clear()
        with self.assertRaisesRegex(RuntimeError, "does not apply"):
            module.validate_ruleset(ruleset, effective)

    def test_effective_missing_check_fails(self):
        ruleset, effective = fixtures()
        status = next(x for x in effective if x["type"] == "required_status_checks")
        status["parameters"]["required_status_checks"].pop()
        with self.assertRaisesRegex(RuntimeError, "effective main"):
            module.validate_ruleset(ruleset, effective)

    def test_not_strict_fails(self):
        ruleset, effective = fixtures()
        next(x for x in ruleset["rules"] if x["type"] == "required_status_checks")[
            "parameters"]["strict_required_status_checks_policy"] = False
        with self.assertRaisesRegex(RuntimeError, "up-to-date"):
            module.validate_ruleset(ruleset, effective)


if __name__ == "__main__":
    unittest.main(verbosity=2)
