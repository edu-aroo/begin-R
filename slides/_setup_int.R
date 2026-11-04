# _setup_int.R — shared setup for the three INTERMEDIATE slide decks (sourced in each .Rmd)
# Code chunks run from the PROJECT ROOT (root.dir), so paths are the same as in the course.
source("R/course_helpers.R")           # fig_svg() etc.
source("R/intermediate_pipeline.R")    # cp_*() functions: the checkpoint tables of each session
knitr::opts_chunk$set(comment = "#>", collapse = TRUE,
                      fig.width = 7, fig.height = 4.2,
                      out.width = "58%", fig.align = "center", dpi = 110)
suppressMessages({library(dplyr); library(tidyr); library(ggplot2); library(stringr); library(patchwork)})
theme_set(theme_minimal(base_size = 14))   # same look for every ggplot of the decks
