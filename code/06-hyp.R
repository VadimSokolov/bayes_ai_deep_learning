# Code of chapter: Bayesian Hypothesis Testing
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/06-hyp.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Packages: knitr

source("code/common.R")

# ---- Signal Transmission ---------------------------------------------------

# [fig-signal-error-rate]
sigma <- 0.2
p <- seq(0.01, 0.99, 0.01)
c <- sigma^2 / 2 * log((1 - p) / p)
Pe <- pnorm((c - 1) / sigma) * p + (1 - pnorm((c + 1) / sigma)) * (1 - p)
plot(p, Pe * 1e7, type = "l", xlab = "p", ylab = expression(10^7 ~ P[e]))

# ---- Hockey: Hypothesis Testing for Normal Mean ----------------------------

# [hockey-posterior]
sigma2 <- 36
sigma02 <- 25
mu <- 30
y <- 12
k <- sigma02 + sigma2
mu1 <- sigma2 / k * mu + sigma02 / k * y
sigma21 <- sigma2 * sigma02 / k
mu1
sigma21

# [hockey-post-prob]
a <- 1 - pnorm(24, mu1, sqrt(sigma21))
a

# [hockey-post-odds]
a / (1 - a)

# [hockey-prior-prob]
a <- 1 - pnorm(24, mu, sqrt(sigma02))
print(a)
a / (1 - a)

# ---- Hypothesis Testing for Normal Mean: Two-Sided Test --------------------

# [argon-data]
air <- c(2.31017, 2.30986, 2.31010, 2.31001, 2.31024, 2.31010, 2.31028, 2.31028)
decomp <- c(2.30143, 2.29890, 2.29816, 2.30182, 2.29869, 2.29940, 2.29849, 2.29889)

# [argon-bayes-factor]
y <- air - decomp
n <- length(y)
m0 <- 0
sigma <- sqrt(var(air) + var(decomp))
n0 <- 1
Z <- (mean(y) - m0) / (sigma / sqrt(n))
BF <- sqrt((n + n0) / n0) * exp(-0.5 * n / (n + n0) * Z^2)
format(BF, scientific = TRUE, digits = 3)

# [argon-post-prob]
a <- 1 / (1 + BF)
a

# ---- Hypothesis Testing for Proportions ------------------------------------

# [proportions-monte-carlo]
set.seed(92) # Kuzy
y1 <- 1755
n1 <- 2500
alpha1 <- 1
beta1 <- 1
y2 <- 1818
n2 <- 2500
alpha2 <- 1
beta2 <- 1
m <- 10000
p1 <- rbeta(m, y1 + alpha1, n1 - y1 + beta1)
p2 <- rbeta(m, y2 + alpha2, n2 - y2 + beta2)
rd <- p2 - p1
plot(density(rd), main = "", xlab = expression(p[2] - p[1]), ylab = "Density", lwd = 3)
q <- quantile(rd, c(.05, .95))
print(q)
abline(v = q, col = "red", lwd = 2)

# ---- Highest Posterior Density (HPD) Credible Set --------------------------

# [hpd-visualization]
theta <- seq(0, 1, 0.01)
p <- dbeta(theta, 8, 5)
plot(theta, p, type = "l", xlab = expression(theta), ylab = "Density")
abline(h = 2.5, col = "red")
abline(v = c(0.55, 0.715), col = "blue")
text(0.2, 2.7, expression(k(alpha)), col = "red", cex = 1)
arrows(0.55, 0.1, 0.715, 0.1, code = 3, col = "blue", angle = 15)
text(0.62, 0.25, "C", col = "blue", cex = 1)

# ---- Cauchy ----------------------------------------------------------------

# [cauchy-data]
y <- c(2, -7, 4, -6)

# [cauchy-posterior]
par(mar = c(4, 4, 0, 0), bty = "n")
lhood <- function(theta) 1 / prod(1 + (y - theta)^2)
theta <- seq(-10, 10, 0.1)
post <- sapply(theta, lhood)
post <- 10 * post / sum(post)
plot(theta, post, type = "l", xlab = expression(theta), ylab = "Posterior Density")
abline(h = c(0.008475, 0.0159, 0.1, 0.2), col = "red")

