library(stringr)
library(dplyr)
library(biomaRt)
library(org.Hs.eg.db)

get_entrez_gene_list <- function(){
  mart <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")
  symb <- keys(org.Hs.eg.db, "SYMBOL")
  annotated_genes <- getBM(attributes = c("entrezgene_id", "hgnc_symbol"), 
                           filters = "hgnc_symbol", 
                           values = symb, 
                           mart = mart) %>%
    dplyr::rename(entrez_id = entrezgene_id, gene_symbol = hgnc_symbol) %>%
    dplyr::filter(!is.na(entrez_id) & !is.na(gene_symbol))
  
  genes <- annotated_genes$gene_symbol
}


load_pubmed_data <- function(pubmed_data){
  df <- results %>%
    mutate(
      gene_symbol = str_extract(search_term, "^[^ ]+"), # Extracts the first word before space
      year = str_extract(search_term, "\\d{4}(?=\\[PDAT\\])") # Extracts four digits before "[PDAT]"
    )
}

extract_gene_list <- function(pubmed_data, entrez_gene_list){
  df_merged <- pubmed_data %>%
    inner_join(entrez_gene_list, by = "gene_symbol")
  genelist <- unique(df_merged$gene_symbol)
}

