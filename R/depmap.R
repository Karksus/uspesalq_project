library(stringr)
library(dplyr)
library(depmap)
library(purrr)
library(fastDummies)

load_depmap_crispr_data <- function() {
  crispr <-
    crispr_22Q1() %>% dplyr::select(c("cell_line", "gene_name", "entrez_id", "dependency")) %>%
    dplyr::filter(!is.na(dependency))
}

filter_depmap_crispr <- function(depmap_crispr_data) {
  unique_data <- depmap_crispr_data %>%
    dplyr::filter(!duplicated(dplyr::select(., cell_line, dependency)) &
                    !duplicated(dplyr::select(., cell_line, dependency), fromLast = TRUE)) %>%
    dplyr::filter(!is.na(cell_line))
}

depmap_crispr_site_to_column <-
  function(filtered_depmap_crispr_data) {
    df <- filtered_depmap_crispr_data %>%
      pivot_wider(names_from = cell_line,
                  values_from = dependency) %>%
      rename_with( ~ paste0("depmap_crispr_", .),-c(entrez_id, gene_name)) %>%
      dplyr::filter(!is.na(entrez_id))
  }

depmap_crispr_depedency_classify <- function(pivot_crispr) {
  df_categorical <- pivot_crispr %>%
    mutate(across(
      starts_with("depmap_crispr_"),
      ~ case_when(
        is.na(.) ~ NA_character_,
        . <= -1 ~ "strong_dependency",
        . <= -0.5 ~ "dependency",
        TRUE ~ "weak_dependency"
      )
    ))
}

dummify_depmap_crispr <- function(depmap_crispr_class) {
  df_other <- depmap_crispr_class %>%
    dplyr::select(-starts_with("depmap_crispr_"))
  
  df_dummified <- depmap_crispr_class %>%
    dplyr::select(starts_with("depmap_crispr_")) %>%
    mutate(across(everything(), as.factor)) %>%
    fastDummies::dummy_cols(remove_selected_columns = TRUE,
                            remove_first_dummy = TRUE)
  
  final_df <- bind_cols(df_other, df_dummified)
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
    pivot_wider(names_from = cell_line,
                values_from = dependency) %>%
    rename_with( ~ paste0("depmap_rnai_", .),-c(entrez_id, gene_name)) %>%
    dplyr::filter(!is.na(entrez_id))
}

depmap_rnai_depedency_classify <- function(pivot_rnai) {
  df_categorical <- pivot_rnai %>%
    mutate(across(
      starts_with("depmap_rnai_"),
      ~ case_when(
        is.na(.) ~ NA_character_,
        . <= -1 ~ "strong_dependency",
        . <= -0.5 ~ "dependency",
        TRUE ~ "weak_dependency"
      )
    ))
}

dummify_depmap_rnai <- function(depmap_rnai_class) {
  df_other <- depmap_rnai_class %>%
    dplyr::select(-starts_with("depmap_rnai_"))
  
  df_dummified <- depmap_rnai_class %>%
    dplyr::select(starts_with("depmap_rnai_")) %>%
    mutate(across(everything(), as.factor)) %>%
    fastDummies::dummy_cols(remove_selected_columns = TRUE,
                            remove_first_dummy = TRUE)
  
  final_df <- bind_cols(df_other, df_dummified)
}