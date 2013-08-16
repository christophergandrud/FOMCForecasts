#############
# Create Fed Testimony File in which to add indv. forecasts 
# Christopher Gandrud
# 16 August 2013
#############

# Load packages
library(lubridate)
library(plyr)

# Load testimony data
# From: http://papers.ssrn.com/sol3/papers.cfm?abstract_id=2279258
FullTest <- read.csv("~/Dropbox/Fed_Speeches_Paper/FedSpeech/Data/Raw/TestimonyRaw.csv", stringsAsFactors = FALSE)

# Keep data
Keepers1 <- c("full_date", "speechtitle", "hyperlink", "name", "position_cat1", "legislature")

SubTest <- FullTest[, Keepers1]

SubTest <- rename(SubTest, c("legislature" = "type"))

SubTest$full_date <- dmy(SubTest$full_date)

SubTest <- SubTest[order(SubTest$full_date), ]

## Merge with public speeches data
# Load public speeches data
FullSpeeches <- read.csv("~/Dropbox/Fed_Speeches_Paper/FedSpeech/Data/Raw/FedSpeechesCorrected-NEW.csv", stringsAsFactors = FALSE)

Keepers2 <- c("date_of_speech", "speech_name", "vars.link", "name", "position_cat")

SubSpeech <- FullSpeeches[, Keepers2]
names(SubSpeech) <- c("full_date", "speechtitle", "hyperlink", "name", "position_cat1")
SubSpeech$type <- "Public"

SubSpeech$full_date <- dmy(SubSpeech$full_date)

Sub <- rbind(SubTest, SubSpeech)

Sub <- Sub[order(Sub$full_date), ]

# Save
write.csv(Sub, file = "/git_repositories/FOMCForecasts/Data/BaseTest.csv",
          row.names = FALSE)
