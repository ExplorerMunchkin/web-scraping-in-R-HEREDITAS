# SETTING YOUR WORKING DIRECTORY
setwd("**WORKING_DIR**")
getwd()

# Sourcing our getHereditasJournalbyDate(pyear) function
source("Function.R", echo = T)

# To get all the articles; give pyear= 2015
hereditas <- getHereditasJournalbyDate(2015)

# Reading Hereditas Journal From File;
hjournal <- read.csv("hereditas_journal.csv")
