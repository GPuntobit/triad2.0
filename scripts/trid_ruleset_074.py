#!/usr/bin/env python3
"""TRID-074: configure/verify the mandatory main-branch GitHub ruleset.

Run with GitHub CLI authenticated as repository administrator.
The script never reads or prints a GitHub token.
"""
import argparse
import json
import subprocess
import sys

REPOSITORY = "GPuntobit/triad2.0"
RULESET_ID = 26023880  # Existing, initially disabled triad repository ruleset
APP_ID = 15368  # GitHub Actions app, confirmed from main check runs
CHECKS = (
    "TRID / S0",
    "TRID / S1",
    "TRID / Epistemic",
    "TRID / Integration",
    "TRID / Conformance",
    "TRID / Merge Gate",
)


def gh_api(path, *, payload=None):
    cmd = ["gh", "api"]
    if payload is not None:
        cmd += ["--method", "PUT", "--input", "-"]
    cmd += [path]
    try:
        result = subprocess.run(
            cmd, input=json.dumps(payload) if payload is not None else None,
            text=True, check=True, capture_output=True,
        )
    except FileNotFoundError as exc:
        raise RuntimeError("GitHub CLI 'gh' missing; install github-cli") from exc
    except subprocess.CalledProcessError as exc:
        raise RuntimeError(
            f"GitHub API failed for {path}: {exc.stderr.strip() or exc.stdout.strip()}"
        ) from exc
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        raise RuntimeError("GitHub API returned invalid JSON") from exc


def validate_ruleset(ruleset, effective):
    def require(condition, message):
        if not condition:
            raise RuntimeError(f"TRID-074 VERIFY FAIL: {message}")

    require(ruleset.get("id") == RULESET_ID, "unexpected ruleset ID")
    require(ruleset.get("name") == "triad", "unexpected ruleset name")
    require(ruleset.get("target") == "branch", "ruleset target is not branch")
    require(ruleset.get("enforcement") == "active", "ruleset is not active")
    refs = ruleset.get("conditions", {}).get("ref_name", {})
    require("refs/heads/main" in refs.get("include", []), "main is not targeted")
    require(not refs.get("exclude"), "unexpected branch exclusions")
    # Absent field is unverifiable, therefore fail closed.
    require(ruleset.get("bypass_actors") == [], "bypass actors present or not readable")
    rules = {r["type"]: r for r in ruleset.get("rules", [])}
    require({"pull_request", "required_status_checks", "deletion", "non_fast_forward"}
            <= rules.keys(), "missing mandatory GitHub rules")
    pr = rules["pull_request"].get("parameters", {})
    require(isinstance(pr.get("required_approving_review_count"), int)
            and pr["required_approving_review_count"] >= 0,
            "required pull request parameters missing")
    require(pr.get("required_review_thread_resolution") is True,
            "review thread resolution not required")
    sc = rules["required_status_checks"].get("parameters", {})
    require(sc.get("strict_required_status_checks_policy") is True,
            "up-to-date head checks not required")
    actual_checks = {
        x.get("context"): x.get("integration_id")
        for x in sc.get("required_status_checks", [])
    }
    require(all(actual_checks.get(c) == APP_ID for c in CHECKS),
            "all six TRID GitHub Actions checks must be required and source-pinned")

    # Check effective rules on main, not only ruleset JSON.
    applied = [r for r in effective if r.get("ruleset_id") == RULESET_ID]
    require(any(r.get("type") == "pull_request" for r in applied),
            "GitHub does not apply the PR rule to main")
    applied_status = next((r.get("parameters", {}) for r in applied
                           if r.get("type") == "required_status_checks"), None)
    require(applied_status is not None,
            "GitHub does not apply the required check rule to main")
    applied_contexts = {
        x.get("context"): x.get("integration_id")
        for x in applied_status.get("required_status_checks", [])
    }
    require(all(applied_contexts.get(c) == APP_ID for c in CHECKS),
            "GitHub effective main rules are missing a required TRID check")
    require(applied_status.get("strict_required_status_checks_policy") is True,
            "GitHub effective main rules are not strict")
    print("TRID-074 ruleset active and effective on main: PASS")
    print(f"repository={REPOSITORY} ruleset_id={RULESET_ID} app_id={APP_ID}")
    print("required_checks=" + ", ".join(CHECKS))
    print(f"required_approvals={pr['required_approving_review_count']}")
    print("NOTE: perform a negative PR merge-blocking test for full DoD certification.")


def requested_configuration(approvals):
    return {
        "name": "triad", "target": "branch", "enforcement": "active",
        "bypass_actors": [],
        "conditions": {"ref_name": {"include": ["refs/heads/main"], "exclude": []}},
        "rules": [
            {"type": "deletion"},
            {"type": "non_fast_forward"},
            {"type": "pull_request", "parameters": {
                "dismiss_stale_reviews_on_push": True,
                "require_code_owner_review": False,
                "require_last_push_approval": False,
                "required_review_thread_resolution": True,
                "required_approving_review_count": approvals,
                "allowed_merge_methods": ["merge", "squash", "rebase"],
            }},
            {"type": "required_status_checks", "parameters": {
                "strict_required_status_checks_policy": True,
                "required_status_checks": [
                    {"context": context, "integration_id": APP_ID}
                    for context in CHECKS
                ],
            }},
        ],
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--verify", action="store_true", help="Read-only ruleset verification")
    mode.add_argument("--apply", action="store_true", help="Enable existing triad ruleset on main")
    parser.add_argument("--approvals", type=int, choices=(0, 1), default=0,
                        help="Independent reviewers, 0 for solo repositories (default)")
    args = parser.parse_args()
    url = f"repos/{REPOSITORY}/rulesets/{RULESET_ID}"
    current = gh_api(url)
    if args.apply:
        before_types = {"deletion", "non_fast_forward"}
        refs = current.get("conditions", {}).get("ref_name", {})
        types = {r.get("type") for r in current.get("rules", [])}
        if current.get("enforcement") == "active":
            print("Ruleset already active; verifying existing configuration")
        elif not (current.get("id") == RULESET_ID and
                  current.get("name") == "triad" and
                  current.get("target") == "branch" and
                  current.get("enforcement") == "disabled" and
                  current.get("bypass_actors") == [] and
                  refs.get("include", []) == [] and
                  refs.get("exclude", []) == [] and
                  types == before_types):
            raise RuntimeError("Existing triad ruleset changed; review manually before updating")
        else:
            print(f"Enabling ruleset {RULESET_ID} on main with {len(CHECKS)} mandatory checks")
            print(f"Required approving reviews: {args.approvals}")
            gh_api(url, payload=requested_configuration(args.approvals))
        current = gh_api(url)

    effective = gh_api(f"repos/{REPOSITORY}/rules/branches/main?per_page=100")
    if not isinstance(effective, list):
        raise RuntimeError("GitHub active branch rules endpoint did not return a list")
    validate_ruleset(current, effective)


if __name__ == "__main__":
    try:
        main()
    except RuntimeError as exc:
        print(f"TRID-074: {exc}", file=sys.stderr)
        raise SystemExit(1)
