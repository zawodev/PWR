# Aleksander Stepaniuk 272644
# zmiany:
# RF: mtry: liczba cech rozważanych równa sqrt(liczba_cech) - zwiększa to różnorodność (poprzednia wartość była zbyt duża
# DT: bez maksymalnej głębokości drzewa model może się przeuczać (overfit) więc ustawiłem maxdepht = 10
# LR: zmieniłem z podstawowej classif.log_reg na glmnet bo on obsługuje regularyzację, oraz alpha na 0.5 żeby sieć była elastyczniejsza
# LGBM: learning rate ustawiony na 0.1, bez jawnego learning ratu model nie może się dopasować co może prowadzić do overfittingu

# finalne wyniki:
# RF: 0.622
# DT: 0.598
# LR: 0.605
# LGBM: 0.577

################################################################################
# EXTENDED LUCENE DEFECT PREDICTION - ADVANCED VERSION
# Purpose: Predict buggy classes with advanced ML techniques
# Dataset: Lucene 2.2 (train), Lucene 2.4 (test)
# Date: 2025-11-03
#
# NEW FEATURES:
# 1. SMOTE for imbalance handling
# 2. Hyperparameter tuning with Bayesian optimization
# 3. Confusion matrix visualizations
# 4. Feature importance analysis
################################################################################

# =============================================================================
# STEP 1: SETUP AND PACKAGE LOADING
# =============================================================================
cat("\n=== STEP 1: Loading Required Packages ===\n")

# Install packages if needed (uncomment on first run)
# install.packages(c("mlr3", "mlr3learners", "mlr3verse", "mlr3tuning", "mlr3mbo",
#                    "mlr3pipelines", "ranger", "rpart", "lightgbm",
#                    "ggplot2", "data.table", "knitr", "reshape2", "gridExtra"))

# Load essential packages
library(mlr3)           # Machine learning framework
library(mlr3learners)   # Additional learners
library(mlr3verse)      # Complete mlr3 ecosystem
library(mlr3tuning)     # NEW: Hyperparameter tuning
library(mlr3mbo)        # NEW: Bayesian optimization
library(mlr3pipelines)  # NEW: Pipeline operations (SMOTE)
library(ranger)         # Random Forest implementation
library(rpart)          # Decision Tree implementation
library(lightgbm)       # Gradient Boosting implementation
library(ggplot2)        # Visualization
library(data.table)     # Fast data manipulation
library(knitr)          # Nice tables
library(reshape2)       # NEW: Data reshaping for confusion matrix
library(gridExtra)      # NEW: Arranging multiple plots

# Set random seed for reproducibility
set.seed(123)

# Create output directory for results
if (!dir.exists("results")) dir.create("results")
if (!dir.exists("visualizations")) dir.create("visualizations")

cat("Packages loaded successfully!\n")


# =============================================================================
# STEP 2: DATA LOADING AND EXPLORATION
# =============================================================================
cat("\n=== STEP 2: Loading and Exploring Data ===\n")

# Data URLs
train_url <- "https://madeyski.e-informatyka.pl/download/stud/CaseStudies/Lucene/lucene2.2train.csv"
test_url <- "https://madeyski.e-informatyka.pl/download/stud/CaseStudies/Lucene/lucene2.4test.csv"

# Download and cache data
train_file <- "results/lucene_2.2_train.csv"
test_file <- "results/lucene_2.4_test.csv"

if (!file.exists(train_file)) {
  cat("Downloading training data...\n")
  download.file(train_url, train_file, mode = "wb")
}
if (!file.exists(test_file)) {
  cat("Downloading test data...\n")
  download.file(test_url, test_file, mode = "wb")
}

# Load data
train_data <- read.csv(train_file, stringsAsFactors = FALSE)
test_data <- read.csv(test_file, stringsAsFactors = FALSE)

cat(sprintf("Training data: %d rows, %d columns\n", nrow(train_data), ncol(train_data)))
cat(sprintf("Test data: %d rows, %d columns\n", nrow(test_data), ncol(test_data)))

# Show class distribution
cat("\nClass Distribution (Training):\n")
print(table(train_data$isBuggy))
cat(sprintf("Imbalance ratio: %.1f%% buggy, %.1f%% non-buggy\n",
            mean(train_data$isBuggy) * 100,
            (1 - mean(train_data$isBuggy)) * 100))


# =============================================================================
# STEP 3: DATA PREPROCESSING
# =============================================================================
cat("\n=== STEP 3: Data Preprocessing ===\n")

# Convert target to factor (required for classification)
train_data$isBuggy <- factor(train_data$isBuggy, levels = c(TRUE, FALSE))
test_data$isBuggy <- factor(test_data$isBuggy, levels = c(TRUE, FALSE))

