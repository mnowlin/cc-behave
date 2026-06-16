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
envatt$hhincome <- envatt$q83
envatt$Ideology <- ifelse(envatt$q80 == 8, 4, envatt$q80)   # "haven't thought" -> moderate
envatt$Dem      <- ifelse(envatt$q78 == 1 | envatt$q79c == 1, 1, 0)
envatt$Rep      <- ifelse(envatt$q78 == 2 | envatt$q79c == 2, 1, 0)
envatt$urban    <- envatt$q81
envatt$educ     <- envatt$q82

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
envatt$PEB    <- rowSums(envatt[c("public","private","stocks")])   # observed DV, 0-13
envatt$BEHAVE <- envatt$PEB

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
.semModelCNS <- '
  HIER  =~ cc_eh_2 + cc_eh_5 + cc_eh_7
  EGAL  =~ cc_eh_11 + cc_eh_13 + cc_eh_14
  INDIV =~ cc_ci_2 + cc_ci_3 + cc_ci_12
  COMM  =~ cc_ci_13 + cc_ci_14 + cc_ci_16
  CNS   =~ cns2 + cns6 + cns7
  CNS    ~ HIER + EGAL + INDIV + COMM
  BEHAVE ~ CNS + HIER + EGAL + INDIV + COMM
'
.semModelNEP <- '
  HIER  =~ cc_eh_2 + cc_eh_5 + cc_eh_7
  EGAL  =~ cc_eh_11 + cc_eh_13 + cc_eh_14
  INDIV =~ cc_ci_2 + cc_ci_3 + cc_ci_12
  COMM  =~ cc_ci_13 + cc_ci_14 + cc_ci_16
  NEP   =~ nep5 + nep10 + nep15
  NEP    ~ HIER + EGAL + INDIV + COMM
  BEHAVE ~ NEP + HIER + EGAL + INDIV + COMM
'
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
  energy    = "Reduced your household's use of energy",
  stocks    = "Bought or sold stocks based on companies' environmental records")

.bvars <- names(.behave_src)
tbl1 <- data.frame(
  Behavior = .behave_label[.bvars],
  Mean = round(sapply(.bvars, function(v) mean(envatt[[v]], na.rm = TRUE)), 2),
  SD   = round(sapply(.bvars, function(v) sd(envatt[[v]],   na.rm = TRUE)), 2),
  row.names = NULL, check.names = FALSE)
tbl1 <- rbind(tbl1, data.frame(Behavior = "Total pro-environmental behaviors (0-13)",
                               Mean = peb_mean, SD = peb_sd))

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

.med_model <- function(focal, others, orient, items) paste0(
  "HIER  =~ cc_eh_2 + cc_eh_5 + cc_eh_7\n",
  "EGAL  =~ cc_eh_11 + cc_eh_13 + cc_eh_14\n",
  "INDIV =~ cc_ci_2 + cc_ci_3 + cc_ci_12\n",
  "COMM  =~ cc_ci_13 + cc_ci_14 + cc_ci_16\n",
  orient, " =~ ", items, "\n",
  "BEHAVE ~ c*", focal, " + ", paste(others, collapse = " + "), "\n",
  orient, " ~ a*", focal, " + ", paste(others, collapse = " + "), "\n",
  "BEHAVE ~ b*", orient, "\n",
  "ab := a*b\n",
  "total := c + (a*b)\n")

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
  dir <- pick("BEHAVE", "~", s$focal); ind <- pick("ab", ":=", "a*b"); tot <- pick("total", ":=", "c+(a*b)")
  data.frame(Path = s$label,
             Direct   = .fmt(dir["est"], dir["p"]),
             Indirect = .fmt(ind["est"], ind["p"]),
             Total    = .fmt(tot["est"], tot["p"]),
             row.names = NULL)
}))

## =====================================================================
## 8. FIGURE HELPER (Figures 2 & 3)
## =====================================================================
draw_sem <- function(fit) {
  p <- semPaths(fit, whatLabels = "std", sizeMan = 5, node.width = 1,
                edge.label.cex = .75, style = "ram", rotation = 2,
                mar = c(5, 5, 5, 5), DoNotPlot = TRUE)
  plot(mark_sig(p, fit))
}
