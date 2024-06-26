load_clinicaltrials_data <- function(clinicaltrials_path) {
  df <- read.csv(clinicaltrials_path)
}

annotate_clinicaltrials_data <- function(clinicaltrials_data, entrez_data) {
  df_merged <- clinicaltrials_data %>%
    dplyr::rename(gene_symbol = Gene) %>%
    left_join(entrez_data, by = "gene_symbol")
}