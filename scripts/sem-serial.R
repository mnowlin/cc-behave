## =====================================================================
## sem-serial.R
##
## Combined serial SEM: cultural cognition -> NEP -> CNS -> behavior.
## Compares the strict serial chain (fitSerial) against the full model
## with direct paths added (fitFull), and reports the standardized
## effect decomposition.
##
## Reuses the cleaning, model fits, and tables built in analysis-prep.R.
## Run from the project root:  Rscript scripts/sem-serial.R
## =====================================================================

source("scripts/analysis-prep.R")   # provides fitSerial, fitFull, tbl5, tbl6, lrt_text, draw_sem

out_dir <- "_output/reproduction"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

cat("\n=================== SERIAL CHAIN MODEL ===================\n")
print(summary(fitSerial, standardized = TRUE, fit.measures = TRUE))

cat("\n=================== FULL MODEL (+ direct paths) ===================\n")
print(summary(fitFull, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE))

cat("\n=================== FIT COMPARISON (Table 5) ===================\n")
print(tbl5, row.names = FALSE)
cat("\n", gsub("\\$|\\\\chi\\^2|\\\\Delta|\\\\", "", lrt_text), "\n", sep = "")

cat("\n=================== EFFECT DECOMPOSITION (Table 6, standardized) ===================\n")
print(tbl6, row.names = FALSE)

## save tables + path diagram of the full model
write.csv(tbl5, file.path(out_dir, "table5_serial_fit.csv"),    row.names = FALSE)
write.csv(tbl6, file.path(out_dir, "table6_serial_decomp.csv"), row.names = FALSE)
png(file.path(out_dir, "figure4_serial.png"), width = 2200, height = 1500, res = 200)
draw_sem(fitFull)
dev.off()

cat("\nOutputs written to", out_dir, "\n")
