library(tidymodels)
library(rpart.plot)
library(nnet)
library(caret)
library(randomForest)
library(Boruta)

# TODO: this is a mess, will deal with this soon

tar_load(entrez_pubmed_merged)
tar_load(annotated_clinicaltrials_data)
tar_load(merged_cosmic_data)
tar_load(formatted_oncokb)
tar_load(merged_cosmic_data)
tar_load(pivot_wider_depmap_crispr)
tar_load(pivot_wider_depmap_rnai)

list_df = list(
  entrez_pubmed_merged,
  annotated_clinicaltrials_data,
  formatted_oncokb,
  merged_cosmic_data,
  pivot_wider_depmap_crispr,
  pivot_wider_depmap_rnai
)
all_dfs <- list_df %>% reduce(full_join, by = 'entrez_id')

df <- all_dfs %>%
  mutate(across(where(is.numeric), ~ replace_na(., 0))) %>%
  dplyr::select(
    -c(
      cosmic_gene,
      oncokb_gene,
      depmap_rnai_gene_name,
      depmap_crispr_gene_name,
      cosmic_gene_symbol,
      clinicaltrials_gene_symbol,
    )
  ) %>%
  dplyr::filter(!is.na(entrez_id)) %>%
  mutate(across(where(is.logical), as.character)) %>%
  mutate(across(all_of(
    c(
      "oncokb_highestResistanceLevel",
      "oncokb_highestSensitiveLevel",
      "cosmic_is_cgc",
      "cosmic_HALLMARK",
      "oncokb_oncogene",
      "oncokb_tsg",
      "cosmic_cgc_status",
      "pubmed_gene_symbol"
    )
  ),
  ~ replace_na(., "no_data"))) %>%
  distinct(pubmed_gene_symbol, .keep_all = TRUE) %>%
  column_to_rownames(var = "pubmed_gene_symbol") %>%
  select(-entrez_id) %>%
  select_if(~ !all(is.na(.))) %>%
  #mutate(across(where(~ !is.numeric(.)), ~ as.numeric(as.factor(.)))) %>%
  select_if(function(col) length(unique(col)) > 1) #remove constants

#mutate(cosmic_cgc_status = as.factor(cosmic_cgc_status)) %>%

df <- as.data.frame(scale(df))

df$cosmic_cgc_status <- as.factor(df$cosmic_cgc_status)

set.seed(123)

data_split <- initial_split(df, prop = 0.7)
train_data <- training(data_split)
test_data <- testing(data_split)

model <- rpart(cosmic_cgc_status ~ ., data = train_data, method = "class")

boruta_output <- Boruta(cosmic_cgc_status ~ ., data = train_data, doTrace = 0)
rough_fix_mod <- TentativeRoughFix(boruta_output)
boruta_signif <- getSelectedAttributes(rough_fix_mod)
importances <- attStats(rough_fix_mod)
importances <- importances[importances$decision != "Rejected", c("meanImp", "decision")]
importances[order(-importances$meanImp), ]
plot(boruta_output, ces.axis = 0.7, las = 2, xlab = "", main = "Feature importance")

pred_class <- predict(model, newdata = test_data, type = "class")

pred_prob <- predict(model, newdata = test_data, type = "prob")

confusionMatrix(test_data$cosmic_cgc_status, pred_class)



tree_spec <- decision_tree(tree_depth = 20) %>%
  set_engine("rpart") %>%
  set_mode("regression")

tree_fit <- tree_spec %>%
  fit(cosmic_cgc_status ~ ., data = train_data)

predictions <- tree_fit %>%
  predict(test_data) %>%
  pull(.pred)

metrics <- metric_set(rmse, rsq)
model_performance <- test_data %>%
  mutate(predictions = predictions) %>%
  metrics(truth = cosmic_cgc_status, estimate = predictions)

print(model_performance)

rpart.plot(tree_fit$fit, type = 4, extra = 101, under = TRUE, cex = 0.8, box.palette = "auto")
rpart.plot(tree_fit$fit, type = 4, extra = 101, under = TRUE, cex = 0.8, box.palette = "auto")
