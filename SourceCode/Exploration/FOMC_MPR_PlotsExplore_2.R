################
# Graphs to explore FOMC monetary policy forecasts (2)
# Christopher Gandrud
# 19 August 2013
################

# Load packages
library(ggplot2)
library(gridExtra)

# Create data sets from source
source("/git_repositories/FOMCForecasts/SourceCode/DataPreparation/FOMCMPR_GreenBook_Combine.R")

# Create inflation forecast graphs
Plot1 <- ggplot(data = SameYearFeb, aes(x = year, y = ObsInfFebSame)) +
        geom_line(linetype = "dashed") +
        geom_ribbon(aes(ymin = SInflationL, ymax = SInflationH), alpha = 0.2) +
        geom_ribbon(aes(ymin = SCInflationL, ymax = SCInflationH), alpha = 0.2) +
        ylab("Inflation\n") + xlab("") + ggtitle("Forecast Made in February\n") + theme_bw()

Plot2 <- ggplot(data = SameYearJul, aes(x = year, y = ObsInfJulySame)) +
        geom_line(linetype = "dashed") +
        geom_ribbon(aes(ymin = SInflationL, ymax = SInflationH), alpha = 0.2) +
        geom_ribbon(aes(ymin = SCInflationL, ymax = SCInflationH), alpha = 0.2) +
        ylab("") + xlab("") + ggtitle("Forecast Made in July\n") + theme_bw()

# Create GDP forecast graphs
Plot3 <- ggplot(data = SameYearFeb, aes(x = year, y = ObsGDP)) +
        geom_line(linetype = "dashed") +
        geom_ribbon(aes(ymin = SGDPL, ymax = SGDPH), alpha = 0.2) +
        geom_ribbon(aes(ymin = SCGDPL, ymax = SCGDPH), alpha = 0.2) +
        ylab("GDP Growth\n") + xlab("") + theme_bw()

Plot4 <- ggplot(data = SameYearJul, aes(x = year, y = ObsGDP)) +
        geom_line(linetype = "dashed") +
        geom_ribbon(aes(ymin = SGDPL, ymax = SGDPH), alpha = 0.2) +
        geom_ribbon(aes(ymin = SCGDPL, ymax = SCGDPH), alpha = 0.2) +
        ylab("") + xlab("") + theme_bw()

# Create Unemployment forecast graphs
Plot5 <- ggplot(data = SameYearFeb, aes(x = year, y = ObsUnemp)) +
        geom_line(linetype = "dashed") +
        geom_ribbon(aes(ymin = SUnemL, ymax = SUnemH), alpha = 0.2) +
        geom_ribbon(aes(ymin = SCUnemL, ymax = SCUnemH), alpha = 0.2) +
        ylab("Unemployment\n") + xlab("") + theme_bw()

Plot6 <- ggplot(data = SameYearJul, aes(x = year, y = ObsUnemp)) +
        geom_line(linetype = "dashed") +
        geom_ribbon(aes(ymin = SUnemL, ymax = SUnemH), alpha = 0.2) +
        geom_ribbon(aes(ymin = SCUnemL, ymax = SCUnemH), alpha = 0.2) +
        ylab("") + xlab("") + theme_bw()

grid.arrange(Plot1, Plot2, Plot3, Plot4, Plot5, Plot6)
