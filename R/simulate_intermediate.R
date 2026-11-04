# =============================================================================
# simulate_intermediate.R — all datasets of the INTERMEDIATE level
#   source("R/simulate_intermediate.R")      (needs: openxlsx, only for you)
# -----------------------------------------------------------------------------
# THE STORY (simulated, names invented): the seaweed farmers' cooperative
# "Fanantenana" works in 12 villages of a fictional bay ("Sarondra Bay").
#  1. seaweed_farming.xlsx  — technician's register of farming lines (2 years)
#  2. water_quality_*.csv   — probe measurements at 10 stations (3 years)
#  3. survey_*.csv          — household survey, 6 villages, 3 linked tables
#  4. seacucumber_*.csv     — sea cucumber pens of 3 farms (final project)
#  5. villages.csv, stations.csv, coastline.csv — coordinates for the maps
# Values are realistic in order of magnitude but describe NO real place.
# =============================================================================
set.seed(2027)
dir.create("data", showWarnings = FALSE)

# ---- 0. villages and coordinates -----------------------------------------------
villages <- data.frame(
  village = c("Ankarabe", "Antsiraka", "Mahavelo", "Tsiandavaka", "Ambalakely", "Ampasimena",
              "Befasy", "Lovobe", "Sarondrano", "Andrevobe", "Tsimanjaka", "Ambatofotsy"),
  zone    = rep(c("North", "Centre", "South"), each = 4),
  lat     = round(seq(-22.62, -23.28, length.out = 12) + rnorm(12, 0, 0.01), 4),
  stringsAsFactors = FALSE)
# coastline: x = longitude of the shore for each latitude (a wavy line)
coast_lat <- seq(-22.5, -23.4, by = -0.01)
coast_lon <- 43.62 + 0.05 * sin(coast_lat * 9) + 0.03 * cos(coast_lat * 23)
villages$lon <- round(approx(coast_lat, coast_lon, villages$lat)$y + 0.008, 4)  # just inland (land is east of the shore)
coastline <- data.frame(lon = round(c(coast_lon, 44.2, 44.2), 4),            # closed polygon of land
                        lat = round(c(coast_lat, -23.4, -22.5), 4))
write.csv(coastline, "data/coastline.csv", row.names = FALSE)

# ---- 1. seaweed farming ----------------------------------------------------------
n_farm <- 96
farmers <- data.frame(
  farmer_id  = sprintf("F%03d", 1:n_farm),
  village    = sample(villages$village, n_farm, replace = TRUE),
  sex        = sample(c("F", "M"), n_farm, replace = TRUE, prob = c(.55, .45)),
  age        = round(runif(n_farm, 18, 62)),
  experience_years = NA,
  joined_coop = as.Date("2018-01-01") + sample(0:2200, n_farm, replace = TRUE),
  stringsAsFactors = FALSE)
farmers$experience_years <- pmax(0, pmin(farmers$age - 16, round(rexp(n_farm, 1/5))))
# women adopt the new "long-line" technique more often (for the chi-square test in I10)
farmers$technique <- ifelse(runif(n_farm) < ifelse(farmers$sex == "F", .62, .38), "long-line", "off-bottom")
# messy village spelling in the farmers sheet
i <- sample(n_farm, 9); farmers$village[i] <- toupper(farmers$village[i])
i <- sample(n_farm, 6); farmers$village[i] <- paste0(farmers$village[i], " ")

# monthly sea temperature (used for growth and for water quality)
month_temp <- c(28.6, 29.0, 28.7, 27.6, 26.0, 24.6, 23.8, 23.9, 24.7, 25.9, 27.0, 28.0)

