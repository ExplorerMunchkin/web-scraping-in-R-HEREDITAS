
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

getHereditasJournalbyDate <- function(pyear){
  
# Finding out how many pages are there
base_url <- "https://hereditasjournal.biomedcentral.com"
page_url <- paste0(base_url, "/articles")
hereditas_html <- read_html(page_url)
nodes <- html_nodes(hereditas_html, 'li.c-pagination__item[data-page]') %>% html_text()
page_count <- length(nodes)

hereditas_journal <- data.frame()
for(i in 1:page_count) {
  articles_overview_url <- paste(base_url, "/articles?searchType=journalSearch&sort=PubDate&page=", i, sep = "")
  articles <-  (read_html(articles_overview_url) %>% html_nodes('article'))
  #Get details of each individual article on each page:
  for (article in articles) {
    title = html_nodes(article, 'h3.c-listing__title') %>% html_text() %>% str_trim() 
    authors = html_nodes(article, '.c-listing__authors') %>% html_text() %>% str_replace_all("[\r\n]" , "") %>% str_trim()
    authors = str_remove(authors, "Authors: ")
    publish_date = html_nodes(article, 'span[itemprop=datePublished]') %>% html_text() %>% str_trim() %>% dmy() %>% format(format='%m/%d/%Y')
    
    #Get details from full article URL
    full_article_html = paste(base_url, (html_nodes(article, 'a[data-test=fulltext-link]') %>% html_attr('href')), sep = "") %>% read_html()
    abstract = html_nodes(full_article_html, 'section[data-title=Abstract] div#Abs1-content') %>% html_text()
    if (identical(abstract,character(0))) {
      abstract = c("NA")
    }
    author_affiliations = html_nodes(full_article_html, 'p.c-article-author-affiliation__address') %>% html_text() %>% str_trim()
    corresponding_author = html_nodes(full_article_html, 'a#corresp-c1') %>% html_text() %>% str_trim()
    #Corresponding AUTHORS EMAIL: NOT AVAILABLE
    keywords = html_nodes(full_article_html, 'ul.c-article-subject-list li span') %>% html_text() %>% str_trim()
    if (identical(keywords,character(0))) {
      keywords = c("NA")
    }
    
    full_paper = html_nodes(full_article_html, 'article') %>% html_text()  %>% str_replace_all("[\r\n]" , "") %>% str_trim() %>% str_replace_all("  +" , " ")
    
    # Combining all the fields to create an article record:
    temp_frame <- data.frame(
                             Title = title, 
                             Authors = authors, 
                             PublishDate = publish_date, 
                             Author_Affiliations = paste(author_affiliations, collapse = ','), 
                             Corresponding_Author = corresponding_author,
                             Corr_Auth_Email = "NA", 
                             Abstract = paste(abstract, collapse = '\r\n'), 
                             Keywords = paste(keywords, collapse = ','), 
                             Full_Paper = gsub('[^\x20-\x7E]', '', substr(full_paper,1,32767))#truncate string so the data fits in an excel cell
                          )
    # Adding each article record into the data frame
    if (identical(hereditas_journal,data.frame())) {
      hereditas_journal <- temp_frame
    } else {
      hereditas_journal <- rbind(hereditas_journal, temp_frame)
    }
    
  }
}

#Adding ID column to our dataframe
hereditas_journal <- tibble::rowid_to_column(hereditas_journal, "ID")
# Get the year part from publish date
publish_date <- format(as.Date(hereditas_journal$PublishDate, format='%m/%d/%Y'),"%Y")
# Extracting data by the year
hereditas_journal_bydate <- (hereditas_journal[publish_date >= pyear,])
# WRITING the extracted data to CSV FILE
write.csv(hereditas_journal_bydate,"hereditas_journal.csv", row.names = FALSE, eol = "\r\n", fileEncoding = "UTF-8") 

return(hereditas_journal_bydate)
}


