
# Question 1.1 - Prepare input documents for MapReduce
# 01_prepare_input.R
# Prepare the documents for MapReduce.

prepare_input <- function(
    input_dir = "Question_1_MapReduce/input",
    prepared_dir = "Question_1_MapReduce/prepared"
) {
  
  files <- sort(list.files(
    input_dir,
    pattern = "\\.txt$",
    full.names = TRUE
  ))
  
  if (length(files) == 0) {
    stop("No text files found in the input folder.")
  }
  
  dir.create(prepared_dir,
             recursive = TRUE,
             showWarnings = FALSE)
  
  for (file in files) {
    
    lines <- readLines(
      file,
      warn = FALSE,
      encoding = "UTF-8"
    )
    
    records <- paste(
      basename(file),
      seq_along(lines),
      lines,
      sep = "\t"
    )
    
    writeLines(
      records,
      file.path(prepared_dir, basename(file)),
      useBytes = TRUE
    )
  }
  
  cat("Prepared", length(files), "documents.\n")
  
  invisible(length(files))
}
