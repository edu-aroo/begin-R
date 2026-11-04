# Answers of the I13 final project quiz (sourced, hidden, by i13-final-project.Rmd)
suppressMessages({library(dplyr)})
pens <- read.csv("data/seacucumber_pens.csv")
mon  <- read.csv("data/seacucumber_monitoring.csv")
harv <- read.csv("data/seacucumber_harvest.csv")
pens$stocking_date <- as.Date(pens$stocking_date, format = "%d/%m/%Y")
mon$date <- as.Date(mon$date)
sgr_fun <- function(w0, w1, days) 100 * (log(w1) - log(w0)) / days
pen_month <- mon %>% group_by(pen_id, month_no, date) %>%
  summarise(mean_w = mean(weight_g), .groups = "drop")
growth <- pen_month %>% group_by(pen_id) %>% arrange(month_no, .by_group = TRUE) %>%
  summarise(w_first = first(mean_w), w_last = last(mean_w),
            days = as.numeric(last(date) - first(date)), .groups = "drop") %>%
  mutate(sgr = sgr_fun(w_first, w_last, days))
res <- pens %>% left_join(harv, by = "pen_id") %>% left_join(growth, by = "pen_id") %>%
  mutate(survival_pct = 100 * alive_at_harvest / juveniles_stocked,
         biomass_kg = alive_at_harvest * w_last / 1000,
         yield_kg_m2 = biomass_kg / area_m2)
f13a <- sum(pens$density_per_m2 > 1.5)
f13b <- round(mean(mon$weight_g[mon$month_no == 10]), 1)
f13c <- res$pen_id[which.max(res$sgr)]
f13d <- round(max(res$sgr), 3)
f13e <- round(mean(res$survival_pct[res$farm == "Farm B"]), 1)
f13f <- round(sum(res$biomass_kg))
bc <- res[res$farm %in% c("Farm B", "Farm C"), ]
f13g <- round(mean(bc$sgr[bc$farm == "Farm C"]) - mean(bc$sgr[bc$farm == "Farm B"]), 3)
f13p <- t.test(sgr ~ farm, data = bc)$p.value
f13h <- round(cor(res$density_per_m2, res$sgr), 3)
