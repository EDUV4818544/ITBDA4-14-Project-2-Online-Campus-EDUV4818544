
# Question 4.2 - Clean, denoise and impute book records
# 02_clean_books.R

clean_books <- function(books_raw) {
  
  # Extract a numeric price with a regular expression.
  extract_price <- function(x) {
    if (is.na(x)) return(NA_real_)
    match <- regexpr("[0-9]+\\.[0-9]{2}", x)
    if (match[1] == -1) return(NA_real_)
    as.numeric(regmatches(x, match))
  }
  
  # Extract One-Five from the HTML rating class.
  extract_rating <- function(x) {
    if (is.na(x)) return(NA_integer_)
    found <- regexpr("One|Two|Three|Four|Five", x)
    if (found[1] == -1) return(NA_integer_)
    base::match(regmatches(x, found),
                c("One", "Two", "Three", "Four", "Five"))
  }
  
  # Prefer the complete title instead of the shortened label.
  title <- ifelse(
    is.na(books_raw$title_full) |
      !nzchar(trimws(books_raw$title_full)),
    books_raw$title_display,
    books_raw$title_full
  )
  title <- trimws(gsub("[[:space:]]+", " ", title))
  title[!nzchar(title)] <- "Unknown title"
  
  price <- vapply(books_raw$price_raw, extract_price, numeric(1))
  rating <- vapply(books_raw$rating_raw, extract_rating, integer(1))
  
  price_imputed <- is.na(price)
  rating_imputed <- is.na(rating)
  
  # Use the observed median if any numerical values are missing.
  if (all(price_imputed) || all(rating_imputed)) {
    stop("Not enough valid price or rating values to impute.")
  }
  price[price_imputed] <- median(price, na.rm = TRUE)
  rating[rating_imputed] <- as.integer(
    round(median(rating, na.rm = TRUE))
  )
  
  availability <- ifelse(
    grepl("in[[:space:]]+stock", books_raw$availability_raw,
          ignore.case = TRUE),
    "In stock", "Unknown"
  )
  
  # The listing pages do not provide a book category.
  category <- ifelse(
    is.na(books_raw$category_raw) |
      !nzchar(trimws(books_raw$category_raw)),
    "Not provided", trimws(books_raw$category_raw)
  )
  
  price_band <- as.character(cut(
    price,
    breaks = c(-Inf, 20, 40, Inf),
    labels = c("Budget", "Mid-range", "Premium")
  ))
  
  books_cleaned <- data.frame(
    book_id = seq_along(title),
    title = title,
    price_gbp = round(price, 2),
    rating = rating,
    availability = availability,
    category = category,
    price_band = price_band,
    price_imputed = price_imputed,
    rating_imputed = rating_imputed,
    source_url = books_raw$source_url,
    stringsAsFactors = FALSE
  )
  
  return(books_cleaned)
}
