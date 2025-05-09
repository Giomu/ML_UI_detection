################### Second Analysis: Unaware Infection Identification ####################
# This script compares different classification models (k-NN, Random Forest, SVM-RBF) 
# for predicting asymptomatic infections using a labelled synthetic dataset (synth2). 
# The models are trained with 5-fold cross-validation and their performance is evaluated  
# based on multiple metrics. The best-performing model is then used for final predictions 
# on a synthetic unlabelled dataset (synth3).
#
# Steps:
# 1. Load and explore synthetic data
# 2. Define cross-validation settings
# 3. Train k-NN, Random Forest, and SVM models
# 4. Compare model performance using several metrics
# 5. Predict asymptomatic infection status using the best model
#
##########################################################################################

# Load necessary libraries
library(caret)
library(dplyr)
library(foreach)
library(doParallel)
library(MLmetrics)

# Load the labeled synthetic dataset (synth2)
load("data/synth2.rda")
# Ensure the target variable is a factor
synth2$Class <- as.factor(synth2$Class)

# Display basic dataset structure and summary
str(synth2)
summary(synth2)

# Set a global seed
set.seed(1058) 

# Create 5 cross-validation folds to use for all models
cv_folds <- caret::createFolds(synth2$Class, k = 5, returnTrain = TRUE)

# Define training control settings
control <- caret::trainControl(
  method = "cv", number = 5, 
  classProbs = TRUE, 
  summaryFunction = multiClassSummary, 
  verboseIter = TRUE, 
  index = cv_folds
)

# Define a function for hyper parameter tuning and training models
train_model <- function(method, tL) {
  caret::train(Class ~ ., data = synth2, method = method, 
               trControl = control, tuneLength = tL)
}

# Train models with hyperparameter tuning
knn_model <- train_model("knn", tL = 5)
rf_model  <- train_model("rf", tL = 5)
svm_model <- train_model("svmRadial", tL = 5)

# Collect and compare model results
results <- resamples(list(kNN = knn_model, RF = rf_model, SVM = svm_model))

# Select metrics of interest
selected_metrics <- results$values %>% 
  select(contains(c("Accuracy", "Precision", "Recall", "F1")))

# Display performance summary
summary(selected_metrics)

# Visualization of model performance
bwplot(results)
dotplot(results)

# Variable Importance analysis
# Define a function to compute permutation-based feature importance for SVM and k-NN
permute_importance <- function(model, data, target_col, metric = "Accuracy", 
                               n_permutations = 10, parallel = TRUE) {
  set.seed(0306)
  
  y <- data[[target_col]]
  if (!is.factor(y)) y <- as.factor(y)  # Converte il target in fattore se necessario
  X <- data[, colnames(data) != target_col, drop = FALSE]
  
  # Check input data
  stopifnot(is.data.frame(data))
  stopifnot(target_col %in% colnames(data))
  stopifnot(nrow(data) > 10) 
  
  # Compute original accuracy
  original_preds <- predict(model, newdata = X)
  if (is.numeric(original_preds)) {
    original_preds <- ifelse(original_preds > 0.5, levels(y)[2], levels(y)[1])}
  original_acc <- mean(original_preds == y)
  
  # Prepare data frame to store importances
  importances <- data.frame(Feature = colnames(X), Importance = 0)
  
  # Allow parallel computation
  if (parallel) {
    registerDoParallel(cores = detectCores() - 1)}
  
  # Loop on each feature and compute importances
  results <- foreach(feature = colnames(X), .combine = rbind, .packages = "caret") %dopar% {
    acc_drops <- numeric(n_permutations)
    
    for (i in 1:n_permutations) {
      X_permuted <- X
      X_permuted[[feature]] <- sample(na.omit(X_permuted[[feature]]), replace = TRUE)
      
      permuted_preds <- predict(model, newdata = X_permuted)
      permuted_acc <- mean(permuted_preds == y)
      
      acc_drops[i] <- original_acc - permuted_acc}
    data.frame(Feature = feature, Importance = median(acc_drops))}
  
  # End parallel computation
  if (parallel) {
    stopImplicitCluster()}
  
  # Organize results
  results <- results[order(-results$Importance), ]
  
  # Plot importances
  p <- ggplot(results, aes(x = reorder(Feature, Importance), y = Importance)) +
    geom_col(fill = "steelblue") +
    coord_flip() +
    labs(title = "Feature Importance via Permutation",
         x = "Feature",
         y = "Importance (Drop in Accuracy)") +
    theme_minimal()
  print(p)
  
  return(results)
}

# Compute permutation-based importances for SVM-Radial
importance_svm <- permute_importance(svm_model, synth2, "Class", metric = "Accuracy", n_permutations = 10)
print(importance_svm)
# Compute permutation-based importances for k-NN
importance_knn <- permute_importance(knn_model, synth2, "Class", metric = "Accuracy", n_permutations = 30)
print(importance_knn)
# Compute vip based importances for Random Forest
importance_rf <- caret::varImp(rf_model, scale = TRUE)
importance_rf <- importance_rf$importance
importance_rf$Feature <- rownames(importance_rf)
ggplot(importance_rf, aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Feature Importance via Permutation",
       x = "Feature",
       y = "Importance (Drop in Accuracy)") +
  theme_minimal()
print(importance_rf)


# Load synthetic unlabeled data (synth3)
load("data/synth3.rda")

# Ensure feature consistency between synth2 and synth3
common_features <- intersect(names(synth2), names(synth3))
synth3 <- synth3[, common_features, drop = FALSE]

# Make predictions using trained models
synth3$kNN <- predict(knn_model, synth3)
synth3$RF  <- predict(rf_model, synth3)
synth3$SVM <- predict(svm_model, synth3)

# Compare model predictions
table(synth3$kNN)
table(synth3$RF)
table(synth3$SVM)




















