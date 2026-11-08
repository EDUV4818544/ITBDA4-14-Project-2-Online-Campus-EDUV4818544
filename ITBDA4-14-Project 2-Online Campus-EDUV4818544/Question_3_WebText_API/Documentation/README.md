

\# Question 3 - WebText API



\## Purpose

Extract and analyse webpage content using RStudio.



\## Source Website

NASA Science - What Is Climate Change?

https://science.nasa.gov/climate-change/what-is-climate-change/



\## Ethical Web Scraping

Retrieve one publicly accessible article.

Respect the website's robots.txt and terms.

Do not bypass access restrictions.

Acknowledge NASA as the content source.



\## Question 3.1

Use rvest and xml2 to extract webpage text.

Store the results in an R data frame.



\## Question 3.2

Clean and preprocess the text.

Remove punctuation, numbers, stop words and noise.

Preserve original sentences for summarisation.



\## Question 3.3

Apply two extractive summarisation techniques:



1\. Frequency-based summarisation.

2\. TextRank summarisation.



Generate two visualisations:



1\. Keyword frequency bar chart.

2\. Sentence importance comparison graph.



\## Required Libraries

rvest

xml2

tm

igraph

ggplot2



\## R Scripts

01\_scrape\_webpage.R

02\_preprocess\_text.R

03\_summarize\_visualize.R

04\_run\_question3.R



\## Run the Project

Open the main RStudio project.



Run:

source("Question\_3\_WebText\_API/R/04\_run\_question3.R")



Enter the NASA URL when prompted.



\## Outputs

Raw webpage data.

Cleaned webpage data.

Sentence data.

Two text summaries.

Keyword frequencies.

Sentence importance scores.

Two PNG visualisations.



