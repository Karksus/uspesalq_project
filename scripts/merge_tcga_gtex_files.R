## Download and unzip .txt files from prebuilt OncoDB datasets:

# https://oncodb.org/data_download.html

# *_Differential_Gene_Expression_Table.txt for gene expression data
# *_Differential_Methylation_GeneBody_Table.txt for methylation data
# *_Differential_Methylation_Promoter_Table.txt for methylation data
library(dplyr)
library(readr)

exp_patt <- "_Differential_Gene_Expression_Table.txt$"
meth_patt <- "_Differential_Methylation_All_Table.txt$"
#meth_patt_promoter <- "_Differential_Methylation_Promoter_Table.txt$"
txt_path <- "scripts/"

merge_oncodb_data <- function(path, pattern) {
  df <-
    list.files(path = path,
               full.names = TRUE,
               pattern = pattern) %>%
    lapply(read_tsv) %>%
    bind_rows
}

df_exp <- merge_oncodb_data(txt_path, exp_patt)
df_meth <- merge_oncodb_data(txt_path, meth_patt)
# df_meth_promoter <- merge_oncodb_data(txt_path, meth_patt_promoter)

write_tsv(x = df_exp, file = "data/tcga_gtex_gene_exp.tsv")
write_tsv(x = df_meth, file = "data/tcga_gtex_meth.tsv")
# write_tsv(x = df_meth_promoter, file = "data/tcga_gtex_promoter_meth.tsv")
