# Code of chapter: Quantile Neural Networks
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/21-qnn.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Packages: dplyr, ggplot2, knitr, quantreg, tidyr

source("code/common.R")

# ---- Linear Quantile Regression --------------------------------------------

# Define the check loss (pinball loss) function
check_loss <- function(u, tau) {
    # rho_tau(u) = u * (tau - I(u < 0))
    u * (tau - (u < 0))
}

# Objective function: sum of check losses for quantile regression
quantile_objective <- function(beta, X, y, tau) {
    y_pred <- X %*% beta
    residuals <- y - y_pred
    sum(check_loss(residuals, tau))
}

# Prepare data
X <- cbind(1, log(mtcars$disp)) # Design matrix with intercept
y <- log(mtcars$mpg)

# [fig-plot-mtcars]
# Fit quantile regression models using optim()
quantiles <- c(0.1, 0.5, 0.9)
results <- list()

for (tau in quantiles) {
    # Initial values (use OLS estimates as starting point)
    ols_fit <- lm(log(mpg) ~ log(disp), data = mtcars)
    beta_init <- coef(ols_fit)

    # Optimize using BFGS (quasi-Newton method)
    # The check loss is non-differentiable at zero, so BFGS, which assumes a
    # smooth objective, only approximates the minimum
    optim_result <- optim(
        par = beta_init,
        fn = quantile_objective,
        X = X,
        y = y,
        tau = tau,
        method = "BFGS"
    )

    results[[as.character(tau)]] <- list(
        coefficients = optim_result$par,
        value = optim_result$value,
        convergence = optim_result$convergence
    )
}

# Also fit OLS for comparison
ols_model <- lm(log(mpg) ~ log(disp), data = mtcars)

# Create visualization
plot(log(mtcars$disp), log(mtcars$mpg),
    pch = 16, col = "gray30",
    xlab = "log(Displacement)",
    ylab = "log(Miles per Gallon)", cex.lab = 0.8, cex.axis = 0.8, cex.main = 0.8
)

# Add regression lines
disp_range <- seq(min(log(mtcars$disp)), max(log(mtcars$disp)), length.out = 100)

# OLS line
abline(ols_model, col = "black", lwd = 2, lty = 2)

# Quantile regression lines
colors <- c("blue", "darkgreen", "red")
for (i in seq_along(quantiles)) {
    tau <- quantiles[i]
    beta <- results[[as.character(tau)]]$coefficients
    # Predicted values: y = beta_0 + beta_1 * x
    pred <- beta[1] + beta[2] * disp_range
    lines(disp_range, pred, col = colors[i], lwd = 2, lty = c(3, 1, 4)[i])
}

# Add legend
legend("topright",
    legend = c(
        "OLS (Mean)",
        expression(tau == 0.1),
        expression(tau == 0.5 ~ "(Median)"),
        expression(tau == 0.9)
    ),
    col = c("black", colors), lty = c(2, 3, 1, 4),
    lwd = 2, bg = "white", bty = "n", cex = 0.6
)

# [tbl-quantile-regression-results]
# Print model summaries
# Create results table
results_table <- data.frame(
    Model = character(),
    Intercept = numeric(),
    Slope = numeric(),
    stringsAsFactors = FALSE
)

# Add quantile regression results
for (tau in quantiles) {
    results_table <- rbind(results_table, data.frame(
        Model = sprintf("Quantile tau = %.1f", tau),
        Intercept = results[[as.character(tau)]]$coefficients[1],
        Slope = results[[as.character(tau)]]$coefficients[2]
    ))
}

# Add OLS results
results_table <- rbind(results_table, data.frame(
    Model = "OLS (Mean)",
    Intercept = coef(ols_model)[1],
    Slope = coef(ols_model)[2]
))

# Display as kable table
knitr::kable(results_table,
    digits = 4,
    caption = "Quantile Regression Results: Fuel Efficiency vs. Engine Displacement",
    col.names = c("Model", "Intercept", "Slope")
)

# ---- An Instructional Linear Baseline --------------------------------------

# [amazon-demand-forecast]
# Load required libraries
library(quantreg) # For quantile regression
library(ggplot2)
library(dplyr)
library(tidyr)

# Set seed for reproducibility
set.seed(42)

# Generate synthetic demand data for multiple products
generate_demand_data <- function(n_days = 365 * 2, n_products = 5) {
    days <- 1:n_days

    # Create data frame
    data_list <- lapply(1:n_products, function(p) {
        # Base parameters varying by product
        base_demand <- 50 + p * 20
        trend <- 0.05 * p

        # Seasonal components
        weekly_pattern <- 10 * sin(2 * pi * days / 7 + p)
        monthly_pattern <- 15 * sin(2 * pi * days / 30.5 + p * 0.5)

        # Promotional effect (random promotions)
        promo <- rbinom(n_days, 1, 0.1) # 10% of days have promotions
        promo_effect <- promo * (30 + 20 * p)

        # Trend + seasonality + promotions + noise
        mu <- base_demand + trend * days + weekly_pattern + monthly_pattern + promo_effect

        # Heteroskedastic noise (variance increases with demand)
        sigma <- 5 + 0.1 * mu
        demand <- pmax(0, rnorm(n_days, mu, sigma)) # Demand can't be negative

        data.frame(
            product = paste0("Product_", p),
            day = days,
            demand = demand,
            promo = promo,
            day_of_week = (days %% 7) + 1,
            day_of_month = ((days - 1) %% 30) + 1
        )
    })

    do.call(rbind, data_list)
}

