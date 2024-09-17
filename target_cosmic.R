library(targets)
library(qs)

tar_option_set(
  packages = c(
    "dplyr",
    "data.table",
    "arrow",
    "fastDummies",
    "tidyr",
    "tidyverse"
  ),
  memory = "transient"
)

tar_source("R/")

list(
  tar_target(
    targeted_data,
    get_cosmic_target_data("data/Cosmic_CompleteTargetedScreensMutant_v99_GRCh37.tsv"),
    format = "qs"
  ),
  tar_target(
    wgs_data,
    get_cosmic_wgs_data("data/Cosmic_GenomeScreensMutant_v99_GRCh37.tsv"),
    format = "qs"
  ),
  tar_target(
    classification_data,
    load_classification_data("data/Cosmic_Classification_v99_GRCh37.tsv"),
    format = "qs"
  ),
  tar_target(
    cgc_data,
    load_cgc_data("data/Cosmic_CancerGeneCensus_v99_GRCh37.tsv"),
    format = "qs"
  ),
  tar_target(
    cgc_futreal_data,
    load_cgc_futreal_data("data/cancer_gene_census_futreal.csv"),
    format = "qs"
  ),
  tar_target(
    targeted_classify,
    join_targeted_classification(targeted_data, classification_data),
    format = "qs"
  ),
  tar_target(
    wgs_classify,
    join_wgs_classification(wgs_data, classification_data),
    format = "qs"
  ),
  tar_target(
    targeted_counts,
    calculate_targeted_counts(targeted_classify),
    format = "qs"
  ),
  tar_target(
    wgs_total_counts,
    calculate_wgs_counts(wgs_classify),
    format = "qs"
  ),
  tar_target(
    merged_counts,
    merge_counts(targeted_counts, wgs_total_counts),
    format = "qs"
  ),
  tar_target(
    cosmic_gene_frequency,
    calculate_cosmic_frequency(merged_counts),
    format = "fst_dt"
  ),
  tar_target(entrez_gene_data,
             get_entrez_gene_data(),
             format = "qs"),
  tar_target(
    annotated_cosmic_freq_data,
    annotate_cosmic_freq_data(cosmic_gene_frequency, entrez_gene_data),
    format = "qs"
  ),
  tar_target(
    merged_cosmic_freq_cgc,
    merge_cosmic_freq_cgc(annotated_cosmic_freq_data, cgc_data),
    format = "qs"
  ),
  tar_target(
    pivot_wider_cosmic,
    cosmic_site_to_column(merged_cosmic_freq_cgc),
    format = "qs"
  ),
  tar_target(
    merged_cosmic_data,
    merge_cosmic_data(pivot_wider_cosmic, cgc_futreal_data),
    format = "qs"
  ),
  tar_target(
    dummified_cosmic_data,
    dummify_cosmic_data(merged_cosmic_data),
    format = "qs"
  )
)