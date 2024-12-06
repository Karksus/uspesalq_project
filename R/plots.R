library(ggplot2)
library(pROC)

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

make_train_lambda_deviance_plot <-
  function(train_elasticnet_model) {
    jpeg(
      "plots/train_lambda_deviance_plot.jpg",
      width = 1700,
      height = 1200,
      res = 300
    )
    plot(train_elasticnet_model, xvar = "lambda", label = TRUE)
    dev.off()
    
  }

make_test_lambda_deviance_plot <- function(test_elasticnet_model) {
  jpeg(
    "plots/test_lambda_deviance_plot.jpg",
    width = 1700,
    height = 1200,
    res = 300
  )
  plot(test_elasticnet_model, xvar = "lambda", label = TRUE)
  dev.off()
  
}

make_train_lambda_coeffs_plot <- function(train_elasticnet_model) {
  jpeg(
    "plots/train_lambda_coeffs_plot.jpg",
    width = 1500,
    height = 1400,
    res = 300
  )
  plot(train_elasticnet_model$glmnet.fit, "lambda")
  dev.off()
}

make_test_lambda_coeffs_plot <- function(test_elasticnet_model) {
  jpeg(
    "plots/test_lambda_coeffs_plot.jpg",
    width = 1500,
    height = 1400,
    res = 300
  )
  plot(test_elasticnet_model$glmnet.fit, "lambda")
  dev.off()
}

make_train_top10_coeffs_plot <- function(train_lambda_coeffs) {
  coef_optimal <- train_lambda_coeffs[[2]]
  coef_data <- data.frame(Feature = rownames(coef_optimal),
                          Coefficient = as.vector(coef_optimal))
  coef_df <- coef_data[order(-abs(coef_data$Coefficient)), ][1:10, ]
  
  train_top10_coeffs_plot <-
    ggplot(coef_df, aes(x = reorder(Feature, Coefficient), y = Coefficient)) +
    geom_point(color = "blue", size = 3) +
    coord_flip() +
    labs(title = "Features by coeffcient - Top 10 (training set)",
         x = "Feature", y = "Coefficient") +
    theme_minimal()
  ggsave(
    filename = "plots/train_top10_coeffs_plot.jpg",
    plot = train_top10_coeffs_plot,
    dpi = 300,
    height = 2,
    width = 8,
    device = "jpeg"
  )
  
}

make_train_top30_coeffs_plot <- function(train_lambda_coeffs) {
  coef_optimal <- train_lambda_coeffs[[2]]
  coef_data <- data.frame(Feature = rownames(coef_optimal),
                          Coefficient = as.vector(coef_optimal))
  coef_df <- coef_data[order(-abs(coef_data$Coefficient)), ][1:30, ]
  
  train_top30_coeffs_plot <-
    ggplot(coef_df, aes(x = reorder(Feature, Coefficient), y = Coefficient)) +
    geom_point(color = "blue", size = 3) +
    coord_flip() +
    labs(title = "Features by coeffcient - Top 30 (training set)",
         x = "Feature", y = "Coefficient") +
    theme_minimal()
  ggsave(
    filename = "plots/train_top30_coeffs_plot.jpg",
    plot = train_top30_coeffs_plot,
    dpi = 300,
    height = 4,
    width = 8,
    device = "jpeg"
  )
}

make_test_top10_coeffs_plot <- function(test_lambda_coeffs) {
  coef_optimal <- test_lambda_coeffs[[2]]
  coef_data <- data.frame(Feature = rownames(coef_optimal),
                          Coefficient = as.vector(coef_optimal))
  coef_df <- coef_data[order(-abs(coef_data$Coefficient)), ][1:10, ]
  
  test_top10_coeffs_plot <-
    ggplot(coef_df, aes(x = reorder(Feature, Coefficient), y = Coefficient)) +
    geom_point(color = "blue", size = 3) +
    coord_flip() +
    labs(title = "Features by coeffcient - Top 10 (test set)",
         x = "Feature", y = "Coefficient") +
    theme_minimal()
  
  ggsave(
    filename = "plots/test_top10_coeffs_plot.jpg",
    plot = test_top10_coeffs_plot,
    dpi = 300,
    height = 2,
    width = 8,
    device = "jpeg"
  )
  
}