lines <- do.call(rbind, lapply(1:n_farm, function(k) {
  n_cycles <- sample(6:9, 1)
  starts <- sort(as.Date("2024-01-08") + sample(0:690, n_cycles))
  do.call(rbind, lapply(seq_along(starts), function(cy) {
    n_lines <- sample(2:5, 1)
    days <- sample(40:50, n_lines, replace = TRUE)
    m <- as.integer(format(starts[cy], "%m"))
    temp <- month_temp[m]
    # growth rate (% per day): best around 25-27 °C, long-line a bit better
    sgr <- 3.6 - 0.10 * (temp - 26)^2 + ifelse(farmers$technique[k] == "long-line", 0.45, 0) +
           rnorm(n_lines, 0, 0.55)
    w0 <- round(runif(n_lines, 8, 14), 1)                 # kg of cuttings tied on the line
    wf <- round(w0 * exp(pmax(sgr, 0.3) / 100 * days), 1)
    status <- sample(c("harvested", "lost - storm", "grazed by fish"), n_lines, replace = TRUE,
                     prob = c(.90, .05, .05))
    wf[status != "harvested"] <- NA
    data.frame(farmer_id = farmers$farmer_id[k], cycle = cy, planting_date = starts[cy],
               harvest_date = starts[cy] + days, line_length_m = sample(c(10, 15, 20), 1),
               initial_weight_kg = w0, final_weight_kg = wf, status = status, stringsAsFactors = FALSE)
  }))
}))
lines <- lines[order(lines$planting_date), ]
lines$line_id <- sprintf("L%04d", seq_len(nrow(lines)))
lines <- lines[, c("line_id", "farmer_id", "cycle", "planting_date", "harvest_date", "line_length_m",
                   "initial_weight_kg", "final_weight_kg", "status")]
# realistic errors: some weights typed in grams, harvest date typed as text dd/mm/yyyy
i <- sample(which(!is.na(lines$final_weight_kg)), 7); lines$final_weight_kg[i] <- lines$final_weight_kg[i] * 1000
lines$harvest_date <- format(lines$harvest_date, "%d/%m/%Y")
lines$notes <- ""
lines$notes[lines$status == "lost - storm"] <- "cyclone / strong swell"
lines$notes[sample(nrow(lines), 30)] <- "checked by technician"

readme <- data.frame(info = c(
  "Fanantenana seaweed cooperative — farming register (SIMULATED DATA for teaching)",
  "Collected by the cooperative technician, Jan 2024 - Dec 2025.",
  "Each line of cuttings (Kappaphycus) is weighed with a hanging scale at planting and at harvest.",
  "Sheet 'farmers': one row per farmer. Sheet 'lines': one row per farming line.",
  "Weights in kg. harvest_date was typed by hand as dd/mm/yyyy.",
  "status: harvested / lost - storm / grazed by fish (no final weight when the line was lost)."))

wb <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb, "README");  openxlsx::writeData(wb, "README", readme, colNames = FALSE)
openxlsx::addWorksheet(wb, "farmers"); openxlsx::writeData(wb, "farmers", farmers)
openxlsx::addWorksheet(wb, "lines")
openxlsx::writeData(wb, "lines", data.frame(x = c("Seaweed lines register — Fanantenana cooperative",
                                                  "Technician: R. Hary  |  scale: 50 kg hanging scale")),
                    colNames = FALSE)                   # two title rows above the table
openxlsx::writeData(wb, "lines", lines, startRow = 4)   # the table starts on row 4
openxlsx::saveWorkbook(wb, "data/seaweed_farming.xlsx", overwrite = TRUE)

# ---- 2. water quality ------------------------------------------------------------
stations <- data.frame(station = sprintf("WQ%02d", 1:10),
                       zone = rep(c("North", "Centre", "South"), c(3, 4, 3)),
                       lat = round(seq(-22.66, -23.24, length.out = 10), 4))
stations$lon <- round(approx(coast_lat, coast_lon, stations$lat)$y - runif(10, 0.03, 0.08), 4)  # at sea
stations$depth_m <- round(runif(10, 1.5, 6), 1)
write.csv(stations, "data/stations.csv", row.names = FALSE)

dates <- sort(c(seq(as.Date("2023-01-05"), as.Date("2025-12-20"), by = "month"),
                seq(as.Date("2023-01-19"), as.Date("2025-12-20"), by = "month")))
wq <- expand.grid(date = dates, station = stations$station, stringsAsFactors = FALSE)
wq <- merge(wq, stations[, c("station", "zone", "depth_m")])
m <- as.integer(format(wq$date, "%m"))
wq$temp_C        <- round(month_temp[m] + rnorm(nrow(wq), 0, 0.6) - 0.08 * wq$depth_m, 1)
wq$salinity_psu  <- round(35.2 - ifelse(m %in% c(12, 1, 2, 3), 1.6, 0) - ifelse(wq$zone == "South", 0.8, 0) +
                            rnorm(nrow(wq), 0, 0.5), 1)
