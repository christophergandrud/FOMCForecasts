###########
# Combine FOMC Monetary Policy Report with Greenbook Paper 
# Christopher Gandrud
# 18 August 2013
###########

# Load packages
library(quantmod)
library(plyr)
library(ggplot2)
library(gridExtra)

#### Download actual data from FRED ####
# CPIAUCNS = Consumer Price Index for All Urban Consumers: All Items 
# PCEPI = Personal Consumption Expenditures: Chain-type Price Index
# PCEPILFE = Personal consumption expenditures excluding food and energy (chain-type price index)
# GDPC96 = Real Gross Domestic Product, 3 Decimal
# UNRATE = Civilian Unemployment Rate
Symbols <- c("CPIAUCNS", "PCEPI", "PCEPILFE", "GDPC96", "UNRATE")

ToDF <- function(x){
  
  getSymbols(x, src = "FRED")
  
  First <- x[1]
  for (i in x){
    TempDF <- get(i)
    if (i == First){ 
      mthlySumm <- apply.monthly(TempDF, mean)
      DateField <- index(TempDF)
      TempData <- data.frame(DateField, TempDF)
    }
    else if (i != First){
      mthlySumm <- apply.monthly(TempDF, mean)
      DateField <- index(TempDF)
      TempDataMore <- data.frame(DateField, TempDF)
      TempData <- merge(TempData, TempDataMore, by = "DateField", all = TRUE)  
    }
  }
  TempData
}

CombinedInflation <- ToDF(Symbols)

# Find average change per quarter 
quarter_change <- function(data, Var, TimeVar, NewVar = NULL, NoChange = FALSE)
{
  require(lubridate)
  require(plyr)
  require(DataCombine)
  data$Quarter <- quarter(data[, TimeVar], with_year = TRUE)
  data <- data[, c(TimeVar, "Quarter", Var)]
  names(data) <- c("Date", "Quarter", "TempVar")

    MeanTemp <- ddply(data, .(Quarter), transform, MeanVar = mean(TempVar, 
                                                                  na.rm = TRUE))
    MeanTemp <- MeanTemp[, c(1:2, 4)]
    MeanTemp <- MeanTemp[!duplicated(MeanTemp[, 2], MeanTemp[, 3]), ]
  if (!isTRUE(NoChange)){
    MeanTemp <- slide(data = MeanTemp, Var = "MeanVar", slideBy = -4, 
                      NewVar = "Lag")
    MeanTemp$ChangeTemp <- ((MeanTemp$MeanVar - MeanTemp$Lag)/MeanTemp$Lag) * 100
  }
  MeanTemp <- subset(MeanTemp, quarter(Date) == 4)
  MeanTemp$year <- year(MeanTemp$Date)
  if (!isTRUE(NoChange)){
    MeanTemp <- MeanTemp[, c(6, 5)]
  }
  else if (isTRUE(NoChange)){
    MeanTemp <- MeanTemp[, c(4, 3)]
  }
  if (!is.null(NewVar)){
    names(MeanTemp) <- c("year", NewVar)
    return(MeanTemp)
  } else
    return(MeanTemp)
}

QCPI <- quarter_change(data = CombinedInflation, Var = "CPIAUCNS", 
                     TimeVar = "DateField", NewVar = "ObsInflation")
QPCE <- quarter_change(data = CombinedInflation, Var = "PCEPI", 
                     TimeVar = "DateField", NewVar = "ObsInflation")
QPCECore <- quarter_change(data = CombinedInflation, Var = "PCEPILFE", 
                     TimeVar = "DateField", NewVar = "ObsInflation")
GDP <- quarter_change(data = CombinedInflation, Var = "GDPC96", 
                        TimeVar = "DateField", NewVar = "ObsGDP")
Unemp <- quarter_change(data = CombinedInflation, Var = "UNRATE", 
                        TimeVar = "DateField", NewVar = "ObsUnemp",
                        NoChange = TRUE)



# Keep only quarters and years used by FOMC
# February Same Year
QCPIF <- subset(QCPI, year < 2000)
QPCEF <- subset(QPCE, year >= 2000)
QPCEF <- subset(QPCEF, year < 2005)
QPCECoreF <- subset(QPCECore, year >= 2005)

