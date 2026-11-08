
# Question 2 - Complete topic modelling demonstration
# 04_run_question2.R

# Load the required packages.
library(tm)
library(topicmodels)
library(ggplot2)

# Load the three Question 2 scripts.
source("Question_2_Topic_Modeling/R/01_load_preprocess.R")
source("Question_2_Topic_Modeling/R/02_lda_topics.R")
source("Question_2_Topic_Modeling/R/03_visualize_topics.R")

# Configure the number of topics and words.
n_topics <- 3
top_k <- 8

# Create the output directories.
dir.create(
  "Question_2_Topic_Modeling/data",
  showWarnings = FALSE
)

dir.create(
  "Question_2_Topic_Modeling/output",
  showWarnings = FALSE
)

dir.create(
  "Question_2_Topic_Modeling/plots",
  showWarnings = FALSE
)

# QUESTION 2.1 - Load the news documents.
news_raw <- load_news()

# Preprocess the documents.
news_clean <- preprocess_news(news_raw)

# Save both data frames.
write.csv(
  news_raw,
  "Question_2_Topic_Modeling/data/news_raw.csv",
  row.names = FALSE
)

write.csv(
  news_clean,
  "Question_2_Topic_Modeling/data/news_cleaned.csv",
  row.names = FALSE
)

cat("\nQUESTION 2.1 - DATA PREPROCESSING\n")
cat("Documents loaded:", nrow(news_raw), "\n")
cat("Data frame columns:",
    paste(names(news_raw), collapse = ", "), "\n")

# QUESTION 2.2 - Run the LDA model.
results <- fit_lda_model(
  news_clean,
  n_topics = n_topics,
  top_k = top_k
)

# Save the trained model.
saveRDS(
  results$model,
  "Question_2_Topic_Modeling/output/lda_model.rds"
)

# Save the topic results.
write.csv(
  results$top_words,
  "Question_2_Topic_Modeling/output/top_words_per_topic.csv",
  row.names = FALSE
)

write.csv(
  results$word_distribution,
  "Question_2_Topic_Modeling/output/topic_word_distribution.csv",
  row.names = FALSE
)

write.csv(
  results$document_topics,
  "Question_2_Topic_Modeling/output/document_topic_probabilities.csv",
  row.names = FALSE
)

write.csv(
  results$topic_prevalence,
  "Question_2_Topic_Modeling/output/topic_prevalence.csv",
  row.names = FALSE
)

cat("\nQUESTION 2.2 - LDA TOPICS\n")
cat("Number of topics:", n_topics, "\n")
cat("Top words per topic:", top_k, "\n")
cat("Vocabulary size:", ncol(results$dtm), "\n\n")

cat("Top keywords and probabilities:\n")
print(results$top_words, row.names = FALSE)

cat("\nAverage topic prevalence:\n")
print(results$topic_prevalence, row.names = FALSE)

cat("\nTopic probabilities per document:\n")
print(results$document_topics, row.names = FALSE)

# QUESTION 2.3 - Create the visualisations.
plots <- create_topic_plots(results)

# Display both graphs in RStudio.
print(plots$bar_plot)
print(plots$heat_plot)

# Save the first graph.
ggplot2::ggsave(
  "Question_2_Topic_Modeling/plots/01_top_words_bar.png",
  plot = plots$bar_plot,
  width = 10,
  height = 10,
  dpi = 300
)

# Save the second graph.
ggplot2::ggsave(
  "Question_2_Topic_Modeling/plots/02_topic_word_heatmap.png",
  plot = plots$heat_plot,
  width = 10,
  height = 8,
  dpi = 300
)

cat("\nQUESTION 2.3 - VISUALISATIONS\n")
cat("Bar chart and heatmap saved successfully.\n")
cat("\nQuestion 2 processing completed.\n")