wq$pH            <- round(8.15 + rnorm(nrow(wq), 0, 0.06), 2)
wq$DO_mgL        <- round(7.2 - 0.12 * (wq$temp_C - 26) + rnorm(nrow(wq), 0, 0.35), 2)
wq$turbidity_NTU <- round(exp(rnorm(nrow(wq), log(ifelse(wq$zone == "South", 6, 3)), 0.5)), 1)
# probe problems: sentinel codes and impossible values
i <- sample(nrow(wq), 12); wq$temp_C[i] <- -999
i <- sample(nrow(wq), 6);  wq$pH[i] <- 0
i <- sample(nrow(wq), 8);  wq$DO_mgL[i] <- NA
wq <- wq[order(wq$date, wq$station), c("station", "date", "temp_C", "salinity_psu", "pH", "DO_mgL", "turbidity_NTU")]
wq$date <- format(wq$date, "%d/%m/%Y")
write.csv(wq, "data/water_quality_long.csv", row.names = FALSE)   # one row per visit (parameters in columns)

# the same temperatures as an "Excel report": one row per station, one column per month
wq_ok <- wq; wq_ok$temp_C[wq_ok$temp_C < 0] <- NA
wq_ok$month <- format(as.Date(wq_ok$date, "%d/%m/%Y"), "%Y-%m")
wide <- tapply(wq_ok$temp_C, list(wq_ok$station, wq_ok$month), mean, na.rm = TRUE)
wide <- data.frame(station = rownames(wide), round(wide, 1), check.names = FALSE)
write.csv(wide, "data/water_quality_wide.csv", row.names = FALSE)

# ---- 3. household survey -----------------------------------------------------------
sv_vill <- villages$village[c(1, 3, 5, 7, 9, 11)]
n_hh <- 420
hh <- data.frame(
  hh_id = sprintf("HH%03d", 1:n_hh),
  village = sample(sv_vill, n_hh, replace = TRUE),
  interview_date = format(as.Date("2025-07-01") + sample(0:45, n_hh, replace = TRUE), "%Y-%m-%d"),
  enumerator = sample(c("Fara", "Tojo", "Mamy"), n_hh, replace = TRUE),
  head_sex = sample(c("Female", "Male"), n_hh, replace = TRUE, prob = c(.3, .7)),
  head_age = round(runif(n_hh, 20, 75)),
  head_education = sample(c("None", "Primary", "Secondary", "Higher"), n_hh, replace = TRUE, prob = c(.25, .45, .25, .05)),
  stringsAsFactors = FALSE)
hh$main_income <- sample(c("fishing", "seaweed farming", "trade", "agriculture", "salaried"), n_hh,
                         replace = TRUE, prob = c(.42, .25, .15, .1, .08))
# monthly income in Ariary: right-skewed (log-normal) -> transformation in I9
base <- c(fishing = 380000, "seaweed farming" = 420000, trade = 520000, agriculture = 300000, salaried = 650000)
hh$monthly_income_mga <- round(exp(rnorm(n_hh, log(base[hh$main_income]), 0.55)), -3)
hh$distance_coast_km <- round(rexp(n_hh, 1 / 0.6), 2)
# activities: multiple-choice answer stored in ONE cell, separated by ";"
acts <- c("fishing", "seaweed", "gleaning", "agriculture", "trade", "livestock")
hh$activities <- sapply(seq_len(n_hh), function(k) paste(sample(acts, sample(1:3, 1)), collapse = ";"))
# Likert answers typed with inconsistent spelling
lik <- c("Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree")
hh$mpa_benefits <- sample(lik, n_hh, replace = TRUE, prob = c(.07, .13, .25, .35, .20))
i <- sample(n_hh, 20); hh$mpa_benefits[i] <- tolower(hh$mpa_benefits[i])
i <- sample(n_hh, 10); hh$mpa_benefits[i] <- paste0(" ", hh$mpa_benefits[i])
hh$mpa_benefits[sample(n_hh, 8)] <- NA
hh$satisfaction_1to5 <- sample(1:5, n_hh, replace = TRUE, prob = c(.1, .2, .3, .28, .12))

