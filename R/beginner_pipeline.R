# ==============================================================================
# beginner_pipeline.R — the "checkpoint" tables of the Beginner level
# ------------------------------------------------------------------------------
# Each function repeats EXACTLY the code of a session, so that a student who
# missed a session (or broke their script) can download the table and go on.
#   source("R/beginner_pipeline.R"); write_checkpoints_beginner()
# Files are written in data/checkpoints/ (B = Beginner, number = session).
# ==============================================================================

# Session 3 — two new columns
cb_s03 <- function() {
  sg <- read.csv("data/seagrass_quadrats.csv")
  sg$cover_prop     <- sg$seagrass_cover / 100
  sg$shoots_counted <- sg$shoot_density * 0.25
  sg
}

# Session 4 — columns calculated from 1, 2 or 3 columns
cb_s04_seagrass <- function() {
  sg <- read.csv("data/seagrass_quadrats.csv")
  sg$campaign       <- "2026-A"
  sg$cover_prop     <- sg$seagrass_cover / 100
  sg$shoots_counted <- sg$shoot_density * 0.25
  sg$quadrat_id     <- paste(sg$site, sg$quadrat, sep = "_")
  sg$canopy_index   <- sg$cover_prop * sg$canopy_height_cm
  sg
}
cb_s04_fish <- function() {
  fish <- read.csv("data/fish_uvc.csv")
  fish$weight_g  <- fish$a * fish$length_cm^fish$b       # weight of ONE fish (g)
  fish$biomass_g <- fish$count * fish$weight_g           # weight of the group (g)
  fish
}

# Session 5 — the messy file, cleaned
cb_s05 <- function() {
  raw <- read.csv("data/seagrass_messy.csv")
  raw$site <- trimws(raw$site)
  raw$site <- tools::toTitleCase(tolower(raw$site))
  names(raw)[names(raw) == "Seagrass.cover...."] <- "seagrass_cover"
  raw$seagrass_cover <- gsub("%", "", raw$seagrass_cover)
  raw$seagrass_cover[raw$seagrass_cover == "-"] <- NA
  raw$seagrass_cover <- as.numeric(raw$seagrass_cover)
  raw$seagrass_cover[which(raw$seagrass_cover > 100)] <- NA
  raw[!duplicated(raw), ]
}

# Session 6 — summary table per site
cb_s06 <- function() {
  sg <- read.csv("data/seagrass_quadrats.csv")
  n_site    <- tapply(sg$seagrass_cover, sg$site, length)
  mean_site <- tapply(sg$seagrass_cover, sg$site, mean)
  sd_site   <- tapply(sg$seagrass_cover, sg$site, sd)
  s <- data.frame(site = names(mean_site), n = as.vector(n_site),
                  mean = round(as.vector(mean_site), 1), sd = round(as.vector(sd_site), 1))
  s$se <- round(s$sd / sqrt(s$n), 1)
  s
}

write_checkpoints_beginner <- function() {
  dir.create("data/checkpoints", showWarnings = FALSE)
  w <- function(x, f) write.csv(x, file.path("data/checkpoints", f), row.names = FALSE)
  w(cb_s03(),          "B03_seagrass_new_columns.csv")
  w(cb_s04_seagrass(), "B04_seagrass_columns.csv")
  w(cb_s04_fish(),     "B04_fish_biomass.csv")
  w(cb_s05(),          "B05_seagrass_clean.csv")
  w(cb_s06(),          "B06_seagrass_summary_by_site.csv")
  message("Beginner checkpoints written in data/checkpoints/")
}