# ---- Ulcer Treatment Clinical Trial ----------------------------------------

# [ulcer-posterior]
# Posterior distributions for death rates
# Treatment A: 7 deaths out of 100
# Treatment B: 1 death out of 100
alpha_A <- 1 + 7
beta_A <- 1 + 93
alpha_B <- 1 + 1
beta_B <- 1 + 99

# Monte Carlo estimate of P(p_A > p_B | data)
set.seed(123)
n_sims <- 100000
p_A_samples <- rbeta(n_sims, alpha_A, beta_A)
p_B_samples <- rbeta(n_sims, alpha_B, beta_B)

prob_A_worse <- mean(p_A_samples > p_B_samples)
cat("P(death rate A > death rate B | data) =", round(prob_A_worse, 3), "\n")

# [ulcer-chisquare]
# Frequentist chi-square test of homogeneity
# Construct the contingency table (Excellent, Fair, Death) x (Treatment A, B, C, D)
outcome_matrix <- matrix(c(
  76, 17, 7, # Treatment A
  89, 10, 1, # Treatment B
  86, 13, 1, # Treatment C
  88, 9, 3 # Treatment D
), nrow = 4, byrow = TRUE)
rownames(outcome_matrix) <- c("A", "B", "C", "D")
colnames(outcome_matrix) <- c("Excellent", "Fair", "Death")

# Chi-square test
chisq_result <- suppressWarnings(chisq.test(outcome_matrix))
cat("Chi-square statistic:", round(chisq_result$statistic, 2), "\n")
cat("Degrees of freedom:", chisq_result$parameter, "\n")
cat("P-value:", round(chisq_result$p.value, 3), "\n")

# Fisher's exact test for just the death column (A vs B)
death_table <- matrix(c(7, 93, 1, 99), nrow = 2, byrow = TRUE)
rownames(death_table) <- c("A", "B")
colnames(death_table) <- c("Death", "Survival")
fisher_result <- fisher.test(death_table, alternative = "greater")
cat("\nFisher's exact test (A vs B, deaths only):\n")
cat("P-value:", round(fisher_result$p.value, 3), "\n")

# [ulcer-plot-posteriors]
p_grid <- seq(0, 0.2, length.out = 500)
plot(p_grid, dbeta(p_grid, alpha_A, beta_A),
  type = "l", col = "red", lwd = 2,
  xlab = "Death rate", ylab = "Posterior density", ylim = c(0, 40)
)
lines(p_grid, dbeta(p_grid, alpha_B, beta_B), col = "blue", lwd = 2, lty = 3)
legend("topright",
  legend = c("Treatment A", "Treatment B"),
  col = c("red", "blue"), lwd = 2, lty = c(1, 3), bty = "n"
)

# Add posterior means
abline(v = alpha_A / (alpha_A + beta_A), col = "red", lty = 2)
abline(v = alpha_B / (alpha_B + beta_B), col = "blue", lty = 2)

# [ulcer-sensitivity]
# Prior sensitivity analysis
set.seed(456)
n_sims <- 100000

# Data: Treatment A: 7 deaths, 93 survivals; Treatment B: 1 death, 99 survivals
deaths_A <- 7
survivals_A <- 93
deaths_B <- 1
survivals_B <- 99

# Different priors to consider
priors <- data.frame(
  Prior = c(
    "Uniform Beta(1,1)",
    "Jeffreys Beta(0.5,0.5)",
    "Skeptical Beta(2,20)",
    "Optimistic Beta(1,10)",
    "Strong Beta(5,50)"
  ),
  alpha = c(1, 0.5, 2, 1, 5),
  beta = c(1, 0.5, 20, 10, 50)
)