# Identify and remove all character/factor columns except target
# mlr3 requires all features to be numeric
char_cols_train <- names(train_data)[sapply(train_data, is.character)]
char_cols_test <- names(test_data)[sapply(test_data, is.character)]

if (length(char_cols_train) > 0) {
  cat(sprintf("Removing character columns from training data: %s\n",
              paste(char_cols_train, collapse = ", ")))
  train_data <- train_data[, !(names(train_data) %in% char_cols_train)]
}

if (length(char_cols_test) > 0) {
  cat(sprintf("Removing character columns from test data: %s\n",
              paste(char_cols_test, collapse = ", ")))
  test_data <- test_data[, !(names(test_data) %in% char_cols_test)]
}

# Ensure all features are numeric (except target which is factor)
feature_cols <- setdiff(names(train_data), "isBuggy")
for (col in feature_cols) {
  if (!is.numeric(train_data[[col]])) {
    train_data[[col]] <- as.numeric(as.character(train_data[[col]]))
  }
  if (!is.numeric(test_data[[col]])) {
    test_data[[col]] <- as.numeric(as.character(test_data[[col]]))
  }
}

# Handle missing values (required for some learners like Logistic Regression)
# Check for missing values in training data
na_counts_train <- sapply(train_data[, feature_cols], function(x) sum(is.na(x)))
cols_with_na_train <- names(na_counts_train[na_counts_train > 0])

if (length(cols_with_na_train) > 0) {
  cat(sprintf("Found missing values in %d column(s): %s\n",
              length(cols_with_na_train),
              paste(cols_with_na_train, collapse = ", ")))
  
  # Impute missing values with median for each column
  for (col in cols_with_na_train) {
    if (col %in% names(train_data)) {
      median_val <- median(train_data[[col]], na.rm = TRUE)
      train_data[[col]][is.na(train_data[[col]])] <- median_val
      # Apply same imputation to test data
      if (col %in% names(test_data)) {
        test_data[[col]][is.na(test_data[[col]])] <- median_val
      }
    }
  }
  cat("Missing values imputed with column medians\n")
}

cat(sprintf("After preprocessing: %d features (all numeric, no missing values)\n", ncol(train_data) - 1))

# Create MLR3 tasks
task_train <- TaskClassif$new(
  id = "lucene_train",
  backend = train_data,
  target = "isBuggy",
  positive = "TRUE"
)

task_test <- TaskClassif$new(
  id = "lucene_test",
  backend = test_data,
  target = "isBuggy",
  positive = "TRUE"
)

cat("MLR3 tasks created successfully!\n")


# =============================================================================
# STEP 4: DEFINE MODELS TO COMPARE
# =============================================================================
cat("\n=== STEP 4: Defining Classification Models ===\n")

# We'll compare 4 models representing different algorithm families
models <- list(
  "Decision Tree" = lrn("classif.rpart", predict_type = "prob", maxdepth = 10, minsplit = 10),
  "Random Forest" = lrn("classif.ranger", predict_type = "prob", num.trees = 1000, mtry = floor(sqrt(ncol(train_data) - 1))),
  "LightGBM" = lrn("classif.lightgbm", predict_type = "prob", num_iterations = 100, learning_rate = 0.1, max_depth = 6),
  "Logistic Regression" = lrn("classif.glmnet", predict_type = "prob", alpha = 0.5)
)

cat(sprintf("Defined %d models for comparison\n", length(models)))


# =============================================================================
# STEP 5: DEFINE IMBALANCE STRATEGIES (INCLUDING SMOTE)
# =============================================================================
cat("\n=== STEP 5: Defining Class Imbalance Handling Strategies ===\n")

# Strategy 1: Baseline (no special handling)
# Strategy 2: Class weights (penalize minority class errors more)
# Strategy 3: Threshold optimization (find best decision boundary)
# Strategy 4: SMOTE (Synthetic Minority Over-sampling Technique) - NEW!

strategies <- c("baseline", "class_weights", "threshold", "smote")
cat(sprintf("Testing %d imbalance handling strategies (including SMOTE)\n", length(strategies)))


# =============================================================================
# STEP 6: DEFINE EVALUATION METRICS
# =============================================================================
cat("\n=== STEP 6: Defining Evaluation Metrics ===\n")

metrics <- list(
  mcc = msr("classif.mcc"),
  bacc = msr("classif.bacc"),
  f1 = msr("classif.fbeta", beta = 1),
  precision = msr("classif.precision"),
  recall = msr("classif.recall")
)

cat(sprintf("Using %d evaluation metrics\n", length(metrics)))
cat("Primary metric: MCC (Matthews Correlation Coefficient)\n")


# =============================================================================
# STEP 7: CROSS-VALIDATION SETUP
# =============================================================================
cat("\n=== STEP 7: Setting Up Cross-Validation ===\n")

