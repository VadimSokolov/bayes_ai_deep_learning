# Run from the book folder: Rscript code/15-forecasting-bsts-claims.R
# Writes data/tft/claims.csv, data/tft/bsts_results.csv; code/15-forecasting-tft.py reads both.
library(bsts)
library(zoo)
dir.create("data/tft", recursive = TRUE, showWarnings = FALSE)

# Load data
data(iclaims)
y <- initial.claims$iclaimsNSA

# Create time index (weekly data starting from 2004-01-04)
# The dataset documentation says "weekly initial claims... starting in 2004".
# We'll generate a sequence of dates.
dates <- seq(as.Date("2004-01-04"), by = "week", length.out = length(y))

# Split Data (80% Train, 20% Test) - TEMPORAL SPLIT
n <- length(y)
n_train <- floor(0.8 * n)
train_indices <- 1:n_train
test_indices <- (n_train + 1):n

y_train <- y[train_indices]
y_test <- y[test_indices]
dates_train <- dates[train_indices]
dates_test <- dates[test_indices]

# Save Raw Data for Python
df_all <- data.frame(
    Date = dates,
    Claims = y,
    Type = c(rep("Train", n_train), rep("Test", length(test_indices))),
    time_idx = 1:n # Useful for TFT
)
write.csv(df_all, "data/tft/claims.csv", row.names = FALSE)
cat("Saved data/tft/claims.csv\n")

# --- Fit BSTS Model ---
ss <- AddLocalLinearTrend(list(), y_train)
ss <- AddSeasonal(ss, y_train, nseasons = 52)
model1 <- bsts(y_train, state.specification = ss, niter = 1000, ping = 100)

# --- Predict on Test Set ---
# Check if horizon matches test length
horizon <- length(test_indices)
pred <- predict(model1, horizon = horizon)

# Extract prediction intervals
mean_pred <- pred$mean
lower_pred <- apply(pred$distribution, 2, quantile, 0.025)
upper_pred <- apply(pred$distribution, 2, quantile, 0.975)

# Prepare BSTS Results Data Frame
# combining train (fitted values) and test (forecast)
# For train, we can use the model's one-step-ahead prediction errors or state contributions,
# but simply extracting the original 'y_train' is enough for plotting 'Actuals'.
# To plot the fit on training data, we can use model1$one.step.prediction.errors to reconstruct or just use summary.
# For simplicity in benchmarking, let's focus on the Out-of-Sample Forecast vs Actuals in the plot.
# But we'll save everything.

df_bsts_test <- data.frame(
    Date = dates_test,
    Actual = y_test,
    Pred_Mean = mean_pred,
    Pred_Lower = lower_pred,
    Pred_Upper = upper_pred,
    Type = "Test"
)

# For training data, we can just use the actuals and maybe 0s for preds if we don't want to plot training fit,
# OR we can get in-sample fit. Let's get in-sample fit to look nice.
# bsts doesn't store full in-sample posterior predictive easily without re-running,
# but we can approximate with state contribution or just leave blank for Training part.
# Let's simple save the TEST results for the benchmark plot, as that's the critical part.
write.csv(df_bsts_test, "data/tft/bsts_results.csv", row.names = FALSE)
cat("Saved data/tft/bsts_results.csv\n")
