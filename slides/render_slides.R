# ==============================================================================
# render_slides.R — build the 3 slide decks into slides/   source("slides/render_slides.R")
# Each deck is ONE self-contained .html file (works offline, can be copied on a
# USB key). Open it in a browser; press F for full screen, W for wide mode,
# arrows to move, P for presenter notes.
# ==============================================================================
for (f in c("slides/part1_sessions0-3.Rmd", "slides/part2_sessions4-6.Rmd",
            "slides/part3_sessions7-10.Rmd")) {
  rmarkdown::render(f, encoding = "UTF-8", quiet = TRUE)
}
message("Slides written in slides/*.html")
