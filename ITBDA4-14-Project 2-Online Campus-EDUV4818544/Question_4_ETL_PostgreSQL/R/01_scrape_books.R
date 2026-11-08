
# Question 4.1 - Scrape unstructured book listings
# 01_scrape_books.R

scrape_books <- function(pages = 1:2) {
  all_pages <- list()
  
  for (page_number in pages) {
    url <- paste0(
      "https://books.toscrape.com/catalogue/page-",
      page_number, ".html"
    )
    
    page <- xml2::read_html(url)
    cards <- rvest::html_elements(page, "article.product_pod")
    
    if (length(cards) == 0) {
      stop("No books found on: ", url)
    }
    
    records <- lapply(cards, function(card) {
      link <- rvest::html_element(card, "h3 a")
      price <- rvest::html_element(card, ".price_color")
      rating <- rvest::html_element(card, "p.star-rating")
      availability <- rvest::html_element(card, ".availability")
      
      data.frame(
        title_display = rvest::html_text2(link),
        title_full = rvest::html_attr(link, "title"),
        price_raw = rvest::html_text(price, trim = FALSE),
        rating_raw = rvest::html_attr(rating, "class"),
        availability_raw = rvest::html_text(
          availability, trim = FALSE
        ),
        category_raw = NA_character_,
        source_url = url,
        stringsAsFactors = FALSE
      )
    })
    
    all_pages[[length(all_pages) + 1]] <- do.call(rbind, records)
    if (page_number != tail(pages, 1)) Sys.sleep(1)
  }
  
  books_raw <- do.call(rbind, all_pages)
  rownames(books_raw) <- NULL
  
  if (nrow(books_raw) < 20) {
    stop("Fewer than 20 records were scraped.")
  }
  
  return(books_raw)
}
