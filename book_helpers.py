"""Shared helpers for the local book validation scripts."""
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def git_show(rel: str) -> str:
    """Return a UTF-8 file from the repository's HEAD revision."""
    relative_path = Path(rel.replace("\\", "/"))
    if (
        not rel
        or rel.endswith(("/", "\\"))
        or not relative_path.name
        or relative_path.is_absolute()
        or ".." in relative_path.parts
    ):
        raise ValueError(f"Git path must be repository-relative: {rel!r}")

    git_path = relative_path.as_posix()
    try:
        (ROOT / relative_path).resolve().relative_to(ROOT)
    except ValueError as error:
        raise ValueError(f"Git path must stay within the repository: {rel!r}") from error

    git_executable = shutil.which("git")
    if git_executable is None:
        raise RuntimeError("Unable to read HEAD: git executable was not found on PATH")

    try:
        result = subprocess.run(
            [git_executable, "-C", str(ROOT), "show", f"HEAD:{git_path}"],
            capture_output=True,
            check=True,
        )
    except subprocess.CalledProcessError as error:
        details = error.stderr.decode("utf-8", errors="replace").strip()
        raise RuntimeError(f"Unable to read HEAD:{git_path}: {details or error}") from error
    except OSError as error:
        raise RuntimeError(f"Unable to run git while reading HEAD:{git_path}: {error}") from error

    try:
        return result.stdout.decode("utf-8")
    except UnicodeDecodeError as error:
        raise RuntimeError(f"HEAD:{git_path} is not valid UTF-8") from error
