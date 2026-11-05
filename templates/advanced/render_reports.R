# ==============================================================================
# render_reports.R — one report per MPA, in one click (Session A4)
# Run from the project root: source("R/render_reports.R")
# ==============================================================================
library(rmarkdown)
library(here)

mpas <- c("Ankaramena", "Nosy Fasika", "Tanjona")
dir.create(here("outputs", "reports"), recursive = TRUE, showWarnings = FALSE)

for (m in mpas) {
  file_name <- paste0("report_", gsub(" ", "_", tolower(m)), "_2025.html")   # no spaces in file names
  render(input       = here("reports", "mpa_report.Rmd"),
         params      = list(mpa = m, year = 2025),
         output_file = file_name,
         output_dir  = here("outputs", "reports"),
         envir       = new.env(),        # a clean environment for each report
         quiet       = TRUE)
  message("Done: ", file_name)
}
