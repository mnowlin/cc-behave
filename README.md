# Cultural Cognition, Environmental Orientation, and Pro-Environmental Behavior

Manuscript and reproducible analysis examining how cultural cognition relates to
pro-environmental behavior, mediated by environmental orientation as measured by
the New Ecological Paradigm (NEP) and the Connectedness to Nature Scale (CNS).

The analysis fits structural equation models (lavaan) and reproduces all tables
and figures reported in the manuscript.

## Layout

```
cc-behave.qmd              Manuscript source (renders to HTML, PDF, DOCX)
_quarto.yaml               Quarto project config
sustainability-template.dot  Word template used for the DOCX output
scripts/
  analysis-prep.R          Sourced by the .qmd: cleans data, fits SEMs,
                           builds Tables 1-4 and the figure helper (no side effects)
  reproduce-analysis.R     Standalone script: prints results, writes CSVs + figures
  export-cited-refs.R      Pre-render step: trims the master .bib to cited keys
  legacy/                  Original exploratory scripts (superseded; see note below)
reference/                 Prior manuscript versions (Word) for comparison
data/                      Survey data + codebook (NOT in git -- see below)
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
