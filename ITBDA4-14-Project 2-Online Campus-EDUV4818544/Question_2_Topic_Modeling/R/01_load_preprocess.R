
# Question 2.1 - Load and preprocess news documents
# 01_load_preprocess.R

# Load the 10 news files into a data frame.
load_news <- function() {
  
  input_dir <- "Question_2_Topic_Modeling/input"
  
  files <- sort(list.files(
    input_dir,
    pattern = "\\.txt$",
    full.names = TRUE
  ))
  
  if (length(files) != 10) {
    stop("Exactly 10 news files are required.")
  }
  
  news_df <- data.frame(
    file_name = basename(files),
    content = vapply(files, function(file) {
      paste(
        readLines(
          file,
          warn = FALSE,
          encoding = "UTF-8"
        ),
        collapse = " "
      )
    }, character(1)),
    stringsAsFactors = FALSE
  )
  
  rownames(news_df) <- NULL
  
  return(news_df)
}

# Clean the text in each document.
clean_text <- function(text) {
  
  # Convert accented and special characters.
  text <- iconv(
    text,
    from = "UTF-8",
    to = "ASCII//TRANSLIT",
    sub = " "
  )
  
  # Convert to lowercase.
  text <- tolower(text)
  
  # Remove website links.
  text <- gsub(
    "https?://[^[:space:]]+|www\\.[^[:space:]]+",
    " ",
    text
  )
  
  # Remove numbers and punctuation.
  text <- gsub("[^a-z[:space:]]", " ", text)
  
  # Split text into individual words.
  words <- strsplit(
    text,
    "[[:space:]]+"
  )[[1]]
  
  # Remove very short words.
  words <- words[nchar(words) >= 3]
  
  # Remove common English stop words.
  words <- words[
    !words %in% tm::stopwords("en")
  ]
  
  # Remove unnecessary reporting words.
  noise_words <- c(
    "said", "says", "would", "could",
    "also", "read", "gov", "according"
  )
  
  words <- words[
    !words %in% noise_words
  ]
  
  # Rebuild the cleaned text.
  return(paste(words, collapse = " "))
}

# Preprocess the full news data frame.
preprocess_news <- function(news_df) {
  
  cleaned_df <- data.frame(
    file_name = news_df$file_name,
    content = vapply(
      news_df$content,
      clean_text,
      character(1)
    ),
    stringsAsFactors = FALSE
  )
  
  return(cleaned_df)
}
