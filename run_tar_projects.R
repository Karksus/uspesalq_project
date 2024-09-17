library(targets)

Sys.setenv(TAR_PROJECT = "project_cosmic")
tar_make()

Sys.setenv(TAR_PROJECT = "project_clinicaltrials")
tar_make()

Sys.setenv(TAR_PROJECT = "project_pubmed")
tar_make()

Sys.setenv(TAR_PROJECT = "project_oncokb")
tar_make()

Sys.setenv(TAR_PROJECT = "project_depmap")
tar_make()

Sys.setenv(TAR_PROJECT = "project_prepare_model")
tar_make()

Sys.setenv(TAR_PROJECT = "project_model")
tar_make()
