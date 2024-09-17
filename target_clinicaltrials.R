library(targets)
library(qs)

tar_option_set(packages = "dplyr",
               memory = "transient")

tar_source("R/")

object_from_project_cosmic <-
  tar_read(entrez_gene_data, store = "store_cosmic")

list(
  tar_target(
    clinicaltrials_gene_count,
    load_clinicaltrials_data("data/clinical_trials_data.csv"),
    format = "qs"
  ),
  tar_target(
    annotated_clinicaltrials_data,
    annotate_clinicaltrials_data(clinicaltrials_gene_count, object_from_project_cosmic),
    format = "qs"
  )
)
