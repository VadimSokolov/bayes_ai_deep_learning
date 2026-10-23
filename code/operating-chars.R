# Function to simulate one trial
simulate_trial <- function(p_C_true, p_T_true, n_max = 30, 
                           interim_points = c(10, 20, 30),
                           theta_E = 0.95, theta_F = 0.10,
                           alpha_prior = 1, beta_prior = 1, n_mc = 5000) {
  
  # Generate all outcomes upfront
  control_outcomes <- rbinom(n_max, 1, p_C_true)
  treatment_outcomes <- rbinom(n_max, 1, p_T_true)
  
  for (n_current in interim_points) {
    x_C <- sum(control_outcomes[1:n_current])
    x_T <- sum(treatment_outcomes[1:n_current])
    
    # Posterior samples
    p_C_samp <- rbeta(n_mc, alpha_prior + x_C, beta_prior + n_current - x_C)
    p_T_samp <- rbeta(n_mc, alpha_prior + x_T, beta_prior + n_current - x_T)
    p_superior <- mean(p_T_samp > p_C_samp)
    
    if (p_superior > theta_E) {
      return(list(decision = "Efficacy", n_final = n_current, p_superior = p_superior))
    } else if (p_superior < theta_F) {
      return(list(decision = "Futility", n_final = n_current, p_superior = p_superior))
    }
  }
  
  # Reached max sample size
  return(list(decision = "Max reached", n_final = n_max, p_superior = p_superior))
}

# Simulate under different scenarios
set.seed(42)
n_trials <- 1000
scenarios <- data.frame(
  scenario = c("Null (no effect)", "Small effect", "Moderate effect", "Large effect"),
  p_C = c(0.30, 0.30, 0.30, 0.30),
  p_T = c(0.30, 0.40, 0.50, 0.60)
)

results_all <- list()
for (i in 1:nrow(scenarios)) {
  trials <- replicate(n_trials, 
                      simulate_trial(scenarios$p_C[i], scenarios$p_T[i]),
                      simplify = FALSE)
  
  decisions <- sapply(trials, function(x) x$decision)
  n_finals <- sapply(trials, function(x) x$n_final)
  
  results_all[[i]] <- data.frame(
    Scenario = scenarios$scenario[i],
    `True p_C` = scenarios$p_C[i],
    `True p_T` = scenarios$p_T[i],
    `P(Efficacy)` = mean(decisions == "Efficacy"),
    `P(Futility)` = mean(decisions == "Futility"),
    `E[N per arm]` = mean(n_finals),
    check.names = FALSE
  )
}

op_chars <- do.call(rbind, results_all)
knitr::kable(op_chars, digits = 3,
             caption = "Operating characteristics of the Bayesian sequential design")