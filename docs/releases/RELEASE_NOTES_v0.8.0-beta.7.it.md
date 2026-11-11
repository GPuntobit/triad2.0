# Triad 2.0 – Beta 7 (v0.8.0-beta.7)

## Cosa è cambiato

- `scripts/` suddivisa per scopo: helper di build in `scripts/docs/`
  (`build-libro.mjs`, `build-epub.cjs`, `build-docx.cjs`,
  `frontespizio.mjs`, `download_chart.py`), wrapper seed Windows in
  `scripts/seed-runner/`, esperimenti dev one-off in `scripts/experiments/`.
  Aggiornati di conseguenza i percorsi interni degli script di build e del
  workflow `download-chart.yml`.
- Traduzioni del tutorial consolidate in `tutorial/` (spostato
  `docs/TUTORIAL-RU.md` → `tutorial/TUTORIAL.ru.md`, accanto ai già presenti
  `TUTORIAL.md`, `TUTORIAL.it.md`, `TUTORIAL.zh.md`); aggiornati i link in
  README, manuale, pagine del sito e script di build.
- `README.md`: sezione "Project Structure" aggiornata al nuovo layout.
- `scripts/download_chart.py`: riparata indentazione/typo e uso dei conteggi
  download degli asset; corretto il repository predefinito.
- `scripts/build-epub.cjs`, `scripts/build-libro.mjs`: riparato typo `continue`
  e mismatch di variabili.

**Changelog completo**: <https://github.com/GPuntobit/triad2.0/compare/v0.8.0-beta.6...v0.8.0-beta.7>
