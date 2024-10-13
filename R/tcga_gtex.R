library(dplyr)
library(readr)
library(tidyr)
library(fastDummies)

load_tcga_gtex_exp_data <- function(exp_dataset) {
  df <- readr::read_tsv(exp_dataset)
}

load_tcga_gtex_meth_data <- function(meth_dataset) {
  df <- readr::read_tsv(meth_dataset)
}

format_tcga_gtex_meth_data <- function(meth_dataset) {
  df <- meth_dataset %>%
    mutate(
      methylation_status = case_when(
        `FDR adjusted p-value` <= 0.05 &
          `Beta difference value` >= 0.2 &
          `Cancer Sample Med` > `Normal Sample Med` ~ "hyper_methylation",
        `FDR adjusted p-value` <= 0.05 &
          `Beta difference value` >= 0.2 &
          `Normal Sample Med` > `Cancer Sample Med` ~ "hypo_methylation",
        `FDR adjusted p-value` > 0.05 |
          `Beta difference value` < 0.2 ~ "no_meth_effect"
      )
    ) %>%
    dplyr::rename(entrez_id = `NCBI gene id`,cancer_type = `Cancer type`) %>%
    dplyr::select(all_of(
      c(
        "cancer_type",
        "entrez_id",
        "methylation_status"
      )
    ))
}

tcga_gtex_meth_cancertype_to_column <- function(formmated_meth_data) {
  df <- formmated_meth_data %>%
    pivot_wider(names_from = cancer_type,
                values_from = methylation_status) %>%
    rename_with(~ paste0("tcga_gtex_meth_", .), -entrez_id) %>%
    dplyr::filter(complete.cases(.))
}

dummify_tcga_gtex_meth_data <- function(df) {
  df_other <- df %>%
    dplyr::select(-starts_with("tcga_gtex_meth_"))
  df_dummified <- df %>%
    dplyr::select(starts_with("tcga_gtex_meth_")) %>%
    mutate(across(everything(), as.factor)) %>%
    fastDummies::dummy_cols(remove_selected_columns = TRUE,
                            remove_first_dummy = TRUE)
  
  final_df <- bind_cols(df_other, df_dummified)
}

format_tcga_gtex_exp_data <- function(exp_dataset) {
  df <- exp_dataset %>%
    mutate(
      gene_expression_status = case_when(
        `FDR adjusted p-value` <= 0.05 &
          `log2 fold change` >= 1 ~ "overexpressed",
        `FDR adjusted p-value` <= 0.05 &
          `log2 fold change` <= -1 ~ "underexpressed",
        `FDR adjusted p-value` > 0.05 |
          between(`log2 fold change`,-1, 1) ~ "no_exp_effect"
      )
    ) %>%
    dplyr::rename(entrez_id = `NCBI gene id`,
                  cancer_type = `Cancer type`) %>%
    dplyr::select(all_of(c(
      "cancer_type", "entrez_id", "gene_expression_status"
    )))
}

tcga_gtex_exp_cancertype_to_column <- function(formmated_exp_data) {
  df <- formmated_exp_data %>%
    pivot_wider(names_from = cancer_type,
                values_from = gene_expression_status) %>%
    rename_with(~ paste0("tcga_gtex_exp_", .), -entrez_id)
}

dummify_tcga_gtex_exp_data <- function(df) {
  df_other <- df %>%
    dplyr::select(-starts_with("tcga_gtex_exp_"))
  df_dummified <- df %>%
    dplyr::select(starts_with("tcga_gtex_exp_")) %>%
    mutate(across(everything(), as.factor)) %>%
    fastDummies::dummy_cols(remove_selected_columns = TRUE,
                            remove_first_dummy = TRUE)
  
  final_df <- bind_cols(df_other, df_dummified)
}
