library(targets)
library(qs)

tar_option_set(
  packages = c(
    "dplyr",
    "fastDummies",
    "tidyr",
    "readr"
  ),
  memory = "transient"
)

tar_source("R/")

list(
  tar_target(
    tcga_gtex_exp_data,
    load_tcga_gtex_exp_data("data/tcga_gtex_gene_exp.tsv"),
    format = "qs"
  ),
  tar_target(
    formatted_tcga_gtex_exp_data,
    format_tcga_gtex_exp_data(tcga_gtex_exp_data),
    format = "qs"
  ),
  tar_target(
    pivot_wider_tcga_gtex_exp,
    tcga_gtex_exp_cancertype_to_column(formatted_tcga_gtex_exp_data),
    format = "qs"
  ),
  tar_target(
    dummified_tcga_gtex_exp_data,
    dummify_tcga_gtex_exp_data(pivot_wider_tcga_gtex_exp),
    format = "qs"
  ),
  tar_target(
    tcga_gtex_meth_data,
    load_tcga_gtex_meth_data("data/tcga_gtex_meth.tsv"),
    format = "qs"
  ),
  tar_target(
    formatted_tcga_gtex_meth_data,
    format_tcga_gtex_meth_data(tcga_gtex_meth_data),
    format = "qs"
  ),
  tar_target(
    pivot_wider_tcga_gtex_meth,
    tcga_gtex_meth_cancertype_to_column(formatted_tcga_gtex_meth_data),
    format = "qs"
  ),
  tar_target(
    dummified_tcga_gtex_meth_data,
    dummify_tcga_gtex_meth_data(pivot_wider_tcga_gtex_meth),
    format = "qs"
  )
)