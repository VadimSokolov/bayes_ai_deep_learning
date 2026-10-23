# Code of chapter: Bayesian Learning
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/03-bl.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Data: data/GOOG2019.csv, data/SPMonthly.csv, data/epl.csv, data/epl_season_match_stats.json
# Packages: Lock5Data, dplyr, knitr

source("code/common.R")

# ---- Posterior Distribution for Coin Toss ----------------------------------

theta <- seq(0, 1, by = 0.1)
prior <- c(0, 0.024, 0.077, 0.132, 0.173, 0.188, 0.173, 0.132, 0.077, 0.024, 0)

# [fig-coinposterior]
barplot(prior, names.arg = theta, xlab = expression(theta), ylab = "prior", ylim = c(0, 0.2), col = "lightblue")

likelihood <- function(theta, n, Y) {
  theta^Y * (1 - theta)^(n - Y)
}
posterior <- likelihood(theta, 10, 3) * prior
posterior <- posterior / sum(posterior) # normalize
barplot(posterior, names.arg = theta, xlab = expression(theta), ylab = "posterior", ylim = c(0, 0.4), col = "lightblue")

posterior <- likelihood(theta, 100, 30) * prior
posterior <- posterior / sum(posterior) # normalize
barplot(posterior, names.arg = theta, xlab = expression(theta), ylab = "posterior", ylim = c(0, 1), col = "lightblue")

# ---- Beta-Binomial Model ---------------------------------------------------

# [fig-betadistributions]
x <- seq(0, 1, length.out = 1000)

# Define Beta distribution parameters for each curve
beta_params <- list(
  red = c(0.5, 0.5), # U-shaped
  blue = c(2, 1), # Increasing
  green = c(1, 2), # Decreasing
  purple = c(2, 2), # Bell-shaped
  orange = c(5, 2) # Asymmetric bell (skewed left)
)

# Calculate density values for each Beta distribution
densities <- lapply(beta_params, function(params) {
  dbeta(x, shape1 = params[1], shape2 = params[2])
})


# Create empty plot
plot(1, type = "n", xlim = c(0, 1), ylim = c(0, 3.2), xlab = expression(theta), ylab = "Density")
# Plot each curve
colors <- c("red", "blue", "green", "purple", "orange")
for (i in seq_along(densities)) {
  lines(x, densities[[i]], col = colors[i], lwd = 2, lty = i)
}

# Add legend
legend("top",
  legend = c(
    expression(paste(alpha, " = ", beta, " = 0.5")),
    expression(paste(alpha, " = 2, ", beta, " = 1")),
    expression(paste(alpha, " = 1, ", beta, " = 2")),
    expression(paste(alpha, " = 2, ", beta, " = 2")),
    expression(paste(alpha, " = 5, ", beta, " = 2"))
  ),
  col = colors, lty = 1:5, lwd = 2, bty = "n", ncol = 2
)

# ---- Black Swans -----------------------------------------------------------

# Prior parameters (uniform prior)
alpha <- 1
beta_param <- 1

# Data: 100 white swans, 0 black swans
T <- 100
Y <- 100 # number of white swans

# Posterior parameters
alpha_n <- alpha + Y
beta_n <- beta_param + T - Y

# Predictive probability next swan is white
pred_white <- alpha_n / (alpha_n + beta_n)
cat("P(next swan is white) =", sprintf("%.2f", pred_white), "\n")

# P(at least one black swan in next 100) via Monte Carlo
set.seed(42)
n_samples <- 10000
theta_samples <- rbeta(n_samples, alpha_n, beta_n)
prob_all_white_100 <- theta_samples^100
prob_at_least_one_black <- mean(1 - prob_all_white_100)
cat("P(at least one black swan in next 100) =", sprintf("%.2f", prob_at_least_one_black), "\n")

# [fig-blackswan]
# Plot posterior distribution
theta_grid <- seq(0.9, 1, length.out = 1000)
posterior_density <- dbeta(theta_grid, alpha_n, beta_n)
plot(theta_grid, posterior_density,
  type = "l", lwd = 2, col = "blue",
  xlab = expression(theta), ylab = "Posterior density",
  main = "Posterior after 100 white swans"
)
abline(v = pred_white, lty = 2, col = "red")
legend("topleft", c("Posterior", "Posterior mean"),
  col = c("blue", "red"), lty = c(1, 2), lwd = c(2, 1), bty = "n"
)