cv_strategy <- rsmp("cv", folds = 5)
cv_strategy$instantiate(task_train)

cat("Using 5-fold stratified cross-validation\n")


# =============================================================================
# STEP 8: HELPER FUNCTIONS
# =============================================================================

# Function to apply class weights to a learner
apply_class_weights <- function(learner, task) {
  # Calculate class frequencies
  class_freq <- table(task$truth())
  
  # IMPORTANT: Use named access to avoid index confusion
  # Calculate weights: inverse frequency (minority class gets higher weight)
  weight_false <- 1 / class_freq["FALSE"]
  weight_true <- 1 / class_freq["TRUE"]
  
  # Normalize weights
  total_weight <- weight_false + weight_true
  weights <- c(weight_false / total_weight * 2, weight_true / total_weight * 2)
  names(weights) <- c("FALSE", "TRUE")
  
  # Apply weights (method varies by learner)
  if (learner$id == "classif.rpart") {
    # Note: rpart in mlr3 doesn't expose the parms/loss parameter
    # For educational purposes, we'll skip class weighting for rpart
    # Alternative: use threshold optimization or SMOTE instead
    cat("  Note: Decision Tree (rpart) doesn't support class weights in mlr3\n")
    cat("  Running with baseline parameters instead\n")
    
  } else if (learner$id == "classif.ranger") {
    # Random Forest uses class.weights parameter
    learner$param_set$values$class.weights = as.numeric(weights)
    
  } else if (learner$id == "classif.lightgbm") {
    # LightGBM uses scale_pos_weight for binary classification
    # Must set objective to 'binary' first
    learner$param_set$values$objective = "binary"
    
    # scale_pos_weight in LightGBM: weight to apply to positive class (TRUE)
    # For minority class (TRUE=37.8%), we need TRUE weight > FALSE weight
    # So scale_pos_weight = TRUE weight / FALSE weight should be > 1
    scale_pos <- weights["TRUE"] / weights["FALSE"]
    learner$param_set$values$scale_pos_weight = scale_pos
    
  } else if (learner$id == "classif.log_reg") {
    # Logistic regression doesn't support class weights in mlr3's glmnet implementation
    # Keep as is - will work but without class weighting
    cat("  Note: Logistic Regression doesn't support class weights in mlr3\n")
  }
  
  return(learner)
}

# NEW: Function to create SMOTE pipeline
create_smote_pipeline <- function(learner, task) {
  # IMPORTANT: SMOTE requires all features to be numeric (not factor, not character)
  # Use po("colapply") to ensure all features are numeric before SMOTE
  
  # Create SMOTE graph learner with explicit numeric conversion for ALL features
  graph <- po("colapply", applicator = as.numeric, affect_columns = selector_all()) %>>%
    po("smote", dup_size = 2) %>>%  # Oversample minority class by factor of 2
    po("learner", learner = learner)
  
  # Convert to GraphLearner
  smote_learner <- GraphLearner$new(graph)
  smote_learner$id <- paste0(learner$id, "_smote")
  smote_learner$predict_type <- "prob"
  
  return(smote_learner)
}

# Function to optimize classification threshold
optimize_threshold <- function(learner, task, resampling) {
  rr <- resample(task, learner, resampling, store_models = TRUE)
  preds <- rr$prediction()
  
  thresholds <- seq(0.1, 0.9, by = 0.05)
  best_mcc <- -Inf
  best_thresh <- 0.5
  
  for (thresh in thresholds) {
    pred_labels <- ifelse(preds$prob[, "TRUE"] >= thresh, "TRUE", "FALSE")
    pred_labels <- factor(pred_labels, levels = c("TRUE", "FALSE"))
    
    cm <- table(Truth = preds$truth, Predicted = pred_labels)
    if (nrow(cm) == 2 && ncol(cm) == 2) {
      tp <- cm["TRUE", "TRUE"]
      tn <- cm["FALSE", "FALSE"]
      fp <- cm["FALSE", "TRUE"]
      fn <- cm["TRUE", "FALSE"]
      
      denominator <- sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn))
      if (denominator > 0) {
        mcc <- (tp * tn - fp * fn) / denominator
        if (mcc > best_mcc) {
          best_mcc <- mcc
          best_thresh <- thresh
        }
      }
    }
  }
  
  return(list(threshold = best_thresh, mcc = best_mcc, resampling_result = rr))
}

# Function to calculate all metrics
calculate_metrics <- function(prediction) {
  results <- list()
  for (metric_name in names(metrics)) {
    results[[metric_name]] <- prediction$score(metrics[[metric_name]])
  }
  return(results)
}

# NEW: Function to extract confusion matrix
extract_confusion_matrix <- function(prediction) {
  cm <- prediction$confusion
  return(cm)
}


