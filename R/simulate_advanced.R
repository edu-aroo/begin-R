# =============================================================================
# simulate_advanced.R — the (simulated) datasets of the ADVANCED level
# -----------------------------------------------------------------------------
# Run once from the project root:   source("R/simulate_advanced.R")
# Needs: sf, terra.  Writes everything in data/advanced/ and a zip.
#
# Story: the three MPAs of the Beginner final project (Ankaramena, Nosy Fasika,
# Tanjona) now have a long-term MONITORING PROGRAMME (2019-2025):
#   - coral reef transects every year (Point Intercept Transects),
#   - mangrove forest plots (tree inventory),
#   - GIS layers (land, MPA zones, sites) and rasters (bathymetry, sea temperature).
# Places, names and values are INVENTED: they describe no real place.
# =============================================================================
suppressMessages({ library(sf); library(terra) })
set.seed(2028)
out <- "data/advanced"
dir.create(out, showWarnings = FALSE, recursive = TRUE)

# ---- 0. coastline and land (re-uses the coast of the Intermediate level) -------
coast <- read.csv("data/coastline.csv")
coast_line <- coast[coast$lon < 44, ]                       # the shore only (north -> south)
shore_lon <- function(lat) approx(coast_line$lat, coast_line$lon, lat, rule = 2)$y
land <- st_sf(name = "mainland",
              geometry = st_sfc(st_polygon(list(as.matrix(rbind(coast, coast[1, ])))), crs = 4326))

# ---- 1. MPAs and their zones ---------------------------------------------------
# Each MPA = a band of sea in front of the coast; the inner part is the No-take zone.
mpa_def <- data.frame(mpa = c("Ankaramena", "Nosy Fasika", "Tanjona"),
                      lat_n = c(-22.60, -22.88, -23.12), lat_s = c(-22.78, -23.04, -23.32),
                      created = c(2015, 2017, 2019))
sea_poly <- function(lat_n, lat_s, off_in, off_out) {        # polygon between 2 distances from the shore
  lats <- seq(lat_n, lat_s, length.out = 30)
  inner <- cbind(shore_lon(lats) - off_in, lats)
  outer <- cbind(shore_lon(rev(lats)) - off_out, rev(lats))
  m <- rbind(inner, outer, inner[1, ])
  st_polygon(list(m))
}
zones <- do.call(rbind, lapply(seq_len(nrow(mpa_def)), function(i) {
  d <- mpa_def[i, ]
  mid_n <- d$lat_n - (d$lat_n - d$lat_s) * 0.30; mid_s <- d$lat_n - (d$lat_n - d$lat_s) * 0.70
  st_sf(mpa = d$mpa, zone = c("Fishing", "No-take", "Fishing"),
        part = c("north", "core", "south"), created = d$created,
        geometry = st_sfc(sea_poly(d$lat_n, mid_n, 0, 0.12),
                          sea_poly(mid_n, mid_s, 0, 0.12),
                          sea_poly(mid_s, d$lat_s, 0, 0.12), crs = 4326))
}))
zones <- suppressWarnings(st_difference(zones, st_union(land)))   # never on land
zones <- st_cast(zones, "MULTIPOLYGON")

# ---- 2. Reef monitoring sites (points) -----------------------------------------
sites <- do.call(rbind, lapply(seq_len(nrow(mpa_def)), function(i) {
  d <- mpa_def[i, ]
  data.frame(mpa = d$mpa,
             zone = rep(c("No-take", "Fishing"), each = 3),
             lat = c(seq(d$lat_n - (d$lat_n - d$lat_s) * 0.38, d$lat_n - (d$lat_n - d$lat_s) * 0.62, length.out = 3),
                     d$lat_n - (d$lat_n - d$lat_s) * c(0.12, 0.20, 0.85)))
}))
sites$site_id <- sprintf("R%02d", seq_len(nrow(sites)))
sites$lon <- round(shore_lon(sites$lat) - runif(nrow(sites), 0.03, 0.09), 5)
sites$lat <- round(sites$lat, 5)
sites$depth_m <- round(runif(nrow(sites), 3, 12), 1)
sites <- sites[, c("site_id", "mpa", "zone", "lon", "lat", "depth_m")]
sites_sf <- st_as_sf(sites, coords = c("lon", "lat"), crs = 4326, remove = FALSE)