# Calculate P(p_A > p_B | data) for each prior
results <- sapply(1:nrow(priors), function(i) {
  a <- priors$alpha[i]
  b <- priors$beta[i]

  # Posterior parameters
  alpha_A_post <- a + deaths_A
  beta_A_post <- b + survivals_A
  alpha_B_post <- a + deaths_B
  beta_B_post <- b + survivals_B

  # Monte Carlo
  p_A <- rbeta(n_sims, alpha_A_post, beta_A_post)
  p_B <- rbeta(n_sims, alpha_B_post, beta_B_post)
  mean(p_A > p_B)
})

priors$`Prior Mean` <- round(priors$alpha / (priors$alpha + priors$beta), 3)
priors$`P(p_A > p_B | data)` <- round(results, 3)
knitr::kable(priors[, c("Prior", "Prior Mean", "P(p_A > p_B | data)")],
  caption = "Sensitivity of posterior probability to prior specification"
)

# ---- Bayesian Sequential Trial for a Rare Disease --------------------------

# [berry-trial-setup]
set.seed(2024)

# True parameters (unknown to trialists)
p_control_true <- 0.30
p_treatment_true <- 0.50

# Prior parameters (Beta(1,1) = uniform)
alpha_prior <- 1
beta_prior <- 1

# Trial parameters
n_max_per_arm <- 30
interim_points <- c(10, 20, 30) # Patients per arm at each look
n_sims <- 10000 # Monte Carlo samples for posterior probability

# Efficacy and futility thresholds
theta_E <- 0.95
theta_F <- 0.10

# [berry-simulate-outcomes]
# Simulate patient outcomes
n_control <- n_max_per_arm
n_treatment <- n_max_per_arm
control_outcomes <- rbinom(n_control, 1, p_control_true)
treatment_outcomes <- rbinom(n_treatment, 1, p_treatment_true)

# [berry-sequential]
# Storage for results
results <- data.frame(
  interim = integer(),
  n_per_arm = integer(),
  x_control = integer(),
  x_treatment = integer(),
  p_superior = numeric(),
  decision = character()
)

# Conduct sequential analysis
final_decision <- "Continue"
for (k in seq_along(interim_points)) {
  n_current <- interim_points[k]

  # Accumulated data
  x_C <- sum(control_outcomes[1:n_current])
  x_T <- sum(treatment_outcomes[1:n_current])

  # Posterior parameters
  alpha_C_post <- alpha_prior + x_C
  beta_C_post <- beta_prior + n_current - x_C
  alpha_T_post <- alpha_prior + x_T
  beta_T_post <- beta_prior + n_current - x_T

  # Monte Carlo estimate of P(p_T > p_C | data)
  p_C_samples <- rbeta(n_sims, alpha_C_post, beta_C_post)
  p_T_samples <- rbeta(n_sims, alpha_T_post, beta_T_post)
  p_superior <- mean(p_T_samples > p_C_samples)

  # Decision
  if (p_superior > theta_E) {
    decision <- "Stop for Efficacy"
    final_decision <- decision
  } else if (p_superior < theta_F) {
    decision <- "Stop for Futility"
    final_decision <- decision
  } else {
    decision <- "Continue"
  }

  results <- rbind(results, data.frame(
    interim = k,
    n_per_arm = n_current,
    x_control = x_C,
    x_treatment = x_T,
    p_superior = round(p_superior, 4),
    decision = decision
  ))

  if (decision != "Continue") break
}

# Display results
knitr::kable(results,
  col.names = c(
    "Interim", "N per arm", "Control successes",
    "Treatment successes", "P(Treatment > Control)", "Decision"
  ),
  caption = "Sequential analysis results"
)

# [fig-berry-posteriors]
# Plot posterior distributions at final analysis
final_n <- results$n_per_arm[nrow(results)]
final_x_C <- results$x_control[nrow(results)]
final_x_T <- results$x_treatment[nrow(results)]

# Posterior parameters
alpha_C_final <- alpha_prior + final_x_C
beta_C_final <- beta_prior + final_n - final_x_C
alpha_T_final <- alpha_prior + final_x_T
beta_T_final <- beta_prior + final_n - final_x_T

