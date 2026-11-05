# ==============================================================================
# R/02_clean_2026.R — add the 2026 campaign to the monitoring table (final project)
# Reads  data/raw/reef_monitoring.csv (2019-2025) and data/raw/reef_monitoring_2026.csv
# Writes data/derived/reef_2019_2026.csv
# ==============================================================================
library(dplyr)
library(here)

old <- read.csv(here("data", "raw", "reef_monitoring.csv"))
new <- read.csv(here("data", "raw", "reef_monitoring_2026.csv"))

# 1. Look before you clean -------------------------------------------------------
nrow(new)
sum(duplicated(new))                      # rows typed twice
setdiff(unique(new$site_id), unique(old$site_id))   # site codes that do not exist
summary(new$hard_coral)                   # values > 100 % ?

# 2. Clean (every correction is written here, never in the raw file) ------------
new <- new %>%
  distinct() %>%                                                    # TO DO: check the number of rows removed
  mutate(site_id     = toupper(site_id),                            # "r07" -> "R07"
         survey_date = format(as.Date(survey_date, format = "%d/%m/%Y"), "%Y-%m-%d"),   # same format as old
         hard_coral  = ifelse(hard_coral > 100, hard_coral / 10, hard_coral))           # decimal point forgotten

# 3. Same columns, then stack the years -----------------------------------------
stopifnot(identical(names(old), names(new)))
all <- bind_rows(old, new)
dir.create(here("data", "derived"), showWarnings = FALSE)
write.csv(all, here("data", "derived", "reef_2019_2026.csv"), row.names = FALSE)
message("Rows 2019-2026: ", nrow(all))
