
# Question 3 - Complete WebText API demonstration
# 04_run_question3.R

# Load required libraries.
library(rvest)
library(xml2)
library(tm)
library(igraph)
library(ggplot2)

# Load the three Question 3 scripts.
source("Question_3_WebText_API/R/01_scrape_webpage.R")
source("Question_3_WebText_API/R/02_preprocess_text.R")
source("Question_3_WebText_API/R/03_summarize_visualize.R")

# Default website for the demonstration.
default_url <- paste0(
  "https://science.nasa.gov/climate-change/",
  "what-is-climate-change/"
)

# Ask the user for a webpage URL.
url <- utils::winDialogString(
  "Enter a website URL:",
  default = default_url
)

if (is.null(url) || !nzchar(trimws(url))) {
  stop("A website URL is required.")
}

url <- trimws(url)

# Create output folders.
base_dir <- "Question_3_WebText_API"

dir.create(
  file.path(base_dir, "data"),
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  file.path(base_dir, "output"),
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  file.path(base_dir, "plots"),
  recursive = TRUE,
  showWarnings = FALSE
)

# QUESTION 3.1 - Scrape the webpage.
cat("\nQUESTION 3.1 - WEB SCRAPING\n")

webpage_df <- scrape_webpage(url)

write.csv(
  webpage_df,
  file.path(base_dir, "data/webpage_raw.csv"),
  row.names = FALSE
)

cat("Website:", url, "\n")
cat("Article title:", webpage_df$page_title[1], "\n")
cat("Paragraphs extracted:", nrow(webpage_df), "\n")

# QUESTION 3.2 - Preprocess the text.
cat("\nQUESTION 3.2 - TEXT PREPROCESSING\n")

cleaned_df <- preprocess_page(webpage_df)

sentence_df <- make_sentence_data(webpage_df)

write.csv(
  cleaned_df,
  file.path(base_dir, "data/webpage_cleaned.csv"),
  row.names = FALSE
)

write.csv(
  sentence_df,
  file.path(base_dir, "data/sentences_cleaned.csv"),
  row.names = FALSE
)

cat("Cleaned paragraphs:", nrow(cleaned_df), "\n")
cat("Sentences for analysis:", nrow(sentence_df), "\n")

# QUESTION 3.3 - Generate summaries.
cat("\nQUESTION 3.3 - TEXT SUMMARISATION\n")

results <- summarize_page(
  sentence_df,
  n_sentences = 3
)

cat("\nMETHOD 1 - FREQUENCY-BASED SUMMARY:\n")
cat(
  paste(results$frequency_summary, collapse = " "),
  "\n"
)

cat("\nMETHOD 2 - TEXTRANK SUMMARY:\n")
cat(
  paste(results$textrank_summary, collapse = " "),
  "\n"
)

# Save both summaries.
writeLines(
  results$frequency_summary,
  file.path(base_dir, "output/summary_frequency.txt")
)

writeLines(
  results$textrank_summary,
  file.path(base_dir, "output/summary_textrank.txt")
)

# Save scores and word frequencies.
write.csv(
  results$sentence_scores,
  file.path(base_dir, "output/sentence_scores.csv"),
  row.names = FALSE
)

write.csv(
  results$word_frequencies,
  file.path(base_dir, "output/word_frequencies.csv"),
  row.names = FALSE
)

cat("\nTop 12 keywords:\n")
print(head(results$word_frequencies, 12))

# Create both visualisations.
plots <- create_summary_plots(results)

# Display the graphs in RStudio.
print(plots$keyword_plot)
print(plots$importance_plot)

# Save Graph 1.
ggplot2::ggsave(
  file.path(base_dir, "plots/01_top_keywords.png"),
  plot = plots$keyword_plot,
  width = 10,
  height = 6,
  dpi = 300
)

# Save Graph 2.
ggplot2::ggsave(
  file.path(base_dir, "plots/02_sentence_importance.png"),
  plot = plots$importance_plot,
  width = 10,
  height = 6,
  dpi = 300
)

cat("\nBoth graphs saved successfully.\n")
cat("\nQuestion 3 processing completed.\n")
