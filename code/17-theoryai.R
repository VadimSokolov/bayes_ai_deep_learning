# Code of chapter: Statistical Learning Theory and Regularization
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/17-theoryai.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Data: data/EfronMorrisBB.txt, data/clemente.csv
# Packages: dplyr, ggplot2, glmnet, gridExtra, horseshoe, knitr

source("code/common.R")

# ---- Example: James-Stein for Baseball Batting Averages --------------------

# Data source: https://www1.swarthmore.edu/NatSci/peverso1/Sports%20Data/JamesSteinData/Efron-Morris%20Baseball/EfronMorrisBB.txt
baseball <- read.csv("data/EfronMorrisBB.txt", sep = "\t", stringsAsFactors = FALSE) %>% dplyr::select(LastName, AtBats, BattingAverage, SeasonAverage)
baseball$LastName[baseball$LastName == "Swaboda"] <- "Swoboda" # misspelled in the source file

k <- nrow(baseball)
mu_hat <- mean(baseball$BattingAverage)
sigma2_hat <- mu_hat * (1 - mu_hat) / 45

shrink <- 1 - (k - 3) * sigma2_hat / sum((baseball$BattingAverage - mu_hat)^2)
baseball <- baseball %>% mutate(JS = mu_hat + shrink * (BattingAverage - mu_hat))
kable(baseball)

ggplot(baseball, aes(x = BattingAverage, y = JS)) +
  geom_point(alpha = 0.6) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +
  labs(
    x = "Observed Batting Average",
    y = "James-Stein Estimate",
    title = "Empirical Bayes Shrinkage of Batting Averages"
  )

mse_observed <- mean((baseball$BattingAverage - baseball$SeasonAverage)^2)
mse_js <- mean((baseball$JS - baseball$SeasonAverage)^2)

cat(sprintf("MSE (Observed): %.6f\n", mse_observed))
cat(sprintf("MSE (James-Stein): %.6f\n", mse_js))

a <- matrix(rep(1:3, nrow(baseball)), 3, nrow(baseball))
b <- matrix(c(baseball$BattingAverage, baseball$SeasonAverage, baseball$JS), 3, nrow(baseball), byrow = TRUE)

par(mar = c(0.5, 2.5, 0.3, 0.5))
matplot(a, b, pch = " ", xlab = "", ylab = "batting average", xaxt = "n", xlim = c(0.5, 3.1), ylim = c(0.13, 0.42))
matlines(a, b, lwd = 1.5)
ly <- ave(baseball$BattingAverage, baseball$BattingAverage, FUN = function(v) v + 0.006 * (seq_along(v) - (length(v) + 1) / 2))
text(rep(0.7, nrow(baseball)), ly, baseball$LastName, cex = 0.55)
text(1, 0.14, "First 45\nat bats", cex = 0.5)
text(2, 0.14, "Season\naverage", cex = 0.5)
text(3, 0.14, "J-S\nestimator", cex = 0.5)

# Data source: https://www.baseball-almanac.com/players/hittinglogs.php?p=clemero01&y=1970
cl <- read.csv("data/clemente.csv")
x <- cumsum(cl$AB)
y <- cumsum(cl$H) / cumsum(cl$AB)
# Plot x,y starting from index 2
ind <- c(1, 2)
plot(x[-ind], y[-ind], type = "o", ylim = range(y[-ind], baseball$JS[1]), ylab = "Batting Average", xlab = "Number at Bats", pch = 21, bg = "lightblue", cex = 0.55, lwd = 1.5)
# Add horizontal line for season average 145/412 and add text above line `Season Average`
text(200, 145 / 412, "Season Average", col = "red", cex = 0.7, pos = 3)
abline(h = 145 / 412, col = "red", lty = 2)
# Ted williams record is .406 in 1941, so you know the first data points are noise
text(50, baseball$JS[1], "JS", col = "red", cex = 0.7, pos = 3)
abline(h = baseball$JS[1], col = "red", lty = 2)
text(200, baseball$BattingAverage[1], "After 45 At Bats", col = "red", cex = 0.7, pos = 3)
abline(h = baseball$BattingAverage[1], col = "red", lty = 2)

# ---- Lasso Regression ($\ell_1$ Norm) --------------------------------------

