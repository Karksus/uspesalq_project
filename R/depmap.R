library(stringr)
library(dplyr)
library(depmap)

crispr <- crispr_22Q1() %>% select(c("cell_line","gene_name","entrez_id","dependency")) %>% 
  filter(!is.na(dependency))

rnai <- depmap_rnai() %>% select(c("cell_line","gene_name","entrez_id","dependency")) %>% 
  filter(!is.na(dependency)) %>%
  mutate(gene_name = str_split(gene_name, ";") %>% map_chr(1)) %>%
  mutate(entrez_id = str_split(entrez_id, ";") %>% map_chr(1))