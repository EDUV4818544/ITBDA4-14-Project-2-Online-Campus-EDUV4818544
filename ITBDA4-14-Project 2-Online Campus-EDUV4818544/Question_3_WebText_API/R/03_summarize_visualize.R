
# Question 3.3 - Text summarisation and visualisations
# 03_summarize_visualize.R

summarize_page <- function(
    sentence_df,
    n_sentences = 3) {
  
  # Get the cleaned words in each sentence.
  tokens <- strsplit(
    sentence_df$clean_text,
    " ",
    fixed = TRUE
  )
  
  all_words <- unlist(tokens, use.names = FALSE)
  
  # Calculate word frequencies.
  word_counts <- sort(
    table(all_words),
    decreasing = TRUE
  )
  
  word_frequencies <- data.frame(
    word = names(word_counts),
    count = as.integer(word_counts),
    stringsAsFactors = FALSE
  )
  
  # METHOD 1: Frequency-based summarisation.
  frequency_scores <- vapply(
    tokens,
    function(words) {
      mean(as.numeric(word_counts[words]))
    },
    numeric(1)
  )
  
  # METHOD 2: TextRank summarisation.
  
  # Create a sentence-word frequency matrix.
  vocabulary <- names(word_counts)
  
  term_matrix <- t(vapply(
    tokens,
    function(words) {
      as.numeric(table(factor(
        words,
        levels = vocabulary
      )))
    },
    numeric(length(vocabulary))
  ))
  
  # Calculate cosine similarity between sentences.
  sentence_lengths <- sqrt(
    rowSums(term_matrix^2)
  )
  
  similarity <- tcrossprod(term_matrix) /
    outer(sentence_lengths, sentence_lengths)
  
  similarity[!is.finite(similarity)] <- 0
  
  diag(similarity) <- 0
  
  # Build the sentence similarity graph.
  graph <- igraph::graph_from_adjacency_matrix(
    similarity,
    mode = "undirected",
    weighted = TRUE,
    diag = FALSE
  )
  
  # Calculate TextRank scores using PageRank.
  textrank_scores <- igraph::page_rank(
    graph,
    directed = FALSE
  )$vector
  
  # Select the top sentences for both methods.
  n <- min(n_sentences, nrow(sentence_df))
  
  frequency_selected <- sort(
    order(frequency_scores, decreasing = TRUE)[1:n]
  )
  
  textrank_selected <- sort(
    order(textrank_scores, decreasing = TRUE)[1:n]
  )
  
  # Build readable summaries.
  frequency_summary <- sentence_df$sentence[
    frequency_selected
  ]
  
  textrank_summary <- sentence_df$sentence[
    textrank_selected
  ]
  
  # Store sentence importance scores.
  sentence_scores <- data.frame(
    sentence_id = sentence_df$sentence_id,
    sentence = sentence_df$sentence,
    frequency_score = frequency_scores,
    textrank_score = textrank_scores,
    stringsAsFactors = FALSE
  )
  
  # Return all results.
  return(list(
    frequency_summary = frequency_summary,
    textrank_summary = textrank_summary,
    word_frequencies = word_frequencies,
    sentence_scores = sentence_scores
  ))
}

# Create two labelled visualisations.
create_summary_plots <- function(results) {
  
  # VISUALISATION 1: Top keyword frequencies.
  top_words <- head(
    results$word_frequencies, 12
  )
  
  top_words$word <- factor(
    top_words$word,
    levels = rev(top_words$word)
  )
  
  keyword_plot <- ggplot2::ggplot(
    top_words,
    ggplot2::aes(x = word, y = count)
  ) +
    ggplot2::geom_col(fill = "steelblue") +
    ggplot2::coord_flip() +
    ggplot2::labs(
      title = "Top 12 Keywords in NASA Climate Article",
      x = "Keyword",
      y = "Number of Occurrences"
    ) +
    ggplot2::theme_minimal(base_size = 12)
  
  # VISUALISATION 2: Sentence importance scores.
  scores <- results$sentence_scores
  
  score_data <- rbind(
    data.frame(
      sentence_id = scores$sentence_id,
      relative_score = scores$frequency_score /
        max(scores$frequency_score),
      method = "Frequency-Based"
    ),
    data.frame(
      sentence_id = scores$sentence_id,
      relative_score = scores$textrank_score /
        max(scores$textrank_score),
      method = "TextRank"
    )
  )
  
  importance_plot <- ggplot2::ggplot(
    score_data,
    ggplot2::aes(
      x = sentence_id,
      y = relative_score,
      color = method
    )
  ) +
    ggplot2::geom_line() +
    ggplot2::geom_point(size = 2) +
    ggplot2::labs(
      title = "Sentence Importance by Summarisation Method",
      x = "Sentence Number",
      y = "Relative Importance Score (0 to 1)",
      color = "Method"
    ) +
    ggplot2::theme_minimal(base_size = 12)
  
  return(list(
    keyword_plot = keyword_plot,
    importance_plot = importance_plot
  ))
}