# ---- 3. Mangrove plots (points, on the shore) ---------------------------------
patches <- data.frame(patch = c("Ankarabe", "Ambalakely", "Sarondrano"),
                      lat = c(-22.64, -22.85, -23.12), mpa = c("Ankaramena", "Nosy Fasika", "Tanjona"))
plots <- do.call(rbind, lapply(1:3, function(i) {
  data.frame(plot_id = sprintf("M%d%02d", i, 1:8), patch = patches$patch[i], mpa = patches$mpa[i],
             lat = round(patches$lat[i] + runif(8, -0.02, 0.02), 5))
}))
plots$lon <- round(shore_lon(plots$lat) + runif(nrow(plots), 0.002, 0.008), 5)   # just inland
plots$status <- rep(c("reference", "reference", "harvested", "harvested",
                      "restored", "restored", "reference", "harvested"), 3)
plots$survey_date <- format(as.Date("2025-05-05") + sample(0:30, nrow(plots), TRUE), "%Y-%m-%d")
plots_sf <- st_as_sf(plots, coords = c("lon", "lat"), crs = 4326, remove = FALSE)

# ---- 4. GeoPackage in UTM 38S (metres) + a shapefile in WGS84 ------------------
utm <- 32738
gpkg <- file.path(out, "monitoring_gis.gpkg")
unlink(gpkg)
st_write(st_transform(land, utm),     gpkg, layer = "land",            quiet = TRUE)
st_write(st_transform(zones, utm),    gpkg, layer = "mpa_zones",       quiet = TRUE)
st_write(st_transform(sites_sf, utm), gpkg, layer = "reef_sites",      quiet = TRUE)
st_write(st_transform(plots_sf, utm), gpkg, layer = "mangrove_plots",  quiet = TRUE)
shp_dir <- file.path(out, "villages_shp"); unlink(shp_dir, recursive = TRUE); dir.create(shp_dir)
vill <- read.csv("data/villages.csv")
st_write(st_as_sf(vill, coords = c("lon", "lat"), crs = 4326), file.path(shp_dir, "villages.shp"), quiet = TRUE)

# ---- 5. Reef monitoring table (2019-2025) ---------------------------------------
# Hard coral cover per transect. No-take zones higher; a bleaching event in 2024
# (warm water, see the SST raster) lowers cover in 2024-2025, less in No-take zones.
# Tanjona was not surveyed in 2022 (cyclone) -> missing year.
years <- 2019:2025
reef <- do.call(rbind, lapply(seq_len(nrow(sites)), function(k) {
  s <- sites[k, ]
  base <- c(Ankaramena = 34, `Nosy Fasika` = 28, Tanjona = 22)[s$mpa] + ifelse(s$zone == "No-take", 9, 0) + rnorm(1, 0, 4)
  do.call(rbind, lapply(years, function(y) {
    if (s$mpa == "Tanjona" && y == 2022) return(NULL)
    trend <- ifelse(s$zone == "No-take", 0.8, 0.1) * (y - 2019)
    bleach <- ifelse(y == 2024, ifelse(s$zone == "No-take", -6, -11), ifelse(y == 2025, ifelse(s$zone == "No-take", -4, -9), 0))
    hc <- pmin(pmax(round(base + trend + bleach + rnorm(3, 0, 4), 1), 2), 80)
    data.frame(site_id = s$site_id, year = y, transect = 1:3,
               survey_date = format(as.Date(paste0(y, "-04-01")) + sample(0:40, 1), "%Y-%m-%d"),
               hard_coral = hc,
               macroalgae = round(pmin(pmax(30 - 0.4 * hc + rnorm(3, 0, 4), 1), 70), 1),
               # 2024: bleaching follows the marine heatwave (centre of the bay, see the SST raster)
               bleached_pct = round(ifelse(y == 2024, pmin(pmax(rnorm(3, ifelse(s$zone == "No-take", 12, 20) +
                                                         22 * exp(-((s$lat + 22.95)^2) / 0.02), 8), 0), 90),
                                     pmax(rnorm(3, 3, 2), 0)), 1),
               observer = sample(c("HN", "FT", "RA"), 1))
  }))
}))
write.csv(reef, file.path(out, "reef_monitoring.csv"), row.names = FALSE)
write.csv(sites, file.path(out, "reef_sites.csv"), row.names = FALSE)

