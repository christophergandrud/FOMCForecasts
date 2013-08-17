###########
# Combine FOMC Monetary Policy Report with Greenbook Paper 
# Christopher Gandrud
# 17 August 2013
###########

# Load packages
library(quantmod)

#### Download actual data from FRED ####
# CPIAUCSL = Consumer Price Index for All Urban Consumers
# PCEPI = Personal Consumption Expenditures: Chain-type Price Index
# DPCCRC1M027SBEA = Personal consumption expenditures excluding food and energy 
Symbols <- c("CPIAUCSL", "PCEPI", "DPCCRC1M027SBEA")

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
quarter_change <- function(data, Var, TimeVar, NewVar = NULL)
{
  require(lubridate)
  require(plyr)
  require(DataCombine)
  data$Quarter <- quarter(data[, TimeVar], with_year = TRUE)
  data <- data[, c("Quarter", Var)]
  names(data) <- c("Quarter", "TempVar")
  MeanTemp <- ddply(data, .(Quarter), transform, MeanVar = mean(TempVar))
  MeanTemp <- MeanTemp[, c(1, 3)]
  MeanTemp <- MeanTemp[!duplicated(MeanTemp[, 1], MeanTemp[, 2]), ]
  MeanTemp <- slide(data = MeanTemp, Var = "MeanVar", slideBy = -4, 
                    NewVar = "Lag")
  MeanTemp$ChangeTemp <- ((MeanTemp$MeanVar - MeanTemp$Lag)/MeanTemp$Lag) * 100 
  MeanTemp <- MeanTemp[, c(1, 4)]
  if (!is.null(NewVar)){
    names(MeanTemp) <- c("Quarter", NewVar)
    return(MeanTemp)
  } else
    return(MeanTemp)
}

QCPI <- quarter_change(data = CombinedInflation, Var = "CPIAUCSL", 
                     TimeVar = "DateField", NewVar = "ObsInflation")
QPCE <- quarter_change(data = CombinedInflation, Var = "PCEPI", 
                     TimeVar = "DateField", NewVar = "ObsInflation")
QPCECore <- quarter_change(data = CombinedInflation, Var = "DPCCRC1M027SBEA", 
                     TimeVar = "DateField", NewVar = "ObsInflation")

# Keep only quarters and years used by FOMC
# February Same Year
QCPI <- subset(QCPI, Quarter < 2000)
QPCE <- subset(QPCE, Quarter >= 2000)
QPCE <- subset(QPCE, Quarter < 2005)
QPCECore <- subset(QPCECore, Quarter >= 2004)

FebInfl <- rbind(QCPI, QPCE, QPCECore)
names(FebInfl) <- c("Quarter", "ObsInfFebSame")

# July Same Year
QCPI <- subset(QCPI, Quarter < 2000)
QPCE <- subset(QPCE, Quarter >= 2000)
QPCE <- subset(QPCE, Quarter < 2004)
QPCECore <- subset(QPCECore, Quarter >= 2004)

JulyInfl <- rbind(QCPI, QPCE, QPCECore)
names(FebInfl) <- c("Quarter", "ObsInfJulySame")

SameYearInfl <- merge(FebInfl, JulyInfl)
