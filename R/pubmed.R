library(stringr)
library(dplyr)
library(biomaRt)
library(org.Hs.eg.db)

get_entrez_gene_data <- function() {
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
  annotated_genes <-
    annotated_genes[!duplicated(annotated_genes$gene_symbol), ]
  
}

load_and_format_pubmed_data <- function(pubmed_path) {
  pubmed_data <- read.csv(pubmed_path)
  df <- pubmed_data %>%
    mutate(
      gene_symbol = str_extract(search_term, "^[^ ]+"),
      year = str_extract(search_term, "\\d{4}(?=\\[PDAT\\])")
    )
}

merge_entrez_pubmed <- function(pubmed_data, entrez_data) {
  df_merged <- pubmed_data %>%
    inner_join(entrez_data, by = "gene_symbol") %>%
    dplyr::select(-search_term) %>%
    distinct(gene_symbol, entrez_id, year, .keep_all = TRUE) %>%
    pivot_wider(names_from = year,
                values_from = count) %>%
    mutate(entrez_id = as.character(entrez_id)) %>%
    rename_with(~ paste0("pubmed_", .), -entrez_id) %>%
    dplyr::filter(!is.na(entrez_id))
  
}

calculate_cagr <- function(start, end, periods) {
  start <- start + 1
  end <- end + 1
  return ((end / start) ^ (1 / periods) - 1)
}
calculate_cagr_pubmed <- function(pubmed_df) {
  cagr_df <- pubmed_df %>%
    rowwise() %>%
    mutate(pubmed_CAGR = calculate_cagr(`pubmed_2013`, `pubmed_2023`, 10)) %>%
    dplyr::select(c(pubmed_gene_symbol, entrez_id, pubmed_CAGR))
}

final_gene_list <- function(df_merged) {
  genelist <- unique(df_merged$pubmed_gene_symbol)
}
