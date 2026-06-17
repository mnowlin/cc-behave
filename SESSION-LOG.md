# Session Log — cc-behave

A running record of work done on this project. Newest session at the top.
Each entry follows the same structure: **Goal → What we did → Files changed →
Decisions → Verification → Open items**.

---

## 2026-06-17 — Citation keys, conceptual-model figure, structural-only SEM

**Goal:** Convert the manuscript's parenthetical citations to BibTeX cite keys
backed by the master bibliography, add a conceptual-model figure (Figure 1), and
split the combined SEM figure so the main text shows only the structural model.

### What we did

1. **Replaced every parenthetical citation** in `cc-behave.qmd` with Quarto `@`
   cite keys (33 cited works), cross-checked against the reference page of
   `Cultural Cognition revised clean.docx`.
2. **Discovered the bib pipeline:** the project-root `refs.bib` was a *copy* of
   the master; the pre-render step (`export-cited-refs.R`) regenerates
   `references.bib` from the master at `…/Manuscript-Files/refs.bib`, so every
   cite key must exist in the master. 29 of the 34 reference-page works were
   already there; the author added the missing 5 (Brick & Lewis 2016, Grendstad
   1999, Kaiser 2021, Kollmuss & Agyeman 2002, Kovacs 2024), plus Dunlap & Van
   Liere 1978 and Lou et al. 2022, to the Zotero master. Aligned one key mismatch
   (`kollmussMindGap2002` → `kollmussMindGapWhy2002`, the Zotero-generated key).
   Deleted the project-root `refs.bib` copy.
3. **Added the conceptual-model figure (Figure 1)** — cultural cognition → NEP →
   CNS → public/private behavior, pure black and white. Tried Mermaid, then
   Graphviz `dot`; both require a headless browser to rasterize for PDF/DOCX and
   hung (see Flags). Final implementation is a base-R graphics helper.
4. **Split the combined SEM figure:** the main text now shows a **structural-only**
   diagram (`fig-structural`); the **full** measurement + structure diagram moved
   to the supplement (`fig-serial`).

### Files created / changed

- `cc-behave.qmd` *(changed)* — parenthetical citations → `@`/`[-@…]` cite keys;
  added `fig-model` (base-R conceptual model); replaced the full SEM figure with
  the structural-only `fig-structural`.
- `cc-behave-supplemental.qmd` *(changed)* — added the full combined-model figure
  (`fig-serial`, measurement + structure) under a new section.
- `scripts/analysis-prep.R` *(changed)* — added `draw_sem_struct()` (structural-only
  SEM; keeps the observed PUBLIC/PRIVATE outcomes by dropping only indicator nodes
  via `semptools::drop_nodes` with an explicit layout, residual loops off) and
  `draw_concept_model()` (base-R Figure 1).
- `references.bib` *(regenerated)* — now populated by the pre-render step from the
  master (33 cited entries); not hand-maintained.
- `refs.bib` *(deleted)* — the project-root master copy, removed after the
  citation pass.
- Master bib `…/Manuscript-Files/refs.bib` *(author-edited via Zotero)* — 7
  references added (the 5 above + Dunlap & Van Liere 1978 + Lou et al. 2022).

### Decisions

- **Cite keys are validated against the master bib**, because
  `export-cited-refs.R` regenerates `references.bib` from it on every render. A
  hand-built `references.bib` is overwritten, so created entries had to land in
  the Zotero master, not just the local file.
- **Narrative citations** use author-in-prose + `[-@key]` (year only) to preserve
  wording; parenthetical citations use `[@key]`.
- **Figures are drawn in base-R graphics, not Mermaid/Graphviz** — diagram
  rasterization for PDF/DOCX needs a headless browser that does not work here (see
  Flags). R graphics render natively to all three formats (like the `semPaths`
  figures).
- **Main text = structural model only** (measurement omitted for clarity); the
  full measurement + structure diagram lives in the supplement.

### Verification

- `export-cited-refs.R` reports **33/33 cited keys matched** in the master; no
  unresolved `@key` literals in the rendered output.
- Both documents render to HTML/PDF/DOCX from a single `quarto render`;
  `cc-behave.qmd` alone renders in **~23 s** with no browser and no hang.
- Figures confirmed visually: conceptual model is B/W and correctly proportioned;
  the structural SEM includes PUBLIC and PRIVATE with significance stars.

### Notable findings / flags

