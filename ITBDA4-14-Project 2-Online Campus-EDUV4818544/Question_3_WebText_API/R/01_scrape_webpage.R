
# Question 3.1 - Web scraping using rvest and xml2
# 01_scrape_webpage.R

scrape_webpage <- function(url) {
  
  # Check that the URL is valid.
  if (!grepl("^https?://", url)) {
    stop("Please enter a valid website URL.")
  }
  
  # Read the webpage HTML.
  page <- tryCatch(
    xml2::read_html(url),
    error = function(e) {
      stop("Unable to access webpage: ", e$message)
    }
  )
  
  # Extract the webpage title.
  page_title <- rvest::html_element(page, "h1")
  page_title <- rvest::html_text2(page_title)
  
  if (is.na(page_title) || !nzchar(page_title)) {
    page_title <- "Untitled webpage"
  }
  
  # Extract paragraphs from the article.
  paragraphs <- rvest::html_elements(
    page, "article p"
  )
  
  # Use the main section if necessary.
  if (length(paragraphs) < 4) {
    paragraphs <- rvest::html_elements(
      page, "main p"
    )
  }
  
  if (length(paragraphs) == 0) {
    stop("No article paragraphs were found.")
  }
  
  # Convert HTML paragraphs into text.
  content <- rvest::html_text2(paragraphs)
  
  # Remove excess whitespace.
  content <- trimws(
    gsub("\\s+", " ", content)
  )
  
  # Remove empty and very short paragraphs.
  content <- content[nchar(content) >= 50]
  
  # Remove repeated paragraphs.
  content <- unique(content)
  
  if (length(content) < 4) {
    stop("Not enough article text was extracted.")
  }
  
  # Create the R data frame.
  webpage_df <- data.frame(
    source_url = rep(url, length(content)),
    page_title = rep(page_title, length(content)),
    paragraph_id = seq_along(content),
    content = content,
    stringsAsFactors = FALSE
  )
  
  return(webpage_df)
}
