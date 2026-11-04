# ==============================================================================
# check_setup.R — "Is my computer ready for this level?"
# ------------------------------------------------------------------------------
# 1. Open your course RStudio project.
# 2. Change LEVEL below if needed: "beginner", "intermediate" or "advanced".
# 3. Run the whole script (Ctrl + Shift + Enter) and read the ✔ / ✘ lines.
# ==============================================================================
LEVEL <- "beginner"

ok   <- function(msg) cat("  ✔ ", msg, "\n", sep = "")
bad  <- function(msg, fix) cat("  ✘ ", msg, "\n      -> ", fix, "\n", sep = "")

cat("\n== R and RStudio ==\n")
v <- getRversion()
if (v >= "4.1.0") ok(paste("R version", v)) else
  bad(paste("R version", v, "is old"), "install the latest R from https://cran.r-project.org")
if (Sys.getenv("RSTUDIO") == "1") ok("running inside RStudio") else
  bad("not running inside RStudio", "open RStudio, then open your course project")

if (.Platform$OS.type == "windows") {
  if (nzchar(Sys.which("make"))) ok("Rtools found") else
    bad("Rtools not found", "install the Rtools version matching your R (Beginner, Session 0)")
}

cat("\n== Project folders ==\n")
for (d in c("data", "scripts", "outputs")) {
  if (dir.exists(d)) ok(paste0("folder '", d, "/' exists")) else
    bad(paste0("folder '", d, "/' is missing"), paste0("create it: dir.create(\"", d, "\")"))
}

cat("\n== Packages for the", LEVEL, "level ==\n")
pkgs <- list(
  beginner     = c("dplyr", "ggplot2"),
  intermediate = c("dplyr", "ggplot2", "readxl", "tidyr", "lubridate", "stringr", "patchwork"),
  advanced     = c("dplyr", "ggplot2", "readxl", "tidyr", "rmarkdown", "knitr", "here", "renv",
                   "sf", "terra", "tmap")
)[[LEVEL]]
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
for (p in setdiff(pkgs, missing)) ok(paste(p, packageVersion(p)))
if (length(missing)) {
  bad(paste("missing packages:", paste(missing, collapse = ", ")),
      paste0('install.packages(c("', paste(missing, collapse = '", "'), '"))'))
}

cat("\n== Data files ==\n")
files <- list(
  beginner     = c("seagrass_quadrats.csv", "seagrass_messy.csv", "coral_pit_example.csv",
                   "coral_cover_raw.csv", "fish_uvc.csv"),
  intermediate = c("seaweed_farming.xlsx", "water_quality_wide.csv", "survey_households.csv",
                   "survey_members.csv", "survey_assets.csv", "coastline.csv", "villages.csv"),
  advanced     = character(0)
)[[LEVEL]]
for (f in files) {
  if (file.exists(file.path("data", f))) ok(f) else
    bad(paste(f, "not found in data/"), "download the data of this level and put the files in data/")
}

if (LEVEL == "advanced") {
  cat("\n== Tools for reports ==\n")
  if (nzchar(Sys.which("git"))) ok("Git found") else bad("Git not found", "install Git: https://git-scm.com")
  if (nzchar(Sys.which("quarto"))) ok("Quarto found") else bad("Quarto not found", "install Quarto: https://quarto.org")
}
cat("\nIf every line shows ✔ you are ready. Otherwise follow the -> instructions and run this script again.\n")