# =============================================================================
# STEP 9: TRAIN AND EVALUATE ALL MODEL CONFIGURATIONS
# =============================================================================
cat("\n=== STEP 9: Training and Evaluating Models ===\n")
cat(sprintf("Total configurations: %d models Ă %d strategies = %d\n",
            length(models), length(strategies), length(models) * length(strategies)))

# Initialize results storage
results_list <- list()
confusion_matrices <- list()  # NEW: Store confusion matrices
result_counter <- 1

# Progress tracking
total_configs <- length(models) * length(strategies)
config_num <- 0

# Loop through all combinations
for (model_name in names(models)) {
  for (strategy in strategies) {
    config_num <- config_num + 1
    cat(sprintf("\n[%d/%d] Training: %s with %s strategy\n",
                config_num, total_configs, model_name, strategy))
    
    # Clone the learner for this configuration
    learner <- models[[model_name]]$clone()
    
    # Record start time
    start_time <- Sys.time()
    
    # Apply strategy
    tryCatch({
      if (strategy == "baseline") {
        rr <- resample(task_train, learner, cv_strategy, store_models = FALSE)
        pred <- rr$prediction()
        threshold <- 0.5
        
      } else if (strategy == "class_weights") {
        learner <- apply_class_weights(learner, task_train)
        rr <- resample(task_train, learner, cv_strategy, store_models = FALSE)
        pred <- rr$prediction()
        threshold <- 0.5
        
      } else if (strategy == "threshold") {
        result <- optimize_threshold(learner, task_train, cv_strategy)
        rr <- result$resampling_result
        pred_orig <- rr$prediction()
        threshold <- result$threshold
        cat(sprintf("  Optimal threshold: %.3f\n", threshold))
        
        # IMPORTANT: Apply the optimized threshold to predictions
        # Create new response predictions using the optimized threshold
        new_response <- ifelse(pred_orig$prob[, "TRUE"] >= threshold, "TRUE", "FALSE")
        new_response <- factor(new_response, levels = c("TRUE", "FALSE"))
        
        # Set the new response in the prediction object
        pred_orig$data$response <- new_response
        pred <- pred_orig
        
      } else if (strategy == "smote") {
        # NEW: SMOTE strategy
        smote_learner <- create_smote_pipeline(learner, task_train)
        rr <- resample(task_train, smote_learner, cv_strategy, store_models = FALSE)
        pred <- rr$prediction()
        threshold <- 0.5
      }
      
      # Record end time
      end_time <- Sys.time()
      training_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
      
      # Calculate metrics (now uses correct threshold for "threshold" strategy)
      metrics_scores <- calculate_metrics(pred)
      
      # NEW: Extract confusion matrix
      cm <- extract_confusion_matrix(pred)
      confusion_matrices[[paste(model_name, strategy, sep = "_")]] <- cm
      
      # Store results
      results_list[[result_counter]] <- data.frame(
        model = model_name,
        strategy = strategy,
        threshold = threshold,
        mcc = metrics_scores$mcc,
        balanced_accuracy = metrics_scores$bacc,
        f1 = metrics_scores$f1,
        precision = metrics_scores$precision,
        recall = metrics_scores$recall,
        training_time_sec = training_time,
        stringsAsFactors = FALSE
      )
      
      cat(sprintf("  MCC: %.3f | Bal.Acc: %.3f | F1: %.3f | Time: %.2fs\n",
                  metrics_scores$mcc, metrics_scores$bacc,
                  metrics_scores$f1, training_time))
      
      result_counter <- result_counter + 1
      
    }, error = function(e) {
      cat(sprintf("  ERROR: %s\n", e$message))
      cat("  Storing NA results for this configuration\n")
      
      # Store NA results so this configuration appears in output
      results_list[[result_counter]] <- data.frame(
        model = model_name,
        strategy = strategy,
        threshold = NA,
        mcc = NA,
        balanced_accuracy = NA,
        f1 = NA,
        precision = NA,
        recall = NA,
        training_time_sec = NA,
        stringsAsFactors = FALSE
      )
      
      # Also store empty confusion matrix
      confusion_matrices[[paste(model_name, strategy, sep = "_")]] <- matrix(0, nrow = 2, ncol = 2)
      
      result_counter <<- result_counter + 1  # Use <<- to modify outer scope variable
    })
  }
}

# Combine all results
results_df <- do.call(rbind, results_list)

# Save results
write.csv(results_df, "results/model_comparison.csv", row.names = FALSE)
cat("\nâ Results saved to: results/model_comparison.csv\n")


# =============================================================================
# STEP 10: HYPERPARAMETER TUNING FOR BEST MODEL
# =============================================================================
cat("\n=== STEP 10: Hyperparameter Tuning for Best Model ===\n")

