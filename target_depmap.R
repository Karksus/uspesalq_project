library(targets)
library(qs)

tar_option_set(
  packages = c("dplyr",
               "stringr",
               "biomaRt",
               "depmap",
               "purrr",
               "fastDummies"),
  memory = "transient"
)

tar_source("R/")

list(
  tar_target(depmap_crispr_data,
             load_depmap_crispr_data(),
             format = "qs"),
  tar_target(
    depmap_filtered_crispr_data,
    filter_depmap_crispr(depmap_crispr_data),
    format = "qs"
  ),
  tar_target(
    pivot_wider_depmap_crispr,
    depmap_crispr_site_to_column(depmap_filtered_crispr_data),
    format = "qs"
  ),
  tar_target(
    pivot_wider_depmap_crispr_class,
    depmap_crispr_depedency_classify(pivot_wider_depmap_crispr),
    format = "qs"
  ),
  tar_target(
    dummified_depmap_crispr,
    dummify_depmap_crispr(pivot_wider_depmap_crispr_class),
    format = "qs"
  ),
  tar_target(depmap_rnai_data,
             load_depmap_rnai_data(),
             format = "qs"),
  tar_target(
    pivot_wider_depmap_rnai,
    depmap_rnai_site_to_column(depmap_rnai_data),
    format = "qs"
  ),
  tar_target(
    pivot_wider_depmap_rnai_class,
    depmap_rnai_depedency_classify(pivot_wider_depmap_rnai),
    format = "qs"
  ),
  tar_target(
    dummified_depmap_rnai,
    dummify_depmap_rnai(pivot_wider_depmap_rnai_class),
    format = "qs"
  )
)
