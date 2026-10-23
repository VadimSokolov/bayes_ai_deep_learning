set.seed(2024)

# Parameters
theta_true <- c(0.04, 0.05)
K <- 2
visits_per_day <- 100
classical_days <- 223
n_simulations <- 500
n_mc <- 5000

# Function to run one bandit trial
run_bandit_trial <- function(theta_true, visits_per_day, max_days = 300) {
  alpha_params <- c(1, 1)
  beta_params <- c(1, 1)
  total_conversions <- 0
  
  for (day in 1:max_days) {
    # Compute probability each arm is optimal
    theta_samples <- cbind(
      rbeta(n_mc, alpha_params[1], beta_params[1]),
      rbeta(n_mc, alpha_params[2], beta_params[2])
    )
    prob_optimal <- colMeans(theta_samples == apply(theta_samples, 1, max))
    
    # Allocate traffic
    for (v in 1:visits_per_day) {
      theta_sampled <- rbeta(2, alpha_params, beta_params)
      a <- which.max(theta_sampled)
      y <- rbinom(1, 1, theta_true[a])
      alpha_params[a] <- alpha_params[a] + y
      beta_params[a] <- beta_params[a] + (1 - y)
      total_conversions <- total_conversions + y
    }
    
    # Check stopping
    if (max(prob_optimal) > 0.95) {
      winner <- which.max(prob_optimal)
      return(list(day = day, conversions = total_conversions, 
                  winner = winner, correct = (winner == 2)))
    }
  }
  winner <- which.max(prob_optimal)
  return(list(day = max_days, conversions = total_conversions, 
              winner = winner, correct = (winner == 2)))
}

# Run simulations
results <- lapply(1:n_simulations, function(i) run_bandit_trial(theta_true, visits_per_day))

# Extract results
bandit_days <- sapply(results, function(x) x$day)
bandit_conversions <- sapply(results, function(x) x$conversions)
correct_arm <- sapply(results, function(x) x$correct)

# Classical experiment: fixed allocation for 223 days
# Expected conversions per day: 50 * 0.04 + 50 * 0.05 = 4.5
classical_conversions_per_day <- visits_per_day * mean(theta_true)
classical_total_conversions <- classical_days * classical_conversions_per_day

# For bandit, compute expected conversions if we ran to classical_days
# with optimal allocation after stopping
expected_bandit_conversions <- bandit_conversions + 
  (classical_days - bandit_days) * visits_per_day * max(theta_true)

# Days saved and conversions saved
days_saved <- classical_days - bandit_days
conversions_saved <- expected_bandit_conversions - classical_total_conversions

# Plot histograms
dev.copy(png, "fig/bandit_simulation_results.png", width = 1600, height = 600)

par(mfrow = c(1, 2), mar = c(4, 4.5, 3, 1))

hist(days_saved, breaks = 20, col = "lightgreen", border = "white",
     main = "Days of Testing Saved", xlab = "Number of Days",
     ylab = "Frequency", xlim = c(-50, 250))
abline(v = mean(days_saved), col = "darkgreen", lwd = 2, lty = 2)

hist(conversions_saved, breaks = 20, col = "lightgreen", border = "white",
     main = "Conversions Saved", xlab = "Number of Conversions",
     ylab = "Frequency")
abline(v = mean(conversions_saved), col = "darkgreen", lwd = 2, lty = 2)
dev.off()



# Summary statistics
cat("Simulation results (n =", n_simulations, "):\n")
cat("  Correct arm identified:", sum(correct_arm), "/", n_simulations, 
    "(", round(100*mean(correct_arm), 1), "%)\n")
cat("  Average days to finish:", round(mean(bandit_days), 1), "\n")
cat("  Average days saved:", round(mean(days_saved), 1), "\n")
cat("  Average conversions saved:", round(mean(conversions_saved), 1), "\n")