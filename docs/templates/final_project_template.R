# ==============================================================================
# FINAL PROJECT - Hard coral cover in three MPAs (simulated data)
# Author : <your name>
# Date   : <date>
# Data   : data/coral_cover_raw.csv  (Point Intercept Transects, 1 row = 1 point)
# ==============================================================================
# Fill in every "..." and run the script from top to bottom (Ctrl + Shift + Enter).
# Write down the numbers asked in the quiz as you go.

# ---- 0. Packages / functions --------------------------------------------------
# Function from Session 7: % of points of a given category
pct_cover <- function(categories, code = "HC") {
  categories <- categories[!is.na(categories)]
  sum(categories == code) / length(categories) * 100
}

# ---- 1. Import and inspect ----------------------------------------------------
raw <- read.csv("...")
str(raw)
nrow(raw)                       # Q1
unique(raw$mpa)                 # Q2: how many spellings?
table(raw$category, useNA = "always")

# ---- 2. Clean -----------------------------------------------------------------
# 2a. MPA names: double spaces -> one space, trim, same case
raw$mpa <- gsub("\\s+", " ", raw$mpa)
raw$mpa <- ...                  # trimws()
raw$mpa <- ...                  # tools::toTitleCase(tolower(...))
table(raw$mpa)                  # must show exactly 3 MPAs

# 2b. Zone: "No-take" or "Fishing"
raw$zone <- ifelse(tolower(raw$zone) == "no-take", "No-take", "Fishing")
table(raw$zone)

# 2c. Benthic codes: trim spaces, upper case, empty text -> NA
raw$category <- ...
raw$category <- ...
raw$category[raw$category == ""] <- NA
table(raw$category, useNA = "always")

# 2d. Duplicated rows
sum(duplicated(raw))            # Q3
pts <- raw[!duplicated(raw), ]

# 2e. Points without category
sum(is.na(pts$category))        # Q4
pts <- pts[...]                 # keep only rows where category is not NA
nrow(pts)                       # Q5
write.csv(pts, "outputs/coral_points_clean.csv", row.names = FALSE)

# ---- 3. Database: one row per transect ----------------------------------------
db <- aggregate(category ~ mpa + zone + transect, data = pts, FUN = pct_cover)
names(db)[names(db) == "category"] <- "hc_cover"
nrow(db)                        # Q6
db
write.csv(db, "outputs/coral_transects_db.csv", row.names = FALSE)

# ---- 4. Mean and SD per MPA x zone (the transect is the replicate) -----------
m <- tapply(db$hc_cover, list(db$zone, db$mpa), mean)
s <- tapply(db$hc_cover, list(db$zone, db$mpa), sd)
round(m, 2)
round(s, 2)

# ---- 5. Graph -----------------------------------------------------------------
m <- m[c("No-take", "Fishing"), ]          # No-take first
s <- s[c("No-take", "Fishing"), ]
png("outputs/fig_hard_coral_cover.png", width = 18, height = 12, units = "cm", res = 300)
bp <- barplot(m, beside = TRUE, ylim = c(0, max(m + s) * 1.15),
              col = c("#1b7f8c", "#d9694a"), las = 1,
              ylab = "Hard coral cover (%) - mean ± SD (n = 3 transects)")
arrows(bp, m - s, bp, m + s, angle = 90, code = 3, length = 0.06)
legend("topright", fill = c("#1b7f8c", "#d9694a"), legend = rownames(m), bty = "n")
box(bty = "l")
dev.off()

# ---- 6. Interpretation ----------------------------------------------------------
# Write 3-4 sentences: which MPA / zone has the highest cover? Is the no-take
# effect the same in all MPAs? What are the limits (n = 3 transects, simulated data)?