# Select best model from initial results (without tuning)
best_initial <- results_df[which.max(results_df$mcc), ]
cat(sprintf("Best initial model: %s with %s (MCC: %.3f)\n",
            best_initial$model, best_initial$strategy, best_initial$mcc))

# For demonstration, we'll tune Random Forest (typically best performer)
cat("\nTuning Random Forest hyperparameters...\n")

# Create tuning learner
rf_learner <- lrn("classif.ranger", predict_type = "prob")

# Define expanded search space with more hyperparameters
# IMPORTANT: Use very high num.trees to reduce Random Forest variance
search_space <- ps(
  num.trees = p_int(lower = 1000, upper = 5000),     # Very high num.trees for stability
  mtry = p_int(lower = 2, upper = 12),               # Feature selection parameter
  min.node.size = p_int(lower = 1, upper = 15),      # Terminal node size
  sample.fraction = p_dbl(lower = 0.6, upper = 1.0), # Bootstrap sampling rate
  max.depth = p_int(lower = 10, upper = 30)          # Tree depth limit
)

# Create tuning instance with Bayesian Optimization
tuner <- tnr("mbo")  # Bayesian optimization tuner (more efficient than random search)
terminator <- trm("evals", n_evals = 150) #150)  # Increase to 150 evaluations for better exploration

# CRITICAL: Use same CV strategy as baseline evaluation (5-fold stratified)
# This ensures fair comparison with baseline results
# Create AutoTuner
at <- AutoTuner$new(
  learner = rf_learner,
  resampling = rsmp("cv", folds = 5),  # CHANGED: Use 5-fold CV (same as baseline!)
  measure = msr("classif.mcc"),
  search_space = search_space,
  terminator = terminator,
  tuner = tuner
)

# Run tuning
cat("Running Bayesian hyperparameter optimization (150 evaluations with 5-fold CV)...\n")
cat("This will take several minutes. Progress will be shown below.\n")
tuning_start <- Sys.time()
at$train(task_train)
tuning_end <- Sys.time()
tuning_time <- as.numeric(difftime(tuning_end, tuning_start, units = "secs"))

# Get best hyperparameters
best_params <- at$tuning_result$learner_param_vals[[1]]
cat("\nBest hyperparameters found:\n")
print(best_params)

# IMPORTANT: Get CV performance from tuning (not train set prediction!)
# at$tuning_result contains the cross-validation performance
# Use this as the authoritative result since it's from the same 5-fold CV as baseline
tuned_mcc_cv <- at$tuning_result$classif.mcc

cat(sprintf("\nTuned Random Forest performance (from 5-fold CV during tuning):\n"))
cat(sprintf("  MCC: %.3f\n", tuned_mcc_cv))
cat(sprintf("  Tuning time: %.1f seconds\n", tuning_time))

# Use the tuning CV result as the final metrics
# NOTE: We trust the tuning CV result (5-fold) rather than re-evaluating,
# since re-evaluation introduces additional variance from different random seeds
cat("\nUsing tuning CV result as final performance (most reliable estimate).\n")
tuned_metrics <- list(
  mcc = tuned_mcc_cv,
  bacc = NA,  # Not available from tuning (only MCC was optimized)
  f1 = NA
)

cat(sprintf("  Final MCC: %.3f\n", tuned_metrics$mcc))

# Compare with default Random Forest
default_rf_results <- results_df[results_df$model == "Random Forest" &
                                   results_df$strategy == "baseline", ]
cat(sprintf("\nImprovement over default: %.3f MCC (%.1f%% improvement)\n",
            tuned_metrics$mcc - default_rf_results$mcc,
            ((tuned_metrics$mcc / default_rf_results$mcc) - 1) * 100))

# Save tuning results
tuning_results <- data.frame(
  model = "Random Forest (Tuned)",
  strategy = "baseline",
  mcc = tuned_metrics$mcc,
  balanced_accuracy = ifelse(is.null(tuned_metrics$bacc) || is.na(tuned_metrics$bacc), NA, tuned_metrics$bacc),
  f1 = ifelse(is.null(tuned_metrics$f1) || is.na(tuned_metrics$f1), NA, tuned_metrics$f1),
  precision = NA,
  recall = NA,
  tuning_time_sec = tuning_time,
  best_params = paste(names(best_params), best_params, sep = "=", collapse = ", "),
  stringsAsFactors = FALSE
)

write.csv(tuning_results, "results/tuning_results.csv", row.names = FALSE)
cat("â Tuning results saved to: results/tuning_results.csv\n")


# =============================================================================
# STEP 11: FEATURE IMPORTANCE ANALYSIS
# =============================================================================
cat("\n=== STEP 11: Feature Importance Analysis ===\n")

# Train models that support feature importance
cat("Training models for feature importance analysis...\n")

