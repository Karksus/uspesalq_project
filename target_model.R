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
    "glmnet"
  ),
  memory = "transient"
)

tar_source("R/")

object_from_project_prepare_model <-
  tar_read(no_missing_data_dataset, store = "store_prepare_model")

list(
  tar_target(
    no_constants_dataset,
    remove_constants(object_from_project_prepare_model),
    format = "qs"
  ),
  tar_target(scaled_dataset,
             scale_dataset(no_constants_dataset),
             format = "qs"),
  tar_target(
    splitted_train_test_dataset,
    split_dataset_train_test(scaled_dataset),
    format = "qs"
  ),
  tar_target(
    train_dataset,
    extract_train_dataset(splitted_train_test_dataset),
    format = "qs"
  ),
  tar_target(
    test_dataset,
    extract_test_dataset(splitted_train_test_dataset),
    format = "qs"
  ),
  tar_target(
    training_elasticnet_model,
    build_elasticnet_model(train_dataset),
    format = "qs"
  ),
  tar_target(
    training_elasticnet_model_coeffs,
    get_elasticnet_best_lambda_coeffs(training_elasticnet_model),
    format = "qs"
  )
)
