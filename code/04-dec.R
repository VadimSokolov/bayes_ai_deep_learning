# Code of chapter: Utility, Risk and Decisions
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/04-dec.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Packages: knitr, tidyr

source("code/common.R")

# ---- Risk Aversion ---------------------------------------------------------

# [fig-risk-aversion]
w <- seq(0.2, 2, length.out = 500)
gamma <- 2
# Plot this data frame
df <- data.frame(
  w = w,
  logu = log(w),
  kelly = (w^(1 - gamma) - 1) / (1 - gamma)
)
ulab <- expression("log utility", "power utility" ~ (gamma == 2))
# 3. Plot use different y-scales for
ggplot(df, aes(x = w)) +
  geom_line(aes(y = logu, color = "log utility", linetype = "log utility"), size = 1.3) +
  geom_line(aes(y = kelly, color = "power utility (gamma=2)", linetype = "power utility (gamma=2)"), size = 1.3) +
  geom_vline(xintercept = c(0.5, 1, 1.5), linetype = "dashed", color = "black") +
  scale_color_manual(values = c("log utility" = "blue", "power utility (gamma=2)" = "red"), labels = ulab) +
  scale_linetype_manual(values = c("log utility" = "solid", "power utility (gamma=2)" = "dotdash"), labels = ulab) +
  labs(
    title = "Concave Utility Functions",
    x = "Wealth (w)",
    y = "Utility",
    color = "Utility Type",
    linetype = "Utility Type"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom", legend.key.width = unit(1.5, "cm"))

w1 <- 0.5
w2 <- 1.5
p <- 0.5
E_W <- p * w1 + (1 - p) * w2

# Define utility function (handling log case)
u_crra <- function(w, gamma) {
  if (abs(gamma - 1) < 1e-4) {
    return(log(w))
  }
  (w^(1 - gamma) - 1) / (1 - gamma)
}

# Inverse utility to find CE
u_inv <- function(u, gamma) {
  if (abs(gamma - 1) < 1e-4) {
    return(exp(u))
  }
  (u * (1 - gamma) + 1)^(1 / (1 - gamma))
}

gammas <- c(0, 0.5, 1, 2, 4)
results <- data.frame(Gamma = gammas)
results$CE <- sapply(gammas, function(g) {
  eu <- p * u_crra(w1, g) + (1 - p) * u_crra(w2, g)
  u_inv(eu, g)
})
results$RiskPremium <- E_W - results$CE

knitr::kable(results,
  digits = 3,
  col.names = c("Risk Aversion ($\\gamma$)", "Certainty Equivalent", "Risk Premium"),
  caption = "Impact of risk aversion on the valuation of a gamble with outcomes {0.5, 1.5}."
)

# ---- Allais Paradox: Independence Axiom ------------------------------------

E1 <- 5 * 1
E2 <- 25 * 0.1 + 5 * 0.89 + 0 * 0.01
E3 <- 5 * 0.11 + 0 * 0.89
E4 <- 25 * 0.1 + 0 * 0.9
print(c(E1 - E2, E3 - E4), digits = 3)

# ---- Medical Testing -------------------------------------------------------

0.02 * 90 + 0.98 * 90 # treat
0.02 * 0 + (1 - 0.02) * 100 # do not treat

p <- seq(0, 1, 0.01)
plot(p, 100 * (1 - p), type = "l", xlab = "p", ylab = "E[U(a)]")
abline(h = 90, col = "red")
legend("bottomleft", legend = c(
  TeX("$E[U(a_N)]$"),
  TeX("$E[U(a_T)]$")
), col = c("black", "red"), lty = 1, bty = "n")

# P(D | T = 0) = P(T = 0 | D) P(D) / P(T = 0)
pdt0 <- 0.05 * 0.02 / (0.05 * 0.02 + 0.99 * 0.98)
# Expected utility given the test is negative
# E[U(a_N | T=0)]
UN0 <- pdt0 * 0 + (1 - pdt0) * 100
# E[U(a_T | T=0)]
UT0 <- pdt0 * 90 + (1 - pdt0) * 90

sprintf("P(D | T = 0) : %.4f, E[U(a_N | T=0)] : %.1f, E[U(a_T | T=0)] : %.1f", pdt0, UN0, UT0)

# P(D | T = 1) = P(T = 1 | D) P(D) / P(T = 1)
pdt <- 0.95 * 0.02 / (0.95 * 0.02 + 0.01 * 0.98)
# E[U(a_N | T=1)]
UN1 <- pdt * 0 + (1 - pdt) * 100
# E[U(a_T | T=1)]
UT1 <- pdt * 90 + (1 - pdt) * 90

sprintf("P(D | T = 1) : %.4f, E[U(a_N | T=1)] : %.1f, E[U(a_T | T=1)] : %.1f", pdt, UN1, UT1)

# P(T=1) = P(T=1 | D) P(D) + P(T=1 | D=0) P(D=0)
pt <- 0.95 * 0.02 + 0.01 * 0.98
# P(T=0) = P(T=0 | D) P(D) + P(T=0 | D=0) P(D=0)
pt0 <- 0.05 * 0.02 + 0.99 * 0.98
# Expected utility of the strategy
sprintf("P(T=1) : %.4f, P(T=0) : %.4f, E[U(a)] : %.1f", pt, pt0, pt * UT1 + pt0 * UN0)

# ---- Marble Game -----------------------------------------------------------

set.seed(17)
n_rounds <- 50

# A's payoff, matching f_A(p, p_1) above: $3 on red-red, $1 on blue-blue,
# nothing on a mismatch (the \$2 goes to B, so it is not a loss for A).
payoff <- function(a, b) {
  if (a == b) {
    if (a == "R") {
      return(3)
    } else {
      return(1)
    }
  } else {
    return(0) # B collects $2; A collects nothing
  }
}

# Tit-for-tat: start with R, then copy opponent's last move
tit_for_tat <- function(opponent_history) {
  if (length(opponent_history) == 0) {
    return("R")
  }
  return(tail(opponent_history, 1))
}

# Simulate against different strategies
simulate_game <- function(b_strategy, n = n_rounds) {
  a_history <- c()
  b_history <- c()
  payoffs <- c()

  for (i in 1:n) {
    a_move <- tit_for_tat(b_history)
    b_move <- b_strategy(i, a_history)

    a_history <- c(a_history, a_move)
    b_history <- c(b_history, b_move)
    payoffs <- c(payoffs, payoff(a_move, b_move))
  }
  return(cumsum(payoffs))
}

# B strategies
b_always_red <- function(round, a_hist) "R"
b_always_blue <- function(round, a_hist) "B"
b_alternating <- function(round, a_hist) if (round %% 2 == 1) "R" else "B"
b_random <- function(round, a_hist) sample(c("R", "B"), 1)
b_tit_for_tat <- function(round, a_hist) {
  if (length(a_hist) == 0) {
    return("R")
  }
  return(tail(a_hist, 1))
}

# Run simulations
results <- data.frame(
  round = 1:n_rounds,
  vs_always_red = simulate_game(b_always_red),
  vs_always_blue = simulate_game(b_always_blue),
  vs_alternating = simulate_game(b_alternating),
  vs_random = simulate_game(b_random),
  vs_tit_for_tat = simulate_game(b_tit_for_tat)
)

# Plot
library(tidyr)
results_long <- pivot_longer(results, -round,
  names_to = "opponent", values_to = "cumulative_payoff"
)
results_long$opponent <- factor(results_long$opponent,
  levels = c(
    "vs_always_red", "vs_tit_for_tat", "vs_random",
    "vs_always_blue", "vs_alternating"
  ),
  labels = c(
    "B: Always Red", "B: Tit-for-Tat", "B: Random",
    "B: Always Blue", "B: Alternating"
  )
)

# Always Red and Tit-for-Tat coincide exactly: Always Red is wide and light, Tit-for-Tat dark and dashed on top.
ggplot(results_long, aes(
  x = round, y = cumulative_payoff,
  color = opponent, linetype = opponent, linewidth = opponent
)) +
  geom_line() +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
  scale_color_manual(values = c("#F4A582", "#222222", "#C9A100", "#2166AC", "#9970AB")) +
  scale_linetype_manual(values = c("solid", "dashed", "dotted", "longdash", "dotdash")) +
  scale_linewidth_manual(values = c(2.6, 1, 1, 1, 1)) +
  labs(
    x = "Round", y = "Cumulative Payoff for A",
    color = "Opponent Strategy", linetype = "Opponent Strategy",
    linewidth = "Opponent Strategy"
  ) +
  theme_minimal() +
  theme(legend.position = "right", legend.key.width = unit(1.2, "cm"))

# Average per-round payoff in the last 20 rounds
# Calculate average payoffs for last 20 rounds
payoff_summary <- data.frame(
  Opponent = c("Always Red", "Tit-for-Tat", "Random", "Always Blue", "Alternating"),
  `Average Payoff` = c(
    mean(diff(c(0, results$vs_always_red))[(n_rounds - 19):n_rounds]),
    mean(diff(c(0, results$vs_tit_for_tat))[(n_rounds - 19):n_rounds]),
    mean(diff(c(0, results$vs_random))[(n_rounds - 19):n_rounds]),
    mean(diff(c(0, results$vs_always_blue))[(n_rounds - 19):n_rounds]),
    mean(diff(c(0, results$vs_alternating))[(n_rounds - 19):n_rounds])
  ),
  check.names = FALSE
)

kable(payoff_summary,
  caption = "Average payoff per round (last 20 rounds)",
  digits = 2
)
