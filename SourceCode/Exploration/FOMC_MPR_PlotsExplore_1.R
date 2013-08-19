##############
# FOMC Monetary Policy Report Corrections Basic Explore
# Christopher Gandrud
# 17 August 2013
##############

# Load packages
library(lubridate)
library(ggplot2)
library(gridExtra)

#### Load same year forecasts ####
SameYear <- read.csv("/git_repositories/FOMCForecasts/Data/Raw/FOMCMPRForecasts/SameYear.csv", stringsAsFactors = FALSE)

# Convert date
SameYear$ForecastDate <- dmy(SameYear$ForecastDate)

# Only February or July Predictions
SameYearFeb <- subset(SameYear, month(ForecastDate) == 2)
SameYearJul <- subset(SameYear, month(ForecastDate) == 7)

# Create inflation forecast graphs
Plot1 <- ggplot(data = SameYearFeb, aes(x = ForecastDate)) +
				geom_ribbon(aes(ymin = SInflationL, ymax = SInflationH), alpha = 0.2) +
				geom_ribbon(aes(ymin = SCInflationL, ymax = SCInflationH), alpha = 0.2) +
				ylab("Inflation\n") + xlab("") + ggtitle("Forecast Made in February\n") + theme_bw()

Plot2 <- ggplot(data = SameYearJul, aes(x = ForecastDate)) +
				geom_ribbon(aes(ymin = SInflationL, ymax = SInflationH), alpha = 0.2) +
				geom_ribbon(aes(ymin = SCInflationL, ymax = SCInflationH), alpha = 0.2) +
				xlab("") + ggtitle("Forecast Made in July\n") + theme_bw()

# Create GDP forecast graphs
Plot3 <- ggplot(data = SameYearFeb, aes(x = ForecastDate)) +
				geom_ribbon(aes(ymin = SGDPL, ymax = SGDPH), alpha = 0.2) +
				geom_ribbon(aes(ymin = SCGDPL, ymax = SCGDPH), alpha = 0.2) +
				ylab("GDP Growth\n") + xlab("") + theme_bw()

Plot4 <- ggplot(data = SameYearJul, aes(x = ForecastDate)) +
				geom_ribbon(aes(ymin = SGDPL, ymax = SGDPH), alpha = 0.2) +
				geom_ribbon(aes(ymin = SCGDPL, ymax = SCGDPH), alpha = 0.2) +
				xlab("") + theme_bw()

# Create Unemployment forecast graphs
Plot5 <- ggplot(data = SameYearFeb, aes(x = ForecastDate)) +
				geom_ribbon(aes(ymin = SUnemL, ymax = SUnemH), alpha = 0.2) +
				geom_ribbon(aes(ymin = SCUnemL, ymax = SCUnemH), alpha = 0.2) +
				ylab("Unemployment\n") + xlab("") + theme_bw()

Plot6 <- ggplot(data = SameYearJul, aes(x = ForecastDate)) +
				geom_ribbon(aes(ymin = SUnemL, ymax = SUnemH), alpha = 0.2) +
				geom_ribbon(aes(ymin = SCUnemL, ymax = SCUnemH), alpha = 0.2) +
				xlab("") + theme_bw()

grid.arrange(Plot1, Plot2, Plot3, Plot4, Plot5, Plot6)

#### Load next year forecasts ####
NextYear <- read.csv("/git_repositories/FOMCForecasts/Data/Raw/FOMCMPRForecasts/NextYear.csv", stringsAsFactors = FALSE)

# Convert date
NextYear$ForecastDate <- dmy(NextYear$ForecastDate)

# Only February or July Predictions
NextYearFeb <- subset(NextYear, month(ForecastDate) == 2)
NextYearJul <- subset(NextYear, month(ForecastDate) == 7)

# Create inflation forecast graphs
Plot1 <- ggplot(data = NextYearFeb, aes(x = ForecastDate)) +
				geom_ribbon(aes(ymin = NInflationL, ymax = NInflationH), alpha = 0.2) +
				geom_ribbon(aes(ymin = NCInflationL, ymax = NCInflationH), alpha = 0.2) +
				ylab("Inflation\n") + xlab("") + ggtitle("Forecast Made in February Previous Year\n") + theme_bw()

Plot2 <- ggplot(data = NextYearJul, aes(x = ForecastDate)) +
				geom_ribbon(aes(ymin = NInflationL, ymax = NInflationH), alpha = 0.2) +
				geom_ribbon(aes(ymin = NCInflationL, ymax = NCInflationH), alpha = 0.2) +
				xlab("") + ggtitle("Forecast Made in July Previous Year\n") + theme_bw()

# Create GDP forecast graphs
Plot3 <- ggplot(data = NextYearFeb, aes(x = ForecastDate)) +
				geom_ribbon(aes(ymin = NGDPL, ymax = NGDPH), alpha = 0.2) +
				geom_ribbon(aes(ymin = NCGDPL, ymax = NCGDPH), alpha = 0.2) +
				ylab("GDP Growth\n") + xlab("") + theme_bw()

Plot4 <- ggplot(data = NextYearJul, aes(x = ForecastDate)) +
				geom_ribbon(aes(ymin = NGDPL, ymax = NGDPH), alpha = 0.2) +
				geom_ribbon(aes(ymin = NCGDPL, ymax = NCGDPH), alpha = 0.2) +
				xlab("") + theme_bw()

# Create Unemployment forecast graphs
Plot5 <- ggplot(data = NextYearFeb, aes(x = ForecastDate)) +
				geom_ribbon(aes(ymin = NUnemL, ymax = NUnemH), alpha = 0.2) +
				geom_ribbon(aes(ymin = NCUnemL, ymax = NCUnemH), alpha = 0.2) +
				ylab("Unemployment\n") + xlab("") + theme_bw()

Plot6 <- ggplot(data = NextYearJul, aes(x = ForecastDate)) +
				geom_ribbon(aes(ymin = NUnemL, ymax = NUnemH), alpha = 0.2) +
				geom_ribbon(aes(ymin = NCUnemL, ymax = NCUnemH), alpha = 0.2) +
				xlab("") + theme_bw()

grid.arrange(Plot1, Plot2, Plot3, Plot4, Plot5, Plot6)