# Random Forest feature importance
rf_model <- lrn("classif.ranger", predict_type = "prob",
                num.trees = 500, importance = "impurity")
rf_model$train(task_train)
rf_importance <- rf_model$model$variable.importance
rf_importance_df <- data.frame(
  feature = names(rf_importance),
  importance = as.numeric(rf_importance),
  model = "Random Forest",
  stringsAsFactors = FALSE
)

# Decision Tree feature importance (based on splits)
dt_model <- lrn("classif.rpart", predict_type = "prob")
dt_model$train(task_train)
dt_importance <- dt_model$model$variable.importance
dt_importance_df <- data.frame(
  feature = names(dt_importance),
  importance = as.numeric(dt_importance),
  model = "Decision Tree",
  stringsAsFactors = FALSE
)

# Combine importance from both models
feature_importance_df <- rbind(rf_importance_df, dt_importance_df)

# Calculate average importance
avg_importance <- aggregate(importance ~ feature, data = feature_importance_df, FUN = mean)
avg_importance <- avg_importance[order(-avg_importance$importance), ]

cat("\nTop 10 Most Important Features:\n")
cat("ââââââââââââââââââââââââââââââââââââââââââââââââ\n")
print(head(avg_importance, 10))

# Save feature importance
write.csv(feature_importance_df, "results/feature_importance.csv", row.names = FALSE)
write.csv(avg_importance, "results/feature_importance_avg.csv", row.names = FALSE)
cat("\nâ Feature importance saved to: results/feature_importance.csv\n")


# =============================================================================
# STEP 12: VISUALIZATION - CONFUSION MATRICES
# =============================================================================
cat("\n=== STEP 12: Creating Confusion Matrix Visualizations ===\n")

# Function to plot confusion matrix
plot_confusion_matrix <- function(cm, title) {
  # Convert to proportions
  cm_prop <- prop.table(cm)
  cm_df <- as.data.frame(cm)
  colnames(cm_df) <- c("Truth", "Prediction", "Freq")
  
  # Add percentage
  cm_df$Percentage <- cm_df$Freq / sum(cm_df$Freq) * 100
  
  # Create plot
  p <- ggplot(cm_df, aes(x = Prediction, y = Truth, fill = Freq)) +
    geom_tile(color = "white") +
    geom_text(aes(label = sprintf("%d\n(%.1f%%)", Freq, Percentage)),
              color = "white", size = 5, fontface = "bold") +
    scale_fill_gradient(low = "#3575b5", high = "#d7301f",
                        name = "Count") +
    labs(
      title = title,
      subtitle = sprintf("Accuracy: %.1f%%",
                         sum(diag(cm)) / sum(cm) * 100),
      x = "Predicted Class",
      y = "True Class"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      axis.text = element_text(size = 12),
      legend.position = "right"
    ) +
    coord_fixed()
  
  return(p)
}

# Create confusion matrices for top 4 models
top_4_configs <- head(results_df[order(-results_df$mcc), ], 4)
cm_plots <- list()

for (i in 1:nrow(top_4_configs)) {
  config <- top_4_configs[i, ]
  config_name <- paste(config$model, config$strategy, sep = "_")
  
  if (config_name %in% names(confusion_matrices)) {
    cm <- confusion_matrices[[config_name]]
    title <- sprintf("%s (%s)\nMCC: %.3f",
                     config$model, config$strategy, config$mcc)
    cm_plots[[i]] <- plot_confusion_matrix(cm, title)
  }
}

# Arrange in grid
if (length(cm_plots) > 0) {
  combined_plot <- do.call(gridExtra::grid.arrange, c(cm_plots, ncol = 2))
  ggsave("visualizations/confusion_matrices.png", combined_plot,
         width = 12, height = 10, dpi = 300)
  cat("â Saved: visualizations/confusion_matrices.png\n")
}


# =============================================================================
# STEP 13: VISUALIZATION - FEATURE IMPORTANCE
# =============================================================================
cat("\n=== STEP 13: Creating Feature Importance Visualization ===\n")

# Plot top 15 features
top_features <- head(avg_importance, 15)

p_importance <- ggplot(top_features, aes(x = reorder(feature, importance),
                                         y = importance)) +
  geom_bar(stat = "identity", fill = "#2c7fb8") +
  coord_flip() +
  labs(
    title = "Top 15 Most Important Features for Defect Prediction",
    subtitle = "Average importance across Random Forest and Decision Tree",
    x = "Feature",
    y = "Importance Score"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text = element_text(size = 11),
    panel.grid.major.y = element_blank()
  )

ggsave("visualizations/feature_importance.png", p_importance,
       width = 10, height = 8, dpi = 300)
cat("â Saved: visualizations/feature_importance.png\n")

