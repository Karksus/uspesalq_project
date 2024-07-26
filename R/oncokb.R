library(httr)
library(dplyr)
###############################ONCOKB###########################################
get_oncokb_data <- function(url) {
  onco_kb_data <- GET(url) %>%
    httr::content("text") %>%
    fromJSON()
}

format_oncokb_data <- function(oncokb_data) {
  oncokb_data <- oncokb_data %>%
    dplyr::select(
      entrezGeneId,
      hugoSymbol,
      oncogene,
      highestSensitiveLevel,
      highestResistanceLevel,
      tsg
    ) %>%
    dplyr::rename(
      entrez_id = entrezGeneId,
      gene = hugoSymbol,
      oncogene = oncogene,
      highestSensitiveLevel = highestSensitiveLevel,
      highestResistanceLevel = highestResistanceLevel,
      tsg = tsg
    ) %>%
    mutate(across(where(is.character), ~ na_if(., ""))) %>%
    mutate(entrez_id = as.character(entrez_id)) %>%
    rename_with(~ paste0("oncokb_", .), -entrez_id)
}
