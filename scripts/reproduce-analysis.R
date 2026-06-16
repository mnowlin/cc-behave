## =====================================================================
## Reproduction script for:
##   "Cultural Cognition, Environmental Orientation, and
##    Pro-Environmental Behavior"
##   (Cultural Cognition revised clean.docx)
##
## Reproduces: sample descriptives, Table 1 (behaviors),
##   Table 2 (measurement items + reliability), Figures 2 & 3
##   (CNS and NEP SEM path diagrams), Table 3 (model fit),
##   and Table 4 (mediation: direct / indirect / total effects).
##
## Run from the project root:  Rscript scripts/reproduce-analysis.R
## =====================================================================

## ---- packages -------------------------------------------------------
pkgs <- c("psych", "lavaan", "semTools", "semPlot", "semptools")
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  message("Installing missing packages: ", paste(missing, collapse = ", "))
  install.packages(missing, repos = "https://cloud.r-project.org")
}
library(psych)
library(lavaan)
library(semTools)
library(semPlot)
library(semptools)

## ---- output directory for figures/tables ---------------------------
out_dir <- "_output/reproduction"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

## =====================================================================
## 1. DATA CLEANING  (from "Data cleaning script.R")
## =====================================================================
envatt <- read.csv("data/apsa17.csv")

## --- controls --------------------------------------------------------
envatt$age      <- envatt$q75
envatt$female   <- ifelse(envatt$q76 == 2, 1, 0)
envatt$hhincome <- envatt$q83

# ideology: "haven't thought about it" (8) folded into moderate (4)
envatt$Ideology <- ifelse(envatt$q80 == 8, 4, envatt$q80)

envatt$Dem <- ifelse(envatt$q78 == 1 | envatt$q79c == 1, 1, 0)
envatt$Rep <- ifelse(envatt$q78 == 2 | envatt$q79c == 2, 1, 0)

envatt$urban <- envatt$q81
envatt$educ  <- envatt$q82

## --- cultural cognition: egalitarianism-hierarchy (cc_eh_1..14) ------
for (i in 1:7) envatt[[paste0("cc_eh_", i)]] <- envatt[[paste0("q1x31_", i)]]
# items 8-14 are reverse-keyed on the 1-4 scale (4->1 ... 1->4)
for (i in 8:14) envatt[[paste0("cc_eh_", i)]] <- 5 - envatt[[paste0("q1x31_", i)]]

## --- cultural cognition: communitarianism-individualism (cc_ci_1..17)
for (i in 1:12) envatt[[paste0("cc_ci_", i)]] <- envatt[[paste0("q1x31_", i + 14)]]
# items 13-17 are reverse-keyed (map q1x31_27..31)
for (i in 13:17) envatt[[paste0("cc_ci_", i)]] <- 5 - envatt[[paste0("q1x31_", i + 14)]]

## --- New Ecological Paradigm (nep1..15) ------------------------------
nep_src <- c("q46x59_46","q46x59_47","q46x59_48","q46x59_491","q46x59_492",
             "q46x59_50","q46x59_51","q46x59_52","q46x59_53","q46x59_54",
             "q46x59_55","q46x59_56","q46x59_57","q46x59_58","q46x59_59")
for (i in seq_along(nep_src)) envatt[[paste0("nep", i)]] <- envatt[[nep_src[i]]]
# reverse-keyed NEP items (6 - x on the 1-5 scale)
for (i in c(2,4,6,8,10,12,14)) envatt[[paste0("nep", i, "_r")]] <- 6 - envatt[[paste0("nep", i)]]

envatt$NEPa <- rowMeans(envatt[c("nep1","nep2_r","nep3","nep4_r","nep5","nep6_r",
                                 "nep7","nep8_r","nep9","nep10_r","nep11","nep12_r",
                                 "nep13","nep14_r","nep15")], na.rm = TRUE)

## --- Connectedness to Nature Scale (cns1..14) ------------------------
cns_src <- paste0("q32x45_", 32:45)
for (i in seq_along(cns_src)) envatt[[paste0("cns", i)]] <- envatt[[cns_src[i]]]
for (i in c(4,12,14)) envatt[[paste0("cns", i, "_r")]] <- 6 - envatt[[paste0("cns", i)]]

