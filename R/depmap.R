library(stringr)
library(dplyr)
library(depmap)
library(purrr)

load_depmap_crispr_data <- function() {
  crispr <-
    crispr_22Q1() %>% dplyr::select(c("cell_line", "gene_name", "entrez_id", "dependency")) %>%
    dplyr::filter(!is.na(dependency))
}

unique_data <- depmap_crispr_data %>%
  dplyr::filter(!duplicated(dplyr::select(., cell_line, dependency)) & !duplicated(dplyr::select(., cell_line, dependency), fromLast = TRUE))


depmap_crispr_site_to_column <- function(depmap_crispr_data) {
  df <- depmap_crispr_data %>%
    pivot_wider(
      names_from = cell_line,
      values_from = dependency
    )
}

load_depmap_rnai_data <- function() {
  rnai <-
    depmap_rnai() %>% dplyr::select(c("cell_line", "gene_name", "entrez_id", "dependency")) %>%
    dplyr::filter(!is.na(dependency)) %>%
    mutate(gene_name = str_split(gene_name, ";") %>% purrr::map_chr(1)) %>%
    mutate(entrez_id = str_split(entrez_id, ";") %>% purrr::map_chr(1))
}

depmap_rnai_site_to_column <- function(depmap_rnai_data) {
  df <- depmap_rnai_data %>%
    pivot_wider(
      names_from = cell_line,
      values_from = dependency
    )
}