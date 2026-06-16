# Session Log — cc-behave

A running record of work done on this project. Newest session at the top.
Each entry follows the same structure: **Goal → What we did → Files changed →
Decisions → Verification → Open items**.

---

## 2026-06-16 — Reproduce analysis, wire into manuscript, set up repo

**Goal:** Reproduce the analysis from `Cultural Cognition revised clean.docx`
in R, wire the tables/figures into the Quarto manuscript, organize the project
folder, and put it under version control.

### What we did

1. **Reproduced the SEM analysis** from the two original scripts (`Data cleaning
   script.R`, `SEManalysis.R`) against `data/apsa17.csv`, consolidating the logic
   into a clean standalone script and verifying every number against the
   manuscript.
2. **Wired tables and figures into `cc-behave.qmd`** via a side-effect-free prep
   script that the `.qmd` sources. Confirmed rendering to HTML, PDF, and DOCX.
3. **Discussed SEM fit sufficiency** (see Decisions) and **added TLI + RMSEA 90%
   CI** to the model-fit table.
4. **Switched the DOCX output** to use `sustainability-template.dot`.
5. **Organized the folder** (moderate reorg) and **initialized git**.
6. **Moved `.git` outside OneDrive** to avoid sync corruption.
7. **Created a private GitHub repo and pushed.**

### Files created / changed

- `scripts/analysis-prep.R` *(new)* — sourced by the `.qmd`; cleans data, fits
  SEMs, builds Tables 1–4 and a `draw_sem()` figure helper. No printing/writing.
- `scripts/reproduce-analysis.R` *(new)* — standalone; prints results and writes
  CSVs + figures to `_output/reproduction/`.
- `scripts/export-cited-refs.R` *(user-added; I fixed it)* — pre-render step that
  trims the master `.bib` to cited keys. Fixed a zero-match crash (`unlist()`
  returned `NULL` → `writeLines()` failed) by wrapping in `as.character()`.
- `cc-behave.qmd` *(changed)* — setup chunk sources the prep script; added six
  labelled chunks: `@tbl-behaviors`, `@tbl-measurement`, `@fig-cns`, `@fig-nep`,
  `@tbl-fit`, `@tbl-mediation`. DOCX `reference-doc` → `sustainability-template.dot`.
- `README.md` *(new)*, `.gitignore` *(new)*, `SESSION-LOG.md` *(new, this file)*.
- Reorg: `reference/` ← `Cultural Cognition revised clean.docx`, `Appendix.docx`;
  `scripts/legacy/` ← original `Data cleaning script.R`, `SEManalysis.R`.
- Deleted junk: `.DS_Store` files, `.Rhistory`, 5 OneDrive "conflicted copy" files.

### Decisions

- **Reliability (Table 2):** compute CR/AVE from a pure measurement CFA (six
  latents correlated, no structural paths). The original used the full structural
  model, which distorts the endogenous CNS/NEP factors under current `semTools`
  (CNS reliability came out 0.144). CFA approach gives the values matching the
  manuscript (CNS CR = .72, NEP = .73).
- **Git ignores:** `data/`, `archive/`, `lit-review/`, plus all build artifacts
  and pre-render-generated `references.bib` / `.csl`. Consequence: a fresh clone
  can't render until `data/` is restored.
- **GitHub repo is private** (unpublished manuscript referencing data).
- **`.git` relocated** to `~/git-repos/cc-behave.git` (outside OneDrive); the
  in-project `.git` is now a pointer file.

### Verification

- All reproduced numbers match the manuscript: egal→CNS .28, comm→CNS .19,
  CNS→behave .42, egal→behave .19; PEB mean 5.52 / sd 2.98; N = 501.
- Mediation (Table 4): egal→CNS direct .189 / indirect .118 / total .307;
  comm→CNS indirect .078, total .111 (p<.10) — match the paper.
- All three formats render via `quarto render`. DOCX confirmed to carry the
  template's body font (Palatino Linotype).
- GitHub: `mnowlin/cc-behave` (private), `main` pushed and tracking `origin/main`.

### Notable findings / flags

- **Likely typo in the manuscript:** NEP-model egalitarianism *indirect* effect is
  printed as `0.118` (same as the CNS row); the correct value is `0.175`
  (0.585 × 0.298). Worth correcting in the paper.
- **SEM fit:** CNS model fits well (RMSEA .050, CFI .956, TLI .942, SRMR .050).
  NEP model is acceptable but borderline on stricter indices (RMSEA .074,
  CI upper .083; CFI .915; TLI .887; χ²/df ≈ 3.8). Both pass the Schreiber et al.
  (2006) cutoffs the paper cites; the CNS-better-than-NEP asymmetry supports the
  paper's argument.

### Open items / next steps

- `data/` not in git — restore before rendering on a new clone.
- Manuscript prose is written by the author; chunks are placed in document order
  and referenced via `@tbl-…` / `@fig-…`.
- Optional: commit `_freeze/` for render-without-data reproducibility (currently
  ignored). Optional: clean up SEM figure node labels (currently raw variable
  names like `cc_eh_2`, `EGA`, `BEH`).
- Multi-machine: prefer `git clone` outside OneDrive over syncing the folder
  (the `.git` pointer holds an absolute path).

---

<!-- Template for future entries — copy below the line and fill in:

## YYYY-MM-DD — <short title>

**Goal:**

### What we did

### Files created / changed

### Decisions

### Verification

### Open items / next steps

-->
