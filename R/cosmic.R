library(dplyr)
library(arrow)
library(data.table)
library(tidyr)
library(tidyverse)
library(fastDummies)

get_cosmic_target_data <- function(targeted_path) {
  valid_mut_type <-
    c(
      "coding_sequence_variant",
      "coding_sequence_variant,splice_acceptor_variant",
      "coding_sequence_variant,splice_donor_variant",
      "inframe_deletion",
      "inframe_deletion,start_lost",
      "inframe_deletion,stop_gained",
      "inframe_deletion,stop_lost",
      "inframe_insertion",
      "inframe_insertion,splice_acceptor_variant",
      "inframe_insertion,stop_gained",
      "missense_variant",
      "splice_acceptor_variant",
      "splice_donor_variant",
      "start_lost",
      "stop_gained",
      "stop_lost",
      "stop_retained_variant",
      ""
    )
  
  target_data <-
    arrow::open_dataset(targeted_path, format = "tsv") %>%
    dplyr::select(
      c(
        "GENE_SYMBOL",
        "COSMIC_SAMPLE_ID",
        "MUTATION_DESCRIPTION",
        "COSMIC_PHENOTYPE_ID"
      )
    ) %>%
    dplyr::filter(MUTATION_DESCRIPTION %in% valid_mut_type) %>%
    collect() %>%
    setDT()
}

get_cosmic_wgs_data <- function(wgs_path) {
  valid_mut_type <-
    c(
      "coding_sequence_variant",
      "coding_sequence_variant,splice_acceptor_variant",
      "coding_sequence_variant,splice_donor_variant",
      "inframe_deletion",
      "inframe_deletion,start_lost",
      "inframe_deletion,stop_gained",
      "inframe_deletion,stop_lost",
      "inframe_insertion",
      "inframe_insertion,splice_acceptor_variant",
      "inframe_insertion,stop_gained",
      "missense_variant",
      "splice_acceptor_variant",
      "splice_donor_variant",
      "start_lost",
      "stop_gained",
      "stop_lost",
      "stop_retained_variant",
      ""
    )
  genome_data <- arrow::open_dataset(wgs_path, format = "tsv") %>%
    dplyr::select(
      c(
        "GENE_SYMBOL",
        "COSMIC_SAMPLE_ID",
        "MUTATION_DESCRIPTION",
        "COSMIC_PHENOTYPE_ID"
      )
    ) %>%
    dplyr::filter(MUTATION_DESCRIPTION %in% valid_mut_type) %>%
    collect() %>%
    setDT()
}

load_classification_data <- function(classification_path) {
  classification <- fread(classification_path) %>%
    dplyr::select(1:2) %>%
    unique() %>%
    {
      df <- as.data.frame(table(.$COSMIC_PHENOTYPE_ID)) %>%
        filter(Freq == 1)
      filter(., COSMIC_PHENOTYPE_ID %in% df$Var1)
    }
}

join_targeted_classification <-
  function(target_data, classification_data) {
    target_data <- target_data %>%
      left_join(classification_data) %>%
      dplyr::select(-COSMIC_PHENOTYPE_ID)
  }

join_wgs_classification <- function(wgs_data, classification_data) {
  wgs_data <- wgs_data %>%
    left_join(classification_data) %>%
    dplyr::select(-COSMIC_PHENOTYPE_ID)
}

calculate_targeted_counts <- function(target_data) {
  target_counts <- target_data[, .(
    target_pos_samples = uniqueN(COSMIC_SAMPLE_ID[MUTATION_DESCRIPTION != ""]),
    target_neg_samples = uniqueN(COSMIC_SAMPLE_ID[MUTATION_DESCRIPTION == ""])
  ), by = .(GENE_SYMBOL, PRIMARY_SITE)]
}

calculate_wgs_counts <- function(genome_data) {
  wgs_counts <- genome_data[, .(
    wgs_pos_samples = uniqueN(COSMIC_SAMPLE_ID[MUTATION_DESCRIPTION != ""]),
    wgs_neg_samples = uniqueN(COSMIC_SAMPLE_ID[MUTATION_DESCRIPTION == ""])
  ), by = .(GENE_SYMBOL, PRIMARY_SITE)]
}
merge_counts <- function(target_counts, genome_counts) {
  gene_counts <-
    merge(
      target_counts,
      genome_counts,
      by = c("GENE_SYMBOL", "PRIMARY_SITE"),
      all = TRUE
    )
  gene_counts[is.na(gene_counts)] <- 0
  gene_counts <- setDT(gene_counts)
}

calculate_cosmic_frequency <- function(gene_counts) {
  gene_counts[, FREQ := (target_pos_samples + wgs_pos_samples) /
                (target_neg_samples + target_pos_samples + (wgs_pos_samples +
                                                              wgs_neg_samples)) * 100]
  #gene_frequency_df <- gene_counts[, .(GENE_SYMBOL, PRIMARY_SITE, FREQ)]
}

load_cgc_data <- function(cgc_path) {
  cgc_data <- arrow::open_dataset(cgc_path, format = "tsv") %>%
    dplyr::select(c("GENE_SYMBOL", "ROLE_IN_CANCER")) %>%
    dplyr::filter(!is.na("ROLE_IN_CANCER")) %>%
    collect() %>%
    setDT()
}

load_cgc_futreal_data <- function(cgc_futreal_path) {
  df <- read.csv(cgc_futreal_path, sep = ";")
}

annotate_cosmic_freq_data <- function(cosmic_data, entrez_data) {
  df_merged <- cosmic_data %>%
    dplyr::rename(gene_symbol = GENE_SYMBOL) %>%
    left_join(entrez_data, by = "gene_symbol")
}

merge_cosmic_freq_cgc <-
  function(annotated_cosmic_freq_data, cgc_data) {
    cgc_data <- cgc_data %>% dplyr::rename(gene_symbol = GENE_SYMBOL)
    df_merged <- annotated_cosmic_freq_data %>%
      left_join(cgc_data, by = "gene_symbol")
  }

cosmic_site_to_column <- function(merged_cosmic_freq) {
  df <- merged_cosmic_freq %>%
    pivot_wider(
      names_from = PRIMARY_SITE,
      values_from = c(
        target_pos_samples,
        target_neg_samples,
        wgs_pos_samples,
        wgs_neg_samples,
        FREQ
      )
    )
}

merge_cosmic_data <- function(cosmic_wider, cgc_futreal_data) {
  df <- cosmic_wider %>%
    full_join(cgc_futreal_data, by = "entrez_id") %>%
    mutate(cgc_status = case_when(
      !is.na(ROLE_IN_CANCER) |
        !is.na(is_cgc) ~ "true",
      is.na(ROLE_IN_CANCER) &
        is.na(is_cgc) ~ "false"
    )) %>%
    dplyr::select(-c(ROLE_IN_CANCER, is_cgc)) %>%
    mutate(entrez_id = as.character(entrez_id)) %>%
    rename_with( ~ paste0("cosmic_", .),-entrez_id) %>%
    dplyr::filter(!is.na(entrez_id))
}
