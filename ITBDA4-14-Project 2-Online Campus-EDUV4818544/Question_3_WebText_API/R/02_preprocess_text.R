
# Question 3.2 - Text preprocessing
# 02_preprocess_text.R

# Clean and tokenize text.
clean_words <- function(text) {
  
  # Standardise special characters.
  text <- iconv(
    text,
    to = "ASCII//TRANSLIT",
    sub = " "
  )
  
  # Convert to lowercase.
  text <- tolower(text)
  
  # Remove URLs.
  text <- gsub(
    "https?://[^[:space:]]+",
    " ",
    text
  )
  
  # Remove numbers and punctuation.
  text <- gsub("[^a-z[:space:]]", " ", text)
  
  # Remove excess whitespace.
  text <- trimws(gsub("\\s+", " ", text))
  
  if (!nzchar(text)) {
    return(character())
  }
  
  # Split into words.
  words <- strsplit(text, " ", fixed = TRUE)[[1]]
  
  # Remove short words and stop words.
  words <- words[
    nchar(words) >= 3 &
      !words %in% tm::stopwords("en")
  ]
  
  # Remove non-informative webpage words.
  noise_words <- c(
    "nasa", "click", "read", "more",
    "image", "credit", "source", "here",
    "page", "website", "learn"
  )
  
  words <- words[!words %in% noise_words]
  
  return(words)
}

# Clean the extracted paragraphs.
preprocess_page <- function(webpage_df) {
  
  cleaned_df <- data.frame(
    paragraph_id = webpage_df$paragraph_id,
    original_text = webpage_df$content,
    clean_text = vapply(
      webpage_df$content,
      function(x) {
        paste(clean_words(x), collapse = " ")
      },
      character(1)
    ),
    stringsAsFactors = FALSE
  )
  
  return(cleaned_df)
}

# Divide original content into sentences.
make_sentence_data <- function(webpage_df) {
  
  sentences <- unlist(strsplit(
    webpage_df$content,
    "(?<=[.!?])\\s+",
    perl = TRUE
  ), use.names = FALSE)
  
  # Remove extra whitespace.
  sentences <- trimws(
    gsub("\\s+", " ", sentences)
  )
  
  # Remove very short sentences.
  sentences <- sentences[nchar(sentences) >= 35]
  
  # Clean each sentence for analysis.
  clean_sentences <- vapply(
    sentences,
    function(x) {
      paste(clean_words(x), collapse = " ")
    },
    character(1)
  )
  
  # Keep sentences containing useful words.
  keep <- nzchar(clean_sentences)
  
  sentence_df <- data.frame(
    sentence_id = seq_len(sum(keep)),
    sentence = sentences[keep],
    clean_text = clean_sentences[keep],
    stringsAsFactors = FALSE
  )
  
  if (nrow(sentence_df) < 5) {
    stop("Not enough sentences for summarisation.")
  }
  
  return(sentence_df)
}