# ---- Poisson Model for Count Data ------------------------------------------

# [writeepl]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# d <- fromJSON("data/epl_season_match_stats.json")
# df <- lapply(d, function(game) # Loop through each "game"
# {
#   # Convert each group to a data frame.
#   # This assumes you have 6 elements each time
#   data.frame(matrix(unlist(game), ncol = 7, byrow = T))
# })
# # Now you have a list of data frames, connect them together in
# # one single dataframe
# df <- do.call(rbind, df)
# # Make column names nicer, remove row names
# colnames(df) <- names(d[[1]])
# rownames(df) <- NULL
# df$full_time_score <- as.character(df$full_time_score)
# df <- df %>% separate(full_time_score, c("home_score", "guest_score"), " : ")
# df$home_score <- as.integer(df$home_score)
# df$guest_score <- as.integer(df$guest_score)
# write.csv(df, "data/epl.csv")

# [loadepl]
df <- read.csv("data/epl.csv")
knitr::kable(head(df[, c("home_team_name", "away_team_name", "home_score", "guest_score")]))

# Extract all goals scored by Manchester United (home and away)
team_for <- c(
  df$home_score[df$home_team_name == "Manchester United"],
  df$guest_score[df$away_team_name == "Manchester United"]
)
# Calculate empirical distribution
for_byscore <- table(factor(team_for, levels = 0:4)) / length(team_for)

lambda_for <- mean(team_for)
barplot(rbind(dpois(0:4, lambda = lambda_for), for_byscore), beside = TRUE, col = c("lightblue", "darkorange3"), xlab = "Goals", ylab = "probability", main = "")
legend("topright", c("Poisson", "MU"), pch = 15, col = c("lightblue", "darkorange3"), bty = "n")

# [sumdf]
sumdf <- df %>%
  dplyr::group_by(Team = home_team_name) %>%
  dplyr::summarise(Goals_For_Home = sum(home_score), .groups = "drop") %>%
  dplyr::full_join(
    df %>%
      dplyr::group_by(Team = away_team_name) %>%
      dplyr::summarise(Goals_For_Away = sum(guest_score), .groups = "drop"),
    by = "Team"
  ) %>%
  dplyr::full_join(
    df %>%
      dplyr::group_by(Team = home_team_name) %>%
      dplyr::summarise(Goals_Against_Home = sum(guest_score), .groups = "drop"),
    by = "Team"
  ) %>%
  dplyr::full_join(
    df %>%
      dplyr::group_by(Team = away_team_name) %>%
      dplyr::summarise(Goals_Against_Away = sum(home_score), .groups = "drop"),
    by = "Team"
  )
sumdf[sumdf$Team %in% c("Manchester United", "Hull"), ] %>%
  dplyr::rename(
    GF_H = Goals_For_Home, GF_A = Goals_For_Away,
    GA_H = Goals_Against_Home, GA_A = Goals_Against_Away
  ) %>%
  knitr::kable()

lmb_mu <- (26 + 28) / 38
lmb_h <- (28 + 9) / 38

# [sim]
set.seed(19) # Yzerman
x <- rpois(100, lmb_mu)
y <- rpois(100, lmb_h)
knitr::kable(table(x, y))

# [sim2]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# df[df$home_team_name == "Manchester United" & df$away_team_name == "Hull", ] %>%
#   dplyr::select(home_team_name, away_team_name, home_score, guest_score) %>%
#   dplyr::rename(
#     Home = home_team_name, Away = away_team_name,
#     H_Score = home_score, A_Score = guest_score
#   ) %>%
#   knitr::kable()

# df[df$home_team_name == "Hull" & df$away_team_name == "Manchester United", ] %>%
#   dplyr::select(home_team_name, away_team_name, home_score, guest_score) %>%
#   dplyr::rename(
#     Home = home_team_name, Away = away_team_name,
#     H_Score = home_score, A_Score = guest_score
#   ) %>%
#   knitr::kable()