# ---- 6. Mangrove trees (inventory 2025) ----------------------------------------
sp <- data.frame(species = c("Rhizophora mucronata", "Ceriops tagal", "Avicennia marina",
                             "Bruguiera gymnorrhiza", "Sonneratia alba"),
                 code = c("RM", "CT", "AM", "BG", "SA"),
                 wood_density = c(0.85, 0.89, 0.65, 0.74, 0.50))   # g/cm3, approximate values FOR THE EXERCISE
trees <- do.call(rbind, lapply(seq_len(nrow(plots)), function(k) {
  p <- plots[k, ]
  n <- switch(p$status, reference = sample(55:80, 1), harvested = sample(30:50, 1), restored = sample(60:95, 1))
  spp <- sample(sp$code, n, TRUE, prob = c(.38, .25, .22, .1, .05))
  dbh <- switch(p$status, reference = rlnorm(n, log(11), 0.45), harvested = rlnorm(n, log(7), 0.45),
                restored = rlnorm(n, log(4.5), 0.35))
  dbh <- round(pmax(dbh, 2.5), 1)
  h <- round(1.3 + 1.1 * dbh^0.62 * exp(rnorm(n, 0, 0.12)), 1)
  status <- sample(c("alive", "dead", "cut"), n, TRUE,
                   prob = switch(p$status, reference = c(.93, .06, .01), harvested = c(.78, .05, .17), restored = c(.9, .1, 0)))
  data.frame(plot_id = p$plot_id, tree_no = seq_len(n), species_code = spp, dbh_cm = dbh,
             height_m = h, status = status)
}))
# a few field errors to clean (realistic)
i <- sample(nrow(trees), 4); trees$dbh_cm[i] <- trees$dbh_cm[i] * 10        # comma forgotten
i <- sample(nrow(trees), 3); trees$species_code[i] <- tolower(trees$species_code[i])
write.csv(trees, file.path(out, "mangrove_trees.csv"), row.names = FALSE)
write.csv(sp, file.path(out, "mangrove_species.csv"), row.names = FALSE)
write.csv(plots, file.path(out, "mangrove_plots.csv"), row.names = FALSE)

# ---- 7. Rasters: bathymetry and monthly sea surface temperature 2024 -----------
ext0 <- ext(43.35, 43.85, -23.40, -22.50)
r <- rast(ext0, resolution = 0.0025, crs = "EPSG:4326")
xy <- crds(r, na.rm = FALSE)
dist_deg <- shore_lon(xy[, 2]) - xy[, 1]                     # > 0 at sea
depth <- pmax(0.5, 2 + 160 * dist_deg + 6 * sin(xy[, 2] * 40) + rnorm(nrow(xy), 0, 0.8))
for (k in seq_len(nrow(sites))) {                            # shallow reef flats around the sites
  dd <- sqrt((xy[, 1] - sites$lon[k])^2 + (xy[, 2] - sites$lat[k])^2)
  depth <- depth - 3 * exp(-(dd / 0.012)^2)
}
depth <- pmax(depth, 1)
depth[dist_deg <= 0] <- NA                                   # land
values(r) <- round(depth, 1)
names(r) <- "depth_m"
writeRaster(r, file.path(out, "bathymetry.tif"), overwrite = TRUE, datatype = "FLT4S")

