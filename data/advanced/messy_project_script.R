setwd("C:/Users/Rakoto/Desktop/my analysis FINAL")   # works only on Rakoto's computer!
library(dplyr)
reef <- read.csv("reef_2025_FINAL_v2.csv")
sites <- read.csv("sites.csv")
x <- merge(reef, sites)
aggregate(hard_coral ~ mpa + zone, data = x, FUN = mean)
png("graph1.png"); boxplot(hard_coral ~ zone, data = x); dev.off()
