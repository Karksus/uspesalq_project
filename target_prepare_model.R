library(targets)
library(qs)

tar_option_set(
  packages = c(
    "dplyr",
    "purrr",
    "fastDummies",
    "tidymodels",
    "caret",
    "randomForest",
    "rsample",
    "data.table"
  ),
  memory = "transient"
)

tar_source("R/")

object_from_project_pubmed <-
  tar_read(entrez_pubmed_merged_cagr, store = "store_pubmed")

object_from_project_clinicaltrials <-
  tar_read(annotated_clinicaltrials_data, store = "store_clinicaltrials")

object_from_project_oncokb <-
  tar_read(dummified_oncokb, store = "store_oncokb")

object_from_project_cosmic <-
  tar_read(dummified_cosmic_data, store = "store_cosmic")

object_from_project_depmap_crispr <-
  tar_read(dummified_depmap_crispr, store = "store_depmap")

object_from_project_depmap_rnai <-
  tar_read(dummified_depmap_rnai, store = "store_depmap")

list(
  tar_target(
    all_data,
    merge_all_data(
      object_from_project_pubmed,
      object_from_project_clinicaltrials,
      object_from_project_oncokb,
      object_from_project_cosmic,
      object_from_project_depmap_crispr,
      object_from_project_depmap_rnai
    ),
    format = "qs"
  ),
  tar_target(
    no_redundant_variables_dataset,
    clean_redundant_variables(all_data),
    format = "qs"
  ),
  tar_target(
    no_missing_entrez_dataset,
    remove_na_entrez(no_redundant_variables_dataset),
    format = "qs"
  ),
  tar_target(
    no_missing_cosmic_dataset,
    remove_na_cosmic_cgc(no_missing_entrez_dataset),
    format = "qs"
  ),
  # tar_target(
  #   gene_indexed_lines_dataset,
  #   genes_as_index(no_missing_cosmic_dataset),
  #   format = "qs"
  # ),
  tar_target(
    no_missing_data_dataset,
    treat_na_values(no_missing_cosmic_dataset),
    format = "qs"
  )
)
