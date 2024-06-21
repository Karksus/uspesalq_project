library(httr)
library(dplyr)
###############################ONCOKB###########################################
url_oncokb <- 'https://www.oncokb.org/api/v1/utils/allCuratedGenes?includeEvidence=true'

get_oncokb_data <- function(url){
  onco_kb_data <- GET(url_oncokb) %>%
    content("text") %>%
    fromJSON()
}

format_oncokb_data <- function(oncokb_data){
  oncokb_data <- oncokb_data %>%
    select(grch37Isoform, entrezGeneId, hugoSymbol, oncogene,
           highestSensitiveLevel, highestResistanceLevel, tsg) %>%
    rename(
      isoform = grch37Isoform,
      entrez = entrezGeneId,
      gene = hugoSymbol,
      oncogene = oncogene,
      highestSensitiveLevel = highestSensitiveLevel,
      highestResistanceLevel = highestResistanceLevel,
      tsg = tsg
    ) %>%
    mutate(across(where(is.character), ~na_if(., "")))
}