# Create plot
p_grid <- seq(0, 1, length.out = 500)
par(mar = c(4, 4, 2, 1))
plot(p_grid, dbeta(p_grid, alpha_T_final, beta_T_final),
  type = "l",
  col = "blue", lwd = 2, ylim = c(0, 6),
  xlab = "Response probability", ylab = "Posterior density",
  main = "Posterior distributions at final analysis"
)
lines(p_grid, dbeta(p_grid, alpha_C_final, beta_C_final), col = "red", lwd = 2, lty = 4)
abline(v = p_control_true, col = "gray", lty = 2)
abline(v = p_treatment_true, col = "gray", lty = 2)
legend("topright",
  legend = c("Treatment", "Control", "True values"),
  col = c("blue", "red", "gray"), lwd = c(2, 2, 1), lty = c(1, 4, 2), bty = "n", cex = 0.8
)

# [berry-risk-diff]
# Posterior of risk difference via Monte Carlo
set.seed(123)
p_C_samples <- rbeta(50000, alpha_C_final, beta_C_final)
p_T_samples <- rbeta(50000, alpha_T_final, beta_T_final)
risk_diff <- p_T_samples - p_C_samples

# [berry-summary]
# Summary statistics
cat("Posterior summary for risk difference (p_T - p_C):\n")
cat("  Mean:", round(mean(risk_diff), 3), "\n")
cat(
  "  95% Credible Interval: [", round(quantile(risk_diff, 0.025), 3), ",",
  round(quantile(risk_diff, 0.975), 3), "]\n"
)
cat("  P(p_T > p_C):", round(mean(risk_diff > 0), 4), "\n")
cat("  P(p_T > p_C + 0.10):", round(mean(risk_diff > 0.10), 4), "\n")

# Plot
hist(risk_diff,
  breaks = 50, probability = TRUE, col = "lightblue",
  main = "Posterior distribution of risk difference",
  xlab = expression(p[T] - p[C])
)
abline(v = 0, col = "red", lwd = 2, lty = 2)
abline(v = mean(risk_diff), col = "blue", lwd = 2)
abline(v = quantile(risk_diff, c(0.025, 0.975)), col = "gray", lwd = 1, lty = 2)
legend("topleft",
  legend = c("Posterior mean", "Null (no effect)", "95% CI"),
  col = c("blue", "red", "gray"), lwd = 2, lty = c(1, 2, 2), bty = "n", cex = 0.5
)

# ---- Operating Characteristics via Simulation ------------------------------

# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# # Function to simulate one trial
# simulate_trial <- function(p_C_true, p_T_true, n_max = 30,
#                            interim_points = c(10, 20, 30),
#                            theta_E = 0.95, theta_F = 0.10,
#                            alpha_prior = 1, beta_prior = 1, n_mc = 5000) {
#   # Generate all outcomes upfront
#   control_outcomes <- rbinom(n_max, 1, p_C_true)
#   treatment_outcomes <- rbinom(n_max, 1, p_T_true)

#   for (n_current in interim_points) {
#     x_C <- sum(control_outcomes[1:n_current])
#     x_T <- sum(treatment_outcomes[1:n_current])

#     # Posterior samples
#     p_C_samp <- rbeta(n_mc, alpha_prior + x_C, beta_prior + n_current - x_C)
#     p_T_samp <- rbeta(n_mc, alpha_prior + x_T, beta_prior + n_current - x_T)
#     p_superior <- mean(p_T_samp > p_C_samp)

#     if (p_superior > theta_E) {
#       return(list(decision = "Efficacy", n_final = n_current, p_superior = p_superior))
#     } else if (p_superior < theta_F) {
#       return(list(decision = "Futility", n_final = n_current, p_superior = p_superior))
#     }
#   }

#   # Reached max sample size
#   return(list(decision = "Max reached", n_final = n_max, p_superior = p_superior))
# }