mt <- c(28.6, 29.0, 28.7, 27.6, 26.0, 24.6, 23.8, 23.9, 24.7, 25.9, 27.0, 28.0)   # same months as Intermediate
rc <- aggregate(r, 8, na.rm = TRUE)                          # coarser grid (~2 km), like satellite SST
xyc <- crds(rc, na.rm = FALSE); dc <- shore_lon(xyc[, 2]) - xyc[, 1]
sst <- rast(lapply(1:12, function(m) {
  x <- rc
  hot <- if (m %in% 2:4) 1.6 * exp(-((xyc[, 2] + 22.95)^2) / 0.02) else 0   # 2024 marine heatwave, centre of the bay
  v <- mt[m] + 0.6 + 0.5 * (xyc[, 2] + 22.95) - 3 * pmin(dc, 0.3) + hot + rnorm(nrow(xyc), 0, 0.1)
  v[dc <= 0] <- NA
  values(x) <- round(v, 2); x
}))
names(sst) <- sprintf("sst_2024_%02d", 1:12)
time(sst) <- as.Date(sprintf("2024-%02d-15", 1:12))
writeRaster(sst, file.path(out, "sst_2024.tif"), overwrite = TRUE, datatype = "FLT4S")

# ---- 8. A "messy project" for Session A0 ---------------------------------------
mp <- file.path(tempdir(), "my analysis FINAL"); unlink(mp, recursive = TRUE); dir.create(mp)
write.csv(reef[reef$year == 2025, ], file.path(mp, "reef 2025 (copy).csv"), row.names = FALSE)
write.csv(reef[reef$year == 2025, ], file.path(mp, "reef_2025_FINAL_v2.csv"), row.names = FALSE)
write.csv(sites, file.path(mp, "sites.csv"), row.names = FALSE)
writeLines(c(
  "setwd(\"C:/Users/Rakoto/Desktop/my analysis FINAL\")   # works only on Rakoto's computer!",
  "library(dplyr)",
  "reef <- read.csv(\"reef_2025_FINAL_v2.csv\")",
  "sites <- read.csv(\"sites.csv\")",
  "x <- merge(reef, sites)",
  "aggregate(hard_coral ~ mpa + zone, data = x, FUN = mean)",
  "png(\"graph1.png\"); boxplot(hard_coral ~ zone, data = x); dev.off()"), file.path(mp, "Untitled1.R"))
file.copy(file.path(mp, "Untitled1.R"), file.path(out, "messy_project_script.R"), overwrite = TRUE)  # shown in Session A0
writeLines(c("hard_coral ~ zone 2025", "No-take higher??", "ask Fara about R07"), file.path(mp, "notes.txt"))
old <- setwd(tempdir()); unlink(file.path(getwd(), "messy_project.zip"))
utils::zip("messy_project.zip", "my analysis FINAL", flags = "-r9Xq"); setwd(old)
file.copy(file.path(tempdir(), "messy_project.zip"), file.path(out, "messy_project.zip"), overwrite = TRUE)

# ---- 9. References for the Quarto sessions (real publications) -----------------
writeLines(c(
"@article{komiyama2005,",
"  author  = {Komiyama, Akira and Poungparn, Sasitorn and Kato, Shogo},",
"  title   = {Common allometric equations for estimating the tree weight of mangroves},",
"  journal = {Journal of Tropical Ecology}, year = {2005}, volume = {21}, number = {4}, pages = {471--477},",
"  doi     = {10.1017/S0266467405002476}}",
"",
"@book{hill2004,",
"  author    = {Hill, Jos and Wilkinson, Clive},",
"  title     = {Methods for Ecological Monitoring of Coral Reefs: A Resource for Managers},",
"  publisher = {Australian Institute of Marine Science}, address = {Townsville}, year = {2004}}",
"",
"@article{pebesma2018,",
"  author  = {Pebesma, Edzer},",
"  title   = {Simple Features for {R}: Standardized Support for Spatial Vector Data},",
"  journal = {The R Journal}, year = {2018}, volume = {10}, number = {1}, pages = {439--446},",
"  doi     = {10.32614/RJ-2018-009}}",
"",
"@book{wickham2016,",
"  author = {Wickham, Hadley}, title = {ggplot2: Elegant Graphics for Data Analysis},",
"  publisher = {Springer-Verlag}, address = {New York}, year = {2016}, edition = {2}}",
"",
"@book{xie2018,",
"  author = {Xie, Yihui and Allaire, J. J. and Grolemund, Garrett},",
"  title = {R Markdown: The Definitive Guide}, publisher = {Chapman and Hall/CRC},",
"  address = {Boca Raton, Florida}, year = {2018}}"), file.path(out, "references.bib"))

