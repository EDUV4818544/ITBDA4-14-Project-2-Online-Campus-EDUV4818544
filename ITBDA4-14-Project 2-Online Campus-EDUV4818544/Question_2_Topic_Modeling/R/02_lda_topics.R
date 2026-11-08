
# Question 2.2 - LDA topic modelling
# 02_lda_topics.R

fit_lda_model <- function(
    cleaned_df,
    n_topics = 3,
    top_k = 8) {
  
  # Create a corpus from the cleaned documents.
  corpus <- tm::VCorpus(
    tm::VectorSource(cleaned_df$content)
  )
  
  # Create a document-term matrix.
  dtm <- tm::DocumentTermMatrix(
    corpus,
    control = list(wordLengths = c(3, Inf))
  )
  
  # Check that all documents contain words.
  if (any(rowSums(as.matrix(dtm)) == 0)) {
    stop("One or more documents are empty.")
  }
  
  if (n_topics > nrow(dtm)) {
    stop("Too many topics for the documents.")
  }
  
  # Train the LDA model using Gibbs sampling.
  lda_model <- topicmodels::LDA(
    dtm,
    k = n_topics,
    method = "Gibbs",
    control = list(
      seed = 1234,
      burnin = 500,
      iter = 1000,
      thin = 100
    )
  )
  
  # Extract topic and word probabilities.
  probabilities <- topicmodels::posterior(
    lda_model
  )
  
  word_probs <- probabilities$terms
  document_probs <- probabilities$topics
  
  topic_names <- paste(
    "Topic", seq_len(n_topics)
  )
  
  # Identify the top k words for each topic.
  top_words <- do.call(
    rbind,
    lapply(seq_len(n_topics), function(i) {
      
      positions <- order(
        word_probs[i, ],
        decreasing = TRUE
      )[seq_len(min(top_k, ncol(word_probs)))]
      
      data.frame(
        topic = topic_names[i],
        rank = seq_along(positions),
        word = colnames(word_probs)[positions],
        probability = as.numeric(
          word_probs[i, positions]
        ),
        stringsAsFactors = FALSE
      )
    })
  )
  
  # Store the full word distribution per topic.
  word_distribution <- do.call(
    rbind,
    lapply(seq_len(n_topics), function(i) {
      
      data.frame(
        topic = topic_names[i],
        word = colnames(word_probs),
        probability = as.numeric(word_probs[i, ]),
        stringsAsFactors = FALSE
      )
    })
  )
  
  # Store topic probabilities for each document.
  document_topics <- data.frame(
    file_name = cleaned_df$file_name,
    as.data.frame(document_probs),
    check.names = FALSE
  )
  
  colnames(document_topics) <- c(
    "file_name", topic_names
  )
  
  # Calculate average topic prevalence.
  topic_prevalence <- data.frame(
    topic = topic_names,
    average_probability = colMeans(
      document_probs
    )
  )
  
  # Return all model results.
  return(list(
    model = lda_model,
    dtm = dtm,
    top_words = top_words,
    word_distribution = word_distribution,
    document_topics = document_topics,
    topic_prevalence = topic_prevalence
  ))
}
