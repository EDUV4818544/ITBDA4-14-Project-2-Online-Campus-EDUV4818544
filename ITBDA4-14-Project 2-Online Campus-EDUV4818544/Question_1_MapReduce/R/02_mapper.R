
# Question 1.2 - R Mapper implementation
# 02_mapper.R
# Search for keyword matches and return their locations.

map_records <- function(records, keyword) {
  
  if (length(keyword) != 1 ||
      !nzchar(trimws(keyword))) {
    stop("Please provide a keyword.")
  }
  
  output <- character()
  keyword_length <- nchar(keyword, type = "chars")
  
  for (record in records) {
    
    parts <- strsplit(
      record, "\t", fixed = TRUE
    )[[1]]
    
    if (length(parts) < 3) next
    
    document <- parts[1]
    row <- parts[2]
    line <- paste(parts[-c(1, 2)], collapse = "\t")
    
    positions <- gregexpr(
      tolower(keyword),
      tolower(line),
      fixed = TRUE
    )[[1]]
    
    if (positions[1] == -1) next
    
    for (column in positions) {
      
      before <- if (column > 1) {
        substr(line, column - 1, column - 1)
      } else {
        ""
      }
      
      after_pos <- column + keyword_length
      
      after <- if (
        after_pos <= nchar(line, type = "chars")
      ) {
        substr(line, after_pos, after_pos)
      } else {
        ""
      }
      
      is_word <- function(char) {
        nzchar(char) &&
          grepl("^[[:alnum:]_]$", char)
      }
      
      if (!is_word(before) && !is_word(after)) {
        
        output <- c(
          output,
          paste(
            document,
            paste(row, column, sep = ","),
            sep = "\t"
          )
        )
      }
    }
  }
  
  output
}

# Read input records when executed by Hadoop Streaming.

if (sys.nframe() == 0) {
  
  keyword <- Sys.getenv("SEARCH_KEYWORD")
  
  if (!nzchar(trimws(keyword))) {
    stop("SEARCH_KEYWORD is required.")
  }
  
  connection <- file("stdin", "r")
  
  repeat {
    
    record <- readLines(
      connection,
      n = 1,
      warn = FALSE
    )
    
    if (length(record) == 0) break
    
    result <- map_records(record, keyword)
    
    if (length(result)) {
      cat(
        paste(result, collapse = "\n"),
        "\n",
        sep = ""
      )
    }
  }
  
  close(connection)
}
