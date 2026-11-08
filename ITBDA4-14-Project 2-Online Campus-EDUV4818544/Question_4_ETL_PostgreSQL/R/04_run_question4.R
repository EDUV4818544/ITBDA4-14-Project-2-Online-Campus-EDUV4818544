
# Question 4 - Complete R ETL demonstration
# 04_run_question4.R

library(rvest)
library(xml2)

source("Question_4_ETL_PostgreSQL/R/01_scrape_books.R")
source("Question_4_ETL_PostgreSQL/R/02_clean_books.R")
source("Question_4_ETL_PostgreSQL/R/03_load_postgres.R")

base_dir <- "Question_4_ETL_PostgreSQL"
dir.create(file.path(base_dir, "data"), showWarnings = FALSE)
dir.create(file.path(base_dir, "output"), showWarnings = FALSE)

# QUESTION 4.1 - Extract at least 20 raw records.
books_raw <- scrape_books(pages = 1:2)
write.csv(books_raw, file.path(base_dir, "data/books_raw.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("QUESTION 4.1 - BOOKS SCRAPED:", nrow(books_raw), "\n")

# QUESTION 4.2 - Transform and export the clean dataset.
books_cleaned <- clean_books(books_raw)
write.csv(books_cleaned,
          file.path(base_dir, "data/books_cleaned.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("QUESTION 4.2 - CLEAN RECORDS:", nrow(books_cleaned), "\n")
cat("Price values imputed:", sum(books_cleaned$price_imputed), "\n")
cat("Rating values imputed:", sum(books_cleaned$rating_imputed), "\n")
print(head(books_cleaned, 5))

# QUESTION 4.3 - Import into PostgreSQL and run two SQL queries.
cat("\nQUESTION 4.3 - POSTGRESQL\n")
load_books_postgres()
cat("\nQuestion 4.1-4.3 completed.\n")
