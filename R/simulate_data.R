# =============================================================================
# simulate_data.R
# -----------------------------------------------------------------------------
# Creates ALL the (simulated) datasets used in the course and saves them in
# the data/ folder. Run it once from the project root:
#     source("R/simulate_data.R")
#
# WHY SIMULATE?  We control the "truth" (e.g. MPAs have higher cover), the
# numbers never change (thanks to set.seed), so quiz answers are always
# identical for every student.
#
# TO REUSE FOR ANOTHER COURSE (e.g. socio-economics): keep the same logic
# (set.seed -> build columns -> data.frame -> write.csv) and replace the
# variables (household size, income class, fishing gear...).
#
# NOTE: site and MPA names are invented. Values do NOT describe real reefs.
# =============================================================================

set.seed(2026)   # fixes the random number generator -> same data every run

dir.create("data", showWarnings = FALSE)   # create data/ if it does not exist

# -----------------------------------------------------------------------------
# 1. seagrass_quadrats.csv  (clean practice dataset, sessions 3, 5, 6, 8)
#    4 sites x 15 quadrats (50 x 50 cm) = 60 rows
# -----------------------------------------------------------------------------
sites      <- c("Ambalaboy", "Fasimena", "Tsiandamba", "Belitsaky")
status     <- c("Inside", "Inside", "Outside", "Outside")   # MPA status per site
mean_cover <- c(62, 55, 34, 41)    # "true" mean % cover we want per site
n_quad     <- 15                   # quadrats per site

species_pool <- c("Thalassia hemprichii", "Cymodocea serrulata",
                  "Thalassodendron ciliatum", "Syringodium isoetifolium")

seagrass <- do.call(rbind, lapply(seq_along(sites), function(i) {
  # rnorm() draws random values around a mean; pmin/pmax keep them in 0-100
  cover <- round(pmin(100, pmax(0, rnorm(n_quad, mean_cover[i], 14))))
  data.frame(
    site           = sites[i],
    mpa_status     = status[i],
    quadrat        = 1:n_quad,
    date           = as.character(as.Date("2026-03-10") + i - 1),
    depth_m        = round(runif(n_quad, 0.4, 3.0), 1),   # uniform between 0.4 and 3 m
    species        = sample(species_pool, n_quad, replace = TRUE,
                            prob = c(0.4, 0.25, 0.2, 0.15)),
    seagrass_cover = cover,
    # canopy height loosely linked to cover (+ noise)
    canopy_height_cm = round(8 + 0.18 * cover + rnorm(n_quad, 0, 3), 1),
    # shoots per m2 (counted in 0.25 m2 quadrat, multiplied by 4)
    shoot_density  = 4 * round(pmax(0, 30 + 1.6 * cover + rnorm(n_quad, 0, 15)))
  )
}))

# two missing canopy heights, to practise na.rm = TRUE
seagrass$canopy_height_cm[c(7, 38)] <- NA