envatt$CNSa <- rowMeans(envatt[c("cns1","cns2","cns3","cns4_r","cns5","cns6","cns7",
                                 "cns8","cns9","cns10","cns12_r","cns11","cns13",
                                 "cns14_r")], na.rm = TRUE)

## --- DV: pro-environmental behaviors (13 binary items) ---------------
behave_src <- c(product = "q62x74_62", act.org = "q62x74_63", cand = "q62x74_64",
                money.org = "q62x74_65", cont.off = "q62x74_66", cont.bus = "q62x74_67",
                petition = "q62x74_68", meeting = "q62x74_69", water = "q62x74_70",
                buycott = "q62x74_71", recycle = "q62x74_72", energy = "q62x74_73",
                stocks = "q62x74_74")
for (nm in names(behave_src)) envatt[[nm]] <- ifelse(envatt[[behave_src[nm]]] == 1, 1, 0)

envatt$public  <- rowSums(envatt[c("act.org","cand","money.org","cont.off",
                                   "cont.bus","petition","meeting")], na.rm = TRUE)
envatt$private <- rowSums(envatt[c("product","water","buycott","recycle","energy")],
                          na.rm = TRUE)
# PEB = total of all 13 self-reported behaviors (0-13); used as observed DV
envatt$PEB    <- rowSums(envatt[c("public","private","stocks")])
envatt$BEHAVE <- envatt$PEB

## =====================================================================
## 2. REVERSE-CODE THE ITEMS USED IN THE SEMs  (from "SEManalysis.R")
##    Done once, before fitting, so all constructs point the same way.
## =====================================================================
for (v in c("cc_eh_2","cc_eh_5","cc_eh_7",
            "cc_ci_2","cc_ci_3","cc_ci_12")) envatt[[v]] <- 5 - envatt[[v]]
for (v in c("cns2","cns6","cns7"))           envatt[[v]] <- 6 - envatt[[v]]
for (v in c("nep5","nep15"))                 envatt[[v]] <- 6 - envatt[[v]]

## =====================================================================
## 3. SAMPLE DESCRIPTIVES
## =====================================================================
cat("\n================ SAMPLE ================\n")
cat("N =", nrow(envatt), "\n")
demos <- subset(envatt, select = c(educ, hhincome, Dem, female, Ideology, age, urban))
print(describe(demos))

## =====================================================================
## 4. TABLE 1 — self-reported pro-environmental behaviors
## =====================================================================
behave_items <- names(behave_src)   # 13 items, in manuscript order
table1 <- data.frame(
  behavior = behave_items,
  mean     = round(sapply(behave_items, function(v) mean(envatt[[v]], na.rm = TRUE)), 2),
  sd       = round(sapply(behave_items, function(v) sd(envatt[[v]],   na.rm = TRUE)), 2),
  row.names = NULL
)
table1 <- rbind(table1,
                data.frame(behavior = "PEB (total, 0-13)",
                           mean = round(mean(envatt$PEB, na.rm = TRUE), 2),
                           sd   = round(sd(envatt$PEB,   na.rm = TRUE), 2)))
cat("\n================ TABLE 1: Behaviors ================\n")
print(table1, row.names = FALSE)
write.csv(table1, file.path(out_dir, "table1_behaviors.csv"), row.names = FALSE)

## =====================================================================
## 5. SEM MODELS  (Figures 2 & 3, Tables 3)
## =====================================================================
semModelCNS <- '
  HIER  =~ cc_eh_2 + cc_eh_5 + cc_eh_7
  EGAL  =~ cc_eh_11 + cc_eh_13 + cc_eh_14
  INDIV =~ cc_ci_2 + cc_ci_3 + cc_ci_12
  COMM  =~ cc_ci_13 + cc_ci_14 + cc_ci_16
  CNS   =~ cns2 + cns6 + cns7
  CNS    ~ HIER + EGAL + INDIV + COMM
  BEHAVE ~ CNS + HIER + EGAL + INDIV + COMM
