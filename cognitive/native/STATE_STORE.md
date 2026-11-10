# TRID-005 — atomic S0 journal/projection state

This is a **Linux filesystem transport protocol**, not cognitive reasoning.
Native Triad still performs discovery and independent verification. The shell
only validates, stages, hashes, and publishes serialized output.

## On-disk layout

    $TRID_STATE_DIR/
      .mutex                            # permanent flock inode
      .current -> .revisions/r00000003  # single atomic commit pointer
      hypotheses.log -> .current/hypotheses.log
      memory.txt -> .current/memory.txt
      .revisions/r00000001/{hypotheses.log,memory.txt,checksums.sha256}
      .revisions/r00000003/{hypotheses.log,memory.txt,checksums.sha256}
      .backups/r00000001/{hypotheses.log,memory.txt,checksums.sha256}
      .legacy/{hypotheses.log,memory.txt}  # after explicit --migrate

Both files and their SHA-256 checksums are built in a private working directory,
flushed and renamed into a complete revision. Only then does the **single**
`.current` symbolic link change using GNU `mv -Tf` on the same filesystem.
Journal and memory are never published via two independent renames.
Revision IDs may skip after a crashed candidate. SHA-256 checksums detect
incidental modification, **not** hostile rewriting of checksums too.

## Operations (Linux x86-64)

    TRID_STATE_DIR="$HOME/my-trid" sh cognitive/native/run.sh --recover
    TRID_STATE_DIR="$HOME/my-trid" sh cognitive/native/run.sh --backup
    TRID_STATE_DIR="$HOME/my-trid" sh cognitive/native/run.sh --restore r00000001
    TRID_STATE_DIR="$HOME/legacy-trid" sh cognitive/native/run.sh --migrate

- `--recover` validates the published revision, repairs missing views and
  removes abandoned `.work.*` directories. It NEVER guesses a previous
  revision when `.current` or its checksum is invalid.
- `--backup` makes a checked revision copy in `.backups/<revision>`; it
  refuses to overwrite a backup with different bytes.
- `--restore` validates a chosen backup and publishes it as a **new** revision,
  leaving the old revisions intact. An explicit restore is allowed even if
  the active data were modified.
- `--migrate` is required for the historical pair of regular files. It
  creates one new revision, retains originals in `.legacy/`, and replaces
  root filenames with symlinks. Interrupted migration can be resumed using
  the valid current revision; no implicit migration occurs during a run.
- Linux `flock` owns a permanent `.mutex` inode, released automatically
  when the process terminates. The lock file itself is never unlinked.

## Read consistency and guarantees

The top-level compatibility symlinks both point through `.current`, but a
reader opening them in **separate operations without locking** could cross
one atomic pointer change. A pair reader must hold a matching `flock` on
`.mutex`, or capture a single immutable revision directory and read both
files from it. Directly editing a committed file bypasses the protocol and
causes the next checksum check to fail.

When the pointer has not switched, an interrupted writer leaves the previous
complete pair active. After the switch, it leaves the new pair active.
`TRID_TEST_CRASH_AT=after_stage|before_pointer|after_pointer` is a
test-only SIGKILL hook used to check these outcomes.

This is not a distributed transaction, a signed or authenticated journal,
a guarantee of power-loss durability on every filesystem, or native Triad
persistence. It requires Linux `flock`, GNU `mv -T`, `sync -f`, `sha256sum`
and a local filesystem with atomic same-directory rename. Backups on the
same drive are not a substitute for separately stored disaster backups.

Run `sh cognitive/native/tests/run_store.sh` and the five-suite same-SHA
cognitive baseline before merging.