# [operating-chars]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# # Simulate under different scenarios
# set.seed(42)
# n_trials <- 1000
# scenarios <- data.frame(
#   scenario = c("Null (no effect)", "Small effect", "Moderate effect", "Large effect"),
#   p_C = c(0.30, 0.30, 0.30, 0.30),
#   p_T = c(0.30, 0.40, 0.50, 0.60)
# )

# results_all <- list()
# for (i in 1:nrow(scenarios)) {
#   trials <- replicate(n_trials,
#     simulate_trial(scenarios$p_C[i], scenarios$p_T[i]),
#     simplify = FALSE
#   )

#   decisions <- sapply(trials, function(x) x$decision)
#   n_finals <- sapply(trials, function(x) x$n_final)

#   results_all[[i]] <- data.frame(
#     Scenario = scenarios$scenario[i],
#     `True p_C` = scenarios$p_C[i],
#     `True p_T` = scenarios$p_T[i],
#     `P(Efficacy)` = mean(decisions == "Efficacy"),
#     `P(Futility)` = mean(decisions == "Futility"),
#     `E[N per arm]` = mean(n_finals),
#     check.names = FALSE
#   )
# }

# op_chars <- do.call(rbind, results_all)
# knitr::kable(op_chars,
#   digits = 3,
#   caption = "Operating characteristics of the Bayesian sequential design"
# )

# ---- Reproducing Scott's Bandit Experiment ---------------------------------

# [bandit-single-trial]
set.seed(42)

# True conversion rates
theta_true <- c(0.04, 0.05) # Original, Variation
K <- 2
arm_names <- c("Original", "Variation")

# Experiment parameters
visits_per_day <- 100
max_days <- 300
min_days <- 14 # an experiment runs at least two weeks
classical_days <- 223 # From power calculation

# Initialize Beta(1,1) priors
alpha_params <- c(1, 1)
beta_params <- c(1, 1)

# Day 1 serving weights: no data yet, so split the traffic evenly
prob_optimal <- rep(1 / K, K)

# Storage
prob_optimal_history <- matrix(0, max_days, K)
n_mc <- 10000

# Run single trial
end_day <- max_days
for (day in 1:max_days) {
  # Serve the day's traffic with this morning's weights, held fixed all day
  visits <- as.vector(rmultinom(1, visits_per_day, prob_optimal))
  conversions <- rbinom(K, visits, theta_true)

  # Overnight: one batch update, then fresh weights for tomorrow
  alpha_params <- alpha_params + conversions
  beta_params <- beta_params + (visits - conversions)

  theta_samples <- cbind(
    rbeta(n_mc, alpha_params[1], beta_params[1]),
    rbeta(n_mc, alpha_params[2], beta_params[2])
  )
  # max.col credits exactly one arm per draw, so the weights sum to 1
  prob_optimal <- tabulate(max.col(theta_samples, ties.method = "first"), K) / n_mc
  prob_optimal_history[day, ] <- prob_optimal

  # Stop on evidence that already includes today, never before two weeks
  if (day >= min_days && max(prob_optimal) > 0.95) {
    end_day <- day
    break
  }
}

# Plot: Optimal arm probabilities over time
par(mfrow = c(1, 2))
plot(1:end_day, prob_optimal_history[1:end_day, 1],
  type = "l",
  col = "black", lwd = 2, ylim = c(0, 1),
  xlab = "Time period", ylab = "Probability of being optimal",
  main = "Optimal Arm Probabilities"
)
lines(1:end_day, prob_optimal_history[1:end_day, 2], col = "red", lwd = 2, lty = 2)
abline(h = c(0.05, 0.95), lty = 3, col = "gray40")
legend("right",
  legend = arm_names, col = c("black", "red"),
  lwd = 2, lty = c(1, 2), cex = 0.8, bty = "n"
)

# True success rates
barplot(theta_true,
  names.arg = 1:2, col = c("black", "red"),
  xlab = "Arm", ylab = "", main = "True success rate",
  ylim = c(0, 0.06)
)

