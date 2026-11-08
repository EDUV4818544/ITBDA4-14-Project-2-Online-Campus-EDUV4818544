
# Question 1.4 - Hadoop MapReduce configuration in R
# 05_run_hadoop.R
# Configure and execute Hadoop Streaming using R.

args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  stop("Please supply a search keyword.")
}

keyword <- paste(args, collapse = " ")

if (.Platform$OS.type == "windows") {
  stop("Run this in Ubuntu/WSL with Hadoop installed.")
}

# Prepare documents.

source("Question_1_MapReduce/R/01_prepare_input.R")
prepare_input()

# Locate Hadoop.

hadoop_home <- Sys.getenv("HADOOP_HOME")

if (!nzchar(hadoop_home)) {
  stop("HADOOP_HOME is not configured.")
}

streaming_dir <- file.path(
  hadoop_home, "share", "hadoop", "tools", "lib"
)

jars <- list.files(
  streaming_dir,
  pattern = "^hadoop-streaming-[0-9].*\\.jar$",
  full.names = TRUE
)

if (length(jars) == 0) {
  stop("Hadoop Streaming JAR not found.")
}

# Configure input and output paths.

input_dir <- normalizePath(
  "Question_1_MapReduce/prepared"
)

mapper <- normalizePath(
  "Question_1_MapReduce/R/02_mapper.R"
)

reducer <- normalizePath(
  "Question_1_MapReduce/R/03_reducer.R"
)

safe_keyword <- gsub(
  "[^A-Za-z0-9_-]", "_", keyword
)

dir.create(
  "Question_1_MapReduce/output",
  showWarnings = FALSE
)

output_dir <- file.path(
  normalizePath("Question_1_MapReduce/output"),
  paste0("hadoop_", safe_keyword)
)

if (dir.exists(output_dir)) {
  stop("Hadoop output already exists: ", output_dir)
}

# Hadoop MapReduce settings.

job_args <- c(
  "jar", shQuote(jars[1]),
  
  "-D", "mapreduce.framework.name=local",
  "-D", "fs.defaultFS=file:///",
  "-D", "mapreduce.job.reduces=1",
  
  "-files",
  shQuote(paste(mapper, reducer, sep = ",")),
  
  "-input", shQuote(input_dir),
  "-output", shQuote(output_dir),
  
  "-mapper", shQuote("Rscript 02_mapper.R"),
  "-reducer", shQuote("Rscript 03_reducer.R"),
  
  "-cmdenv",
  shQuote(paste0("SEARCH_KEYWORD=", keyword))
)

# Execute the Hadoop job.

hadoop <- file.path(
  hadoop_home, "bin", "hadoop"
)

status <- system2(
  hadoop,
  args = job_args
)

if (!identical(status, 0L)) {
  stop("Hadoop job failed. Exit code: ", status)
}

# Display the results.

part_files <- list.files(
  output_dir,
  pattern = "^part-",
  full.names = TRUE
)

if (length(part_files) == 0) {
  stop("Hadoop output file was not found.")
}

cat("\nHadoop job completed.\n")

cat(
  paste(
    readLines(part_files[1], warn = FALSE),
    collapse = "\n"
  ),
  "\n",
  sep = ""
)
