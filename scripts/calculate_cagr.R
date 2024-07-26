# Calculate CAGR
calculate_cagr <- function(start, end, periods) {
  start <- start + 1
  end <- end + 1
  return ((end/start)^(1/periods) - 1)
}

# Apply CAGR calculation for each gene
library(dplyr)
cagr_df <- entrez_pubmed_merged %>%
  rowwise() %>%
  mutate(CAGR = calculate_cagr(`pubmed_2013`, `pubmed_2023`, 10))

sumcosmic <- merged_cosmic_freq %>%
  rowwise() %>%
  mutate(total_citations = sum(c_across(ends_with("pos_samples"))))
