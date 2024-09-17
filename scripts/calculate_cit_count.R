sumcosmic <- merged_cosmic_freq %>%
  rowwise() %>%
  mutate(total_citations = sum(c_across(ends_with("pos_samples"))))