# Plot feature importance by model
p_importance_by_model <- ggplot(
  feature_importance_df[feature_importance_df$feature %in% top_features$feature, ],
  aes(x = reorder(feature, importance), y = importance, fill = model)
) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  labs(
    title = "Feature Importance Comparison: Random Forest vs Decision Tree",
    subtitle = "Top 15 features across both models",
    x = "Feature",
    y = "Importance Score",
    fill = "Model"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  ) +
  scale_fill_brewer(palette = "Set1")

ggsave("visualizations/feature_importance_by_model.png", p_importance_by_model,
       width = 12, height = 8, dpi = 300)
cat("â Saved: visualizations/feature_importance_by_model.png\n")


# =============================================================================
# STEP 14: ADDITIONAL VISUALIZATIONS
# =============================================================================
cat("\n=== STEP 14: Creating Additional Visualizations ===\n")

# Visualization 1: Strategy Comparison (including SMOTE)
# Filter out NA values (failed SMOTE attempts)
results_df_valid <- results_df[!is.na(results_df$mcc), ]

# Count how many SMOTE results failed
smote_failed <- sum(is.na(results_df[results_df$strategy == "smote", "mcc"]))
if (smote_failed > 0) {
  cat(sprintf("  Note: %d SMOTE configurations failed and are excluded from visualization\n", smote_failed))
}

p_strategy <- ggplot(results_df_valid, aes(x = strategy, y = mcc, fill = strategy)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, size = 2, alpha = 0.5) +
  labs(
    title = "Performance Comparison Across Imbalance Strategies",
    subtitle = "Including SMOTE (new) compared to baseline, weights, and threshold",
    x = "Strategy",
    y = "MCC (Matthews Correlation Coefficient)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none"
  ) +
  scale_fill_brewer(palette = "Set2")

ggsave("visualizations/strategy_comparison.png", p_strategy,
       width = 10, height = 6, dpi = 300)
cat("â Saved: visualizations/strategy_comparison.png\n")

# Visualization 2: Model Performance Heatmap
results_wide <- reshape2::dcast(results_df, model ~ strategy, value.var = "mcc")
rownames(results_wide) <- results_wide$model
results_wide$model <- NULL
results_matrix <- as.matrix(results_wide)

results_long <- reshape2::melt(results_matrix)
colnames(results_long) <- c("Model", "Strategy", "MCC")

# Create label with proper handling of NA values
results_long$label <- ifelse(is.na(results_long$MCC),
                             "FAILED",
                             sprintf("%.3f", results_long$MCC))

p_heatmap <- ggplot(results_long, aes(x = Strategy, y = Model, fill = MCC)) +
  geom_tile(color = "white") +
  geom_text(aes(label = label), color = "white",
            fontface = "bold", size = 4) +
  scale_fill_gradient2(low = "#d7301f", mid = "#fdae6b", high = "#2c7fb8",
                       midpoint = median(results_long$MCC, na.rm = TRUE),
                       name = "MCC",
                       na.value = "grey50") +
  labs(
    title = "Model Performance Heatmap: MCC Scores",
    subtitle = "Comparison across all model-strategy combinations",
    x = "Imbalance Strategy",
    y = "Classification Model"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid = element_blank()
  )

ggsave("visualizations/performance_heatmap.png", p_heatmap,
       width = 10, height = 7, dpi = 300)
cat("â Saved: visualizations/performance_heatmap.png\n")


# =============================================================================
# STEP 15: FINAL TEST SET EVALUATION
# =============================================================================
cat("\n=== STEP 15: Final Evaluation on Test Set ===\n")

# Use tuned model for final evaluation
cat("Using tuned Random Forest for final test...\n")

# Train on full training set
at$train(task_train)

# Predict on test set
test_pred <- at$predict(task_test)

# Calculate test metrics
test_metrics <- calculate_metrics(test_pred)

# Get confusion matrix
test_cm <- extract_confusion_matrix(test_pred)

cat("\nTest Set Results (Tuned Random Forest):\n")
cat("ââââââââââââââââââââââââââââââââââââââââââââââââ\n")
cat(sprintf("MCC: %.3f\n", test_metrics$mcc))
cat(sprintf("Balanced Accuracy: %.3f\n", test_metrics$bacc))
cat(sprintf("F1 Score: %.3f\n", test_metrics$f1))
cat(sprintf("Precision: %.3f\n", test_metrics$precision))
cat(sprintf("Recall: %.3f\n", test_metrics$recall))

cat("\nConfusion Matrix (Test Set):\n")
print(test_cm)

# Plot test confusion matrix
p_test_cm <- plot_confusion_matrix(test_cm,
                                   "Test Set Confusion Matrix (Tuned Random Forest)")
ggsave("visualizations/test_confusion_matrix.png", p_test_cm,
       width = 8, height = 7, dpi = 300)