# [fig-sim-mu-hull]
set.seed(1)
x <- rpois(100, 28 / 19 * 35 / 19)
y <- rpois(100, 28 / 19 * 17 / 19)
counts <- table(x, y)
layout(matrix(1:2, 1), widths = c(1, lcm(2)))
image(z = counts, x = 0:7, y = 0:5, xlab = "MU Score", ylab = "Hull Score")
par(mar = c(2.5, 0.5, 0.7, 2.5)) # colour key
image(z = matrix(0:max(counts), 1), x = 0:1, y = 0:max(counts), axes = FALSE, xlab = "", ylab = "")
axis(4)
mtext("Number of games out of 100", side = 4, line = 1.5, cex = 0.7)
layout(1)

# [sim4]
sum(x > y)

# ---- Poisson-Gamma: Learning about an Intensity ----------------------------

# [fig-poiss]
set.seed(8) # Ovi
t <- 1:5
lmb <- 1
N <- cumsum(rpois(5, lmb))

# A: rate (beta), a: shape (alpha)
plotgamma <- function(a, A, N) {
  x <- seq(0, 10, 0.01)
  plot(x, dgamma(x, a, A), type = "l", xlab = expression(lambda), ylab = expression(p(lambda)), lwd = 2)
  at <- N + a
  At <- t + A
  mean <- at / At
  plot(N, type = "l", col = "orange", ylim = c(0, 7), xlab = "t", ylab = "N(t)", lwd = 2)
  lines(mean, col = "blue", lwd = 3, lty = 2)
  lines(qgamma(0.05, at, At), col = "grey", lwd = 2, lty = 3)
  lines(qgamma(0.95, at, At), col = "grey", lwd = 2, lty = 3)
  legend("top", c("N(t)", "Mean", "5%, 95%"), col = c("orange", "blue", "grey"), lty = 1:3, lwd = c(2, 3, 2), ncol = 3, bty = "n", cex = 0.6, seg.len = 1.2, x.intersp = 0.4)
}
plotgamma(a = 4, A = 1, N)
plotgamma(a = 1, A = 1, N)
plotgamma(a = 1, A = 5, N)
plotgamma(a = 30, A = 10, N)

# ---- Google Stock 2019 -----------------------------------------------------

p <- read.csv("data/GOOG2019.csv")$Adj.Close
n <- length(p)
r <- log(p[2:n] / p[1:(n - 1)])
hist(r, breaks = 30, col = "lightblue", main = "", xlab = "Daily log-return")

# [normal-fit]
n <- length(r)
rbar <- sum(r) / n
print(rbar)
s2 <- sum((r - rbar)^2) / (n - 1)
print(s2)
x <- seq(-0.08, 0.08, length.out = 200)
hist(r, breaks = 30, col = "lightblue", freq = F, main = "", xlab = "Daily log-return")
lines(x, dnorm(x, rbar, sqrt(s2)), col = "red", lwd = 3)

pnorm(log(1 - 0.03), rbar, sqrt(s2)) * 100

sp <- read.csv("data/SPMonthly.csv")$Adj.Close
n <- length(sp)
spret <- sp[602:n] / sp[601:(n - 1)] - 1 # Calculate returns, February 1978 to September 1987

mean(spret)
sd(spret)

# ---- Stylized Example ------------------------------------------------------

mu0 <- -1
sigma0 <- 1
ybar <- 2
sigma <- 2
mu1 <- (mu0 / sigma0^2 + ybar / sigma^2) / (1 / sigma0^2 + 1 / sigma^2)
sigma1 <- sqrt(1 / (1 / sigma0^2 + 1 / sigma^2))
sprintf("Posterior mean: %f, Posterior standard deviation: %f", mu1, sigma1)

# [fig-kalman]
# The prior distribution
mu <- seq(-4, 10, 0.01)
y <- seq(-4, 10, 0.01)
# Prior
plot(mu, dnorm(mu, mu0, sigma0), type = "l", xlab = "x", ylab = "p(x)", lwd = 3, lty = 2, col = "blue", ylim = c(0, 0.5))
# The likelihood function
lines(y, dnorm(y, ybar, sigma), type = "l", lwd = 3, lty = 3, col = "red")
# The posterior distribution
lines(y, dnorm(y, mu1, sigma1), type = "l", lwd = 3, lty = 1, col = "darkgreen")
# legend
legend("topright", c("Prior", "Data (Likelihood)", "Posterior"), lty = c(2, 3, 1), lwd = 3, col = c("blue", "red", "darkgreen"), bty = "n")

