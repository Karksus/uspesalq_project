library(targets)
library(qs)

tar_option_set(
  packages = c(
    "dplyr",
    "stringr",
    "biomaRt",
    "org.Hs.eg.db"
  ),
  memory = "transient"
)

tar_source("R/")

object_from_project_cosmic <- tar_read(entrez_gene_data, store = "store_cosmic")

list(
  tar_target(
    pubmed_gene_citations,
    load_and_format_pubmed_data("data/pubmed_citation_count.csv"),
    format = "qs"
  ),
  tar_target(
    entrez_pubmed_merged,
    merge_entrez_pubmed(pubmed_gene_citations, object_from_project_cosmic),
    format = "qs"
  ),
  tar_target(
    entrez_pubmed_merged_cagr,
    calculate_cagr_pubmed(entrez_pubmed_merged),
    format = "qs"
  ),
  tar_target(gene_list,
             final_gene_list(entrez_pubmed_merged),
             format = "qs")
)
