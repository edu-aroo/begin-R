# _setup.R — shared setup for the three slide decks (sourced in each .Rmd)
# Code chunks run from the PROJECT ROOT (root.dir), so paths are the same as
# in the course: "data/seagrass_quadrats.csv".
source("R/course_helpers.R")          # fig_svg() etc.
knitr::opts_chunk$set(comment = "#>", collapse = TRUE,   # code + result in one box (saves space)
                      fig.width = 7, fig.height = 4.2,
                      out.width = "75%", fig.align = "center", dpi = 110)
sg   <- read.csv("data/seagrass_quadrats.csv")
fish <- read.csv("data/fish_uvc.csv")
