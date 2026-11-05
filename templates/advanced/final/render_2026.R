# R/render_2026.R — the three 2026 reports, HTML and PDF (Typst)
library(here)
dir.create(here("outputs", "reports"), recursive = TRUE, showWarnings = FALSE)
for (m in c("Ankaramena", "Nosy Fasika", "Tanjona")) {
  slug <- gsub(" ", "_", tolower(m))
  for (fmt in c("html", "typst")) {
    quarto::quarto_render(here("reports", "mpa_report_2026.qmd"), output_format = fmt,
                          output_file = paste0("report_", slug, "_2026.", ifelse(fmt == "html", "html", "pdf")),
                          execute_params = list(mpa = m, year = 2026))
  }
}
# quarto_render() writes next to the .qmd: move the reports to outputs/reports/
f <- list.files(here("reports"), pattern = "^report_.*_2026\\.(html|pdf)$", full.names = TRUE)
file.rename(f, file.path(here("outputs", "reports"), basename(f)))
