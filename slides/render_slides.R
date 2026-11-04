# ==============================================================================
# render_slides.R — build the slide decks into slides/   source("slides/render_slides.R")
# Each deck is ONE self-contained .html file (works offline, can be copied on a
# USB key). Open it in a browser. Keys: arrows / space = move, F = full screen,
# O = overview of all slides, N = show the speaker notes.
# ==============================================================================
decks <- c(
  # Beginner level
  "slides/part1_sessions0-3.Rmd", "slides/part2_sessions4-6.Rmd", "slides/part3_sessions7-10.Rmd",
  # Intermediate level
  "slides/int1_sessions_I0-I4.Rmd", "slides/int2_sessions_I5-I8.Rmd", "slides/int3_sessions_I9-I13.Rmd")
for (f in decks) {
  message("Rendering ", f)
  rmarkdown::render(f, encoding = "UTF-8", quiet = TRUE)
}
message("Slides written in slides/*.html")
