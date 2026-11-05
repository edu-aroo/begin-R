# Answers of the A11 final project quiz (sourced, hidden, by a11-final-project.Rmd)
suppressMessages({library(dplyr); library(tidyr)})
source("R/advanced_pipeline.R")
A <- "data/advanced"
new_raw <- read.csv(file.path(A, "reef_monitoring_2026.csv"))
f11a <- nrow(new_raw)
f11b <- sum(duplicated(new_raw))
clean26 <- new_raw %>% distinct() %>%
  mutate(site_id = toupper(site_id),
         survey_date = format(as.Date(survey_date, format = "%d/%m/%Y"), "%Y-%m-%d"),
         hard_coral = ifelse(hard_coral > 100, hard_coral / 10, hard_coral))
f11c <- sum(new_raw$hard_coral > 100)
sites <- read.csv(file.path(A, "reef_sites.csv"))
all <- bind_rows(read.csv(file.path(A, "reef_monitoring.csv")), clean26) %>% left_join(sites, by = "site_id")
f11d <- nrow(all)
y26 <- all %>% filter(year == 2026)
f11e <- round(mean(y26$hard_coral[y26$zone == "No-take"]), 1)
f11f <- round(mean(y26$hard_coral[y26$zone == "Fishing"]), 1)
gain <- all %>% filter(year %in% 2025:2026) %>% group_by(mpa, year) %>% summarise(m = mean(hard_coral), .groups = "drop") %>%
  pivot_wider(names_from = year, values_from = m, names_prefix = "y") %>% mutate(g = y2026 - y2025)
f11g <- gain$mpa[which.max(gain$g)]
site_m <- all %>% filter(year %in% c(2023, 2026)) %>% group_by(site_id, year) %>% summarise(m = mean(hard_coral), .groups = "drop") %>%
  pivot_wider(names_from = year, values_from = m, names_prefix = "y")
f11h <- sum(site_m$y2026 > site_m$y2023)
P <- ca_plots()
f11i <- round(mean(P$agb_t_ha[P$patch == "Sarondrano" & P$status == "reference"]))
