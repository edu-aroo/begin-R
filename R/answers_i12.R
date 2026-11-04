# Answers of the I12 practice quizzes (sourced, hidden, by i12-practice.Rmd)
suppressMessages({library(dplyr); library(tidyr); library(stringr); library(lubridate)})
st <- read.csv("data/stations.csv")
# ip1 ---------------------------------------------------------------
raw <- read.csv("data/water_quality_long.csv")
ip1a <- sum(raw$temp_C == -999, na.rm = TRUE)
ip1b <- sum(raw$pH == 0, na.rm = TRUE)
ip1c <- sum(is.na(raw$DO_mgL))
raw$date <- as.Date(raw$date, format = "%d/%m/%Y")
ip1d <- sum(month(raw$date) == 7)
ip1e <- as.numeric(max(raw$date) - min(raw$date))
raw$temp_C[raw$temp_C == -999] <- NA
ip1f <- round(mean(raw$temp_C, na.rm = TRUE), 2)
# ip2 ---------------------------------------------------------------
wide <- read.csv("data/water_quality_wide.csv", check.names = FALSE)
long <- pivot_longer(wide, -station, names_to = "month", values_to = "temp")
ip2a <- nrow(long)
lz <- left_join(long, st[, c("station", "zone")], by = "station")
ip2b <- round(mean(lz$temp[lz$zone == "South" & lz$month == "2024-07"]), 2)
mm <- lz %>% group_by(month) %>% summarise(t = mean(temp)) %>% arrange(desc(t))
ip2c <- mm$month[1]
hh_raw <- read.csv("data/survey_households.csv", na.strings = "")
mem <- read.csv("data/survey_members.csv", na.strings = "")
ip2d <- nrow(anti_join(mem, hh_raw, by = "hh_id"))
as_ <- read.csv("data/survey_assets.csv")
ip2e <- n_distinct(as_$hh_id[as_$asset == "pirogue"])
# ip3 ---------------------------------------------------------------
h <- hh_raw[!duplicated(hh_raw), ]
ip3a <- nrow(hh_raw) - nrow(h)
ip3b <- sum(str_detect(h$activities, "fishing"), na.rm = TRUE)
lik <- str_to_sentence(str_squish(h$mpa_benefits))
lik <- lik[!is.na(lik)]                                   # only households that answered
ip3c <- round(100 * mean(lik %in% c("Agree", "Strongly agree")), 1)
ip3d <- names(sort(table(h$main_income), decreasing = TRUE))[1]
ip3e <- round(mean(str_count(h$activities, ";") + 1, na.rm = TRUE), 2)
# ip4 ---------------------------------------------------------------
w <- read.csv("data/checkpoints/I2_water_quality_clean.csv")
cv <- function(x) 100 * sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)
cvs <- sapply(split(w$salinity_psu, w$station), cv)
ip4a <- names(which.max(cvs)); ip4b <- round(max(cvs), 2)
ip4c <- sum(w$temp_C >= 28, na.rm = TRUE)
cls <- ifelse(w$turbidity_NTU < 3, "clear", ifelse(w$turbidity_NTU < 6, "moderate", "turbid"))
ip4d <- sum(cls == "turbid", na.rm = TRUE)
# ip5 ---------------------------------------------------------------
w$month <- month(as.Date(w$date))
dm <- tapply(w$DO_mgL, w$month, mean, na.rm = TRUE)
ip5a <- as.integer(names(which.min(dm))); ip5b <- round(min(dm), 2)
# ip6 ---------------------------------------------------------------
wz <- left_join(w, st[, c("station", "zone")], by = "station")
ns <- wz[wz$zone %in% c("North", "South"), ]
ip6a <- median(ns$turbidity_NTU[ns$zone == "South"], na.rm = TRUE)
ip6p <- wilcox.test(turbidity_NTU ~ zone, data = ns)$p.value
ip6b <- round(cor(w$salinity_psu, w$turbidity_NTU, method = "spearman", use = "complete.obs"), 3)
hc <- read.csv("data/checkpoints/I4_households_clean.csv")
hc <- left_join(hc, read.csv("data/villages.csv")[, c("village", "zone")], by = "village")
tz <- table(hc$zone, hc$does_seaweed)
ip6c <- round(chisq.test(tz)$p.value, 3)
ip6d <- round(min(chisq.test(tz)$expected), 1)