FebInfl <- rbind(QCPIF, QPCEF, QPCECoreF)
names(FebInfl) <- c("year", "ObsInfFebSame")
FebInfl <- merge(FebInfl, GDP, by = "year")
FebInfl <- merge(FebInfl, Unemp, by = "year")


# July Same Year
QCPIJ <- subset(QCPI, year < 2000)
QPCEJ <- subset(QPCE, year >= 2000)
QPCEJ <- subset(QPCEJ, year < 2004)
QPCECoreJ <- subset(QPCECore, year >= 2004)

JulyInfl <- rbind(QCPIJ, QPCEJ, QPCECoreJ)
names(JulyInfl) <- c("year", "ObsInfJulySame")
JulyInfl <- merge(JulyInfl, GDP, by = "year")
JulyInfl <- merge(JulyInfl, Unemp, by = "year")

# Merge with FOMC Inflation Predictions
#### Load same year forecasts ####
SameYear <- read.csv("/git_repositories/FOMCForecasts/Data/Raw/FOMCMPRForecasts/SameYear.csv", stringsAsFactors = FALSE)

# Convert date
SameYear$ForecastDate <- dmy(SameYear$ForecastDate)

# Only February or July Predictions
SameYearFeb <- subset(SameYear, month(ForecastDate) == 2)
SameYearJul <- subset(SameYear, month(ForecastDate) == 7)

# Extract only the year
SameYearFeb$year <- year(SameYearFeb$ForecastDate)
SameYearJul$year <- year(SameYearJul$ForecastDate)

SameYearFeb <- merge(SameYearFeb, FebInfl, by = "year", all.x = TRUE)
SameYearJul <- merge(SameYearJul, JulyInfl, by = "year", all.x = TRUE)

# Create inflation forecast graphs
Plot1 <- ggplot(data = SameYearFeb, aes(x = year, y = ObsInfFebSame)) +
        geom_line() +
        geom_ribbon(aes(ymin = SInflationL, ymax = SInflationH), alpha = 0.2) +
        geom_ribbon(aes(ymin = SCInflationL, ymax = SCInflationH), alpha = 0.2) +
        ylab("Inflation\n") + xlab("") + ggtitle("Forecast Made in February\n") + theme_bw()

Plot2 <- ggplot(data = SameYearJul, aes(x = year, y = ObsInfJulySame)) +
        geom_line() +
        geom_ribbon(aes(ymin = SInflationL, ymax = SInflationH), alpha = 0.2) +
        geom_ribbon(aes(ymin = SCInflationL, ymax = SCInflationH), alpha = 0.2) +
        ylab("") + xlab("") + ggtitle("Forecast Made in July\n") + theme_bw()

# Create GDP forecast graphs
Plot3 <- ggplot(data = SameYearFeb, aes(x = year, y = ObsGDP)) +
        geom_line() +
        geom_ribbon(aes(ymin = SGDPL, ymax = SGDPH), alpha = 0.2) +
        geom_ribbon(aes(ymin = SCGDPL, ymax = SCGDPH), alpha = 0.2) +
        ylab("GDP Growth\n") + xlab("") + theme_bw()

Plot4 <- ggplot(data = SameYearJul, aes(x = year, y = ObsGDP)) +
        geom_line() +
        geom_ribbon(aes(ymin = SGDPL, ymax = SGDPH), alpha = 0.2) +
        geom_ribbon(aes(ymin = SCGDPL, ymax = SCGDPH), alpha = 0.2) +
        ylab("") + xlab("") + theme_bw()

# Create Unemployment forecast graphs
Plot5 <- ggplot(data = SameYearFeb, aes(x = year, y = ObsUnemp)) +
        geom_line() +
        geom_ribbon(aes(ymin = SUnemL, ymax = SUnemH), alpha = 0.2) +
        geom_ribbon(aes(ymin = SCUnemL, ymax = SCUnemH), alpha = 0.2) +
        ylab("Unemployment\n") + xlab("") + theme_bw()

Plot6 <- ggplot(data = SameYearJul, aes(x = year, y = ObsUnemp)) +
        geom_line() +
        geom_ribbon(aes(ymin = SUnemL, ymax = SUnemH), alpha = 0.2) +
        geom_ribbon(aes(ymin = SCUnemL, ymax = SCUnemH), alpha = 0.2) +
        ylab("") + xlab("") + theme_bw()

grid.arrange(Plot1, Plot2, Plot3, Plot4, Plot5, Plot6)
