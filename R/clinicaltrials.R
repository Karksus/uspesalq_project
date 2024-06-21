library(dplyr)
library(httr)
library(jsonlite)

results <- data.frame(Gene = character(), StudyCount = numeric(), stringsAsFactors = FALSE)

for (gene in genes) {
  api_url <- paste0("https://clinicaltrials.gov/api/v2/studies?query.cond=cancer&query.term=", gene, "&countTotal=true")
  response <- GET(api_url)
  data <- fromJSON(httr::content(response, "text"))
  
  # Extract the total count and store in the results data frame
  results <- rbind(results, data.frame(Gene = gene, StudyCount = data$totalCount, stringsAsFactors = FALSE))
}
