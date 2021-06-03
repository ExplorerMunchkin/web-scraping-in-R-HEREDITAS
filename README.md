# Summary
This is a R web scraping/crawling project that downloads articles from the [Hereditas Journal](https://hereditasjournal.biomedcentral.com/).

There are two scripts in the project that can be run:
* Main.R: Running this script will download all articles and their metadata and dump them to a csv file.
* GetCrawledHTMLPages.R: Running this script will download the article html pages themselves.

This project was developed as a part of a school project. The final report can also be found in the repo.

# How to Run

Make sure to set the working directory in all the R script files. Then open the script you'd like to run (Main.R or GetCrawledHTMLPages.R) in RStudio and run it. (Keep in mind Main.R depends on Function.R to work. So make sure Function.R is in the same directory as Main.R).
