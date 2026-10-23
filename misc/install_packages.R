# Install all R packages required by the book
# Usage: Rscript misc/install_packages.R

options(repos = c(CRAN = "https://cran.r-project.org"), timeout = 300)

# All packages used across chapters, exercises, and case studies
pkgs <- c(
  # Core (misc/common.qmd)
  "tidyverse", "ggplot2", "latex2exp", "broom", "quantmod",
  "LearnBayes", "knitr", "MASS", "reticulate",

  # 02-bayes
  "usmap", "lattice",

  # 04-dec
  "tidyr",

  # 08-gp, 09-rl
  "laGP",

  # 12-regression (no extras beyond core)

  # 13-logistic
  "scatterplot3d", "BayesLogit",

  # 14-tree
  "rpart", "rpart.plot", "tree", "randomForest", "gbm", "bartCause",

  # 15-forecasting
  "xts", "bsts", "fma", "fpp2", "gridExtra",

  # 17-theoryai
  "glmnet", "horseshoe",

  # 18-nn
  # scatterplot3d already listed

  # 21-qnn
  "quantreg", "dplyr",

  # Exercise files
  "boot", "gamlr", "lubridate", "Lock5Data", "ranger", "dbarts",
  "mgcv", "nnet", "pROC", "ROCR",

  # case_studies / misc (optional but included for completeness)
  "zoo", "kableExtra", "readr", "scales"
)

# Deduplicate
pkgs <- unique(pkgs)

# Check which are missing
missing <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]

if (length(missing) == 0) {
  cat("All", length(pkgs), "packages are already installed.\n")
} else {
  cat("Installing", length(missing), "missing packages:",
      paste(missing, collapse = ", "), "\n\n")
  install.packages(missing)

  # Report any that still failed
  still_missing <- missing[!sapply(missing, requireNamespace, quietly = TRUE)]
  if (length(still_missing) > 0) {
    cat("\nWARNING: Could not install:", paste(still_missing, collapse = ", "), "\n")
    cat("These may need to be installed from source or an alternative repository.\n")
  } else {
    cat("\nAll packages installed successfully.\n")
  }
}
