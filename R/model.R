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
# library(h2o)
# library(detectseparation)
# TODO: this is a mess, will deal with this soon

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

# genes_as_index <- function(df) {
#   df <- df %>%
#     mutate(pubmed_gene_symbol = replace_na(pubmed_gene_symbol, "no_data")) %>%
#     distinct(pubmed_gene_symbol, .keep_all = TRUE) %>%
#     column_to_rownames(var = "pubmed_gene_symbol") %>%
#     dplyr::select(-entrez_id)
# }

remove_constants <- function(df) {
  df <- df %>%
    select_if( ~ !all(is.na(.))) %>%
    select_if(function(col)
      length(unique(col)) > 1)
}

scale_dataset <- function(dataset) {
  df_main_var <- dataset %>%
    dplyr::select(all_of(c(
      "cosmic_cgc_status", "pubmed_gene_symbol", "entrez_id"
    )))
  df_others <- dataset %>%
    dplyr::select(-c(cosmic_cgc_status, pubmed_gene_symbol, entrez_id))
  df_others <- scale(df_others)
  
  scaled_df <- cbind(df_main_var, df_others)
}

feature_selection <- function(df) {
  df$cosmic_cgc_status <- as.factor(df$cosmic_cgc_status)
  df <- df %>%
    dplyr::select(-c(pubmed_gene_symbol, entrez_id))
  importances <-
    Boruta(cosmic_cgc_status ~ ., data = df, doTrace = 0) %>%
    TentativeRoughFix() %>%
    attStats() %>%
    dplyr::filter(decision != "Rejected") %>%
    dplyr::select(meanImp, decision) %>%
    arrange(desc(meanImp))
}

filter_by_relevant_feature <- function(df, relevant_features) {
  df <- df %>%
    dplyr::select(all_of(c(
      rownames(relevant_features),
      "pubmed_gene_symbol",
      "entrez_id",
      "cosmic_cgc_status"
    )))
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

build_model <- function(train_df) {
  df <- train_df %>%
    dplyr::select(-c(pubmed_gene_symbol, entrez_id))
  m2 <- glm(cosmic_cgc_status ~ .,
            data = df,
            family = "binomial")
}

#some tests to implement and elastic net model to make target

# plot(model,3)
# library(car)
# vif <- car::vif(model)
# filtered_vif <- Filter(function(vif) vif <= 10, vif)
# names(filtered_vif)

library(glmnet)
df_nodepenvar <- relevant_features_filtered_dataset %>%
  select(-c(pubmed_gene_symbol, entrez_id, cosmic_cgc_status))

X <- as.matrix(df_nodepenvar)
y <- relevant_features_filtered_dataset$cosmic_cgc_status

elastic_net_model <- glmnet(X, y, family = "binomial", alpha = 0.5)
cv_elastic_net <- cv.glmnet(X, y, alpha = 0.5, family = "binomial")

best_lambda <- cv_elastic_net$lambda.min
elastic_net_coefficients <- coef(cv_elastic_net, s = best_lambda)