'
semModelNEP <- '
  HIER  =~ cc_eh_2 + cc_eh_5 + cc_eh_7
  EGAL  =~ cc_eh_11 + cc_eh_13 + cc_eh_14
  INDIV =~ cc_ci_2 + cc_ci_3 + cc_ci_12
  COMM  =~ cc_ci_13 + cc_ci_14 + cc_ci_16
  NEP   =~ nep5 + nep10 + nep15
  NEP    ~ HIER + EGAL + INDIV + COMM
  BEHAVE ~ NEP + HIER + EGAL + INDIV + COMM
'
fitCNS <- sem(semModelCNS, data = envatt)
fitNEP <- sem(semModelNEP, data = envatt)

cat("\n================ SEM (CNS) ================\n")
print(summary(fitCNS, standardized = TRUE, fit.measures = TRUE))
cat("\n================ SEM (NEP) ================\n")
print(summary(fitNEP, standardized = TRUE, fit.measures = TRUE))

## =====================================================================
## 6. TABLE 2 — measurement items + reliability (alpha, CR, AVE)
## =====================================================================
constructs <- list(
  HIER  = c("cc_eh_2","cc_eh_5","cc_eh_7"),
  EGAL  = c("cc_eh_11","cc_eh_13","cc_eh_14"),
  INDIV = c("cc_ci_2","cc_ci_3","cc_ci_12"),
  COMM  = c("cc_ci_13","cc_ci_14","cc_ci_16"),
  CNS   = c("cns2","cns6","cns7"),
  NEP   = c("nep5","nep10","nep15")
)

# item-level mean / sd
item_tab <- do.call(rbind, lapply(names(constructs), function(cn) {
  data.frame(construct = cn, item = constructs[[cn]],
             mean = round(sapply(constructs[[cn]], function(v) mean(envatt[[v]], na.rm = TRUE)), 2),
             sd   = round(sapply(constructs[[cn]], function(v) sd(envatt[[v]],   na.rm = TRUE)), 2),
             row.names = NULL)
}))

# Cronbach's alpha per construct
alpha_vals <- sapply(constructs, function(items) {
  suppressMessages(psych::alpha(envatt[items], warnings = FALSE)$total$raw_alpha)
})

# Composite Reliability (CR) and Average Variance Extracted (AVE).
# Computed from a pure measurement model (all six latents correlated, no
# structural paths) so the endogenous CNS/NEP factors are not distorted.
measModel <- '
  HIER  =~ cc_eh_2 + cc_eh_5 + cc_eh_7
  EGAL  =~ cc_eh_11 + cc_eh_13 + cc_eh_14
  INDIV =~ cc_ci_2 + cc_ci_3 + cc_ci_12
  COMM  =~ cc_ci_13 + cc_ci_14 + cc_ci_16
  CNS   =~ cns2 + cns6 + cns7
  NEP   =~ nep5 + nep10 + nep15
'
fitMeas <- cfa(measModel, data = envatt)
cr  <- unlist(compRelSEM(fitMeas))
ave <- AVE(fitMeas)

rel_tab <- data.frame(
  construct = names(constructs),
  alpha = round(alpha_vals[names(constructs)], 2),
  CR    = round(cr[names(constructs)], 2),
  AVE   = round(ave[names(constructs)], 2),
  row.names = NULL
)

cat("\n================ TABLE 2: Measurement items ================\n")
print(item_tab, row.names = FALSE)
cat("\n---- reliability ----\n")
print(rel_tab, row.names = FALSE)
write.csv(item_tab, file.path(out_dir, "table2_items.csv"), row.names = FALSE)
write.csv(rel_tab,  file.path(out_dir, "table2_reliability.csv"), row.names = FALSE)

## =====================================================================
## 7. TABLE 3 — model fit statistics
## =====================================================================
fit_row <- function(fit, label) {
  fm <- fitMeasures(fit, c("chisq","df","rmsea","cfi","srmr"))
  data.frame(model = label,
             N     = lavInspect(fit, "nobs"),
             df    = as.integer(fm[["df"]]),
             chisq = round(fm[["chisq"]], 2),
             RMSEA = round(fm[["rmsea"]], 3),
             CFI   = round(fm[["cfi"]],   3),
             SRMR  = round(fm[["srmr"]],  3))
}
table3 <- rbind(fit_row(fitCNS, "CNS"), fit_row(fitNEP, "NEP"))
cat("\n================ TABLE 3: Model fit ================\n")
print(table3, row.names = FALSE)
write.csv(table3, file.path(out_dir, "table3_fit.csv"), row.names = FALSE)

