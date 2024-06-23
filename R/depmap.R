library(stringr)
library(dplyr)
library(depmap)
library(purrr)

load_depmap_crispr_data <- function() {
  crispr <-
    crispr_22Q1() %>% dplyr::select(c("cell_line", "gene_name", "entrez_id", "dependency")) %>%
    dplyr::filter(!is.na(dependency))
}

load_depmap_rnai_data <- function() {
  rnai <-
    depmap_rnai() %>% dplyr::select(c("cell_line", "gene_name", "entrez_id", "dependency")) %>%
    dplyr::filter(!is.na(dependency)) %>%
    mutate(gene_name = str_split(gene_name, ";") %>% purrr::map_chr(1)) %>%
    mutate(entrez_id = str_split(entrez_id, ";") %>% purrr::map_chr(1))
}