members <- do.call(rbind, lapply(seq_len(n_hh), function(k) {
  n <- sample(2:9, 1)
  data.frame(hh_id = hh$hh_id[k], member_no = 1:n,
             relation = c("head", sample(c("spouse", "child", "child", "parent", "other"), n - 1, replace = TRUE)),
             sex = c(substr(hh$head_sex[k], 1, 1), sample(c("F", "M"), n - 1, replace = TRUE)),
             age = c(hh$head_age[k], round(runif(n - 1, 0, 70))), stringsAsFactors = FALSE)
}))
members$in_school <- ifelse(members$age >= 6 & members$age <= 17, sample(c("yes", "no"), nrow(members), TRUE, c(.7, .3)), NA)
members$works_seaweed <- ifelse(members$age >= 12, sample(c("yes", "no"), nrow(members), TRUE, c(.3, .7)), "no")
# 5 households interviewed twice by mistake (duplicated rows in the household table)
hh <- rbind(hh, hh[sample(n_hh, 5), ])
# 4 member rows refer to households that do not exist (typing error in hh_id) -> anti_join in I3
i <- sample(nrow(members), 4); members$hh_id[i] <- sprintf("HH%03d", 900 + 1:4)

assets <- do.call(rbind, lapply(sprintf("HH%03d", 1:n_hh), function(id) {
  a <- sample(c("pirogue", "motor boat", "fishing net", "mobile phone", "solar panel", "bicycle"), sample(0:4, 1))
  if (!length(a)) return(NULL)
  data.frame(hh_id = id, asset = a, quantity = sample(1:3, length(a), TRUE, c(.7, .2, .1)))
}))
write.csv(hh, "data/survey_households.csv", row.names = FALSE, na = "")
write.csv(members, "data/survey_members.csv", row.names = FALSE, na = "")
write.csv(assets, "data/survey_assets.csv", row.names = FALSE)

# ---- 4. sea cucumbers (final project) --------------------------------------------
pens <- data.frame(pen_id = sprintf("P%02d", 1:24), farm = rep(c("Farm A", "Farm B", "Farm C"), each = 8),
                   village = rep(c("Ankarabe", "Ambalakely", "Sarondrano"), each = 8),
                   area_m2 = sample(c(400, 500, 625), 24, TRUE), stringsAsFactors = FALSE)
pens$stocking_date <- format(as.Date("2024-09-01") + sample(0:40, 24, TRUE), "%d/%m/%Y")
pens$juveniles_stocked <- round(pens$area_m2 * runif(24, 0.8, 1.6))
pens$density_per_m2 <- round(pens$juveniles_stocked / pens$area_m2, 2)
mon <- do.call(rbind, lapply(1:24, function(k) {
  start <- as.Date(pens$stocking_date[k], "%d/%m/%Y")
  do.call(rbind, lapply(1:10, function(mth) {
    d <- start + 30 * mth
    temp <- month_temp[as.integer(format(d, "%m"))]
    farm_eff <- c("Farm A" = 1.0, "Farm B" = 0.85, "Farm C" = 1.12)[pens$farm[k]]
    mw <- 15 * exp((0.30 - 0.05 * pens$density_per_m2[k] - 0.012 * abs(temp - 27)) * farm_eff * mth)
    data.frame(pen_id = pens$pen_id[k], date = format(d, "%Y-%m-%d"), month_no = mth,
               individual = 1:20, weight_g = round(mw * exp(rnorm(20, 0, 0.25)), 1))
  }))
}))
mort <- data.frame(pen_id = pens$pen_id,
                   alive_at_harvest = round(pens$juveniles_stocked * runif(24, 0.45, 0.8)))
write.csv(pens, "data/seacucumber_pens.csv", row.names = FALSE)
write.csv(mon, "data/seacucumber_monitoring.csv", row.names = FALSE)
write.csv(mort, "data/seacucumber_harvest.csv", row.names = FALSE)

# ---- 5. coordinates of villages (without the sea cucumber farms) ----------------
villages$n_farmers <- as.vector(table(factor(trimws(tools::toTitleCase(tolower(farmers$village))),
                                            levels = villages$village)))
write.csv(villages, "data/villages.csv", row.names = FALSE)

# ---- 6. zip of the intermediate data -------------------------------------------
f_int <- c("data/seaweed_farming.xlsx", "data/water_quality_long.csv", "data/water_quality_wide.csv",
           "data/survey_households.csv", "data/survey_members.csv", "data/survey_assets.csv",
           "data/seacucumber_pens.csv", "data/seacucumber_monitoring.csv", "data/seacucumber_harvest.csv",
           "data/villages.csv", "data/stations.csv", "data/coastline.csv")
if (nzchar(Sys.which("zip"))) {
  unlink("data/r_course_data_intermediate.zip")
  utils::zip("data/r_course_data_intermediate.zip", f_int, flags = "-j9q")
}
message("Intermediate datasets written to data/")