## =====================================================================
## 8. FIGURES 2 & 3 — SEM path diagrams with significance marks
## =====================================================================
draw_sem <- function(fit, file) {
  png(file, width = 2000, height = 1400, res = 200)
  p <- semPaths(fit, whatLabels = "std", sizeMan = 5, node.width = 1,
                edge.label.cex = .75, style = "ram", rotation = 2,
                mar = c(5, 5, 5, 5), DoNotPlot = TRUE)
  plot(mark_sig(p, fit))
  dev.off()
}
draw_sem(fitCNS, file.path(out_dir, "figure2_cns.png"))   # Figure 2
draw_sem(fitNEP, file.path(out_dir, "figure3_nep.png"))   # Figure 3
cat("\nFigures written to", out_dir, "\n")

## =====================================================================
## 9. TABLE 4 — mediation analysis (direct, indirect, total)
##    Models pull out one CC predictor as the focal X each time.
## =====================================================================
med_model <- function(focal, others, orientation, orient_items) {
  paste0(
    "HIER  =~ cc_eh_2 + cc_eh_5 + cc_eh_7\n",
    "EGAL  =~ cc_eh_11 + cc_eh_13 + cc_eh_14\n",
    "INDIV =~ cc_ci_2 + cc_ci_3 + cc_ci_12\n",
    "COMM  =~ cc_ci_13 + cc_ci_14 + cc_ci_16\n",
    orientation, " =~ ", orient_items, "\n",
    "BEHAVE ~ c*", focal, " + ", paste(others, collapse = " + "), "\n",
    orientation, " ~ a*", focal, " + ", paste(others, collapse = " + "), "\n",
    "BEHAVE ~ b*", orientation, "\n",
    "ab := a*b\n",
    "total := c + (a*b)\n"
  )
}

med_specs <- list(
  list(label = "Egal -> CNS", focal = "EGAL", others = c("HIER","INDIV","COMM"),
       orient = "CNS", items = "cns2 + cns6 + cns7"),
  list(label = "Comm -> CNS", focal = "COMM", others = c("EGAL","HIER","INDIV"),
       orient = "CNS", items = "cns2 + cns6 + cns7"),
  list(label = "Egal -> NEP", focal = "EGAL", others = c("HIER","INDIV","COMM"),
       orient = "NEP", items = "nep5 + nep10 + nep15"),
  list(label = "Comm -> NEP", focal = "COMM", others = c("EGAL","HIER","INDIV"),
       orient = "NEP", items = "nep5 + nep10 + nep15")
)

table4 <- do.call(rbind, lapply(med_specs, function(s) {
  fit <- sem(med_model(s$focal, s$others, s$orient, s$items), data = envatt)
  ss  <- standardizedSolution(fit)
  get <- function(lhs, op, rhs) {
    r <- ss[ss$lhs == lhs & ss$op == op & ss$rhs == rhs, ]
    c(est = r$est.std[1], p = r$pvalue[1])
  }
  direct   <- get("BEHAVE", "~",  s$focal)     # labeled c
  indirect <- get("ab",     ":=", "a*b")
  total    <- get("total",  ":=", "c+(a*b)")
  data.frame(
    path          = s$label,
    direct        = round(direct["est"], 3),   direct_p   = round(direct["p"], 3),
    indirect      = round(indirect["est"], 3), indirect_p = round(indirect["p"], 3),
    total         = round(total["est"], 3),    total_p    = round(total["p"], 3),
    row.names = NULL
  )
}))
cat("\n================ TABLE 4: Mediation (standardized) ================\n")
print(table4, row.names = FALSE)
write.csv(table4, file.path(out_dir, "table4_mediation.csv"), row.names = FALSE)

cat("\nDone. CSVs and figures are in", out_dir, "\n")
