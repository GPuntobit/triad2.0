"""Shared helpers for the local book validation scripts."""
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def git_show(rel: str) -> str:
    """Return a UTF-8 file from the repository's HEAD revision."""
    try:
        result = subprocess.run(
            ["git", "-C", str(ROOT), "show", f"HEAD:{rel}"],
            capture_output=True,
            check=True,
            text=True,
            encoding="utf-8",
        )
    except subprocess.CalledProcessError as error:
        details = error.stderr.strip() if error.stderr else str(error)
        raise RuntimeError(f"Unable to read HEAD:{rel}: {details}") from error
    return result.stdout
