## =====================================================================
## analysis-prep.R
##
## Side-effect-free preparation for the manuscript
##   "Cultural Cognition, Environmental Orientation, and
##    Pro-Environmental Behavior"
##
## Sourced by cc-behave.qmd. Loads packages, cleans the data, fits the
## SEMs, and builds the data frames for Tables 1-4 plus a draw_sem()
## helper for Figures 2 & 3. It does NOT print, write files, or plot.
##
## Objects created for the .qmd to use:
##   fitCNS, fitNEP, fitMeas   -- fitted lavaan models
##   tbl1                      -- Table 1 (behaviors)
##   tbl2                      -- Table 2 (measurement items + reliability)
##   tbl3                      -- Table 3 (model fit)
##   tbl4                      -- Table 4 (mediation effects)
##   draw_sem(fit)             -- renders a SEM path diagram
##   n_sample, peb_mean, peb_sd
## =====================================================================

## ---- packages -------------------------------------------------------
.pkgs <- c("psych", "lavaan", "semTools", "semPlot", "semptools")
.missing <- .pkgs[!vapply(.pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(.missing)) {
  install.packages(.missing, repos = "https://cloud.r-project.org")
}
suppressPackageStartupMessages({
  library(psych); library(lavaan); library(semTools)
  library(semPlot); library(semptools)
})

## ---- locate project root (robust to cwd) ----------------------------
.find_proj <- function() {
  for (p in c(".", "..", "../..")) {
    if (file.exists(file.path(p, "data/apsa17.csv"))) return(normalizePath(p))
  }
  stop("Could not locate data/apsa17.csv relative to the working directory.")
}
.proj <- .find_proj()

## =====================================================================
## 1. DATA CLEANING  (from "Data cleaning script.R")
## =====================================================================
envatt <- read.csv(file.path(.proj, "data/apsa17.csv"))

## controls
envatt$age      <- envatt$q75
envatt$female   <- ifelse(envatt$q76 == 2, 1, 0)
envatt$male     <- ifelse(envatt$q76 == 1, 1, 0)
envatt$hhincome <- envatt$q83
envatt$Ideology <- ifelse(envatt$q80 == 8, 4, envatt$q80)   # "haven't thought" -> moderate
envatt$Dem      <- ifelse(envatt$q78 == 1 | envatt$q79c == 1, 1, 0)
envatt$Rep      <- ifelse(envatt$q78 == 2 | envatt$q79c == 2, 1, 0)
envatt$urban    <- envatt$q81
envatt$educ     <- envatt$q82
## race/ethnicity is a check-all-that-apply item (q77_1..q77_5: Black,
## Asian, Hispanic, White, Other); q77_4 is the White/Caucasian checkbox.
envatt$white    <- envatt$q77_4

## cultural cognition: egalitarianism-hierarchy (cc_eh_1..14)
for (i in 1:7)  envatt[[paste0("cc_eh_", i)]] <- envatt[[paste0("q1x31_", i)]]
for (i in 8:14) envatt[[paste0("cc_eh_", i)]] <- 5 - envatt[[paste0("q1x31_", i)]]

## cultural cognition: communitarianism-individualism (cc_ci_1..17)
for (i in 1:12)  envatt[[paste0("cc_ci_", i)]] <- envatt[[paste0("q1x31_", i + 14)]]
for (i in 13:17) envatt[[paste0("cc_ci_", i)]] <- 5 - envatt[[paste0("q1x31_", i + 14)]]

## New Ecological Paradigm (nep1..15)
.nep_src <- c("q46x59_46","q46x59_47","q46x59_48","q46x59_491","q46x59_492",
              "q46x59_50","q46x59_51","q46x59_52","q46x59_53","q46x59_54",
              "q46x59_55","q46x59_56","q46x59_57","q46x59_58","q46x59_59")
for (i in seq_along(.nep_src)) envatt[[paste0("nep", i)]] <- envatt[[.nep_src[i]]]
for (i in c(2,4,6,8,10,12,14)) envatt[[paste0("nep", i, "_r")]] <- 6 - envatt[[paste0("nep", i)]]

## Connectedness to Nature Scale (cns1..14)
.cns_src <- paste0("q32x45_", 32:45)
for (i in seq_along(.cns_src)) envatt[[paste0("cns", i)]] <- envatt[[.cns_src[i]]]
for (i in c(4,12,14)) envatt[[paste0("cns", i, "_r")]] <- 6 - envatt[[paste0("cns", i)]]

## DV: 13 binary pro-environmental behaviors.
## NOTE: data suffix _NN corresponds to codebook item NN+1 (verified by content).
.behave_src <- c(product = "q62x74_62", act.org = "q62x74_63", cand = "q62x74_64",
                 money.org = "q62x74_65", cont.off = "q62x74_66", cont.bus = "q62x74_67",
                 petition = "q62x74_68", meeting = "q62x74_69", water = "q62x74_70",
                 buycott = "q62x74_71", recycle = "q62x74_72", energy = "q62x74_73",
                 stocks = "q62x74_74")
for (nm in names(.behave_src)) envatt[[nm]] <- ifelse(envatt[[.behave_src[nm]]] == 1, 1, 0)

envatt$public  <- rowSums(envatt[c("act.org","cand","money.org","cont.off",
                                   "cont.bus","petition","meeting")], na.rm = TRUE)
envatt$private <- rowSums(envatt[c("product","water","buycott","recycle","energy")],
                          na.rm = TRUE)
envatt$PEB    <- rowSums(envatt[c("public","private","stocks")])   # total, 0-13
envatt$BEHAVE <- envatt$PEB
# Split observed outcomes used in the SEMs: PUBLIC (0-7), PRIVATE (0-5).
# `stocks` is in neither index (dropped from PRIVATE in a prior review).
envatt$PUBLIC  <- envatt$public
envatt$PRIVATE <- envatt$private
envatt$BEHAVE12 <- envatt$PUBLIC + envatt$PRIVATE   # PUBLIC + PRIVATE only, 0-12; tbl1 total

## =====================================================================
## 2. REVERSE-CODE THE ITEMS USED IN THE SEMs  (from "SEManalysis.R")
## =====================================================================
for (v in c("cc_eh_2","cc_eh_5","cc_eh_7",
            "cc_ci_2","cc_ci_3","cc_ci_12")) envatt[[v]] <- 5 - envatt[[v]]
for (v in c("cns2","cns6","cns7"))           envatt[[v]] <- 6 - envatt[[v]]
for (v in c("nep5","nep15"))                 envatt[[v]] <- 6 - envatt[[v]]

## =====================================================================
## 3. SEM MODELS
## =====================================================================
## Demographic controls added to every structural (endogenous) regression
## below: age, gender (male), race (white), education (educ, 1-6 ordinal),
## and household income (hhincome, 1-8 ordinal). Kept out of the path
## diagrams (draw_sem*() drop them as manifest nodes) for readability;
## their estimates are still in the underlying lavaan fits and any table
## built from parameterEstimates()/standardizedSolution().
.ctrl_vars <- c("age", "male", "white", "educ", "hhincome")
.ctrl_rhs  <- paste(.ctrl_vars, collapse = " + ")

.semModelCNS <- paste0('
  HIER  =~ cc_eh_2 + cc_eh_5 + cc_eh_7
  EGAL  =~ cc_eh_11 + cc_eh_13 + cc_eh_14
  INDIV =~ cc_ci_2 + cc_ci_3 + cc_ci_12
  COMM  =~ cc_ci_13 + cc_ci_14 + cc_ci_16
  CNS   =~ cns2 + cns6 + cns7
  CNS     ~ HIER + EGAL + INDIV + COMM + ', .ctrl_rhs, '
  PUBLIC  ~ CNS + HIER + EGAL + INDIV + COMM + ', .ctrl_rhs, '
  PRIVATE ~ CNS + HIER + EGAL + INDIV + COMM + ', .ctrl_rhs, '
')
.semModelNEP <- paste0('
  HIER  =~ cc_eh_2 + cc_eh_5 + cc_eh_7
  EGAL  =~ cc_eh_11 + cc_eh_13 + cc_eh_14
  INDIV =~ cc_ci_2 + cc_ci_3 + cc_ci_12
  COMM  =~ cc_ci_13 + cc_ci_14 + cc_ci_16
  NEP   =~ nep5 + nep10 + nep15
  NEP     ~ HIER + EGAL + INDIV + COMM + ', .ctrl_rhs, '
  PUBLIC  ~ NEP + HIER + EGAL + INDIV + COMM + ', .ctrl_rhs, '
  PRIVATE ~ NEP + HIER + EGAL + INDIV + COMM + ', .ctrl_rhs, '
')
fitCNS <- sem(.semModelCNS, data = envatt)
fitNEP <- sem(.semModelNEP, data = envatt)

n_sample <- lavInspect(fitCNS, "nobs")
peb_mean <- round(mean(envatt$PEB, na.rm = TRUE), 2)
peb_sd   <- round(sd(envatt$PEB,   na.rm = TRUE), 2)

## =====================================================================
## 4. TABLE 1 -- self-reported pro-environmental behaviors
## =====================================================================
.behave_label <- c(
  product   = "Avoided using products that harm the environment",
  act.org   = "Been active in a group/organization that works to protect the environment",
  cand      = "Voted for or worked for candidates because of their environmental positions",
  money.org = "Contributed money to an environmental, conservation, or wildlife group",
  cont.off  = "Contacted a public official about an environmental issue",
  cont.bus  = "Contacted a business to complain about environmentally harmful products/policies",
  petition  = "Signed a petition supporting environmental protection",
  meeting   = "Attended a meeting concerning the environment",
  water     = "Tried to use less water in your household",
  buycott   = "Bought a product because it was better for the environment",
  recycle   = "Voluntarily recycled newspapers, glass, aluminum, motor oil, etc.",
  energy    = "Reduced your household's use of energy")

# behavior items grouped by type (public = 7, private = 5)
.public_vars  <- c("act.org","cand","money.org","cont.off","cont.bus","petition","meeting")
.private_vars <- c("product","water","buycott","recycle","energy")
.btype <- setNames(rep("Public", length(.public_vars)), .public_vars)
.btype[.private_vars] <- "Private"

.item_row <- function(v) data.frame(
  Behavior = .behave_label[[v]], Type = .btype[[v]],
  Mean = round(mean(envatt[[v]], na.rm = TRUE), 2),
  SD   = round(sd(envatt[[v]],   na.rm = TRUE), 2),
  row.names = NULL, check.names = FALSE)
.sum_row <- function(label, score) data.frame(
  Behavior = label, Type = "",
  Mean = round(mean(envatt[[score]], na.rm = TRUE), 2),
  SD   = round(sd(envatt[[score]],   na.rm = TRUE), 2),
  row.names = NULL, check.names = FALSE)

tbl1 <- rbind(
  do.call(rbind, lapply(.public_vars,  .item_row)),
  .sum_row("Public behaviors (0-7)",  "PUBLIC"),
  do.call(rbind, lapply(.private_vars, .item_row)),
  .sum_row("Private behaviors (0-5)", "PRIVATE"),
  .sum_row("Total behaviors (0-12)",  "BEHAVE12"))

## =====================================================================
## 5. TABLE 2 -- measurement items + reliability (alpha, CR, AVE)
## =====================================================================
.constructs <- list(
  Hierarchy        = c("cc_eh_2","cc_eh_5","cc_eh_7"),
  Egalitarianism   = c("cc_eh_11","cc_eh_13","cc_eh_14"),
  Individualism    = c("cc_ci_2","cc_ci_3","cc_ci_12"),
  Communitarianism = c("cc_ci_13","cc_ci_14","cc_ci_16"),
  CNS              = c("cns2","cns6","cns7"),
  NEP              = c("nep5","nep10","nep15"))

## Cronbach's alpha per construct
.alpha <- sapply(.constructs, function(items)
  suppressMessages(psych::alpha(envatt[items], warnings = FALSE)$total$raw_alpha))

## CR and AVE from a pure measurement model (all six latents correlated,
## no structural paths) so the endogenous CNS/NEP factors are not distorted.
.measModel <- '
  HIER  =~ cc_eh_2 + cc_eh_5 + cc_eh_7
  EGAL  =~ cc_eh_11 + cc_eh_13 + cc_eh_14
  INDIV =~ cc_ci_2 + cc_ci_3 + cc_ci_12
  COMM  =~ cc_ci_13 + cc_ci_14 + cc_ci_16
  CNS   =~ cns2 + cns6 + cns7
  NEP   =~ nep5 + nep10 + nep15
'
fitMeas <- cfa(.measModel, data = envatt)
.cr  <- unlist(compRelSEM(fitMeas))   # ordered: HIER EGAL INDIV COMM CNS NEP
.ave <- AVE(fitMeas)
names(.cr)  <- names(.constructs)
names(.ave) <- names(.constructs)

## combined table: item rows with mean/sd; alpha/CR/AVE on first row per
## construct only (blank on the rest for a clean published-style layout)
.first <- function(x, n) c(formatC(x, format = "f", digits = 2), rep("", n - 1))
tbl2 <- do.call(rbind, lapply(names(.constructs), function(cn) {
  items <- .constructs[[cn]]
  data.frame(
    Construct = c(cn, rep("", length(items) - 1)),
    Item = items,
    Mean = round(sapply(items, function(v) mean(envatt[[v]], na.rm = TRUE)), 2),
    SD   = round(sapply(items, function(v) sd(envatt[[v]],   na.rm = TRUE)), 2),
    Alpha = .first(.alpha[cn], length(items)),
    CR    = .first(.cr[cn],    length(items)),
    AVE   = .first(.ave[cn],   length(items)),
    row.names = NULL, check.names = FALSE)
}))
names(tbl2)[names(tbl2) == "Alpha"] <- "α"   # Greek alpha

## =====================================================================
## 6. TABLE 3 -- model fit statistics
## =====================================================================
.fit_row <- function(fit, label) {
  fm <- fitMeasures(fit, c("chisq","df","rmsea","rmsea.ci.lower",
                           "rmsea.ci.upper","cfi","tli","srmr"))
  data.frame(Model = label,
             N     = lavInspect(fit, "nobs"),
             df    = as.integer(fm[["df"]]),
             "Chi-sq" = round(fm[["chisq"]], 2),
             RMSEA = round(fm[["rmsea"]], 3),
             "RMSEA 90% CI" = sprintf("[%.3f, %.3f]",
                                      fm[["rmsea.ci.lower"]], fm[["rmsea.ci.upper"]]),
             CFI   = round(fm[["cfi"]],   3),
             TLI   = round(fm[["tli"]],   3),
             SRMR  = round(fm[["srmr"]],  3),
             check.names = FALSE)
}
tbl3 <- rbind(.fit_row(fitCNS, "CNS"), .fit_row(fitNEP, "NEP"))

## =====================================================================
## 7. TABLE 4 -- mediation analysis (direct / indirect / total)
## =====================================================================
.stars <- function(p) ifelse(is.na(p), "",
                  ifelse(p < .001, "***", ifelse(p < .01, "**",
                  ifelse(p < .05, "*",  ifelse(p < .10, "†", "")))))
.fmt <- function(est, p) paste0(formatC(est, format = "f", digits = 3), .stars(p))

# mediation with two observed outcomes (PUBLIC, PRIVATE) estimated jointly;
# demographic controls added to every regression (orient, PUBLIC, PRIVATE)
.med_model <- function(focal, others, orient, items) paste0(
  "HIER  =~ cc_eh_2 + cc_eh_5 + cc_eh_7\n",
  "EGAL  =~ cc_eh_11 + cc_eh_13 + cc_eh_14\n",
  "INDIV =~ cc_ci_2 + cc_ci_3 + cc_ci_12\n",
  "COMM  =~ cc_ci_13 + cc_ci_14 + cc_ci_16\n",
  orient, " =~ ", items, "\n",
  orient, " ~ a*", focal, " + ", paste(others, collapse = " + "), " + ", .ctrl_rhs, "\n",
  "PUBLIC  ~ cu*", focal, " + ", paste(others, collapse = " + "), " + ", .ctrl_rhs, "\n",
  "PRIVATE ~ cv*", focal, " + ", paste(others, collapse = " + "), " + ", .ctrl_rhs, "\n",
  "PUBLIC  ~ bu*", orient, "\n",
  "PRIVATE ~ bv*", orient, "\n",
  "ab_pub  := a*bu\n  ab_prv  := a*bv\n",
  "tot_pub := cu + a*bu\n  tot_prv := cv + a*bv\n")

.med_specs <- list(
  list(label = "Egalitarianism → CNS",    focal = "EGAL", others = c("HIER","INDIV","COMM"), orient = "CNS", items = "cns2 + cns6 + cns7"),
  list(label = "Communitarianism → CNS",  focal = "COMM", others = c("EGAL","HIER","INDIV"), orient = "CNS", items = "cns2 + cns6 + cns7"),
  list(label = "Egalitarianism → NEP",    focal = "EGAL", others = c("HIER","INDIV","COMM"), orient = "NEP", items = "nep5 + nep10 + nep15"),
  list(label = "Communitarianism → NEP",  focal = "COMM", others = c("EGAL","HIER","INDIV"), orient = "NEP", items = "nep5 + nep10 + nep15"))

tbl4 <- do.call(rbind, lapply(.med_specs, function(s) {
  fit <- sem(.med_model(s$focal, s$others, s$orient, s$items), data = envatt)
  ss  <- standardizedSolution(fit)
  pick <- function(lhs, op, rhs) {
    r <- ss[ss$lhs == lhs & ss$op == op & ss$rhs == rhs, ]
    c(est = r$est.std[1], p = r$pvalue[1])
  }
  pickdef <- function(lhs) {
    r <- ss[ss$lhs == lhs & ss$op == ":=", ]
    c(est = r$est.std[1], p = r$pvalue[1])
  }
  row <- function(outcome, dv, indlab, totlab) {
    dir <- pick(dv, "~", s$focal); ind <- pickdef(indlab); tot <- pickdef(totlab)
    data.frame(Path = s$label, Outcome = outcome,
               Direct = .fmt(dir["est"], dir["p"]),
               Indirect = .fmt(ind["est"], ind["p"]),
               Total = .fmt(tot["est"], tot["p"]),
               row.names = NULL)
  }
  rbind(row("Public",  "PUBLIC",  "ab_pub", "tot_pub"),
        row("Private", "PRIVATE", "ab_prv", "tot_prv"))
}))

## =====================================================================
## 8. FIGURE HELPER (Figures 2 & 3)
## =====================================================================
## Demographic controls (.ctrl_vars) are dropped from the diagram for
## readability -- their paths are estimated in `fit` and reported in the
## tables, just not drawn here.
draw_sem <- function(fit) {
  spm <- semPlot::semPlotModel(fit)
  spm <- semptools::drop_nodes(spm, intersect(.ctrl_vars, spm@Vars$name))
  p <- semPaths(spm, whatLabels = "std", sizeMan = 5, node.width = 1,
                edge.label.cex = .75, style = "ram", rotation = 2,
                mar = c(5, 5, 5, 5), DoNotPlot = TRUE)
  plot(mark_sig(p, fit))
}

## Drop edges from a semPaths() qgraph object whose underlying lavaan
## parameter is not significant at `alpha`, matching each drawn edge back
## to parameterEstimates() by its endpoint node names (rather than by the
## qgraph edge index, which is not stable once edges are removed).
.keep_sig_edges <- function(p, fit, alpha = .05) {
  pe   <- lavaan::parameterEstimates(fit)
  nm   <- p$graphAttributes$Nodes$names
  from <- nm[p$Edgelist$from]
  to   <- nm[p$Edgelist$to]
  pval <- mapply(function(f, t) {
    r <- pe$pvalue[pe$lhs == t & pe$op == "~"  & pe$rhs == f]
    if (!length(r)) r <- pe$pvalue[pe$lhs == f & pe$op == "~~" & pe$rhs == t]
    if (!length(r)) r <- pe$pvalue[pe$lhs == t & pe$op == "~~" & pe$rhs == f]
    if (length(r)) r[1] else NA
  }, from, to)
  keep <- !is.na(pval) & pval < alpha
  el <- p$Edgelist
  p$Edgelist <- list(from = el$from[keep], to = el$to[keep],
                      weight = el$weight[keep], directed = el$directed[keep],
                      bidirectional = el$bidirectional[keep])
  p$graphAttributes$Edges <- lapply(p$graphAttributes$Edges, function(v) {
    if (is.matrix(v)) v[keep, , drop = FALSE]
    else if (length(v) == length(keep)) v[keep]
    else v
  })
  p$graphAttributes$Graph$edgesort <- seq_len(sum(keep))
  ## qgraph objects also echo the raw call arguments in $Arguments; plot.qgraph
  ## consults some of these directly, so they need the same edge filter or a
  ## stale (pre-filter) length-35 vector gets recycled against the new edges.
  p$Arguments <- lapply(p$Arguments, function(v) {
    if (is.matrix(v) && nrow(v) == length(keep)) v[keep, , drop = FALSE]
    else if (length(v) == length(keep)) v[keep]
    else v
  })
  ## plotOptions$srt (per-edge label rotation) is a [nEdges x 4] matrix keyed
  ## by the same edge order; leaving it at the pre-filter edge count makes
  ## plot.qgraph recycle it against the shorter edge list.
  p$plotOptions <- lapply(p$plotOptions, function(v) {
    if (is.matrix(v) && nrow(v) == length(keep)) v[keep, , drop = FALSE]
    else if (length(v) == length(keep)) v[keep]
    else v
  })
  p
}

## semPaths draws each covariance as a pair of mirrored directed edges (to
## get the double-line "lens" look); both copies carry their own label.
## When the two lines sit close together (adjacent nodes) the labels land on
## top of each other and look like one; once curved further apart the
## duplicate becomes visible (and can differ by a star if standard errors
## round near a cutoff). Blank the second copy's label so each covariance is
## only labeled once.
.dedupe_cov_labels <- function(p) {
  nm  <- p$graphAttributes$Nodes$names
  key <- paste(pmin(p$Edgelist$from, p$Edgelist$to),
               pmax(p$Edgelist$from, p$Edgelist$to))
  dup <- duplicated(key)
  p$graphAttributes$Edges$labels[dup] <- ""
  p
}

## Structural-only variant: drop the measurement indicators but keep the
## observed behavior outcomes (PUBLIC, PRIVATE) alongside the latent
## constructs, so the diagram shows the full structural chain
## (worldviews -> NEP -> CNS -> public/private behavior). Used in the main
## text; the full version with the measurement model lives in the supplement.
## Only paths (regressions and covariances) significant at p < .05 are drawn.
draw_sem_struct <- function(fit) {
  spm  <- semPlot::semPlotModel(fit)
  drop <- setdiff(spm@Vars$name[spm@Vars$manifest], c("PUBLIC", "PRIVATE"))
  spm  <- semptools::drop_nodes(spm, drop)
  ## node order follows spm@Vars: PUBLIC PRIVATE HIER EGAL INDIV COMM NEP CNS
  lay <- matrix(c(
     2.0,  0.8,   # PUBLIC
     2.0, -0.8,   # PRIVATE
    -2.0,  1.5,   # HIER
    -2.0,  0.5,   # EGAL
    -2.0, -0.5,   # INDIV
    -2.0, -1.5,   # COMM
    -0.7,  0.0,   # NEP
     0.7,  0.0),  # CNS
    ncol = 2, byrow = TRUE)
  p <- semPaths(spm, whatLabels = "std", style = "ram", layout = lay,
                residuals = FALSE, sizeMan = 9, sizeMan2 = 6, nCharNodes = 0,
                edge.label.cex = .8, mar = c(4, 6, 4, 6), DoNotPlot = TRUE)
  ## HIER and COMM sit two slots away from INDIV and EGAL respectively on the
  ## same vertical line, so their covariance edges would otherwise be drawn
  ## straight through the intervening node. Bow them out to the left.
  p <- semptools::set_curve(p, c("HIER ~~ INDIV" = -1.4, "INDIV ~~ HIER" = -1.4,
                                  "EGAL ~~ COMM" = -1.4, "COMM ~~ EGAL" = -1.4))
  p <- mark_sig(p, fit)
  p <- .dedupe_cov_labels(p)
  plot(.keep_sig_edges(p, fit))
}

## Structural-only variant of the HIER-INDIV/EGAL-COMM full model (section
## 10 below): same treatment as draw_sem_struct(), but with a two-node
## layout since HIER_INDIV and EGAL_COMM replace the four separate
## worldview latents.
draw_sem_struct_hiec <- function(fit) {
  spm  <- semPlot::semPlotModel(fit)
  ## HIER_INDIV/EGAL_COMM are observed (manifest = TRUE), unlike the four
  ## latent worldviews in draw_sem_struct(), so they must be spared here too.
  keep <- c("PUBLIC", "PRIVATE", "HIER_INDIV", "EGAL_COMM")
  drop <- setdiff(spm@Vars$name[spm@Vars$manifest], keep)
  spm  <- semptools::drop_nodes(spm, drop)
  ## node order follows spm@Vars: PUBLIC PRIVATE HIER_INDIV EGAL_COMM NEP CNS
  lay <- matrix(c(
     2.0,  0.8,   # PUBLIC
     2.0, -0.8,   # PRIVATE
    -2.0,  0.7,   # HIER_INDIV
    -2.0, -0.7,   # EGAL_COMM
    -0.7,  0.0,   # NEP
     0.7,  0.0),  # CNS
    ncol = 2, byrow = TRUE)
  p <- semPaths(spm, whatLabels = "std", style = "ram", layout = lay,
                residuals = FALSE, sizeMan = 9, sizeMan2 = 6, nCharNodes = 0,
                edge.label.cex = .8, mar = c(4, 6, 4, 6), DoNotPlot = TRUE)
  p <- mark_sig(p, fit)
  p <- .dedupe_cov_labels(p)
  p <- .keep_sig_edges(p, fit)
  p <- semptools::change_node_label(p, c(
    PUBLIC = "Public\nBehavior", PRIVATE = "Private\nBehavior",
    HIER_INDIV = "HIER-\nINDIV", EGAL_COMM = "EGAL-\nCOMM"))
  plot(p)
}

## Conceptual model diagram (Figure 1), drawn with base graphics so it
## renders natively to HTML/PDF/DOCX without a headless browser. Pure black
## and white: cultural cognition -> NEP -> CNS -> public/private behavior.
draw_concept_model <- function() {
  op <- par(mar = c(0, 0, 0, 0), family = "serif"); on.exit(par(op))
  plot.new(); plot.window(xlim = c(0, 11.2), ylim = c(0, 3), asp = 1)
  hw <- 1.18; hh <- 0.55
  box <- function(cx, cy, lab) {
    rect(cx - hw, cy - hh, cx + hw, cy + hh, col = "white", border = "black", lwd = 1.3)
    text(cx, cy, lab, col = "black", cex = 0.85)
  }
  arr <- function(x0, y0, x1, y1)
    arrows(x0, y0, x1, y1, length = 0.10, angle = 20, lwd = 1.4, col = "black")
  ## Plain (arrowless) connector spanning a chain of box centers, labeled
  ## above each segment, used to name construct pairs without implying
  ## direction. Each box gets a short vertical tick dropping from the line
  ## to its top edge; the line itself has a small gap at interior ticks
  ## (e.g., NEP, shared by the Cognition and Environmental Orientation
  ## segments) so the tick reads as a divider between segments rather than
  ## letting them run together into one unbroken line.
  bracket <- function(xs, y, box_top, labs, gap = 0.09) {
    n <- length(xs)
    for (i in seq_len(n - 1)) {
      x0 <- xs[i] + if (i > 1) gap else 0
      x1 <- xs[i + 1] - if (i + 1 < n) gap else 0
      segments(x0, y, x1, y, lwd = 1.1, col = "black")
      text((xs[i] + xs[i + 1]) / 2, y + 0.2, labs[i], col = "black", cex = 0.65, family = "serif")
    }
    for (x in xs) segments(x, y, x, box_top, lwd = 1.1, col = "black")
  }
  cc <- c(1.30, 1.5); nep <- c(4.00, 1.5); cns <- c(6.70, 1.5)
  pub <- c(9.9, 2.35); priv <- c(9.9, 0.65)
  arr(cc[1] + hw, cc[2], nep[1] - hw, nep[2])
  arr(nep[1] + hw, nep[2], cns[1] - hw, cns[2])
  arr(cns[1] + hw, cns[2] + 0.18, pub[1] - hw, pub[2] - 0.12)
  arr(cns[1] + hw, cns[2] - 0.18, priv[1] - hw, priv[2] + 0.12)
  bracket(c(cc[1], nep[1], cns[1]), cc[2] + hh + 0.15, cc[2] + hh,
          c("Cognition", "Environmental Orientation"))
  box(cc[1], cc[2], "Cultural\nWorldviews")
  box(nep[1], nep[2], "Ecological\nWorldviews (NEP)")
  box(cns[1], cns[2], "Connectedness\nto Nature (CNS)")
  box(pub[1], pub[2], "Public\nBehavior")
  box(priv[1], priv[2], "Private\nBehavior")
}

## =====================================================================
## 9. COMBINED SERIAL MODEL: CC -> NEP -> CNS -> BEHAVE
##    fitSerial = strict chain (no direct paths)
##    fitFull   = chain + all direct paths (CC->CNS, CC->BEHAVE, NEP->BEHAVE)
##    tbl5 = fit comparison; tbl6 = standardized effect decomposition
## =====================================================================
.measSerial <- '
  HIER  =~ cc_eh_2 + cc_eh_5 + cc_eh_7
  EGAL  =~ cc_eh_11 + cc_eh_13 + cc_eh_14
  INDIV =~ cc_ci_2 + cc_ci_3 + cc_ci_12
  COMM  =~ cc_ci_13 + cc_ci_14 + cc_ci_16
  NEP   =~ nep5 + nep10 + nep15
  CNS   =~ cns2 + cns6 + cns7
'
.serialModel <- paste0(.measSerial, '
  NEP     ~ HIER + EGAL + INDIV + COMM + ', .ctrl_rhs, '
  CNS     ~ NEP + ', .ctrl_rhs, '
  PUBLIC  ~ CNS + ', .ctrl_rhs, '
  PRIVATE ~ CNS + ', .ctrl_rhs, '
')

## Full model with direct paths to both observed outcomes. Worldview codes:
## H=HIER, E=EGAL, I=INDIV, K=COMM. Outcome prefixes: u=PUBLIC, v=PRIVATE.
## a*=CC->NEP, d=NEP->CNS, m*=CC->CNS. Decomposition := generated per
## worldview x outcome below. Demographic controls are added to every
## equation but left unlabeled (their coefficients aren't part of the
## decomposition, just partialled out of the worldview/NEP/CNS effects).
.wv_full <- c(H = "HIER", E = "EGAL", I = "INDIV", K = "COMM")
.reg_full <- c(
  paste0("NEP     ~ aH*HIER + aE*EGAL + aI*INDIV + aK*COMM + ", .ctrl_rhs),
  paste0("CNS     ~ d*NEP + mH*HIER + mE*EGAL + mI*INDIV + mK*COMM + ", .ctrl_rhs),
  paste0("PUBLIC  ~ uCNS*CNS + uNEP*NEP + uH*HIER + uE*EGAL + uI*INDIV + uK*COMM + ", .ctrl_rhs),
  paste0("PRIVATE ~ vCNS*CNS + vNEP*NEP + vH*HIER + vE*EGAL + vI*INDIV + vK*COMM + ", .ctrl_rhs))
.defs_full <- unlist(lapply(names(.wv_full), function(x) c(
  sprintf("dirP_%s := u%s",                          x, x),                # direct, public
  sprintf("serP_%s := a%s*d*uCNS",                   x, x),                # serial NEP->CNS, public
  sprintf("indP_%s := a%s*uNEP + m%s*uCNS + a%s*d*uCNS", x, x, x, x),      # total indirect, public
  sprintf("totP_%s := u%s + a%s*uNEP + m%s*uCNS + a%s*d*uCNS", x, x, x, x, x),
  sprintf("dirR_%s := v%s",                          x, x),                # direct, private
  sprintf("serR_%s := a%s*d*vCNS",                   x, x),
  sprintf("indR_%s := a%s*vNEP + m%s*vCNS + a%s*d*vCNS", x, x, x, x),
  sprintf("totR_%s := v%s + a%s*vNEP + m%s*vCNS + a%s*d*vCNS", x, x, x, x, x))))
.fullModel <- paste(c(.measSerial, .reg_full, .defs_full), collapse = "\n")

fitSerial <- sem(.serialModel, data = envatt)
fitFull   <- sem(.fullModel,   data = envatt)

## ---- Table 5: fit comparison ----
.cmp_row <- function(fit, label) {
  fm <- fitMeasures(fit, c("chisq","df","cfi","tli","rmsea",
                           "rmsea.ci.lower","rmsea.ci.upper","srmr","aic","bic"))
  data.frame(Model = label,
             "Chi-sq" = round(fm[["chisq"]], 2), df = as.integer(fm[["df"]]),
             CFI = round(fm[["cfi"]], 3), TLI = round(fm[["tli"]], 3),
             RMSEA = round(fm[["rmsea"]], 3),
             "RMSEA 90% CI" = sprintf("[%.3f, %.3f]",
                                      fm[["rmsea.ci.lower"]], fm[["rmsea.ci.upper"]]),
             SRMR = round(fm[["srmr"]], 3),
             AIC = round(fm[["aic"]], 1), BIC = round(fm[["bic"]], 1),
             check.names = FALSE)
}
tbl5 <- rbind(.cmp_row(fitSerial, "Serial chain"),
              .cmp_row(fitFull,   "Full (+ direct paths)"))

## nested chi-square difference test (serial chain is nested in full)
.lrt <- lavTestLRT(fitSerial, fitFull)
.i   <- which(!is.na(.lrt[["Chisq diff"]]))[1]
lrt_text <- sprintf(
  "Nested $\\chi^2$ difference test (serial chain nested in full model): $\\Delta\\chi^2(%d) = %.2f$, $p = %.4f$. The direct paths jointly improve fit.",
  .lrt[["Df diff"]][.i], .lrt[["Chisq diff"]][.i], .lrt[["Pr(>Chisq)"]][.i])

## ---- Table 6: standardized effect decomposition (from the full model) ----
.ssFull <- standardizedSolution(fitFull)
.getdef <- function(name) {
  r <- .ssFull[.ssFull$op == ":=" & .ssFull$lhs == name, ]
  .fmt(r$est.std[1], r$pvalue[1])
}
.wv <- c(Egalitarianism = "E", Communitarianism = "K",
         Hierarchy = "H", Individualism = "I")
.decomp_row <- function(nm, x, outcome, pfx) data.frame(
  Predictor = nm, Outcome = outcome,
  Direct             = .getdef(paste0("dir", pfx, "_", x)),
  "Serial (NEP→CNS)" = .getdef(paste0("ser", pfx, "_", x)),
  "Total indirect"   = .getdef(paste0("ind", pfx, "_", x)),
  Total              = .getdef(paste0("tot", pfx, "_", x)),
  row.names = NULL, check.names = FALSE)
tbl6 <- do.call(rbind, lapply(names(.wv), function(nm) rbind(
  .decomp_row(nm, .wv[[nm]], "Public",  "P"),
  .decomp_row(nm, .wv[[nm]], "Private", "R"))))

## =====================================================================
## 10. EXPLORATORY: HIER-INDIV / EGAL-COMM COMPOSITE GROUPS
##    Collapses the four worldview latents into the two composite,
##    dichotomous groups common in the cultural cognition literature:
##    Hierarch-Individualists (top half of both HIER and INDIV) and
##    Egalitarian-Communitarians (top half of both EGAL and COMM).
##    Re-runs the section 9 serial-chain/full model with HIER_INDIV and
##    EGAL_COMM as observed predictors in place of the four separate
##    worldview latents. Supplement-only (cc-behave-supplemental.qmd)
##    while this is being explored; NOT wired into the main-text objects
##    above (fitSerial/fitFull/tbl5/tbl6 are unchanged).
## =====================================================================
.wv_items <- list(
  HIER  = c("cc_eh_2", "cc_eh_5", "cc_eh_7"),
  EGAL  = c("cc_eh_11", "cc_eh_13", "cc_eh_14"),
  INDIV = c("cc_ci_2", "cc_ci_3", "cc_ci_12"),
  COMM  = c("cc_ci_13", "cc_ci_14", "cc_ci_16"))
for (nm in names(.wv_items)) {
  envatt[[paste0(nm, "_score")]] <- rowMeans(envatt[.wv_items[[nm]]], na.rm = TRUE)
}
## "top half" = at or above that scale's own median.
.top_half <- function(x) x >= median(x, na.rm = TRUE)
envatt$HIER_INDIV <- as.integer(.top_half(envatt$HIER_score) & .top_half(envatt$INDIV_score))
envatt$EGAL_COMM  <- as.integer(.top_half(envatt$EGAL_score)  & .top_half(envatt$COMM_score))

## ---- Table: group sizes ----
tbl_hiec_n <- data.frame(
  Group = c("Hierarch-Individualist (HIER-INDIV)", "Egalitarian-Communitarian (EGAL-COMM)",
            "Both", "Neither"),
  N = c(sum(envatt$HIER_INDIV == 1, na.rm = TRUE),
        sum(envatt$EGAL_COMM  == 1, na.rm = TRUE),
        sum(envatt$HIER_INDIV == 1 & envatt$EGAL_COMM == 1, na.rm = TRUE),
        sum(envatt$HIER_INDIV == 0 & envatt$EGAL_COMM == 0, na.rm = TRUE)),
  Percent = round(100 * c(
    mean(envatt$HIER_INDIV == 1, na.rm = TRUE),
    mean(envatt$EGAL_COMM  == 1, na.rm = TRUE),
    mean(envatt$HIER_INDIV == 1 & envatt$EGAL_COMM == 1, na.rm = TRUE),
    mean(envatt$HIER_INDIV == 0 & envatt$EGAL_COMM == 0, na.rm = TRUE)), 1),
  check.names = FALSE)

## ---- serial chain / full models, HIER_INDIV + EGAL_COMM in place of
##      HIER + EGAL + INDIV + COMM ----
.measSerialHIEC <- '
  NEP   =~ nep5 + nep10 + nep15
  CNS   =~ cns2 + cns6 + cns7
'
.serialModelHIEC <- paste0(.measSerialHIEC, '
  NEP     ~ HIER_INDIV + EGAL_COMM + ', .ctrl_rhs, '
  CNS     ~ NEP + ', .ctrl_rhs, '
  PUBLIC  ~ CNS + ', .ctrl_rhs, '
  PRIVATE ~ CNS + ', .ctrl_rhs, '
')

.wv_fullHIEC <- c(HI = "HIER_INDIV", EC = "EGAL_COMM")
.reg_fullHIEC <- c(
  paste0("NEP     ~ aHI*HIER_INDIV + aEC*EGAL_COMM + ", .ctrl_rhs),
  paste0("CNS     ~ d*NEP + mHI*HIER_INDIV + mEC*EGAL_COMM + ", .ctrl_rhs),
  paste0("PUBLIC  ~ uCNS*CNS + uNEP*NEP + uHI*HIER_INDIV + uEC*EGAL_COMM + ", .ctrl_rhs),
  paste0("PRIVATE ~ vCNS*CNS + vNEP*NEP + vHI*HIER_INDIV + vEC*EGAL_COMM + ", .ctrl_rhs))
.defs_fullHIEC <- unlist(lapply(names(.wv_fullHIEC), function(x) c(
  sprintf("dirP_%s := u%s",                          x, x),
  sprintf("serP_%s := a%s*d*uCNS",                   x, x),
  sprintf("indP_%s := a%s*uNEP + m%s*uCNS + a%s*d*uCNS", x, x, x, x),
  sprintf("totP_%s := u%s + a%s*uNEP + m%s*uCNS + a%s*d*uCNS", x, x, x, x, x),
  sprintf("dirR_%s := v%s",                          x, x),
  sprintf("serR_%s := a%s*d*vCNS",                   x, x),
  sprintf("indR_%s := a%s*vNEP + m%s*vCNS + a%s*d*vCNS", x, x, x, x),
  sprintf("totR_%s := v%s + a%s*vNEP + m%s*vCNS + a%s*d*vCNS", x, x, x, x, x))))
.fullModelHIEC <- paste(c(.measSerialHIEC, .reg_fullHIEC, .defs_fullHIEC), collapse = "\n")

fitSerialHIEC <- sem(.serialModelHIEC, data = envatt)
fitFullHIEC   <- sem(.fullModelHIEC,   data = envatt)

## ---- fit comparison (reuses .cmp_row from section 9) ----
tbl5_hiec <- rbind(.cmp_row(fitSerialHIEC, "Serial chain (HI/EC)"),
                    .cmp_row(fitFullHIEC,   "Full (HI/EC, + direct paths)"))

.lrt_hiec <- lavTestLRT(fitSerialHIEC, fitFullHIEC)
.i_hiec   <- which(!is.na(.lrt_hiec[["Chisq diff"]]))[1]
lrt_text_hiec <- sprintf(
  "Nested $\\chi^2$ difference test (serial chain nested in full model, HIER-INDIV/EGAL-COMM groups): $\\Delta\\chi^2(%d) = %.2f$, $p = %.4f$.",
  .lrt_hiec[["Df diff"]][.i_hiec], .lrt_hiec[["Chisq diff"]][.i_hiec], .lrt_hiec[["Pr(>Chisq)"]][.i_hiec])

## ---- standardized effect decomposition (reuses .fmt from section 7) ----
.ssFullHIEC <- standardizedSolution(fitFullHIEC)
.getdefHIEC <- function(name) {
  r <- .ssFullHIEC[.ssFullHIEC$op == ":=" & .ssFullHIEC$lhs == name, ]
  .fmt(r$est.std[1], r$pvalue[1])
}
.wv_hiec_lab <- c("Hierarch-Individualist" = "HI", "Egalitarian-Communitarian" = "EC")
.decomp_row_hiec <- function(nm, x, outcome, pfx) data.frame(
  Predictor = nm, Outcome = outcome,
  Direct             = .getdefHIEC(paste0("dir", pfx, "_", x)),
  "Serial (NEP→CNS)" = .getdefHIEC(paste0("ser", pfx, "_", x)),
  "Total indirect"   = .getdefHIEC(paste0("ind", pfx, "_", x)),
  Total              = .getdefHIEC(paste0("tot", pfx, "_", x)),
  row.names = NULL, check.names = FALSE)
tbl6_hiec <- do.call(rbind, lapply(names(.wv_hiec_lab), function(nm) rbind(
  .decomp_row_hiec(nm, .wv_hiec_lab[[nm]], "Public",  "P"),
  .decomp_row_hiec(nm, .wv_hiec_lab[[nm]], "Private", "R"))))

## ---- demographic control coefficients, full combined model (HIER-INDIV/
##      EGAL-COMM) reported in the main text -- omitted from the path
##      diagram and from tbl6_hiec for readability, reported here instead ----
.ctrl_lab <- c(age = "Age", male = "Male", white = "White",
               educ = "Education", hhincome = "Household income")
.ctrl_row_hiec <- function(v) {
  r <- .ssFullHIEC[.ssFullHIEC$op == "~" & .ssFullHIEC$rhs == v &
                     .ssFullHIEC$lhs %in% c("NEP", "CNS", "PUBLIC", "PRIVATE"), ]
  vals <- setNames(mapply(.fmt, r$est.std, r$pvalue), r$lhs)
  data.frame(Control = .ctrl_lab[[v]],
             NEP = vals[["NEP"]], CNS = vals[["CNS"]],
             Public = vals[["PUBLIC"]], Private = vals[["PRIVATE"]],
             row.names = NULL, check.names = FALSE)
}
tbl_hiec_controls <- do.call(rbind, lapply(.ctrl_vars, .ctrl_row_hiec))