write.csv(seagrass, "data/seagrass_quadrats.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 2. seagrass_messy.csv  (same survey, typed badly in the field: session 4)
# -----------------------------------------------------------------------------
messy <- seagrass

# (a) inconsistent site spelling: upper case, lower case, trailing spaces
idx <- c(3, 9, 18, 24, 33, 47, 52, 58)
messy$site[idx] <- c("ambalaboy", "Ambalaboy ", "FASIMENA", "fasimena",
                     " Tsiandamba", "belitsaky", "Belitsaky ", "BELITSAKY")

# (b) cover stored as text: some with a "%" sign, some missing coded as "-"
messy$seagrass_cover <- as.character(messy$seagrass_cover)
messy$seagrass_cover[c(5, 21, 40)] <- paste0(messy$seagrass_cover[c(5, 21, 40)], "%")
messy$seagrass_cover[c(12, 44)] <- "-"

# (c) one impossible value (typing error: cover > 100 %)
messy$seagrass_cover[29] <- "130"

# (d) two duplicated rows (the same quadrat entered twice)
messy <- rbind(messy, messy[c(15, 50), ])

# (e) an "Excel-style" column name with spaces and symbols
names(messy)[names(messy) == "seagrass_cover"] <- "Seagrass cover (%)"

write.csv(messy, "data/seagrass_messy.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 3. coral_pit_example.csv  (Point Intercept Transect, session 7)
#    2 reefs x 3 transects x 50 points
#    HC = hard coral, SC = soft coral, MA = macroalgae, TA = turf algae,
#    RB = rubble, SD = sand
# -----------------------------------------------------------------------------
cats <- c("HC", "SC", "MA", "TA", "RB", "SD")
make_pit <- function(prob) sample(cats, 50, replace = TRUE, prob = prob)

pit <- do.call(rbind, lapply(c("Reef_A", "Reef_B"), function(r) {
  prob <- if (r == "Reef_A") c(.40, .08, .10, .17, .15, .10) else c(.18, .05, .27, .25, .15, .10)
  do.call(rbind, lapply(1:3, function(t) {
    data.frame(reef = r, transect = t, point = 1:50,
               distance_m = seq(0.5, 25, by = 0.5),   # one point every 50 cm
               category = make_pit(prob))
  }))
}))
write.csv(pit, "data/coral_pit_example.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 4. coral_cover_raw.csv  (FINAL PROJECT, deliberately messy)
#    3 MPAs x 2 zones (No-take / Fishing) x 3 transects x 50 points = 900 rows
# -----------------------------------------------------------------------------
mpas  <- c("Ankaramena", "Nosy Fasika", "Tanjona")
zones <- c("No-take", "Fishing")
# probability of hard coral (HC) for each MPA x zone
p_hc  <- matrix(c(.46, .30,
                  .38, .27,
                  .52, .24), ncol = 2, byrow = TRUE, dimnames = list(mpas, zones))

raw <- do.call(rbind, lapply(mpas, function(m) {
  do.call(rbind, lapply(zones, function(z) {
    do.call(rbind, lapply(1:3, function(t) {
      hc   <- p_hc[m, z] + rnorm(1, 0, 0.05)          # transect-level variation
      rest <- (1 - hc) * c(.10, .20, .30, .25, .15)    # SC, MA, TA, RB, SD
      data.frame(
        date     = paste0("2026-04-1", which(mpas == m)),   # one survey day per MPA
        mpa      = m,
        zone     = z,
        transect = t,
        point    = 1:50,
        depth_m  = round(rnorm(1, 6, 1.5), 1),
        category = sample(cats, 50, replace = TRUE, prob = c(hc, rest)),
        observer = sample(c("RA", "FT", "HN"), 1)
      )
    }))
  }))
}))

# ---- now we "damage" the clean raw data the way real field sheets look -----
# (a) MPA names typed in different ways (case, extra spaces)
i_mpa <- sample(nrow(raw), 60)
raw$mpa[i_mpa] <- sapply(raw$mpa[i_mpa], function(x)
  switch(sample(4, 1),
         tolower(x),                    # "nosy fasika"
         toupper(x),                    # "NOSY FASIKA"
         paste0(x, " "),                # "Nosy Fasika "  (trailing space)
         gsub(" ", "  ", paste0(" ", x)) # " Nosy  Fasika" (double spaces)
  ))

# (b) zone typed in lower case sometimes
i_zone <- sample(nrow(raw), 40)
raw$zone[i_zone] <- tolower(raw$zone[i_zone])

# (c) benthic codes in lower case or with spaces
i_cat <- sample(nrow(raw), 45)
raw$category[i_cat] <- sapply(raw$category[i_cat], function(x)
  switch(sample(3, 1), tolower(x), paste0(" ", x), paste0(x, " ")))

# (d) some points not recorded: empty "" or "NA" text
i_na <- sample(nrow(raw), 14)
raw$category[i_na] <- sample(c("", "NA"), 14, replace = TRUE)

# (e) a block of 10 rows entered twice (copy-paste error)
raw <- rbind(raw, raw[301:310, ])

# (f) shuffle row order (data sheets merged from several observers)
raw <- raw[sample(nrow(raw)), ]

write.csv(raw, "data/coral_cover_raw.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 5. fish_uvc.csv  (underwater visual census of reef fish: sessions 4 and 9)
#    4 reef sites x 3 belt transects (50 m x 5 m = 250 m2)
#    One row = one group of fish of the same species and size seen on a transect.
#    a and b = length-weight parameters (W = a * L^b, W in g, L in cm).
#    The a/b values are APPROXIMATE, for teaching only (use FishBase for real work).
# -----------------------------------------------------------------------------
lw <- data.frame(
  family  = c("Scaridae", "Scaridae", "Acanthuridae", "Lutjanidae",
              "Serranidae", "Chaetodontidae", "Siganidae", "Labridae"),
  species = c("Scarus ghobban", "Chlorurus sordidus", "Acanthurus triostegus",
              "Lutjanus kasmira", "Epinephelus merra", "Chaetodon auriga",
              "Siganus sutor", "Thalassoma hardwicke"),
  a       = c(0.0145, 0.0170, 0.0250, 0.0135, 0.0110, 0.0270, 0.0160, 0.0100),
  b       = c(3.02, 3.00, 3.00, 3.05, 3.10, 3.00, 3.00, 3.05),
  max_len = c(40, 28, 22, 30, 26, 18, 35, 18)
)
reefs  <- c("Andavaka", "Belavenoke", "Tsifota", "Ambola")
rstat  <- c("Inside", "Inside", "Outside", "Outside")

fish <- do.call(rbind, lapply(seq_along(reefs), function(i) {
  do.call(rbind, lapply(1:3, function(t) {
    n   <- sample(9:14, 1)                         # number of fish groups seen
    sp  <- lw[sample(nrow(lw), n, replace = TRUE), ]
    big <- if (rstat[i] == "Inside") 0.65 else 0.45  # bigger fish inside the MPA
    data.frame(
      site       = reefs[i],
      mpa_status = rstat[i],
      transect   = t,
      family     = sp$family,
      species    = sp$species,
      length_cm  = round(pmax(4, rnorm(n, big * sp$max_len, 0.15 * sp$max_len))),
      count      = sample(1:15, n, replace = TRUE),
      a          = sp$a,
      b          = sp$b
    )
  }))
}))
write.csv(fish, "data/fish_uvc.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 6. One zip file with everything, for easy download by the students
# -----------------------------------------------------------------------------
files <- c("data/seagrass_quadrats.csv", "data/seagrass_messy.csv",
           "data/coral_pit_example.csv", "data/coral_cover_raw.csv",
           "data/fish_uvc.csv")
if (nzchar(Sys.which("zip"))) {
  unlink("data/r_course_data.zip")
  utils::zip("data/r_course_data.zip", files, flags = "-j9q")  # -j: no folder paths
}
message("Datasets written to data/")