# [fig-laplace-distribution]
# PLot Laplace distribution
library(ggplot2)
b <- 1
beta <- seq(-5, 5, length.out = 101)
laplace_pdf <- function(beta, b) {
  (1 / (2 * b)) * exp(-abs(beta) / b)
}
laplace_data <- data.frame(beta = beta, pdf = laplace_pdf(beta, b))
ggplot(laplace_data, aes(x = beta, y = pdf)) +
  geom_line() +
  labs(x = expression(beta), y = "Density") +
  theme_minimal()

# ---- Sparsity and Variable Selection ---------------------------------------

# Generate simulated data
set.seed(123)
n <- 100 # number of observations
p <- 20 # number of predictors
sigma <- 1 # noise level

# Create design matrix with some correlation structure
X <- matrix(rnorm(n * p), n, p)
# Add some correlation between predictors
for (i in 2:p) {
  X[, i] <- 0.5 * X[, i - 1] + sqrt(0.75) * X[, i]
}

# True coefficients - sparse signal
beta_true <- c(3, -2, 1.5, 0, 0, 2, 0, 0, 0, -1, rep(0, 10))
sparse_indices <- which(beta_true != 0)

# Generate response
y <- X %*% beta_true + sigma * rnorm(n)

# Fit LASSO path using glmnet
library(glmnet)
lasso_fit <- glmnet(X, y, alpha = 1)
# Plot coefficient paths
par(mar = c(2.5, 2.5, 2, 0.5))
plot(lasso_fit, xvar = "lambda", label = FALSE)

# Cross-validation to select optimal lambda
cv_lasso <- cv.glmnet(X, y, alpha = 1, nfolds = 10)
# Plot cross-validation curve
par(mar = c(2.5, 2.5, 2, 0.5))
plot(cv_lasso)

# Extract coefficients at optimal lambda
lambda_min <- cv_lasso$lambda.min
lambda_1se <- cv_lasso$lambda.1se
coef_min <- coef(lasso_fit, s = lambda_min)
coef_1se <- coef(lasso_fit, s = lambda_1se)
# Print values of lambda
cat("Optimal lambda (min):", lambda_min, "\n")
cat("Optimal lambda (1se):", lambda_1se, "\n")

# Compare estimates with true values
comparison <- data.frame(
  True = c(0, beta_true), # Include intercept
  LASSO_min = as.vector(coef_min),
  LASSO_1se = as.vector(coef_1se)
)
rownames(comparison) <- c("Intercept", paste0("X", 1:p))
# Visualization of coefficient estimates
library(ggplot2)

# Long format for plotting
plot_data <- data.frame(
  Variable = factor(rep(rownames(comparison), 3), levels = rownames(comparison)),
  variable = factor(rep(names(comparison), each = nrow(comparison)), levels = names(comparison)),
  value = unlist(comparison, use.names = FALSE)
)

