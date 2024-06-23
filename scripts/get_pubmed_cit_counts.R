library(dplyr)
library(glue)
library(biomaRt)
library(org.Hs.eg.db)
library(rentrez)

mart <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")
symb <- keys(org.Hs.eg.db, "SYMBOL")
annotated_genes <-
  getBM(
    attributes = c("entrezgene_id", "hgnc_symbol"),
    filters = "hgnc_symbol",
    values = symb,
    mart = mart
  ) %>%
  dplyr::rename(entrez_id = entrezgene_id, gene_symbol = hgnc_symbol) %>%
  dplyr::filter(!is.na(entrez_id) & !is.na(gene_symbol))

years <- 2013:2023
genes <- annotated_genes$gene_symbol

combinations <-
  expand.grid(year = years,
              gene = genes,
              stringsAsFactors = FALSE) %>%
  mutate(search_term = glue("{gene} AND cancer AND {year}[PDAT]"))

get_citation_count <- function(term) {
  tryCatch({
    Sys.sleep(0.2)  # Sleep first to respect API limit
    search_result <-
      entrez_search(db = "pubmed",
                    term = term,
                    use_history = TRUE)$count
    return(search_result)
  }, error = function(e) {
    return(NA)  # Return NA on error
  })
}

# Initialize a results dataframe
results <-
  data.frame(
    search_term = character(),
    count = integer(),
    stringsAsFactors = FALSE
  )
results_filepath <- "results.csv"

# Check if the results file already exists
if (file.exists(results_filepath)) {
  results <- read.csv(results_filepath, stringsAsFactors = FALSE)
}

# Filter combinations that have not been processed
processed_terms <- results$search_term
pending_combinations <-
  combinations[!combinations$search_term %in% processed_terms, ]

# Process and save periodically
for (i in 1:nrow(pending_combinations)) {
  term <- pending_combinations$search_term[i]
  count <- get_citation_count(term)
  # Append new result
  new_result <-
    data.frame(
      search_term = term,
      count = count,
      stringsAsFactors = FALSE
    )
  results <- rbind(results, new_result)
  
  # Save progress every 100 queries or at the end
  if (i %% 100 == 0 || i == nrow(pending_combinations)) {
    write.csv(results, results_filepath, row.names = FALSE)
    print(paste("Saved progress at query", i))
  }
}

df <- results %>%
  mutate(
    gene_symbol = str_extract(search_term, "^[^ ]+"),
    year = str_extract(search_term, "\\d{4}(?=\\[PDAT\\])")
  )