- **Mermaid and Graphviz `dot` are unusable for PDF/DOCX in this environment.**
  No native Graphviz or `rsvg-convert` is installed, so Quarto falls back to a
  headless browser to rasterize diagrams — and that hangs: the bundled Chromium
  (v91) won't launch on this macOS, and the system Google Chrome (v149) stalls
  indefinitely (caused multi-hour render hangs). Use base-R/R graphics for any
  future diagram, or install native `graphviz` + `librsvg`.
- Three reference-page works (Kahan "Why We Are Poles Apart" 2012, Kline 2023,
  Schreiber et al. 2006) are in the master but **not cited** in the current qmd, so
  they won't appear in the rendered bibliography until cited.

### Open items / next steps

- Today's changes are **uncommitted** (`cc-behave.qmd`,
  `cc-behave-supplemental.qmd`, `scripts/analysis-prep.R`).
- Ensure the 7 author-added references **persist in the Zotero master** so a future
  re-export doesn't drop them (the pipeline depends on them being there).
- Manuscript prose (including the new VBN / ACF section scaffolding) continues to
  be authored by the user.

---

## 2026-06-16 (session 2) — Combined serial model, public/private split, supplement

**Goal:** Extend the analysis with a combined model chaining cultural cognition
→ NEP → CNS → behavior, split the behavior outcome into public vs. private, and
separate the paper into a main document and a supplement.

### What we did

1. **Built a combined serial model** (CC → NEP → CNS → behavior) and a **full
   model** that adds all direct paths; compared them.
2. **Split the behavior outcome** into observed PUBLIC (0–7) and PRIVATE (0–5)
   sum scores across every model.
3. **Separated the paper**: kept only the combined model in the main paper; moved
   the single-orientation (CNS-only, NEP-only) models and the mediation analysis
   into a new supplemental document.
4. Committed in two commits and pushed.

### Files created / changed

- `scripts/analysis-prep.R` *(changed)* — added the serial (`fitSerial`) and full
  (`fitFull`) models, fit-comparison table (`tbl5`), nested χ² test (`lrt_text`),
  and standardized effect decomposition (`tbl6`). Added `PUBLIC`/`PRIVATE`
  outcomes; updated the CNS/NEP/mediation/combined models and Tables 1, 4, 6 to
  the two-outcome structure. Full-model `:=` decomposition generated
  programmatically per worldview × outcome.
- `scripts/sem-serial.R` *(new)* — standalone runner for the combined model;
  prints summaries + comparison and writes CSVs + a path diagram.
- `cc-behave.qmd` *(changed)* — reduced Results to the combined model
  (`@fig-serial`, `@tbl-serial-fit`, `@tbl-serial-effects`); kept Tables 1–2 in
  Measures. Added `html` to output formats.
- `cc-behave-supplemental.qmd` *(new)* — CNS model, NEP model, their fit table,
  and the mediation table.
- `_quarto.yaml` *(changed)* — render both documents.
- `scripts/export-cited-refs.R` *(changed)* — scan the supplement for citations.

### Decisions

- **Public/private = observed sum scores** (not latent factors), consistent with
  the methods text; both outcomes estimated jointly with a correlated residual.
- **Main paper = combined model only**; everything else → supplement. Each
  document numbers figures/tables independently; cross-file `@refs` do not
  resolve (use plain text like "Supplemental Figure 1").
- **Commit split is by file/layer** (analysis vs. document), because the serial
  and public/private work are entangled in the same files and cannot be split by
  `git` without hunk surgery.

### Verification

- Combined model: full beats serial chain (Δχ²(14) = 78.66, p < .001); full-model
  CFI .921, RMSEA .062.
- Public/private split reveals divergent effects: egalitarianism direct on public
  (.21*) but fully mediated for private; communitarianism negative direct on
  private (−.16*); hierarchy negative total on private (−.24*).
- All six outputs (2 docs × HTML/PDF/DOCX) render from a single `quarto render`.

### Notable findings / flags

- **HTML was never being rendered by default** — both frontmatters listed only
  `pdf`/`docx`, overriding the project-level `html`. Fixed by adding `html` to
  both. (CLAUDE.md requires all three formats.)
- The public/private divergence (esp. the communitarianism suppression pattern on
  private behavior) may warrant its own short interpretive subsection.

### Open items / next steps

- `scripts/reproduce-analysis.R` still reflects the original single-outcome (total
  PEB) analysis — left as the faithful reproduction of the published paper.
- Optional: drop the duplicate RMSEA CI column from the fit-comparison table (it
  is identical across the two models).
- Manuscript prose (Introduction → Conclusion outline) still to be written by the
  author.

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
