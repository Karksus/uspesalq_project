library(targets)

tar_config_set(script = "target_clinicaltrials.R",
               store = "store_clinicaltrials",
               project = "project_clinicaltrials")

tar_config_set(script = "target_tcga_gtex.R",
               store = "store_tcga_gtex",
               project = "project_tcga_gtex")

tar_config_set(script = "target_pubmed.R",
               store = "store_pubmed",
               project = "project_pubmed")

tar_config_set(script = "target_cosmic.R",
               store = "store_cosmic",
               project = "project_cosmic")

tar_config_set(script = "target_prepare_model.R",
               store = "store_prepare_model",
               project = "project_prepare_model")

tar_config_set(script = "target_model.R",
               store = "store_model",
               project = "project_model")

tar_config_set(script = "target_depmap.R",
               store = "store_depmap",
               project = "project_depmap")