ggplot(plot_data, aes(x = Variable, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", colour = "black") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(y = "Coefficient Value", fill = "Method") +
  scale_fill_grey(start = 0.15, end = 0.85, labels = c("True", "LASSO (min)", "LASSO (1se)"))

# Calculate prediction errors
pred_min <- predict(lasso_fit, newx = X, s = lambda_min)
pred_1se <- predict(lasso_fit, newx = X, s = lambda_1se)

mse_min <- mean((y - pred_min)^2)
mse_1se <- mean((y - pred_1se)^2)

cat("Mean Squared Error (lambda.min):", round(mse_min, 3), "\n")
cat("Mean Squared Error (lambda.1se):", round(mse_1se, 3), "\n")

# ---- Horseshoe Prior for Sparse Regression ---------------------------------

# [horseshoe-example]
# Set seed for reproducibility
set.seed(123)

# Generate sparse regression data
n <- 100 # number of observations
p <- 50 # number of predictors
s <- 5 # number of non-zero coefficients

# True sparse coefficient vector
beta_true <- rep(0, p)
beta_true[1:s] <- c(50, -30, 15, -4, 3.5) # Varying magnitudes

# Generate design matrix (standardized)
X <- matrix(rnorm(n * p), n, p)
X <- scale(X)

# Generate response with noise
sigma_true <- 1
y <- X %*% beta_true + rnorm(n, 0, sigma_true)
y <- as.vector(y)

# Horseshoe Gibbs sampler
horseshoe_gibbs <- function(y, X, n_iter = 5000, burn_in = 1000) {
  n <- nrow(X)
  p <- ncol(X)

  # Initialize parameters
  beta <- rep(0, p)
  lambda_sq <- rep(1, p)
  tau_sq <- 1
  sigma_sq <- 1
  nu <- rep(1, p)
  xi <- 1

  # Storage for samples
  beta_samples <- matrix(0, n_iter - burn_in, p)
  tau_sq_samples <- numeric(n_iter - burn_in)

  # Pre-compute X'X and X'y
  XtX <- crossprod(X)
  Xty <- crossprod(X, y)

  for (iter in 1:n_iter) {
    # Sample beta from full conditional
    D_lambda_inv <- diag(1 / (lambda_sq * tau_sq))
    V_beta <- solve(XtX + D_lambda_inv)
    mu_beta <- V_beta %*% Xty
    beta <- mu_beta + t(chol(sigma_sq * V_beta)) %*% rnorm(p)

    # Sample sigma^2
    resid <- y - X %*% beta
    sigma_sq <- 1 / rgamma(1, (n + p) / 2, sum(resid^2) / 2 +
      sum(beta^2 / lambda_sq) / (2 * tau_sq))

    # Sample lambda_j^2 for each j
    for (j in 1:p) {
      lambda_sq[j] <- 1 / rgamma(1, 1, 1 / nu[j] + beta[j]^2 / (2 * tau_sq * sigma_sq))
    }

    # Sample nu_j (auxiliary for half-Cauchy)
    for (j in 1:p) {
      nu[j] <- 1 / rgamma(1, 1, 1 + 1 / lambda_sq[j])
    }

    # Sample tau^2 (global shrinkage)
    tau_sq <- 1 / rgamma(1, (p + 1) / 2, 1 / xi + sum(beta^2 / lambda_sq) / (2 * sigma_sq))

    # Sample xi (auxiliary for tau)
    xi <- 1 / rgamma(1, 1, 1 + 1 / tau_sq)

    # Store samples after burn-in
    if (iter > burn_in) {
      beta_samples[iter - burn_in, ] <- beta
      tau_sq_samples[iter - burn_in] <- tau_sq
    }
  }

  list(beta = beta_samples, tau_sq = tau_sq_samples)
}

hs_fit <- horseshoe_gibbs(y, X, n_iter = 5000, burn_in = 1000)
# Compute posterior means
beta_hs <- colMeans(hs_fit$beta)
tau_hs <- mean(hs_fit$tau_sq)

# Compare with Lasso
library(glmnet)
lasso_fit <- cv.glmnet(X, y, alpha = 1)
beta_lasso <- as.vector(coef(lasso_fit, s = "lambda.min"))[-1]

# [fig-horseshoe-comparison]
# Display results
ind <- 1:20
plot(beta_true[ind], pch = 19, type = "p", xlab = "Index", ylab = "Coefficient", xlim = c(0, 20))
lines(beta_hs[ind], col = "blue", type = "p", pch = 1)
lines(beta_lasso[ind], col = "red", type = "p", pch = 4)
# Generate horizonatal line at y=0
abline(h = 0, col = "black", lwd = 2)
legend("topright",
  legend = c("True", "Horseshoe", "Lasso"),
  col = c("black", "blue", "red"), pch = c(19, 1, 4), bty = "n"
)

# Calculate mean squared errors
library(knitr)

# Calculate coefficient mean squared errors
mse_hs <- mean((beta_true - beta_hs)^2)
mse_lasso <- mean((beta_true - beta_lasso)^2)

# Calculate prediction mean squared errors
pred_hs <- X %*% beta_hs
pred_lasso <- X %*% beta_lasso
pmse_hs <- mean((y - pred_hs)^2)
pmse_lasso <- mean((y - pred_lasso)^2)

# Create summary table
results_table <- data.frame(
  Method = c("Horseshoe", "Lasso"),
  `Coefficient MSE` = c(round(mse_hs, 4), round(mse_lasso, 4)),
  `Prediction MSE` = c(round(pmse_hs, 4), round(pmse_lasso, 4))
)

# [tbl-horseshoe-mse]
kable(results_table)

set.seed(88) # Patrick Kane
library(horseshoe)
# Create a 50 by 100 design matrix X
X2 <- matrix(rnorm(50 * 100), 50)
# True betas: first 10 are 6 (signals), rest are 0 (noise)
beta2 <- c(rep(6, 10), rep(0, 90))
# Generate response
y2 <- X2 %*% beta2 + rnorm(50)
# Fit Horseshoe model
invisible(capture.output(
  hs.object <- horseshoe(y2, X2, method.tau = "truncatedCauchy", method.sigma = "Jeffreys")
))

# [fig-hs-prior]
# Visualize Results
df <- data.frame(
  index = 1:100,
  truth = beta2,
  post.mean = hs.object$BetaHat,
  lower.CI = hs.object$LeftCI,
  upper.CI = hs.object$RightCI
)

library(ggplot2)
ggplot(data = df, aes(x = index, y = truth)) +
  theme_classic() +
  ylab("Coefficient Value") +
  geom_point(aes(x = index, y = post.mean, color = "Estimate"), size = 2) +
  geom_errorbar(aes(ymin = lower.CI, ymax = upper.CI, color = "Estimate"), width = .1) +
  geom_point(size = 2, shape = 1, aes(color = "Truth")) +
  scale_color_manual(values = c("Truth" = "black", "Estimate" = "red")) +
  labs(x = "Index", color = NULL)

# ---- Comparison and Package Implementation ---------------------------------

# [fig-hs-posterior-mean]
library(horseshoe)
library(ggplot2)
tau.values <- c(0.005, 0.05, 0.5)
y.values <- seq(-5, 5, length = 100)
df <- data.frame(
  tau = rep(tau.values, each = length(y.values)),
  y = rep(y.values, 3),
  post.mean = c(
    HS.post.mean(y.values, tau = tau.values[1], Sigma2 = 1),
    HS.post.mean(y.values, tau = tau.values[2], Sigma2 = 1),
    HS.post.mean(y.values, tau = tau.values[3], Sigma2 = 1)
  )
)

ggplot(data = df, aes(x = y, y = post.mean, group = tau, color = factor(tau), linetype = factor(tau))) +
  geom_line(linewidth = 1.5) +
  scale_color_brewer(palette = "Dark2") +
  scale_linetype_manual(values = c("solid", "dashed", "dotted")) +
  geom_abline(lty = 2) +
  geom_hline(yintercept = 0, colour = "grey") +
  theme_classic() +
  ylab("Posterior mean") +
  labs(color = expression(tau), linetype = expression(tau)) +
  theme(legend.key.width = unit(1.5, "cm"))

# ---- The Normal Means Problem ----------------------------------------------

# [fig-hs-normal-means]
set.seed(37) # Bergeron
df <- data.frame(
  index = 1:50, truth <- c(rep(5, 10), rep(0, 40)),
  y <- truth + rnorm(50)
) # observations

ggplot(data = df, aes(x = index, y = truth)) +
  geom_point(size = 1.2, shape = 18) +
  geom_point(aes(x = index, y = y), size = 0.8, stroke = 0.25, shape = 1, col = "blue") +
  theme_classic(base_size = 8) +
  labs(x = "Index", y = "Coefficient Value")

tau.est <- HS.MMLE(df$y, Sigma2 = 1)
post.mean <- HS.post.mean(df$y, tau.est, 1)
df$post.mean <- post.mean

ggplot(data = df, aes(x = index, y = truth)) +
  geom_point(size = 1.2, shape = 18) +
  geom_point(aes(x = index, y = y), size = 0.8, stroke = 0.25, shape = 1, col = "blue") +
  theme_classic(base_size = 8) +
  labs(x = "Index", y = "Coefficient Value") +
  geom_point(aes(x = index, y = post.mean), size = 0.8, stroke = 0.25, shape = 4, col = "red")

invisible(capture.output(hs.object <- HS.normal.means(df$y, method.tau = "truncatedCauchy", method.sigma = "Jeffreys")))
df$post.mean.full <- hs.object$BetaHat
df$lower.CI <- hs.object$LeftCI
df$upper.CI <- hs.object$RightCI
df$selected.CI <- HS.var.select(hs.object, df$y, method = "intervals")

ggplot(data = df, aes(x = index, y = truth)) +
  geom_point(size = 1.2, shape = 18) +
  theme_classic(base_size = 8) +
  labs(x = "Index", y = "Coefficient Value") +
  geom_point(aes(x = index, y = post.mean.full, col = factor(selected.CI)), size = 0.8, stroke = 0.25, shape = 4) +
  geom_errorbar(aes(ymin = lower.CI, ymax = upper.CI, col = factor(selected.CI), linetype = factor(selected.CI)), width = .1, linewidth = 0.2) +
  scale_colour_manual(values = c("gray60", "black")) +
  scale_linetype_manual(values = c("dashed", "solid")) +
  theme(legend.position = "none")

# ---- Spike-and-Slab Examples: Bernoulli-Gaussian and Bernoulli-Laplace -----

# [fig-posterior-means]
library(ggplot2)
library(gridExtra)

# Parameters
y_vals <- seq(-5, 5, length.out = 1000)
sigma <- 1
theta <- 0.1
sigma_beta_vals <- c(0.5, 1, 2)

# Bernoulli-Gaussian posterior mean
bg_posterior_mean <- function(y, sigma, theta, sigma_beta) {
  var_spike <- sigma^2
  var_slab <- sigma^2 + sigma_beta^2

  weight_factor <- (1 - theta) * dnorm(y, 0, sqrt(var_spike)) /
    (theta * dnorm(y, 0, sqrt(var_slab)))

  weight <- (sigma_beta^2 / var_slab) / (1 + weight_factor)
  return(weight * y)
}

# Bernoulli-Laplace posterior mean (simplified approximation)
bl_posterior_mean <- function(y, sigma, theta, b) {
  # Simplified version - in practice this involves complex integrals
  weight_gaussian <- (1 - theta) * dnorm(y, 0, sigma)
  weight_laplace <- theta * (1 / (2 * b)) * exp(-abs(y) / b) * exp(sigma^2 / (2 * b^2)) *
    (pnorm(-y / sigma - sigma / b) + pnorm(y / sigma - sigma / b))

  total_weight <- weight_gaussian + weight_laplace
  weight <- weight_laplace / total_weight

  # Simplified shrinkage factor
  shrinkage_factor <- y - sign(y) * pmax(0, abs(y) - sqrt(2) * sigma / b)
  return(weight * shrinkage_factor + (1 - weight) * 0)
}

# Create data for plotting
plot_data_bg <- expand.grid(y = y_vals, sigma_beta = sigma_beta_vals)
plot_data_bg$posterior_mean <- mapply(
  bg_posterior_mean,
  plot_data_bg$y, sigma, theta, plot_data_bg$sigma_beta
)
plot_data_bg$sigma_beta_label <- paste("sigma =", plot_data_bg$sigma_beta)

plot_data_bl <- expand.grid(y = y_vals, b = sigma_beta_vals)
plot_data_bl$posterior_mean <- mapply(
  bl_posterior_mean,
  plot_data_bl$y, sigma, theta, plot_data_bl$b
)
plot_data_bl$b_label <- paste("b =", plot_data_bl$b)

# Bernoulli-Gaussian plot
sb_lab <- c("0.5", "1", "2")
p1 <- ggplot(plot_data_bg, aes(x = y, y = posterior_mean, color = sigma_beta_label, linetype = sigma_beta_label)) +
  geom_line(linewidth = 1.2) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", alpha = 0.5) +
  labs(
    x = "y", y = expression(E(beta ~ "|" ~ y)), title = "Bernoulli-Gaussian Prior",
    color = expression(sigma[beta]), linetype = expression(sigma[beta])
  ) +
  scale_color_discrete(labels = sb_lab) +
  scale_linetype_discrete(labels = sb_lab) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  xlim(-5, 5) +
  coord_cartesian(ylim = c(-3, 3))

# Bernoulli-Laplace plot
b_lab <- c("0.5", "1", "2")
p2 <- ggplot(plot_data_bl, aes(x = y, y = posterior_mean, color = b_label, linetype = b_label)) +
  geom_line(linewidth = 1.2) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", alpha = 0.5) +
  labs(
    x = "y", y = expression(E(beta ~ "|" ~ y)), title = "Bernoulli-Laplace Prior",
    color = "b", linetype = "b"
  ) +
  scale_color_discrete(labels = b_lab) +
  scale_linetype_discrete(labels = b_lab) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  xlim(-5, 5) +
  coord_cartesian(ylim = c(-3, 3))

grid.arrange(p1, p2, ncol = 2)

# [fig-penalty-functions]
# Penalty function computation (numerical approximation)
compute_penalty_bg <- function(z, sigma, theta, sigma_beta) {
  # Find y such that posterior mean equals z
  objective <- function(y) (bg_posterior_mean(y, sigma, theta, sigma_beta) - z)^2

  # Use optimization to find y
  tryCatch(
    {
      y_opt <- optimize(objective, interval = c(-10, 10))$minimum
      penalty <- -0.5 * (y_opt - z)^2 / sigma^2 - log(
        (1 - theta) * dnorm(y_opt, 0, sigma) +
          theta * dnorm(y_opt, 0, sqrt(sigma^2 + sigma_beta^2))
      )
      return(penalty)
    },
    error = function(e) {
      return(NA)
    }
  )
}

compute_penalty_bl <- function(z, sigma, theta, b) {
  # Penalty function for Bernoulli-Laplace: phi(beta) = -log p(beta)
  # where p(beta) = (1-theta)*delta_0(beta) + theta * (1/(2b)) * exp(-|beta|/b)

  if (abs(z) < 1e-10) {
    # At z = 0: phi(0) = -log[(1-theta) + theta/(2b)]
    return(-log((1 - theta) + theta / (2 * b)))
  } else {
    # For z != 0: phi(z) = -log[theta/(2b)] + |z|/b
    return(-log(theta / (2 * b)) + abs(z) / b)
  }
}

# Create penalty data
z_vals <- seq(-3, 3, length.out = 200)
penalty_data_bg <- expand.grid(z = z_vals, sigma_beta = sigma_beta_vals)
penalty_data_bg$penalty <- mapply(function(z, sb) {
  if (abs(z) < 0.01) {
    return(0)
  }
  compute_penalty_bg(z, sigma, theta, sb)
}, penalty_data_bg$z, penalty_data_bg$sigma_beta)
penalty_data_bg$sigma_beta_label <- paste("sigma =", penalty_data_bg$sigma_beta)

penalty_data_bl <- expand.grid(z = z_vals, b = sigma_beta_vals)
penalty_data_bl$penalty <- mapply(
  compute_penalty_bl,
  penalty_data_bl$z, sigma, theta, penalty_data_bl$b
)
penalty_data_bl$b_label <- paste("b =", penalty_data_bl$b)

# Remove invalid values and normalize to have minimum at 0
penalty_data_bg <- penalty_data_bg[!is.na(penalty_data_bg$penalty), ]
penalty_data_bl <- penalty_data_bl[!is.na(penalty_data_bl$penalty), ]

# Normalize each curve to have minimum at 0
for (sb in sigma_beta_vals) {
  idx_bg <- penalty_data_bg$sigma_beta == sb
  if (any(idx_bg)) {
    min_val <- min(penalty_data_bg$penalty[idx_bg], na.rm = TRUE)
    penalty_data_bg$penalty[idx_bg] <- penalty_data_bg$penalty[idx_bg] - min_val
  }

  idx_bl <- penalty_data_bl$b == sb
  if (any(idx_bl)) {
    min_val <- min(penalty_data_bl$penalty[idx_bl], na.rm = TRUE)
    penalty_data_bl$penalty[idx_bl] <- penalty_data_bl$penalty[idx_bl] - min_val
  }
}

# Bernoulli-Gaussian penalty plot
sb_lab <- c("0.5", "1", "2")
p3 <- ggplot(penalty_data_bg, aes(x = z, y = penalty, color = sigma_beta_label, linetype = sigma_beta_label)) +
  geom_line(linewidth = 1.2) +
  labs(
    x = expression(beta), y = expression(phi(beta)), title = "Bernoulli-Gaussian Penalty",
    color = expression(sigma[beta]), linetype = expression(sigma[beta])
  ) +
  scale_color_discrete(labels = sb_lab) +
  scale_linetype_discrete(labels = sb_lab) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  xlim(-3, 3) +
  coord_cartesian(ylim = c(0, 5))

# Bernoulli-Laplace penalty plot
b_lab <- c("0.5", "1", "2")
p4 <- ggplot(penalty_data_bl, aes(x = z, y = penalty, color = b_label, linetype = b_label)) +
  geom_line(linewidth = 1.2) +
  labs(
    x = expression(beta), y = expression(phi(beta)), title = "Bernoulli-Laplace Penalty",
    color = "b", linetype = "b"
  ) +
  scale_color_discrete(labels = b_lab) +
  scale_linetype_discrete(labels = b_lab) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  xlim(-3, 3) +
  coord_cartesian(ylim = c(0, 5))

grid.arrange(p3, p4, ncol = 2)
