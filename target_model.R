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
    "Boruta",
    "rsample",
    "car",
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
  # tar_target(
  #   boruta_relevant_features,
  #   boruta_feature_selection(scaled_dataset),
  #   format = "qs"
  # ),
  # tar_target(
  #   boruta_relevant_features_dataset,
  #   filter_by_boruta_relevant_feature(scaled_dataset, boruta_relevant_features),
  #   format = "qs"
  # ),
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
  # tar_target(
  #   boruta_filtered_train_dataset,
  #   filter_train_by_boruta_relevant_feature(train_dataset,boruta_relevant_features),
  #   format = "qs"
  # ),
  tar_target(
    test_dataset,
    extract_test_dataset(splitted_train_test_dataset),
    format = "qs"
  ),
  # tar_target(
  #   boruta_filtered_test_dataset,
  #   filter_test_by_boruta_relevant_feature(test_dataset,boruta_relevant_features),
  #   format = "qs"
  # ),
  # tar_target(
  #   pre_vif_boruta_binom_model,
  #   build_pre_vif_binom_model(boruta_filtered_train_dataset),
  #   format = "qs"
  # ),
  # tar_target(
  #   vif_boruta_binom_model_variables,
  #   extract_vif_variables(pre_vif_boruta_binom_model),
  #   format = "qs"
  # ),
  # tar_target(
  #   post_vif_boruta_binom_model,
  #   build_post_vif_binom_model(
  #     boruta_filtered_train_dataset,
  #     vif_boruta_binom_model_variables
  #   ),
  #   format = "qs"
  # )
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
