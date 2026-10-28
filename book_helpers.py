"""Shared helpers for the local book validation scripts."""
import os
import subprocess  # nosec B404
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def approved_executable(value: str | Path, names: set[str]) -> Path:
    candidate = Path(value)
    if not candidate.is_absolute():
        raise ValueError("Executable path must be absolute")
    resolved = candidate.resolve(strict=True)
    if os.path.normcase(os.path.abspath(candidate)) != os.path.normcase(str(resolved)):
        raise ValueError("Executable path must not use symlinks")
    if candidate.name.casefold() not in names or not resolved.is_file():
        raise ValueError(f"Executable path must point to one of: {', '.join(sorted(names))}")
    return resolved


def git_show(rel: str, git_executable: str | Path) -> str:
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

    git_executable_path = approved_executable(git_executable, {"git", "git.exe"})

    try:
        # nosemgrep: python.lang.security.audit.dangerous-subprocess-use-audit.dangerous-subprocess-use-audit
        result = subprocess.run(  # nosec B603
            [str(git_executable_path), "-C", str(ROOT), "show", f"HEAD:{git_path}"],
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
