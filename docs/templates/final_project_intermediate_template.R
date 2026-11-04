# ==============================================================================
# INTERMEDIATE FINAL PROJECT - Sea cucumber farming in three farms (simulated data)
# Author : <your name>
# Date   : <date>
# Data   : data/seacucumber_pens.csv        (1 row = 1 pen)
#          data/seacucumber_monitoring.csv  (1 row = 1 animal weighed at 1 visit)
#          data/seacucumber_harvest.csv     (1 row = 1 pen, animals alive at harvest)
# ==============================================================================
# Fill in every "..." and run the script from top to bottom (Ctrl + Shift + Enter).
# Write down the numbers asked in the quiz as you go (Q1, Q2...).

library(dplyr)
library(ggplot2)
library(patchwork)
dir.create("outputs", showWarnings = FALSE)

# ---- 1. Import and check (Sessions I0-I1) --------------------------------------
pens <- read.csv("data/seacucumber_pens.csv")
mon  <- read.csv("...")
harv <- read.csv("...")
str(pens); str(mon); str(harv)

pens$stocking_date <- as.Date(pens$stocking_date, format = "...")   # written dd/mm/yyyy
mon$date <- as.Date(mon$date)

sum(pens$density_per_m2 > ...)                    # Q1
table(table(mon$pen_id))                           # every pen should have 200 rows

# ---- 2. Mean weight per pen and visit (Sessions I3, I6) ------------------------
pen_month <- mon %>%
  group_by(pen_id, month_no, date) %>%
  summarise(mean_w = ..., .groups = "drop")

round(mean(mon$weight_g[mon$month_no == ...]), 1) # Q2

# ---- 3. Growth per pen with your own function (Session I6) ---------------------
sgr <- function(w0, w1, days) {
  ...                                              # 100 * (ln w1 - ln w0) / days
}
growth <- pen_month %>%
  group_by(pen_id) %>%
  arrange(month_no, .by_group = TRUE) %>%
  summarise(w_first = first(mean_w),
            w_last  = ...,
            days    = as.numeric(last(date) - first(date)),
            .groups = "drop") %>%
  mutate(sgr = sgr(w_first, w_last, days))

growth[which.max(growth$sgr), ]                    # Q3

# ---- 4. One analysis table (Session I3) ----------------------------------------
res <- pens %>%
  left_join(harv, by = "...") %>%
  left_join(growth, by = "...") %>%
  mutate(survival_pct = ...,
         biomass_kg   = ...,
         yield_kg_m2  = ...)

res %>% group_by(farm) %>%
  summarise(survival = mean(survival_pct), yield = mean(yield_kg_m2))   # Q4a
round(sum(res$biomass_kg))                                              # Q4b

# ---- 5. Figures (Sessions I7-I8) -----------------------------------------------
se <- function(x) sd(x) / sqrt(length(x))
curves <- mon %>%
  left_join(pens[, c("pen_id", "farm")], by = "pen_id") %>%
  group_by(farm, month_no) %>%
  summarise(m = mean(weight_g), se = se(weight_g), .groups = "drop")

pa <- ggplot(curves, aes(month_no, m, colour = farm)) +
  ...                                              # geom_line() + geom_pointrange()
pb <- ggplot(res, aes(farm, sgr)) +
  ...
pc <- ggplot(res, aes(density_per_m2, sgr, colour = farm)) +
  ...
fig <- (pa / (pb | pc)) + plot_annotation(tag_levels = "A")
ggsave("outputs/seacucumber_figure.png", fig, width = 18, height = 16, units = "cm", dpi = 300)

# ---- 6. Compare Farm B and Farm C (Sessions I9-I10) ----------------------------
bc <- res[res$farm %in% c("Farm B", "Farm C"), ]
# Plot first, then choose the test. Justify your choice here:
# Test chosen: ...  because ...
...
round(mean(bc$sgr[bc$farm == "Farm C"]) - mean(bc$sgr[bc$farm == "Farm B"]), 3)   # Q6

# ---- 7. Density and growth (Session I10) ---------------------------------------
cor.test(...)                                      # Q7
# Is Pearson appropriate? What else could explain the relation? ...

# ---- 8. Map (Session I11) ------------------------------------------------------
coast    <- read.csv("data/coastline.csv")
villages <- read.csv("data/villages.csv")
farm_sum <- res %>%
  group_by(farm, village) %>%
  summarise(biomass = sum(biomass_kg), yield = mean(yield_kg_m2), .groups = "drop") %>%
  left_join(villages[, c("village", "lon", "lat")], by = "village")
ggplot() +
  geom_polygon(data = coast, aes(lon, lat), fill = "#efe6d2") +
  ...                                              # points sized by biomass, filled by yield
  coord_quickmap(xlim = c(43.38, 43.88), ylim = c(-23.35, -22.55))

# ---- 9. Interpretation ---------------------------------------------------------
# Which farm grows sea cucumbers fastest? ...
# Does a high density slow down growth? ...
# Which farm gets the best yield per m2? ...
