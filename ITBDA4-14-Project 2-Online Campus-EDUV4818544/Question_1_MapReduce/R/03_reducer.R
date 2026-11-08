
# Question 1.3 - R Reducer implementation
# 03_reducer.R
# Group and sort keyword locations.

reduce_records <- function(records) {
  
  if (length(records) == 0) {
    return(character())
  }
  
  document <- sub("\t.*$", "", records)
  
  location <- sub(
    "^[^\t]*\t", "", records
  )
  
  groups <- split(
    seq_along(records),
    document
  )
  
  output <- character()
  
  for (name in names(groups)) {
    
    positions <- strsplit(
      location[groups[[name]]],
      ",",
      fixed = TRUE
    )
    
    rows <- as.integer(
      vapply(positions, `[`, character(1), 1)
    )
    
    columns <- as.integer(
      vapply(positions, `[`, character(1), 2)
    )
    
    order_by_position <- order(rows, columns)
    
    coordinates <- paste0(
      "row=", rows[order_by_position],
      ", column=", columns[order_by_position]
    )
    
    output <- c(
      output,
      paste(
        name,
        paste(coordinates, collapse = "; "),
        sep = "\t"
      )
    )
  }
  
  output
}

# Read grouped Mapper results in Hadoop Streaming.

if (sys.nframe() == 0) {
  
  connection <- file("stdin", "r")
  
  current_document <- ""
  group <- character()
  
  repeat {
    
    record <- readLines(
      connection,
      n = 1,
      warn = FALSE
    )
    
    if (length(record) == 0) break
    
    document <- sub("\t.*$", "", record)
    
    if (length(group) > 0 &&
        document != current_document) {
      
      cat(reduce_records(group), "\n", sep = "")
      group <- character()
    }
    
    current_document <- document
    group <- c(group, record)
  }
  
  if (length(group) > 0) {
    cat(reduce_records(group), "\n", sep = "")
  }
  
  close(connection)
}