# ---- 8b. NEW field data for the final project (A11): the 2026 campaign ---------
# Separate seed: adding this block does not change any data above.
set.seed(2029)
r25 <- reef[reef$year == 2025, ]
new <- do.call(rbind, lapply(split(r25, r25$site_id), function(d) {
  s <- sites[sites$site_id == d$site_id[1], ]
  rec <- ifelse(s$zone == "No-take", 3.5, 1.5)                      # recovery after the 2024 bleaching
  data.frame(site_id = d$site_id, year = 2026, transect = 1:3,
             survey_date = format(as.Date("2026-04-06") + sample(0:35, 1), "%d/%m/%Y"),   # typed dd/mm/yyyy this year
             hard_coral = round(pmin(pmax(d$hard_coral + rec + rnorm(3, 0, 2.5), 2), 80), 1),
             macroalgae = round(pmin(pmax(d$macroalgae - 0.5 + rnorm(3, 0, 2), 1), 70), 1),
             bleached_pct = round(pmax(rnorm(3, 2.5, 1.5), 0), 1),
             observer = sample(c("HN", "FT", "RA", "TS"), 1))
}))
i <- sample(nrow(new), 3); new$site_id[i] <- tolower(new$site_id[i])      # "r07"
i <- sample(nrow(new), 2); new$hard_coral[i] <- new$hard_coral[i] * 10   # decimal point forgotten (52.3 -> 523)
new <- rbind(new, new[sample(nrow(new), 2), ])                           # two rows typed twice
rownames(new) <- NULL
write.csv(new, file.path(out, "reef_monitoring_2026.csv"), row.names = FALSE)

# ---- 9a. an example renv.lock (Session A1): the record of a project's packages ---
pk <- data.frame(Package = c("cli", "dplyr", "ggplot2", "glue", "here", "knitr", "readxl", "renv", "rlang", "rmarkdown", "sf", "terra", "tidyr", "units"),
                 Version = c("3.6.3", "1.1.4", "3.5.1", "1.7.0", "1.0.1", "1.47", "1.4.3", "1.0.7", "1.1.4", "2.27", "1.0-16", "1.7-78", "1.3.1", "0.8-5"))
lock <- list(R = list(Version = "4.4.1", Repositories = list(list(Name = "CRAN", URL = "https://cloud.r-project.org"))),
             Packages = setNames(lapply(seq_len(nrow(pk)), function(i)
               list(Package = pk$Package[i], Version = pk$Version[i], Source = "Repository", Repository = "CRAN")), pk$Package))
jsonlite::write_json(lock, file.path(out, "renv_example.lock"), auto_unbox = TRUE, pretty = TRUE)

# ---- 9b. a small project WITH its Git history (Session A2) ---------------------
if (nzchar(Sys.which("git"))) source("R/make_git_demo.R")

# ---- 10. zip of the advanced data ----------------------------------------------
if (nzchar(Sys.which("zip"))) {
  z <- "data/r_course_data_advanced.zip"; unlink(z)
  old <- setwd("data"); utils::zip(file.path("..", z), "advanced", flags = "-r9Xq"); setwd(old)
}
message("Advanced datasets written to ", out)