cat("Experiment ended on day:", end_day, "\n")
cat("Days saved vs classical:", classical_days - end_day, "\n")

# [bandit-simulations]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# set.seed(2024)

# # Parameters
# theta_true <- c(0.04, 0.05)
# K <- 2
# visits_per_day <- 100
# classical_days <- 223
# n_simulations <- 500
# n_mc <- 5000
# min_days <- 14

# # Function to run one bandit trial
# run_bandit_trial <- function(theta_true, visits_per_day, max_days = 300) {
#   alpha_params <- c(1, 1)
#   beta_params <- c(1, 1)
#   prob_optimal <- rep(1 / K, K)
#   total_conversions <- 0

#   for (day in 1:max_days) {
#     # Allocate the day's traffic by this morning's serving weights
#     visits <- as.vector(rmultinom(1, visits_per_day, prob_optimal))
#     conversions <- rbinom(K, visits, theta_true)
#     alpha_params <- alpha_params + conversions
#     beta_params <- beta_params + (visits - conversions)
#     total_conversions <- total_conversions + sum(conversions)

#     # Overnight update of the probability each arm is optimal
#     theta_samples <- cbind(
#       rbeta(n_mc, alpha_params[1], beta_params[1]),
#       rbeta(n_mc, alpha_params[2], beta_params[2])
#     )
#     prob_optimal <- tabulate(max.col(theta_samples, ties.method = "first"), K) / n_mc

#     # Check stopping
#     if (day >= min_days && max(prob_optimal) > 0.95) break
#   }
#   winner <- which.max(prob_optimal)
#   list(
#     day = day, conversions = total_conversions,
#     winner = winner, correct = (winner == 2)
#   )
# }

# # Run simulations
# results <- lapply(1:n_simulations, function(i) run_bandit_trial(theta_true, visits_per_day))

# # Extract results
# bandit_days <- sapply(results, function(x) x$day)
# bandit_conversions <- sapply(results, function(x) x$conversions)
# correct_arm <- sapply(results, function(x) x$correct)

# # Classical experiment: fixed allocation for 223 days
# # Expected conversions per day: 50 * 0.04 + 50 * 0.05 = 4.5
# classical_conversions_per_day <- visits_per_day * mean(theta_true)
# classical_total_conversions <- classical_days * classical_conversions_per_day

# # For bandit, compute expected conversions if we ran to classical_days
# # with optimal allocation after stopping
# expected_bandit_conversions <- bandit_conversions +
#   (classical_days - bandit_days) * visits_per_day * max(theta_true)

# # Days saved and conversions saved
# days_saved <- classical_days - bandit_days
# conversions_saved <- expected_bandit_conversions - classical_total_conversions

# # Plot histograms
# par(mfrow = c(1, 2), mar = c(4, 4, 3, 1))

# hist(days_saved,
#   breaks = 20, col = "lightgreen", border = "white",
#   main = "Days of Testing Saved", xlab = "Number of Days",
#   ylab = "Frequency", xlim = c(-100, 250)
# )
# abline(v = mean(days_saved), col = "darkgreen", lwd = 2, lty = 2)

# hist(conversions_saved,
#   breaks = 20, col = "lightgreen", border = "white",
#   main = "Conversions Saved", xlab = "Number of Conversions",
#   ylab = "Frequency"
# )
# abline(v = mean(conversions_saved), col = "darkgreen", lwd = 2, lty = 2)

# # Summary statistics
# cat("Simulation results (n =", n_simulations, "):\n")
# cat(
#   "  Correct arm identified:", sum(correct_arm), "/", n_simulations,
#   "(", round(100 * mean(correct_arm), 1), "%)\n"
# )
# cat("  Average days to finish:", round(mean(bandit_days), 1), "\n")
# cat("  Average days saved:", round(mean(days_saved), 1), "\n")
# cat("  Average conversions saved:", round(mean(conversions_saved), 1), "\n")
