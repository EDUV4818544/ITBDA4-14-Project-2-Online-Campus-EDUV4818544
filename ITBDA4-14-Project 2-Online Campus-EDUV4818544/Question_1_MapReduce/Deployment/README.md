

\# Question 1 - MapReduce Keyword Search



\## Purpose

Search text documents for a dynamically entered keyword

and return the document name, row and column positions.



The keyword search is case-insensitive.



\## Implementation

Programming language: R

Development environment: RStudio

MapReduce framework: Hadoop Streaming



\## R Scripts

01\_prepare\_input.R - Prepares document records.

02\_mapper.R - Searches for keyword occurrences.

03\_reducer.R - Groups matching positions.

04\_run\_local.R - Runs the process in RStudio.

05\_run\_hadoop.R - Configures Hadoop Streaming.



\## Running the project

Open the main RStudio project.



Execute:

source("Question\_1\_MapReduce/R/04\_run\_local.R")



Enter a keyword when prompted.



\## Expected results for africa

Documents checked: 17

Matching documents: 7

Total matches: 28







