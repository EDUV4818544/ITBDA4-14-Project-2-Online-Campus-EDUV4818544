
# Question 1 - Local MapReduce demonstration in RStudio
# 04_run_local.R
# Run the MapReduce process locally in RStudio.

# Load required scripts.
source("Question_1_MapReduce/R/01_prepare_input.R")
source("Question_1_MapReduce/R/02_mapper.R")
source("Question_1_MapReduce/R/03_reducer.R")

# Ask the user to enter a keyword.
keyword <- utils::winDialogString(
  "Enter keyword to search:",
  default = ""
)

# Validate the keyword.
if (is.null(keyword) || !nzchar(trimws(keyword))) {
  stop("The keyword cannot be empty.")
}

keyword <- trimws(keyword)

cat("\nSearching for keyword:", keyword, "\n")

# Prepare the input documents.
prepare_input()

# Get all prepared text files.
files <- sort(list.files(
  "Question_1_MapReduce/prepared",
  pattern = "\\.txt$",
  full.names = TRUE
))

# Run the Mapper.
mapped <- unlist(lapply(files, function(file) {
  
  map_records(
    readLines(
      file,
      warn = FALSE,
      encoding = "UTF-8"
    ),
    keyword
  )
  
}), use.names = FALSE)

# Run the Reducer.
reduced <- reduce_records(mapped)

# Create output directory.
output_dir <- "Question_1_MapReduce/output"

dir.create(
  output_dir,
  showWarnings = FALSE
)

# Create output filename based on keyword.
safe_keyword <- gsub(
  "[^A-Za-z0-9_-]",
  "_",
  keyword
)

output_file <- file.path(
  output_dir,
  paste0("local_", safe_keyword, ".txt")
)

# Save the results.
writeLines(
  reduced,
  output_file,
  useBytes = TRUE
)

# Display the results.
cat("\nDocuments checked:", length(files), "\n")
cat("Matching documents:", length(reduced), "\n")
cat("Total matches:", length(mapped), "\n\n")

cat("RESULTS (document, row, column):\n")

if (length(reduced) > 0) {
  cat(paste(reduced, collapse = "\n"), "\n")
} else {
  cat("No matches found.\n")
}

cat("\nSaved results to:", output_file, "\n")