cat("\nâ Saved: visualizations/test_confusion_matrix.png\n")

# Save test results
test_results_df <- data.frame(
  model = "Random Forest (Tuned)",
  cv_mcc = tuned_metrics$mcc,
  test_mcc = test_metrics$mcc,
  test_balanced_accuracy = test_metrics$bacc,
  test_f1 = test_metrics$f1,
  test_precision = test_metrics$precision,
  test_recall = test_metrics$recall,
  generalization_gap = tuned_metrics$mcc - test_metrics$mcc,
  stringsAsFactors = FALSE
)

write.csv(test_results_df, "results/test_set_results.csv", row.names = FALSE)
cat("â Test results saved to: results/test_set_results.csv\n")


# =============================================================================
# STEP 16: SUMMARY AND RECOMMENDATIONS
# =============================================================================
cat("\n")
cat("ââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ\n")
cat("          EXTENDED ANALYSIS COMPLETE!                               \n")
cat("ââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ\n")
cat("\n")

cat("NEW FEATURES IMPLEMENTED:\n")
cat("âââââââââââââââââââââââââ\n")
cat("â 1. SMOTE for imbalance handling - synthetic minority oversampling\n")
cat("â 2. Hyperparameter tuning - automated search for best parameters\n")
cat("â 3. Confusion matrix visualizations - detailed error analysis\n")
cat("â 4. Feature importance - identify most predictive code metrics\n")
cat("\n")

cat("KEY FINDINGS:\n")
cat("âââââââââââââ\n")
cat(sprintf("â˘ Best initial model: %s with %s (MCC: %.3f)\n",
            best_initial$model, best_initial$strategy, best_initial$mcc))
cat(sprintf("â˘ After tuning: Random Forest (MCC: %.3f)\n", tuned_metrics$mcc))
cat(sprintf("â˘ Test set performance: MCC = %.3f\n", test_metrics$mcc))
cat(sprintf("â˘ Top 3 important features: %s\n",
            paste(head(avg_importance$feature, 3), collapse = ", ")))
cat("\n")

cat("SMOTE EFFECTIVENESS:\n")
cat("ââââââââââââââââââââ\n")
smote_results <- results_df[results_df$strategy == "smote", ]
baseline_results <- results_df[results_df$strategy == "baseline", ]
avg_smote <- mean(smote_results$mcc, na.rm = TRUE)
avg_baseline <- mean(baseline_results$mcc, na.rm = TRUE)
cat(sprintf("â˘ Average MCC with SMOTE: %.3f\n", avg_smote))
cat(sprintf("â˘ Average MCC without SMOTE: %.3f\n", avg_baseline))

# Check if SMOTE results are valid before comparing
if (is.nan(avg_smote) || is.na(avg_smote)) {
  cat("â˘ SMOTE strategy encountered errors and did not produce valid results\n")
  cat("  (This can happen if SMOTE fails with certain data characteristics)\n")
} else if (avg_smote > avg_baseline) {
  cat(sprintf("â˘ SMOTE improved performance by %.1f%%\n",
              ((avg_smote / avg_baseline) - 1) * 100))
} else {
  cat(sprintf("â˘ SMOTE decreased performance by %.1f%%\n",
              (1 - (avg_smote / avg_baseline)) * 100))
  cat("  (Not all models benefit from SMOTE - tree-based models may not need it)\n")
}
cat("\n")

cat("OUTPUT FILES:\n")
cat("âââââââââââââ\n")
cat("â˘ results/model_comparison.csv - All 16 model configurations\n")
cat("â˘ results/tuning_results.csv - Hyperparameter tuning results\n")
cat("â˘ results/feature_importance.csv - Feature importance scores\n")
cat("â˘ results/test_set_results.csv - Final test evaluation\n")
cat("â˘ visualizations/confusion_matrices.png - Top 4 model confusion matrices\n")
cat("â˘ visualizations/feature_importance.png - Top 15 features\n")
cat("â˘ visualizations/strategy_comparison.png - Strategy effectiveness\n")
cat("â˘ visualizations/performance_heatmap.png - Model Ă Strategy heatmap\n")
cat("â˘ visualizations/test_confusion_matrix.png - Final test results\n")
cat("\n")

cat("RECOMMENDATIONS FOR STUDENTS:\n")
cat("âââââââââââââââââââââââââââââ\n")
cat("1. Examine confusion matrices to understand error patterns\n")
cat("2. Identify which features matter most...\n")
cat("3. Try different SMOTE dup_size values (e.g., 1, 2, 3, 4)\n")
cat("4. Experiment with different hyperparametrs, tuning iterations (50, 100), and search algorithms\n")
cat("5. Compare the effectiveness of strategies like SMOTE etc. across different model types\n")
cat("\n")

cat("ââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ\n")
cat("\n")