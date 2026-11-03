# =============================================================================
# build_site.R — build the whole website into docs/   source("R/build_site.R")
# =============================================================================
rmarkdown::render_site(encoding = "UTF-8")   # knits every .Rmd and copies assets/data
file.create("docs/.nojekyll")                # GitHub Pages: do not run Jekyll
message("Site built in docs/. Open docs/index.html to check, then commit + push.")
