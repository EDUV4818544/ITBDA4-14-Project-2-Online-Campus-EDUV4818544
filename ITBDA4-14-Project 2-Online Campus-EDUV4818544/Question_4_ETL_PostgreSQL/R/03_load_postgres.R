
# Question 4.3 - Load the cleaned CSV into PostgreSQL
# 03_load_postgres.R

load_books_postgres <- function(
    csv_path = "Question_4_ETL_PostgreSQL/data/books_cleaned.csv",
    database = "itbda_project2"
) {
  books <- read.csv(csv_path, stringsAsFactors = FALSE)
  
  # RStudio asks securely for the existing postgres-user password.
  password <- rstudioapi::askForPassword("PostgreSQL password")
  if (!nzchar(password)) stop("A database password is required.")
  
  con <- DBI::dbConnect(
    RPostgres::Postgres(),
    dbname = database,
    host = "localhost",
    port = 5432,
    user = "postgres",
    password = password
  )
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  rm(password)
  
  # This replaces only the project table, never the database.
  DBI::dbWriteTable(
    con, "books_etl", books,
    overwrite = TRUE, row.names = FALSE
  )
  
  cat("Records loaded into PostgreSQL:",
      DBI::dbGetQuery(con,
                      "SELECT COUNT(*) AS n FROM books_etl")$n, "\n")
  
  query1 <- paste(
    "SELECT rating, COUNT(*) AS books,",
    "ROUND(AVG(price_gbp)::numeric, 2) AS avg_price_gbp",
    "FROM books_etl GROUP BY rating ORDER BY rating"
  )
  query2 <- paste(
    "SELECT price_band, COUNT(*) AS books,",
    "ROUND(AVG(rating)::numeric, 2) AS avg_rating,",
    "ROUND(AVG(price_gbp)::numeric, 2) AS avg_price_gbp",
    "FROM books_etl GROUP BY price_band ORDER BY MIN(price_gbp)"
  )
  
  result1 <- DBI::dbGetQuery(con, query1)
  result2 <- DBI::dbGetQuery(con, query2)
  
  write.csv(result1,
            "Question_4_ETL_PostgreSQL/output/query_1_results.csv",
            row.names = FALSE)
  write.csv(result2,
            "Question_4_ETL_PostgreSQL/output/query_2_results.csv",
            row.names = FALSE)
  
  cat("\nQUERY 1 - AVERAGE PRICE BY RATING\n")
  print(result1)
  cat("\nQUERY 2 - PRICE BAND ANALYSIS\n")
  print(result2)
  
  invisible(list(query1 = result1, query2 = result2))
}
