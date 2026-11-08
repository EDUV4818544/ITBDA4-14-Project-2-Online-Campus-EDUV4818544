
# Question 2.3 - Visualise LDA topic keywords
# 03_visualize_topics.R

create_topic_plots <- function(results) {
  
  top_words <- results$top_words
  
  # Method 1: Horizontal bar charts.
  bar_data <- top_words
  
  bar_data$topic_word <- paste(
    bar_data$topic,
    bar_data$word,
    sep = "__"
  )
  
  bar_data$topic_word <- factor(
    bar_data$topic_word,
    levels = bar_data$topic_word[
      order(bar_data$probability)
    ]
  )
  
  bar_plot <- ggplot2::ggplot(
    bar_data,
    ggplot2::aes(
      x = topic_word,
      y = probability,
      fill = topic
    )
  ) +
    ggplot2::geom_col(show.legend = FALSE) +
    ggplot2::coord_flip() +
    ggplot2::facet_wrap(
      ~ topic,
      ncol = 1,
      scales = "free_y"
    ) +
    ggplot2::scale_x_discrete(
      labels = function(x) {
        sub("^Topic [0-9]+__", "", x)
      }
    ) +
    ggplot2::labs(
      title = "Top Words in Each LDA Topic",
      x = "Keyword",
      y = "Word Probability"
    ) +
    ggplot2::theme_minimal(base_size = 12)
  
  # Method 2: Topic-word probability heatmap.
  selected_words <- unique(top_words$word)
  
  heat_data <- results$word_distribution[
    results$word_distribution$word %in%
      selected_words,
  ]
  
  heat_data$word <- factor(
    heat_data$word,
    levels = rev(selected_words)
  )
  
  heat_plot <- ggplot2::ggplot(
    heat_data,
    ggplot2::aes(
      x = topic,
      y = word,
      fill = probability
    )
  ) +
    ggplot2::geom_tile(color = "white") +
    ggplot2::scale_fill_gradient(
      low = "white",
      high = "steelblue"
    ) +
    ggplot2::labs(
      title = "Keyword Distribution Across Topics",
      x = "LDA Topic",
      y = "Keyword",
      fill = "Probability"
    ) +
    ggplot2::theme_minimal(base_size = 12)
  
  # Return both visualisations.
  return(list(
    bar_plot = bar_plot,
    heat_plot = heat_plot
  ))
}
