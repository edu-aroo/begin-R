# =============================================================================
# intermediate_pipeline.R — the reference analysis of the intermediate level
# -----------------------------------------------------------------------------
# Each function = the correct result of one session. They are used to:
#   (1) compute the quiz answers when the site is built,
#   (2) write the "checkpoint" files (data/checkpoints/) that students can
#       download to start a session even if the previous one went wrong.
# Sourced in the setup chunk of each intermediate page.
# =============================================================================
suppressPackageStartupMessages({
  library(readxl); library(dplyr); library(tidyr); library(lubridate); library(stringr)
})

clean_village <- function(x) tools::toTitleCase(tolower(trimws(x)))
is_wet <- function(month) month %in% c(11, 12, 1, 2, 3, 4)          # wet season Nov-Apr

# I0 — import the Excel register ------------------------------------------------
cp_farmers <- function() {
  f <- read_excel("data/seaweed_farming.xlsx", sheet = "farmers")
  f$village <- clean_village(f$village)
  f$joined_coop <- as.Date(f$joined_coop)
  as.data.frame(f)
}
cp_lines_raw <- function() {
  l <- read_excel("data/seaweed_farming.xlsx", sheet = "lines", skip = 3)
  l$planting_date <- as.Date(l$planting_date)
  as.data.frame(l)
}

# I1 — dates, durations, seasons, growth rate -----------------------------------
cp_lines_dated <- function(l = cp_lines_raw()) {
  l$harvest_date <- as.Date(l$harvest_date, format = "%d/%m/%Y")
  l$days     <- as.numeric(l$harvest_date - l$planting_date)
  l$year     <- as.integer(format(l$planting_date, "%Y"))
  l$month    <- as.integer(format(l$planting_date, "%m"))
  l$season   <- ifelse(is_wet(l$month), "wet", "dry")
  i <- which(l$final_weight_kg > 200)                    # weights typed in grams
  l$final_weight_kg[i] <- l$final_weight_kg[i] / 1000
  l$sgr <- 100 * log(l$final_weight_kg / l$initial_weight_kg) / l$days   # % per day
  l
}

# I2 — water quality: clean, long format, monthly means ---------------------------
cp_wq_clean <- function() {
  w <- read.csv("data/water_quality_long.csv")
  w$date <- as.Date(w$date, format = "%d/%m/%Y")
  w$temp_C[w$temp_C == -999] <- NA
  w$pH[w$pH == 0] <- NA
  w
}
cp_wq_tidy <- function(w = cp_wq_clean()) {
  w %>% pivot_longer(temp_C:turbidity_NTU, names_to = "parameter", values_to = "value") %>%
    as.data.frame()
}
cp_wq_monthly <- function(w = cp_wq_clean()) {
  st <- read.csv("data/stations.csv")
  w %>% left_join(st[, c("station", "zone")], by = "station") %>%
    mutate(year = year(date), month = month(date)) %>%
    group_by(zone, year, month) %>%
    summarise(temp_mean = mean(temp_C, na.rm = TRUE), sal_mean = mean(salinity_psu, na.rm = TRUE),
              .groups = "drop") %>% as.data.frame()
}

# I3 — one analysis table: lines + farmers + villages + temperature --------------
cp_seaweed <- function() {
  l <- cp_lines_dated(); f <- cp_farmers()
  v <- read.csv("data/villages.csv")[, c("village", "zone")]
  wm <- cp_wq_monthly()[, c("zone", "year", "month", "temp_mean")]
  l %>% left_join(f, by = "farmer_id") %>%
    left_join(v, by = "village") %>%
    left_join(wm, by = c("zone", "year", "month")) %>% as.data.frame()
}

# I4 — survey: remove duplicates, clean answers, household variables -------------
lik_levels <- c("Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree")
cp_households <- function() {
  h <- read.csv("data/survey_households.csv", na.strings = "")
  h <- h[!duplicated(h), ]
  h$mpa_benefits <- str_to_sentence(str_squish(h$mpa_benefits))
  h$mpa_benefits <- factor(h$mpa_benefits, levels = lik_levels, ordered = TRUE)
  h$n_activities <- str_count(h$activities, ";") + 1
  h$does_seaweed <- str_detect(h$activities, "seaweed")
  m <- read.csv("data/survey_members.csv", na.strings = "")
  size <- m %>% count(hh_id, name = "hh_size")
  h %>% left_join(size, by = "hh_id") %>% as.data.frame()
}

# write all checkpoint files --------------------------------------------------------
write_checkpoints <- function() {
  dir.create("data/checkpoints", showWarnings = FALSE)
  write.csv(cp_farmers(),     "data/checkpoints/I0_farmers.csv", row.names = FALSE)
  write.csv(cp_lines_raw(),   "data/checkpoints/I0_lines.csv", row.names = FALSE)
  write.csv(cp_lines_dated(), "data/checkpoints/I1_lines_dated.csv", row.names = FALSE)
  write.csv(cp_wq_clean(),    "data/checkpoints/I2_water_quality_clean.csv", row.names = FALSE)
  write.csv(cp_wq_monthly(),  "data/checkpoints/I2_water_quality_monthly.csv", row.names = FALSE)
  write.csv(cp_seaweed(),     "data/checkpoints/I3_seaweed_analysis.csv", row.names = FALSE)
  write.csv(cp_households(),  "data/checkpoints/I4_households_clean.csv", row.names = FALSE)
}
