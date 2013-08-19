###########
# Combine FOMC Monetary Policy Report with Greenbook Paper 
# Christopher Gandrud
# 19 August 2013
###########

# Load packages
library(quantmod)
library(plyr)
library(DataCombine)


#### Download actual data from FRED ####
# GNPDEF = Gross National Product: Implicit Price Deflator 
# CPIAUCNS = Consumer Price Index for All Urban Consumers: All Items 
# PCEPI = Personal Consumption Expenditures: Chain-type Price Index
# PCEPILFE = Personal consumption expenditures excluding food and energy (chain-type price index)
# GNPC96 = Real Gross National Product 
# GDPC96 = Real Gross Domestic Product, 3 Decimal
# UNRATE = Civilian Unemployment Rate
Symbols <- c("GNPDEF", "CPIAUCNS", "PCEPI", "PCEPILFE", "GNPC96", "GDPC96", "UNRATE")

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

    MeanTemp <- ddply(data, .(Quarter), transform, 
                      MeanVar = mean(TempVar, na.rm = TRUE))
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

GNPD <- quarter_change(data = CombinedInflation, Var = "GNPDEF", 
                       TimeVar = "DateField", NewVar = "ObsInflation")
QCPI <- quarter_change(data = CombinedInflation, Var = "CPIAUCNS", 
                     TimeVar = "DateField", NewVar = "ObsInflation")
QPCE <- quarter_change(data = CombinedInflation, Var = "PCEPI", 
                     TimeVar = "DateField", NewVar = "ObsInflation")
QPCECore <- quarter_change(data = CombinedInflation, Var = "PCEPILFE", 
                     TimeVar = "DateField", NewVar = "ObsInflation")
GNP <- quarter_change(data = CombinedInflation, Var = "GNPC96", 
                        TimeVar = "DateField", NewVar = "ObsGDP")
GDP <- quarter_change(data = CombinedInflation, Var = "GDPC96", 
                        TimeVar = "DateField", NewVar = "ObsGDP")
Unemp <- quarter_change(data = CombinedInflation, Var = "UNRATE", 
                        TimeVar = "DateField", NewVar = "ObsUnemp",
                        NoChange = TRUE)



# Keep only quarters and years used by FOMC
GNPSub <- subset(GNP, year < 1992)
GDPSub <- subset(GDP, year >= 1992)
GDP <- rbind(GNPSub, GDPSub)

# February Same Year
GNPDF <- subset(GNPD, year < 1989)
QCPIF <- subset(QCPI, year >= 1989)
QCPIF <- subset(QCPIF, year < 2000)
QPCEF <- subset(QPCE, year >= 2000)
QPCEF <- subset(QPCEF, year < 2005)
QPCECoreF <- subset(QPCECore, year >= 2005)

FebInfl <- rbind(GNPDF, QCPIF, QPCEF, QPCECoreF)
names(FebInfl) <- c("year", "ObsInfFebSame")
FebInfl <- merge(FebInfl, GDP, by = "year")
FebInfl <- merge(FebInfl, Unemp, by = "year")


# July Same Year
GNPDJ <- subset(GNPD, year < 1989)
QCPIJ <- subset(QCPI, year >= 1989)
QCPIJ <- subset(QCPIJ, year < 2000)
QPCEJ <- subset(QPCE, year >= 2000)
QPCEJ <- subset(QPCEJ, year < 2004)
QPCECoreJ <- subset(QPCECore, year >= 2004)

JulyInfl <- rbind(GNPDJ, QCPIJ, QPCEJ, QPCECoreJ)
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

# Clean up workspace
rmExcept(keepers = c("SameYearFeb", "SameYearJul"))