make_test_top30_coeffs_plot <- function(test_lambda_coeffs) {
  coef_optimal <- test_lambda_coeffs[[2]]
  coef_data <- data.frame(Feature = rownames(coef_optimal),
                          Coefficient = as.vector(coef_optimal))
  coef_df <- coef_data[order(-abs(coef_data$Coefficient)), ][1:30, ]
  
  test_top30_coeffs_plot <-
    ggplot(coef_df, aes(x = reorder(Feature, Coefficient), y = Coefficient)) +
    geom_point(color = "blue", size = 3) +
    coord_flip() +
    labs(title = "Features by coeffcient - Top 30 (test set)",
         x = "Feature", y = "Coefficient") +
    theme_minimal()
  ggsave(
    filename = "plots/test_top30_coeffs_plot.jpg",
    plot = test_top30_coeffs_plot,
    dpi = 300,
    height = 4,
    width = 8,
    device = "jpeg"
  )
}

###########################FULL DATASET#########################

make_roc_analisys_full_dataset <-
  function(elasticnet_model_prediction) {
    roc_data <-
      roc(elasticnet_model_prediction$cosmic_cgc_status,
          elasticnet_model_prediction$s1)
  }


make_auc_plot_full_dataset <- function(roc_data) {
  auc_value <- auc(roc_data)
  jpeg(
    "plots/roc_full_plot.jpg",
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


make_full_lambda_deviance_plot <-
  function(elasticnet_model) {
    jpeg(
      "plots/full_lambda_deviance_plot.jpg",
      width = 1700,
      height = 1200,
      res = 300
    )
    plot(elasticnet_model, xvar = "lambda", label = TRUE)
    dev.off()
    
  }

make_full_lambda_coeffs_plot <- function(elasticnet_model) {
  jpeg(
    "plots/full_lambda_coeffs_plot.jpg",
    width = 1500,
    height = 1400,
    res = 300
  )
  plot(elasticnet_model$glmnet.fit, "lambda")
  dev.off()
}

make_full_top10_coeffs_plot <- function(lambda_coeffs) {
  coef_optimal <- lambda_coeffs[[2]]
  coef_data <- data.frame(Feature = rownames(coef_optimal),
                          Coefficient = as.vector(coef_optimal))
  coef_df <- coef_data[order(-abs(coef_data$Coefficient)), ][1:10, ]
  
  top10_coeffs_plot <-
    ggplot(coef_df, aes(x = reorder(Feature, Coefficient), y = Coefficient)) +
    geom_point(color = "blue", size = 3) +
    coord_flip() +
    labs(title = "Features by coeffcient - Top 10 (full set)",
         x = "Feature", y = "Coefficient") +
    theme_minimal()
  ggsave(
    filename = "plots/full_top10_coeffs_plot.jpg",
    plot = top10_coeffs_plot,
    dpi = 300,
    height = 2,
    width = 8,
    device = "jpeg"
  )
}


make_full_top30_coeffs_plot <- function(lambda_coeffs) {
  coef_optimal <- lambda_coeffs[[2]]
  coef_data <- data.frame(Feature = rownames(coef_optimal),
                          Coefficient = as.vector(coef_optimal))
  coef_df <- coef_data[order(-abs(coef_data$Coefficient)), ][1:30, ]
  
  top30_coeffs_plot <-
    ggplot(coef_df, aes(x = reorder(Feature, Coefficient), y = Coefficient)) +
    geom_point(color = "blue", size = 3) +
    coord_flip() +
    labs(title = "Features by coeffcient - Top 30 (full set)",
         x = "Feature", y = "Coefficient") +
    theme_minimal()
  ggsave(
    filename = "plots/full_top30_coeffs_plot.jpg",
    plot = top30_coeffs_plot,
    dpi = 300,
    height = 4,
    width = 8,
    device = "jpeg"
  )
}