# Generate data
demand_data <- generate_demand_data(n_days = 365 * 2, n_products = 3)

# Create lagged features
demand_data <- demand_data %>%
    group_by(product) %>%
    arrange(day) %>%
    mutate(
        lag_1 = lag(demand, 1, default = NA),
        lag_7 = lag(demand, 7, default = NA),
        lag_30 = lag(demand, 30, default = NA)
    ) %>%
    ungroup() %>%
    filter(!is.na(lag_30)) # Remove rows with NA lags

# Train/test split
train_days <- max(demand_data$day) - 90
train_data <- demand_data %>% filter(day <= train_days)
test_data <- demand_data %>% filter(day > train_days)

# Quantile regression for multiple quantiles
quantiles <- c(0.1, 0.3, 0.5, 0.7, 0.9)
models <- list()

# cat("Training quantile regression models...\n")
for (q in quantiles) {
    # cat(sprintf("  Quantile %.2f...\n", q))
    models[[as.character(q)]] <- rq(
        demand ~ product + day + promo + day_of_week + day_of_month +
            lag_1 + lag_7 + lag_30,
        tau = q,
        data = train_data
    )
}

# Generate predictions for test set
predictions <- test_data
for (q in quantiles) {
    col_name <- paste0("q_", gsub("\\.", "", sprintf("%.2f", q)))
    predictions[[col_name]] <- predict(models[[as.character(q)]], newdata = test_data)
}

# Calculate prediction intervals and coverage
predictions <- predictions %>%
    mutate(
        in_80_interval = (demand >= q_010 & demand <= q_090),
        in_60_interval = (demand >= q_030 & demand <= q_070)
    )

# Calculate metrics
coverage_80 <- mean(predictions$in_80_interval, na.rm = TRUE)
coverage_60 <- mean(predictions$in_60_interval, na.rm = TRUE)
mae_median <- mean(abs(predictions$demand - predictions$q_050), na.rm = TRUE)

# cat(sprintf("\nForecast Performance:\n"))
# cat(sprintf("  80%% interval coverage: %.1f%% (target: 80%%)\n", coverage_80 * 100))
# cat(sprintf("  40%% interval coverage: %.1f%% (target: 40%%)\n", coverage_60 * 100))
# cat(sprintf("  Median absolute error: %.2f units\n", mae_median))

# Visualization
par(mfrow = c(2, 1))

# Plot 1: Training data for one product
product_1_train <- train_data %>% filter(product == "Product_1")
rng <- range(product_1_train$demand)
plot(product_1_train$day, product_1_train$demand,
    type = "l", lwd = 1.5, col = "darkblue",
    xlab = "Day", ylab = "Demand",
    ylim = c(rng[1], rng[2] + 0.18 * diff(rng)),
    main = "Historical Demand (Product 1)"
)
points(product_1_train$day[product_1_train$promo == 1],
    product_1_train$demand[product_1_train$promo == 1] + 0.05 * diff(rng),
    col = "red", pch = 2, cex = 0.7
)
legend("topleft",
    legend = c("Demand", "Promotion"),
    col = c("darkblue", "red"), lwd = c(2, NA), pch = c(NA, 2), horiz = TRUE,
    bty = "n", cex = 0.6
)
grid()

# Plot 2: Forecasts with quantiles (fan chart)
product_1_test <- predictions %>% filter(product == "Product_1")
plot(product_1_test$day, product_1_test$demand,
    type = "l", lwd = 2, col = "black",
    xlab = "Day", ylab = "Demand",
    main = "Demand Forecasts with Quantiles (Product 1)",
    ylim = range(c(product_1_test$q_010, product_1_test$q_090, product_1_test$demand))
)

# Add prediction intervals
polygon(c(product_1_test$day, rev(product_1_test$day)),
    c(product_1_test$q_010, rev(product_1_test$q_090)),
    col = rgb(0.7, 0.7, 1, 0.3), border = NA
)
polygon(c(product_1_test$day, rev(product_1_test$day)),
    c(product_1_test$q_030, rev(product_1_test$q_070)),
    col = rgb(0.5, 0.5, 1, 0.4), border = NA
)

# Add quantile lines
lines(product_1_test$day, product_1_test$q_010, col = "blue", lty = 3, lwd = 1.5)
lines(product_1_test$day, product_1_test$q_050, col = "darkblue", lty = 2, lwd = 2)
lines(product_1_test$day, product_1_test$q_090, col = "blue", lty = 3, lwd = 1.5)

