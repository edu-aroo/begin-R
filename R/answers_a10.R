# Answers of the A10 practice quizzes (sourced, hidden, by a10-practice.Rmd)
suppressMessages({library(sf); library(terra); library(dplyr)})
source("R/advanced_pipeline.R")
A <- "data/advanced"; gpkg <- file.path(A, "monitoring_gis.gpkg")
# ap1 -- Git history and lockfile ------------------------------------------------
gd <- file.path(tempdir(), "a10-git"); unlink(gd, recursive = TRUE); dir.create(gd)
utils::unzip(file.path(A, "reef_project_git.zip"), exdir = gd)
g <- function(...) system2("git", c("-C", file.path(gd, "reef-monitoring"), ...), stdout = TRUE)
ap1a <- sum(g("log", "--format=%an") == "Fara Rasoa")
ap1b <- g("show", "--name-only", "--format=", "e0ed893")
ap1b <- ap1b[nzchar(ap1b)][1]
ap1c <- jsonlite::read_json(file.path(A, "renv_example.lock"))$Packages$sf$Version
# ap2 -- report numbers ------------------------------------------------------------
reef <- left_join(read.csv(file.path(A, "reef_monitoring.csv")), read.csv(file.path(A, "reef_sites.csv")), by = "site_id")
ap2a <- round(mean(reef$macroalgae[reef$mpa == "Tanjona" & reef$year == 2021]), 1)
ap2b <- sum(reef$mpa == "Ankaramena" & reef$zone == "No-take" & reef$year == 2020)
yrs <- reef %>% group_by(mpa) %>% summarise(n = n_distinct(year))
ap2c <- sum(yrs$n) * 1          # number of (MPA, year) reports possible
# ap3 -- vector GIS -----------------------------------------------------------------
Z <- st_read(gpkg, "mpa_zones", quiet = TRUE); PL <- st_read(gpkg, "mangrove_plots", quiet = TRUE)
ap3a <- round(sum(as.numeric(st_area(Z[Z$mpa == "Nosy Fasika" & Z$zone == "Fishing", ]))) / 1e6, 1)
nt <- st_union(Z[Z$zone == "No-take", ])
ap3b <- sum(as.numeric(st_distance(PL, nt)) < 5000)
mp <- Z %>% group_by(mpa) %>% summarise(.groups = "drop")
ap3c <- sum(mp$mpa[st_nearest_feature(PL, mp)] == "Tanjona")
# ap4 -- rasters ----------------------------------------------------------------------
B <- rast(file.path(A, "bathymetry.tif")); SST <- rast(file.path(A, "sst_2024.tif"))
ap4a <- round(global(SST[[8]], "mean", na.rm = TRUE)[1, 1], 2)
Bm <- mask(crop(B, vect(st_transform(Z, 4326))), vect(st_transform(Z, 4326)))
ap4b <- as.numeric(global(Bm > 20, "sum", na.rm = TRUE)[1, 1])
S <- st_read(gpkg, "reef_sites", quiet = TRUE)
dS <- extract(B, vect(st_transform(S, 4326)))$depth_m
ap4c <- S$site_id[which.max(dS)]
# ap5 -- mangroves ----------------------------------------------------------------------
P <- ca_plots(); TR <- ca_trees_clean()
ap5a <- round(mean(P$ba_m2_ha[P$status == "reference"]), 1)
pl <- read.csv(file.path(A, "mangrove_plots.csv"))
TRs <- merge(TR, pl[, c("plot_id", "status")], by = "plot_id", suffixes = c("", "_plot"))
ap5b <- round(100 * mean(TRs$status[TRs$status_plot == "restored"] == "dead"), 1)
ap5c <- round(mean(P$density_ha[P$status == "harvested"]))
# ap6 -- maps -------------------------------------------------------------------------------
ch <- reef %>% filter(year %in% c(2019, 2025)) %>% group_by(site_id, year) %>%
  summarise(m = mean(hard_coral), .groups = "drop") %>% tidyr::pivot_wider(names_from = year, values_from = m, names_prefix = "y")
ap6a <- sum(ch$y2025 > ch$y2019)
ap6b <- sum(ch$y2025 > ch$y2019 & S$zone[match(ch$site_id, S$site_id)] == "No-take")
