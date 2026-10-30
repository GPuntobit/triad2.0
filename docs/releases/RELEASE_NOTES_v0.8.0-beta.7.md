# Triad 2.0 – Beta 7 (v0.8.0-beta.7)

## What's Changed

- `scripts/` split by purpose: build helpers in `scripts/docs/`
  (`build-libro.mjs`, `build-epub.cjs`, `build-docx.cjs`,
  `frontespizio.mjs`, `download_chart.py`), Windows seed wrappers in
  `scripts/seed-runner/`, one-off dev experiments in `scripts/experiments/`.
  Internal paths of the build scripts and the `download-chart.yml` workflow
  updated accordingly.
- Tutorial translations consolidated in `tutorial/` (moved
  `docs/TUTORIAL-RU.md` → `tutorial/TUTORIAL.ru.md`, alongside the existing
  `TUTORIAL.md`, `TUTORIAL.it.md`, `TUTORIAL.zh.md`); links in README, manual,
  site pages and build scripts updated.
- `README.md`: "Project Structure" section updated to the new layout.
- `scripts/download_chart.py`: repaired indentation/typos and use asset download
  counts; default repo fixed.
- `scripts/build-epub.cjs`, `scripts/build-libro.mjs`: repaired `continue` typo
  and variable mismatches.

**Full Changelog**: <https://github.com/GPuntobit/triad2.0/compare/v0.8.0-beta.6...v0.8.0-beta.7>
