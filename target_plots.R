library(targets)
library(qs)

tar_option_set(
  packages = c(
    "dplyr",
    "purrr",
    "fastDummies",
    "tidymodels",
    "caret",
    "randomForest",
    "rsample",
    "glmnet",
    "pROC"
  ),
  memory = "transient"
)

tar_source("R/")

object_from_project_model_train <-
  tar_read(train_elasticnet_model_prediction, store = "store_model")
object_from_project_model_test <-
  tar_read(test_elasticnet_model_prediction, store = "store_model")

list(
  tar_target(
    roc_train_dataset,
    make_roc_analisys_train_dataset(
      object_from_project_model_train
    ),
    format = "qs"
  ),
  tar_target(
    auc_plot_train_dataset,
    make_auc_plot_train_dataset(
      roc_train_dataset
    ),
    format = "qs"
  ),
  tar_target(
    roc_test_dataset,
    make_roc_analisys_test_dataset(
      object_from_project_model_test
    ),
    format = "qs"
  ),
  tar_target(
    auc_plot_test_dataset,
    make_auc_plot_test_dataset(
      roc_test_dataset
    ),
    format = "qs"
  ),
  
)
