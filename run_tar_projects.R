library(targets)

Sys.setenv(TAR_PROJECT = "project_cosmic")
tar_make()
tar_mermaid(targets_only = TRUE)

Sys.setenv(TAR_PROJECT = "project_tcga_gtex")
tar_make()
tar_mermaid(targets_only = TRUE)

Sys.setenv(TAR_PROJECT = "project_clinicaltrials")
tar_make()
tar_mermaid(targets_only = TRUE)

Sys.setenv(TAR_PROJECT = "project_pubmed")
tar_make()
tar_mermaid(targets_only = TRUE)

Sys.setenv(TAR_PROJECT = "project_depmap")
tar_make()
tar_mermaid(targets_only = TRUE)

Sys.setenv(TAR_PROJECT = "project_prepare_model")
tar_make()
tar_mermaid(targets_only = TRUE)

Sys.setenv(TAR_PROJECT = "project_model")
tar_make()
tar_mermaid(targets_only = TRUE)
