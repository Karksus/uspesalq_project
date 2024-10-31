library(tidymodels)
library(caret)
library(ggplot2)
library(purrr)
library(dplyr)
library(data.table)
library(glmnet)
library(pROC)

merge_all_data <-
  function(pubmed_final_df,
           clinicaltrials_final_df,
           tcga_gtex_exp_final_df,
           tcga_gtex_meth_final_df,
           cosmic_final_df,
           depmapcrispr_final_df,
           depmaprnai_final_df) {
    list_df = list(
      pubmed_final_df,
      clinicaltrials_final_df,
      tcga_gtex_exp_final_df,
      tcga_gtex_meth_final_df,
      cosmic_final_df,
      depmapcrispr_final_df,
      depmaprnai_final_df
    )
    list_df <- lapply(list_df, function(df) {
      df$entrez_id <- as.integer(df$entrez_id)
      return(df)
    })
    all_dfs <-
      list_df %>% purrr::reduce(full_join, by = 'entrez_id')
  }
clean_redundant_variables <- function(all_dfs) {
  df <- all_dfs %>%
    dplyr::select(-dplyr::any_of(
      c(
        "cosmic_gene",
        "oncokb_gene",
        "gene_name.x",
        "gene_name.y",
        "cosmic_gene_symbol",
        "clinicaltrials_gene_symbol"
      )
    ))
}

treat_na_values <- function(df) {
  dt <- as.data.table(df)
  dt[, (names(dt)) := lapply(.SD, function(x)
    ifelse(is.numeric(x) & is.na(x), 0, x))]
}

remove_na_entrez <- function(df) {
  df <- df %>%
    dplyr::filter(!is.na(entrez_id))
}

remove_na_cosmic_cgc <- function(df) {
  df <- df %>%
    dplyr::filter(!is.na(cosmic_cgc_status))
}

remove_constants <- function(df) {
  df <- df %>%
    select_if( ~ !all(is.na(.))) %>%
    select_if(function(col)
      length(unique(col)) > 1)
}

min_max_scale <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

scale_dataset <- function(dataset) {
  df_main_var <- dataset %>%
    dplyr::select(all_of(c(
      "cosmic_cgc_status", "pubmed_gene_symbol", "entrez_id"
    )))
  df_others <- dataset %>%
    dplyr::select(-c(cosmic_cgc_status, pubmed_gene_symbol, entrez_id))
  scaled_df <- as.data.frame(lapply(df_others, min_max_scale))
  scaled_df <- cbind(df_main_var, scaled_df)
}

split_dataset_train_test <- function(df) {
  df$cosmic_cgc_status <- as.factor(df$cosmic_cgc_status)
  set.seed(123)
  data_split <- rsample::initial_split(df, prop = 0.7)
  train_data <- rsample::training(data_split)
  test_data <- rsample::testing(data_split)
  train_test_list <- list(train_data, test_data)
}

extract_train_dataset <- function(train_test_list) {
  train_dataset <- train_test_list[[1]]
}

extract_test_dataset <- function(train_test_list) {
  test_dataset <- train_test_list[[2]]
}

build_train_elasticnet_model <- function(train_dataset) {
  df_nodepenvar <- train_dataset %>%
    dplyr::select(-c(pubmed_gene_symbol, entrez_id, cosmic_cgc_status))
  
  X <- as.matrix(df_nodepenvar)
  y <- train_dataset$cosmic_cgc_status
  
  cv_elastic_net <-
    cv.glmnet(X, y, alpha = 0.5, family = "binomial")
}

get_training_elasticnet_best_lambda_coeffs <-
  function(elasticnet_model) {
    best_lambda <- elasticnet_model$lambda.min
    elastic_net_coefficients <-
      coef(elasticnet_model, s = best_lambda)
    lambda_coeffs_list <-
      list(best_lambda, elastic_net_coefficients)
  }

build_test_elasticnet_model <- function(test_dataset) {
  df_nodepenvar <- test_dataset %>%
    dplyr::select(-c(pubmed_gene_symbol, entrez_id, cosmic_cgc_status))
  
  X <- as.matrix(df_nodepenvar)
  y <- test_dataset$cosmic_cgc_status
  
  cv_elastic_net <-
    cv.glmnet(X, y, alpha = 0.5, family = "binomial")
}

get_test_elasticnet_best_lambda_coeffs <-
  function(elasticnet_model) {
    best_lambda <- elasticnet_model$lambda.min
    elastic_net_coefficients <-
      coef(elasticnet_model, s = best_lambda)
    lambda_coeffs_list <-
      list(best_lambda, elastic_net_coefficients)
  }

predict_train_elasticnet_model <-
  function(train_dataset,
           cv_elastic_net_train,
           lambda_coeffs_list) {
    best_lambda <- lambda_coeffs_list[[1]]
    df_main_var <- train_dataset %>%
      dplyr::select(all_of(c(
        "cosmic_cgc_status", "pubmed_gene_symbol", "entrez_id"
      )))
    X_train <- train_dataset %>%
      dplyr::select(-c(pubmed_gene_symbol, entrez_id, cosmic_cgc_status)) %>%
      as.matrix()
    predicted_probabilities_train <-
      predict(cv_elastic_net_train,
              newx = X_train,
              s = best_lambda,
              type = "response")
    final_df <-
      cbind(df_main_var, predicted_probabilities_train, X_train)
  }

predict_test_elasticnet_model <-
  function(test_dataset,
           cv_elastic_net_test,
           lambda_coeffs_list) {
    best_lambda <- lambda_coeffs_list[[1]]
    df_main_var <- test_dataset %>%
      dplyr::select(all_of(c(
        "cosmic_cgc_status", "pubmed_gene_symbol", "entrez_id"
      )))
    X_test <- test_dataset %>%
      dplyr::select(-c(pubmed_gene_symbol, entrez_id, cosmic_cgc_status)) %>%
      as.matrix()
    predicted_probabilities_test <-
      predict(cv_elastic_net_test,
              newx = X_test,
              s = best_lambda,
              type = "response")
    final_df <-
      cbind(df_main_var, predicted_probabilities_test, X_test)
  }

make_roc_analisys_train_dataset <-
  function(elasticnet_model_prediction) {
    roc_data <-
      roc(elasticnet_model_prediction$cosmic_cgc_status,
          elasticnet_model_prediction$s1)
  }

make_roc_analisys_test_dataset <-
  function(elasticnet_model_prediction) {
    roc_data <-
      roc(elasticnet_model_prediction$cosmic_cgc_status,
          elasticnet_model_prediction$s1)
  }

make_auc_plot_train_dataset <- function(roc_data) {
  auc_value <- auc(roc_data)
  jpeg(
    "plots/roc_train_plot.jpg",
    width = 1200,
    height = 800,
    res = 300
  )
  plot(roc_data, col = "blue", lwd = 2)
  text(
    0.2,
    0.2,
    labels = paste("AUC =", round(auc_value, 3)),
    col = "red",
    cex = 0.8
  )
  dev.off()
}

make_auc_plot_test_dataset <- function(roc_data) {
  auc_value <- auc(roc_data)
  jpeg(
    "plots/roc_test_plot.jpg",
    width = 1200,
    height = 800,
    res = 300
  )
  plot(roc_data, col = "blue", lwd = 2)
  text(
    0.2,
    0.2,
    labels = paste("AUC =", round(auc_value, 3)),
    col = "red",
    cex = 0.8
  )
  dev.off()
}
