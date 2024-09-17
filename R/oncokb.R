library(httr)
library(dplyr)
library(jsonlite)

get_oncokb_data <- function(url) {
  onco_kb_data <- GET(url) %>%
    httr::content("text") %>%
    fromJSON()
}

format_oncokb_data <- function(oncokb_data) {
  oncokb_data <- oncokb_data %>%
    dplyr::select(entrezGeneId,
                  hugoSymbol,
                  highestSensitiveLevel,
                  highestResistanceLevel) %>%
    dplyr::rename(
      entrez_id = entrezGeneId,
      gene = hugoSymbol,
      highestSensitiveLevel = highestSensitiveLevel,
      highestResistanceLevel = highestResistanceLevel,
    ) %>%
    mutate(across(where(is.character), ~ na_if(., ""))) %>%
    mutate(entrez_id = as.character(entrez_id)) %>%
    rename_with(~ paste0("oncokb_", .), -entrez_id) %>%
    dplyr::filter(!is.na(entrez_id))
}

dummify_oncokb_data <- function(df) {
  df_dummified <- df %>%
    fastDummies::dummy_cols(
      select_columns = c(
        "oncokb_highestResistanceLevel",
        "oncokb_highestSensitiveLevel"
      ),
      remove_selected_columns = TRUE,
      remove_first_dummy = TRUE
    )
  
}
