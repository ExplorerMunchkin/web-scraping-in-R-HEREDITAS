# get crawled html pages of all articles

# SETTING YOUR WORKING DIRECTORY
setwd("**WORKING_DIR**")
getwd()

# INSTALLING REQUIRED PACKAGES
# General-purpose data wrangling
if (!("tidyverse" %in% installed.packages())) {
  install.packages("tidyverse")
}
library(tidyverse) 

# Parsing of HTML/XML files
if (!("rvest" %in% installed.packages())) {
  install.packages("rvest")
}
library(rvest)

if (!("dplyr" %in% installed.packages())) {
  install.packages("dplyr")
}
library(dplyr)

# Eases DateTime manipulation
if (!("lubridate" %in% installed.packages())) {
  install.packages("lubridate")
}
library(lubridate)

# String manipulation
library(stringr) 


# Finding out how many pages are there
base_url <- "https://hereditasjournal.biomedcentral.com"
page_url <- paste0(base_url, "/articles")
hereditas_html <- read_html(page_url)
nodes <- html_nodes(hereditas_html, 'li.c-pagination__item[data-page]') %>% html_text()
page_count <- length(nodes)

for(i in 1:page_count) {
  articles_overview_url <- paste(base_url, "/articles?searchType=journalSearch&sort=PubDate&page=", i, sep = "")
  articles <-  (read_html(articles_overview_url) %>% html_nodes('article'))
  for (article in articles) {
    full_text_url <- (html_nodes(article, 'a[data-test=fulltext-link]') %>% html_attr('href'))
    doi <- str_remove(full_text_url, "/articles/")
    split_doi <- strsplit(doi, split = '/')
    doi_folder <- split_doi[[1]][1]
    doi_name <- split_doi[[1]][2]
    dir.create(file.path(paste0(getwd(),"/HTML Pages"), doi_folder), showWarnings = FALSE)
    file_name <- paste0("HTML Pages/",doi_folder,"/", doi_name, ".html")
    full_article_html = paste0(base_url, full_text_url) %>% read_html()
    xml2::write_html(full_article_html, file_name)
    }

  }
