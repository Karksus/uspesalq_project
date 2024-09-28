library(tidymodels)
library(rpart.plot)
library(nnet)
library(caret)
library(randomForest)
library(Boruta)
library(ggplot2)
library(purrr)
library(dplyr)
library(data.table)
library(glmnet)
#library(car)

merge_all_data <-
  function(pubmed_final_df,
           clinicaltrials_final_df,
           oncokb_final_df,
           cosmic_final_df,
           depmapcrispr_final_df,
           depmaprnai_final_df) {
    list_df = list(
      pubmed_final_df,
      clinicaltrials_final_df,
      oncokb_final_df,
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

# boruta_feature_selection <- function(df) {
#   df$cosmic_cgc_status <- as.factor(df$cosmic_cgc_status)
#   df <- df %>%
#     dplyr::select(-c(pubmed_gene_symbol, entrez_id))
#   importances <-
#     Boruta(cosmic_cgc_status ~ ., data = df, doTrace = 0) %>%
#     TentativeRoughFix() %>%
#     attStats() %>%
#     dplyr::filter(decision != "Rejected") %>%
#     dplyr::select(meanImp, decision) %>%
#     arrange(desc(meanImp))
# }
#
# filter_by_boruta_relevant_feature <-
#   function(df, relevant_features) {
#     df <- df %>%
#       dplyr::select(all_of(
#         c(
#           rownames(relevant_features),
#           "pubmed_gene_symbol",
#           "entrez_id",
#           "cosmic_cgc_status"
#         )
#       ))
#   }
#
split_dataset_train_test <- function(df) {
  df$cosmic_cgc_status <- as.factor(df$cosmic_cgc_status)
  set.seed(123)
  data_split <- rsample::initial_split(df, prop = 0.7)
  train_data <- rsample::training(data_split)
  test_data <- rsample::testing(data_split)
  train_test_list <- list(train_data, test_data)
}
#
extract_train_dataset <- function(train_test_list) {
  train_dataset <- train_test_list[[1]]
}
#
# filter_train_by_boruta_relevant_feature <-
#   function(train_df, relevant_features) {
#     df <- train_df %>%
#       dplyr::select(all_of(
#         c(
#           rownames(relevant_features),
#           "pubmed_gene_symbol",
#           "entrez_id",
#           "cosmic_cgc_status"
#         )
#       ))
#   }

extract_test_dataset <- function(train_test_list) {
  test_dataset <- train_test_list[[2]]
}

# filter_test_by_boruta_relevant_feature <-
#   function(test_df, relevant_features) {
#     df <- test_df %>%
#       dplyr::select(all_of(
#         c(
#           rownames(relevant_features),
#           "pubmed_gene_symbol",
#           "entrez_id",
#           "cosmic_cgc_status"
#         )
#       ))
#   }
#
# build_pre_vif_binom_model <- function(train_df) {
#   df <- train_df %>%
#     dplyr::select(-c(pubmed_gene_symbol, entrez_id))
#   m2 <- glm(cosmic_cgc_status ~ .,
#             data = df,
#             family = "binomial")
# }
#
# extract_vif_variables <- function(model) {
#   vif_variables <- car::vif(model) %>%
#     Filter(function(vif)
#       vif <= 10, .) %>%
#     names()
# }
#
# build_post_vif_binom_model <- function(df, vif_vars) {
#   df <- df %>%
#     dplyr::select(-c(pubmed_gene_symbol, entrez_id)) %>%
#     dplyr::select(all_of(c(vif_vars,"cosmic_cgc_status")))
#   m2 <- glm(cosmic_cgc_status ~ .,
#             data = df,
#             family = "binomial")
# }

#some tests to implement and elastic net model to make target

build_elasticnet_model <- function(scaled_dataset) {
  df_nodepenvar <- scaled_dataset %>%
    dplyr::select(-c(pubmed_gene_symbol, entrez_id, cosmic_cgc_status))
  
  X <- as.matrix(df_nodepenvar)
  y <- scaled_dataset$cosmic_cgc_status
  
  cv_elastic_net <-
    cv.glmnet(X, y, alpha = 0.5, family = "binomial")
}

get_elasticnet_best_lambda_coeffs <- function(elasticnet_model) {
  best_lambda <- elasticnet_model$lambda.min
  elastic_net_coefficients <-
    coef(elasticnet_model, s = best_lambda)
}
