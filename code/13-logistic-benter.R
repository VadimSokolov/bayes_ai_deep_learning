# Bayesian Logistic Regression for Horse Race Betting
# This script performs Polya-Gamma augmented Bayesian inference
# for the horse racing betting analysis in Chapter 13
# Run from the book folder: Rscript code/13-logistic-benter.R
# Reads data/df_hkjc_with_factors.csv (made by code/13-logistic-hkjc-prepare.py), writes fig/bayesian-betting-plot.png and results/13-logistic/.

library("BayesLogit")
library("readr")
library("dplyr")
library("MASS")
library("knitr")

# Load the horse racing data
race_df <- read_csv("data/df_hkjc_with_factors.csv", 
                    show_col_types = FALSE) |>
  group_by(race_id) |>
  mutate(is_favorite = rank(-public_prob, ties.method = "first") == 1) |>
  filter(is_favorite) |>
  ungroup()

# Prepare design matrix: intercept, public_prob, field_size
X <- cbind(1, 
           scale(race_df$public_prob),
           scale(race_df$field_size))
y <- race_df$win

# Bayesian logistic regression with Polya-Gamma augmentation
bayesian_logit_pg <- function(y, X, n_iter = 5000, burn_in = 1000) {
  n <- length(y)
  p <- ncol(X)
  beta_prior_mean <- rep(0, p)
  beta_prior_prec <- diag(0.01, p)
  
  beta_samples <- matrix(0, n_iter, p)
  beta <- rep(0, p)
  
  for(iter in 1:n_iter) {
    psi <- X %*% beta
    omega <- rpg(n, h = 1, z = psi)
    
    V_omega <- solve(t(X) %*% diag(omega) %*% X + beta_prior_prec)
    kappa <- y - 0.5
    m_omega <- V_omega %*% (t(X) %*% kappa + beta_prior_prec %*% beta_prior_mean)
    
    beta <- mvrnorm(1, m_omega, V_omega)
    beta_samples[iter, ] <- beta
  }
  
  list(beta = beta_samples[(burn_in + 1):n_iter, ],
       n_samples = n_iter - burn_in)
}

# Fit the Bayesian model
set.seed(42)
results <- bayesian_logit_pg(y, X, n_iter = 5000, burn_in = 1000)

# Compare with frequentist MLE
glm_fit <- glm(y ~ X[,2] + X[,3], family = binomial)
mle_coefs <- coef(glm_fit)

# Create plots
png("fig/bayesian-betting-plot.png", width = 1200, height = 400, res = 120)
par(mfrow = c(1, 3))
coef_names <- c("Intercept", "Public Prob (scaled)", "Field Size (scaled)")

for(j in 1:3) {
  hist(results$beta[, j], 
       breaks = 40, 
       main = coef_names[j],
       xlab = expression(beta),
       col = "lightblue",
       border = "white",
       freq = FALSE)
  abline(v = mle_coefs[j], col = "red", lwd = 2, lty = 2)
  abline(v = mean(results$beta[, j]), col = "blue", lwd = 2)
  
  # Add 95% credible interval
  ci <- quantile(results$beta[, j], c(0.025, 0.975))
  abline(v = ci, col = "darkblue", lty = 3)
}
dev.off()

# Generate summary table
post_summary <- data.frame(
  Parameter = coef_names,
  `Posterior.Mean` = colMeans(results$beta),
  `Posterior.SD` = apply(results$beta, 2, sd),
  `CI.Lower` = apply(results$beta, 2, quantile, 0.025),
  `CI.Upper` = apply(results$beta, 2, quantile, 0.975),
  `MLE` = mle_coefs
)

# Print summary table
cat("\n=== Posterior Summary ===\n")
print(kable(post_summary, digits = 3, format = "markdown"))

# Probability that field size effect is negative
prob_neg <- mean(results$beta[, 3] < 0)
cat(sprintf("\nPosterior probability that field size effect is negative: %.1f%%\n", 
            prob_neg * 100))

# Save results for later use
dir.create("results/13-logistic", recursive = TRUE, showWarnings = FALSE)
saveRDS(list(
  results = results,
  mle_coefs = mle_coefs,
  post_summary = post_summary,
  prob_neg = prob_neg,
  coef_names = coef_names
), file = "results/13-logistic/bayesian-betting-results.rds")

cat("\nResults saved to results/13-logistic/bayesian-betting-results.rds\n")
cat("Plot saved to fig/bayesian-betting-plot.png\n")