# Actual demand
lines(product_1_test$day, product_1_test$demand, col = "black", lwd = 2)

legend("topright",
    legend = c("Actual", "P50 (Median)", "P10-P90 (80%)", "P30-P70 (40%)"),
    col = c("black", "darkblue", rgb(0.7, 0.7, 1), rgb(0.5, 0.5, 1)),
    lwd = c(2, 2, 5, 5), lty = c(1, 2, 1, 1),
    bty = "n", cex = 0.6
)
grid()
par(mfrow = c(1, 1))

# ---- Optional Comparison: Quantile Trend Filtering -------------------------

# [fig-trend-filtering-quantile]
# Set seed for reproducibility
set.seed(123)

# Generate nonlinear synthetic data with heteroskedasticity
n <- 100
x <- sort(runif(n, 0, 10))

# True function with different regimes
f_true <- ifelse(x < 3, 1 + 0.5 * x,
    ifelse(x < 5, 2.5 + 2 * (x - 3),
        6.5 + 0.2 * (x - 5)
    )
)

# Heteroskedastic noise that increases with x
sigma <- 0.3 + 0.1 * x
y <- f_true + rnorm(n, 0, sigma)

# Define second-order difference operator
D2 <- function(n) {
    D <- matrix(0, n - 2, n)
    for (i in 1:(n - 2)) {
        D[i, i:(i + 2)] <- c(1, -2, 1)
    }
    return(D)
}

# Trend filtering objective function for quantile regression
trend_filter_obj <- function(f, y, lambda, tau, D) {
    # Check loss
    residuals <- y - f
    quantile_loss <- sum(residuals * (tau - (residuals < 0)))

    # L1 penalty on second differences
    penalty <- lambda * sum(abs(D %*% f))

    return(quantile_loss + penalty)
}

# Fit trend filtering for multiple quantiles using optim
# For better performance, we use BFGS with box constraints
quantiles <- c(0.1, 0.5, 0.9)
lambda <- 2.0 # Smoothing parameter
D <- D2(n)

results_tf <- list()

for (tau in quantiles) {
    # Initialize with linear quantile regression
    X_init <- cbind(1, x)
    init_fit <- lm(y ~ x)
    f_init <- predict(init_fit)

    # Optimize using L-BFGS-B
    opt_result <- optim(
        par = f_init,
        fn = trend_filter_obj,
        y = y,
        lambda = lambda,
        tau = tau,
        D = D,
        method = "L-BFGS-B"
    )

    results_tf[[as.character(tau)]] <- opt_result$par
}

# Visualization
par(mfrow = c(1, 2))

# Left panel: Data and trend filtering estimates
plot(x, y,
    pch = 16, col = "gray50", cex = 0.8,
    xlab = "x", ylab = "y", ylim = range(c(y, unlist(results_tf))),
    main = "Trend Filtering Quantile Regression"
)

# True function
lines(x, f_true, col = "black", lwd = 2, lty = 2)

# Quantile estimates
colors <- c("blue", "darkgreen", "red")
for (i in seq_along(quantiles)) {
    tau <- quantiles[i]
    lines(x, results_tf[[as.character(tau)]],
        col = colors[i], lwd = 2.5, lty = c(4, 1, 3)[i]
    )
}

legend("bottomright",
    legend = expression("True mean", tau == 0.1, tau == 0.5, tau == 0.9),
    col = c("black", colors),
    lty = c(2, 4, 1, 3),
    lwd = c(2, 2.5, 2.5, 2.5),
    bg = "white",
    bty = "n",
    cex = 0.6
)

# Right panel: Uncertainty quantification
plot(x, y,
    pch = 16, col = "gray50", cex = 0.8,
    xlab = "x", ylab = "y", ylim = range(c(y, unlist(results_tf))),
    main = "Conditional Quantiles and Prediction Intervals"
)

# Fill prediction intervals
polygon(c(x, rev(x)),
    c(results_tf[["0.1"]], rev(results_tf[["0.9"]])),
    col = rgb(0.5, 0.5, 1, 0.3), border = NA
)

# Quantile curves
lines(x, results_tf[["0.1"]], col = "blue", lwd = 2, lty = 2)
lines(x, results_tf[["0.5"]], col = "darkgreen", lwd = 2.5)
lines(x, results_tf[["0.9"]], col = "red", lwd = 2, lty = 2)

legend("bottomright",
    legend = c("P50 (Median)", "P10-P90 (80% interval)"),
    col = c("darkgreen", rgb(0.5, 0.5, 1)),
    lwd = c(2.5, 5),
    bg = "white",
    bty = "n",
    cex = 0.6
)
par(mfrow = c(1, 1))

# Calculate empirical coverage
# coverage <- mean(y >= results_tf[["0.1"]] & y <= results_tf[["0.9"]])
# cat(sprintf("\nEmpirical 80%% interval coverage: %.1f%%\n", coverage * 100))
