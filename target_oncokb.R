library(targets)
library(qs)

tar_option_set(
  packages = c(
    "dplyr",
    "httr",
    "jsonlite"
  ),
  memory = "transient"
)

tar_source("R/")

list(
  tar_target(
    oncokb_data,
    get_oncokb_data(
      "https://www.oncokb.org/api/v1/utils/allCuratedGenes?includeEvidence=true"
    ),
    format = "qs"
  ),
  tar_target(
    formatted_oncokb,
    format_oncokb_data(oncokb_data),
    format = "qs"
  ),
  tar_target(
    dummified_oncokb,
    dummify_oncokb_data(formatted_oncokb),
    format = "qs"
  )
)
