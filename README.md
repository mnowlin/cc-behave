# Cultural Cognition, Environmental Orientation, and Pro-Environmental Behavior

Manuscript and reproducible analysis examining how cultural cognition relates to
pro-environmental behavior, mediated by environmental orientation as measured by
the New Ecological Paradigm (NEP) and the Connectedness to Nature Scale (CNS).

The analysis fits structural equation models (lavaan) and reproduces all tables
and figures reported in the manuscript.

## Layout

```
cc-behave.qmd                 Manuscript source (renders to HTML, PDF, DOCX)
cc-behave-supplemental.qmd    Supplemental materials (CNS-only/NEP-only models,
                               mediation table, full measurement+structure figure)
_quarto.yaml                  Quarto project config (renders both .qmd files)
_output/                      Rendered HTML/PDF/DOCX for both documents (tracked in git)
sustainability-template.dot   Word template used for the DOCX output
LOG.md                        Running session log (newest entry first)
scripts/
  analysis-prep.R             Sourced by both .qmd files: cleans data, fits SEMs,
                               builds the tables/figures (no side effects)
  sem-serial.R                Standalone: reruns the combined serial/full models,
                               writes CSVs + a path diagram to _output/reproduction/
  reproduce-analysis.R        Standalone script: prints results, writes CSVs + figures
  export-cited-refs.R         Pre-render step: trims the master .bib to cited keys
  legacy/                     Original exploratory scripts (superseded; see note below)
reference/                    Prior manuscript versions (Word) for comparison
data/                         Survey data + codebook (NOT in git -- see below)
```

## Reproducing the analysis

Requires R with: `lavaan`, `semTools`, `semPlot`, `semptools`, `psych`
(the scripts auto-install anything missing).

- **Console / CSV output:** `Rscript scripts/reproduce-analysis.R`
  (writes tables and figures to `_output/reproduction/`)
- **Full manuscript:** `quarto render` → outputs to `_output/`
  (HTML, PDF, and DOCX; the DOCX uses `sustainability-template.dot`)

## Data

The `data/` folder is **not tracked in git**. Restore it before rendering:

- `data/apsa17.csv` — survey responses (SSI, July 2017, N = 501 analyzed)
- `data/Values and Environmentalism Ques_4 to SSI-Codebook.docx` — codebook

## Notes

- `scripts/legacy/` holds the original `Data cleaning script.R` and
  `SEManalysis.R`. They are kept for reference only and are superseded by
  `analysis-prep.R`. Their internal relative paths (e.g. `source("Data cleaning
  script.R")`) assume they live in the project root, so run them from
  `scripts/legacy/` if needed.
- `references.bib` and the local `.csl` are generated at render time by the
  pre-render step from the master bibliography, so they are git-ignored.
- `_output/` **is tracked in git** (unlike most build artifacts) so the
  rendered manuscript is available without re-running R/Quarto. Re-render
  (`quarto render`) after any change to the `.qmd` files or `scripts/analysis-prep.R`
  and commit the updated files in `_output/` alongside the source change.
- `LOG.md` records what changed and why for each work session; add a new
  entry at the top rather than editing manuscript prose notes into commit
  messages.
