###################### Second Analysis: Unaware Infection Prediction #######################
# This script compares different classification models (k-NN, Random Forest, SVM-Radial) 
# for predicting asymptomatic infections using a labelled synthetic dataset (synth2). The models 
# are trained with 5-fold cross-validation and their performance is evaluated based on 
# multiple metrics. The best-performing model is then used for final predictions 
# on an unlabelled dataset (synth3).
#
# Steps:
# 1. Load and explore synthetic data
# 2. Define cross-validation settings
# 3. Train k-NN, Random Forest, and SVM models
# 4. Compare model performance using key metrics
# 5. Predict asymptomatic infection status using the best model
#
##########################################################################################

# Load necessary libraries
library(caret)
library(dplyr)

# Load the labeled synthetic dataset (synth2)
data("synth2")

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

# Load synthetic unlabeled data (synth3)
data("synth3")

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




















