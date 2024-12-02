library(targets)
library(qs)

tar_option_set(
  packages = c(
    "dplyr",
    "ggplot2",
    "pROC"
  ),
  memory = "transient"
)

tar_source("R/")

object_from_project_model_train1 <-
  tar_read(training_elasticnet_model, store = "store_model")
object_from_project_model_train2 <-
  tar_read(training_elasticnet_model_lambda_coeffs, store = "store_model")
object_from_project_model_train3 <-
  tar_read(train_elasticnet_model_prediction, store = "store_model")

object_from_project_model_test1 <-
  tar_read(test_elasticnet_model, store = "store_model")
object_from_project_model_test2 <-
  tar_read(test_elasticnet_model_lambda_coeffs, store = "store_model")
object_from_project_model_test3 <-
  tar_read(test_elasticnet_model_prediction, store = "store_model")

list(
  tar_target(
    roc_train_dataset,
    make_roc_analisys_train_dataset(
      object_from_project_model_train3
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
    train_lambda_deviance_plot,
    make_train_lambda_deviance_plot(
      object_from_project_model_train1
    ),
    format = "qs"
  ),
  tar_target(
    train_lambda_coeffs_plot,
    make_train_lambda_coeffs_plot(
      object_from_project_model_train1
    ),
    format = "qs"
  ),
  tar_target(
    train_top10_coeffs_plot,
    make_train_top10_coeffs_plot(
      object_from_project_model_train2
    ),
    format = "qs"
  ),
  tar_target(
    train_top30_coeffs_plot,
    make_train_top30_coeffs_plot(
      object_from_project_model_train2
    ),
    format = "qs"
  ),
  tar_target(
    roc_test_dataset,
    make_roc_analisys_test_dataset(
      object_from_project_model_test3
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
  tar_target(
    test_lambda_deviance_plot,
    make_test_lambda_deviance_plot(
      object_from_project_model_test1
    ),
    format = "qs"
  ),
  tar_target(
    test_lambda_coeffs_plot,
    make_test_lambda_coeffs_plot(
      object_from_project_model_test1
    ),
    format = "qs"
  ),
  tar_target(
    test_top10_coeffs_plot,
    make_test_top10_coeffs_plot(
      object_from_project_model_test2
    ),
    format = "qs"
  ),
  tar_target(
    test_top30_coeffs_plot,
    make_test_top30_coeffs_plot(
      object_from_project_model_test2
    ),
    format = "qs"
  )
)
