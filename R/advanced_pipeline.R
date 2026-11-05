# ==============================================================================
# advanced_pipeline.R — cleaning and indicators of the Advanced level (mangroves)
# Used by the pages A8-A11 (quiz answers) and identical to the code taught there.
# ==============================================================================

# Mangrove trees, cleaned:
#  - species codes in upper case ("am" -> "AM")
#  - DBH typed without the decimal point: a trunk > 30 cm on a tree < 8 m tall is
#    impossible for these species -> divide by 10 (confirmed with the field team)
ca_trees_clean <- function(dir = "data/advanced") {
  tr <- read.csv(file.path(dir, "mangrove_trees.csv"))
  sp <- read.csv(file.path(dir, "mangrove_species.csv"))
  tr$species_code <- toupper(tr$species_code)
  bad <- tr$dbh_cm > 30 & tr$height_m < 8
  tr$dbh_cm[bad] <- tr$dbh_cm[bad] / 10
  tr <- merge(tr, sp, by.x = "species_code", by.y = "code", all.x = TRUE)
  # Komiyama et al. (2005): above-ground biomass (kg) = 0.251 * wood density (g/cm3) * DBH(cm)^2.46
  tr$agb_kg <- 0.251 * tr$wood_density * tr$dbh_cm^2.46
  tr$ba_m2  <- pi * (tr$dbh_cm / 200)^2          # basal area of the trunk (m2): DBH in cm -> radius in m
  tr[order(tr$plot_id, tr$tree_no), ]
}

# One row per plot: living trees only. Plot = circle of 10 m radius.
ca_plots <- function(dir = "data/advanced") {
  tr <- ca_trees_clean(dir)
  pl <- read.csv(file.path(dir, "mangrove_plots.csv"))
  area_m2 <- pi * 10^2
  al <- tr[tr$status == "alive", ]
  out <- do.call(rbind, lapply(split(al, al$plot_id), function(d) data.frame(
    plot_id = d$plot_id[1], n_alive = nrow(d),
    density_ha = nrow(d) / area_m2 * 1e4,
    agb_t_ha = sum(d$agb_kg) / 1000 / (area_m2 / 1e4),
    ba_m2_ha = sum(d$ba_m2) / area_m2 * 1e4)))
  merge(pl, out, by = "plot_id")
}
