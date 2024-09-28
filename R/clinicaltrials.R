library(dplyr)

load_clinicaltrials_data <- function(clinicaltrials_path) {
  df <- read.csv(clinicaltrials_path) %>%
    dplyr::select(-X)
}

annotate_clinicaltrials_data <-
  function(clinicaltrials_data, entrez_data) {
    df_merged <- clinicaltrials_data %>%
      dplyr::rename(gene_symbol = Gene) %>%
      left_join(entrez_data, by = "gene_symbol") %>%
      mutate(entrez_id = as.character(entrez_id)) %>%
      rename_with(~ paste0("clinicaltrials_", .), -entrez_id) %>%
      dplyr::filter(!is.na(entrez_id))
  }