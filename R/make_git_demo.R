# =============================================================================
# make_git_demo.R — builds data/advanced/reef_project_git.zip: a small R project
# WITH its Git history (6 commits by 2 people), used in Session A2.
# Dates and authors are fixed, so the commit hashes are always the same.
# Run from the project root (needs git):   source("R/make_git_demo.R")
# =============================================================================
make_git_demo <- function() {
  root <- file.path(tempdir(), "gitdemo"); unlink(root, recursive = TRUE); dir.create(root)
  repo <- file.path(root, "reef-monitoring"); dir.create(repo)
  git <- function(args, who = c("Fara Rasoa", "fara@example.org"), date = "2025-05-01T09:00:00") {
    env <- c(paste0("GIT_AUTHOR_NAME=", shQuote(who[1])), paste0("GIT_AUTHOR_EMAIL=", who[2]),
             paste0("GIT_COMMITTER_NAME=", shQuote(who[1])), paste0("GIT_COMMITTER_EMAIL=", who[2]),
             paste0("GIT_AUTHOR_DATE=", date, "+0300"), paste0("GIT_COMMITTER_DATE=", date, "+0300"))
    old <- setwd(repo); on.exit(setwd(old))
    out <- system2("git", args, env = env, stdout = TRUE, stderr = TRUE)
    invisible(out)
  }
  w <- function(path, lines) { dir.create(dirname(file.path(repo, path)), FALSE, TRUE); writeLines(lines, file.path(repo, path)) }
  fara <- c("Fara Rasoa", "fara@example.org"); hery <- c("Hery Nirina", "hery@example.org")

  git(c("init", "-q", "-b", "main"))
  w("README.md", c("# Reef monitoring", "", "Analysis of the coral transects of the three MPAs."))
  w(".gitignore", c(".Rhistory", ".RData", ".Rproj.user/", "outputs/"))
  w("R/01_import.R", c('reef <- read.csv("data/raw/reef_monitoring.csv")', 'sites <- read.csv("data/raw/reef_sites.csv")'))
  git(c("add", "."), fara); git(c("commit", "-q", "-m", shQuote("Start the project: README, gitignore, import script")), fara, "2025-05-01T09:00:00")

  w("R/02_clean.R", c('reef <- merge(reef, sites, by = "site_id")', 'reef <- reef[!is.na(reef$hard_coral), ]'))
  git(c("add", "."), fara); git(c("commit", "-q", "-m", shQuote("Add the cleaning script")), fara, "2025-05-02T10:30:00")

  w("R/03_bleaching.R", c("bleach_threshold <- 30   # % of colonies bleached = severe",
                          "reef$severe <- reef$bleached_pct >= bleach_threshold",
                          "table(reef$year, reef$severe)"))
  git(c("add", "."), hery); git(c("commit", "-q", "-m", shQuote("Flag severe bleaching")), hery, "2025-05-05T14:00:00")

  w("R/03_bleaching.R", c("bleach_threshold <- 20   # changed after the meeting with the MPA managers",
                          "reef$severe <- reef$bleached_pct >= bleach_threshold",
                          "table(reef$year, reef$severe)"))
  git(c("add", "."), hery); git(c("commit", "-q", "-m", shQuote("Lower the bleaching threshold to 20 %")), hery, "2025-05-09T08:15:00")

  w("R/04_figures.R", c("library(ggplot2)", "ggplot(reef, aes(factor(year), hard_coral, fill = zone)) + geom_boxplot()",
                        'ggsave("outputs/coral_by_year.png", width = 16, height = 9, units = "cm")'))
  git(c("add", "."), fara); git(c("commit", "-q", "-m", shQuote("Boxplots of coral cover per year")), fara, "2025-05-12T11:00:00")

  w("README.md", c("# Reef monitoring", "", "Analysis of the coral transects of the three MPAs.", "",
                   "Run the scripts of `R/` in order: 01, 02, 03, 04."))
  git(c("add", "."), fara); git(c("commit", "-q", "-m", shQuote("Explain the order of the scripts in the README")), fara, "2025-05-12T16:40:00")

  old <- setwd(root); on.exit(setwd(old))
  unlink("reef_project_git.zip")
  utils::zip("reef_project_git.zip", "reef-monitoring", flags = "-r9Xq")
  file.copy(file.path(root, "reef_project_git.zip"), file.path(old, "data/advanced/reef_project_git.zip"), overwrite = TRUE)
  invisible(repo)
}
repo_git_demo <- make_git_demo()