# ---- Chicago Bears 2014--2015 Season ---------------------------------------

bears <- c(-3, 8, 8, -21, -7, 14, -13, -28, -41)
print(mean(bears))
print(sd(bears))
tau <- 4
sig2 <- sd(bears) * sd(bears) / 9
print(tau^2 / (sig2 + tau^2))
print(0.29997 * -9.22)
print(pnorm(-2.76 / 18))

# ---- Satya Nadella: CEO of Microsoft ---------------------------------------

# [fig-portfolio]
getSymbols(c("MSFT", "SPY"), from = "2001-01-01", to = "2023-12-31")
s <- 3666 # 2015-07-30
prior <- 1:s
obs <- (s + 1):nrow(MSFT) # 2015-07-31 to 2023-12-29
a <- as.numeric(dailyReturn(MSFT))
c <- as.numeric(dailyReturn(SPY))
# Prior on the mean return: prior-period covariance scaled to the sample mean
n_prior <- length(prior)
mu0 <- c(mean(a[prior]), mean(c[prior]))
Sigma0 <- cov(data.frame(a = a[prior], c = c[prior])) / n_prior
# Data: the sample mean of n_obs returns has covariance Sigma / n_obs
n_obs <- length(obs)
mu <- c(mean(a[obs]), mean(c[obs]))
Sigma <- cov(data.frame(a = a, c = c)) / n_obs
# Posterior
SigmaPost <- solve(solve(Sigma0) + solve(Sigma))
muPost <- SigmaPost %*% (solve(Sigma0) %*% mu0 + solve(Sigma) %*% mu)

# [fig-portfolio-plot]
# Plot
par(mar = c(2.5, 3.2, 1.8, 0.5))
plot(a[obs], c[obs],
  xlab = "MSFT", ylab = "", xlim = c(-0.005, 0.005),
  ylim = c(-0.005, 0.005), pch = 16, cex = 0.5, las = 1, tcl = -0.3
)
title(ylab = "SPY", line = 2.2)
abline(v = 0, h = 0, col = "grey")
abline(v = mu0[1], h = mu0[2], col = "blue", lwd = 3, lty = 1) # prior
abline(v = mu[1], h = mu[2], col = "red", lwd = 3, lty = 2) # data
abline(v = muPost[1], h = muPost[2], col = "darkgreen", lwd = 3, lty = 3) # posterior
legend("top", c("Prior", "Likelihood", "Posterior"),
  lty = 1:3, lwd = 3, col = c("blue", "red", "darkgreen"),
  horiz = TRUE, bty = "n", xpd = NA, inset = c(0, -0.14), cex = 0.7
)

# ---- Mixtures of Conjugate Priors ------------------------------------------

mu0 <- c(0, 5)
sigma02 <- c(1, 1)
w0 <- c(0.5, 0.5)
y <- 2
mu3 <- (mu0 / sigma02 + y) / (1 / sigma02 + 1)
sigma3 <- 1 / (1 / sigma02 + 1)
Z <- dnorm(y - mu0, 0, sqrt(1 + sigma02)) * w0
w <- Z / sum(Z)
# To add a new line in sprintf, use "\n" inside the format string.
print("Component parameters:")
sprintf(
  "Mean = (%1.1f,%2.1f)  Var = (%1.1f,%1.1f)  weights = (%1.2f,%1.2f)",
  mu3[1], mu3[2], sigma3[1], sigma3[2], w[1], w[2]
)

# ---- Poisson for Car Counts ------------------------------------------------

cnt = c(2, 2, 1, 1, 0, 4, 3, 0, 2, 1, 1, 1, 4, 0, 2, 2, 3, 2, 4, 3, 2)

table(cnt)

# ---- Poisson MLE vs Bayes --------------------------------------------------

y = c(4,1,3,4,3,2,7,3,4,6,5,5,3,2,4,5,4,7,5,2)

# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# tb = table(y)
# observed = tb/length(y)
# predicted = dpois(1:7,lambda_mle)

# ---- Normal-Normal for Lock5Data -------------------------------------------

library(Lock5Data)
data(FootballBrain)
d = FootballBrain[FootballBrain$Group=="FBConcuss",]
plot(density(d$Hipp,bw=300), main = "", xlab = "Hippocampal volume")
