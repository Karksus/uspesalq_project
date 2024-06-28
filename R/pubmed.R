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
  annotated_genes <- annotated_genes[!duplicated(annotated_genes$gene_symbol),]
    
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
    pivot_wider(
      names_from = year,
      values_from = count
    )
}

final_gene_list <- function(df_merged) {
  genelist <- unique(df_merged$gene_symbol)
}
