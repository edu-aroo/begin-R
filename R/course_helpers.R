# =============================================================================
# course_helpers.R
# -----------------------------------------------------------------------------
# Small helper functions used INSIDE the .Rmd pages (sourced in each page's
# setup chunk). They write HTML that the JavaScript file assets/course.js
# turns into interactive elements.
#
#   fig_svg("rstudio-panes")   -> inserts assets/img/rstudio-panes.svg inline
#   quiz("s01", list(...))     -> inserts an interactive, scored quiz
#   q_num(), q_mcq(), q_text() -> build one quiz question each
#
# Nothing here is needed by the students: it is only used when YOU knit.
# =============================================================================

# ---- knitr options for every page -------------------------------------------
knitr::opts_chunk$set(
  comment   = "#>",    # prefix of printed results (easy to tell from code)
  collapse  = FALSE,   # keep code and output in separate boxes
  fig.align = "center",
  fig.width = 7, fig.height = 4.2,
  dpi       = 110,
  out.width = "85%"
)

# ---- Insert an SVG illustration -----------------------------------------------
# The SVG is pasted *inline* (not as <img>) so that the CSS can hide the
# English or French labels (class "en" / "fr") when the language changes.
fig_svg <- function(name, caption_en = NULL, caption_fr = NULL) {
  path <- file.path("assets", "img", paste0(name, ".svg"))
  svg  <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  svg  <- gsub("$", "&#36;", svg, fixed = TRUE)   # a "$" would be read by pandoc as the start of a math formula
  cap  <- ""
  if (!is.null(caption_en)) {
    cap <- sprintf('<figcaption><span class="en">%s</span><span class="fr">%s</span></figcaption>',
                   caption_en, caption_fr)
  }
  # asis_output() tells knitr: "this is raw HTML, do not escape it"
  # The ```{=html} fence makes pandoc copy the SVG untouched (no markdown processing of its texts:
  # spaces and straight quotes are kept).
  knitr::asis_output(sprintf('\n\n```{=html}\n<figure class="svg-fig">%s%s</figure>\n```\n\n', svg, cap))
}

# ---- Quiz questions -----------------------------------------------------------
# Each function returns a simple list. en/fr = question text in both languages.

# Numeric answer, accepted if |student - answer| <= tol
q_num <- function(en, fr, answer, tol = 0.05, hint_en = "", hint_fr = "") {
  list(type = "num", en = en, fr = fr, answer = answer, tol = tol,
       hint_en = hint_en, hint_fr = hint_fr)
}

# Multiple choice; 'correct' is the position (1, 2, 3...) of the right option
q_mcq <- function(en, fr, options_en, options_fr = options_en, correct) {
  list(type = "mcq", en = en, fr = fr,
       options_en = as.list(options_en), options_fr = as.list(options_fr),
       answer = correct - 1)            # JavaScript counts from 0, R from 1
}

# Short text answer, compared without case and spaces; several answers allowed
q_text <- function(en, fr, answers) {
  list(type = "text", en = en, fr = fr, answer = as.list(answers))
}

# ---- The quiz block -----------------------------------------------------------
# id      : unique quiz id, e.g. "s01" (used to save the score)
# title_en/title_fr : optional title shown above the questions
# qs      : list of questions built with q_num/q_mcq/q_text
# The questions are converted to JSON and then base64-encoded. Base64 is NOT
# encryption: it only stops students from reading the answers at a glance in
# the page source.
quiz <- function(id, qs, title_en = NULL, title_fr = NULL) {
  register_quiz(id, length(qs))      # remember id + number of questions (see below)
  json <- jsonlite::toJSON(qs, auto_unbox = TRUE, digits = NA)
  b64  <- jsonlite::base64_enc(charToRaw(enc2utf8(as.character(json))))
  b64  <- gsub("\n", "", b64)
  # optional title, e.g. for the exercises of the practice session
  ttl  <- if (is.null(title_en)) "" else
    sprintf(' data-title-en="%s" data-title-fr="%s"', title_en, title_fr)
  knitr::asis_output(sprintf(
    '<div class="quiz" id="quiz-%s" data-quiz-id="%s"%s data-q="%s"></div>', id, id, ttl, b64))
}

# ---- Quiz registry ------------------------------------------------------------
# Every quiz() call writes a tiny file .quiz_registry/<id>.json with its number
# of questions, its page and its level. R/build_site.R combines them into
# assets/quiz_index.json (read by the Google Apps Script) and
# assets/quiz_index.js (read by course.js) -> the site knows the maximum score of
# EVERY quiz of a level, even the pages a student has not opened yet.
# Level = first letter of the file name: "i" intermediate, "a" advanced, else beginner.
register_quiz <- function(id, n) {
  page  <- sub("\\..*$", "", basename(knitr::current_input()))
  level <- if (grepl("^i[0-9]", page)) "intermediate" else
           if (grepl("^a[0-9]", page)) "advanced" else "beginner"
  dir.create(".quiz_registry", showWarnings = FALSE)
  writeLines(jsonlite::toJSON(list(id = id, max = n, page = page, level = level), auto_unbox = TRUE),
             file.path(".quiz_registry", paste0(id, ".json")))
}

# ---- Download button for a data file -----------------------------------------
dl <- function(file, label = file, dir = "data") {
  knitr::asis_output(sprintf(
    '<a class="btn-dl" href="%s/%s" download>&#8681; %s</a>', dir, file, label))
}
