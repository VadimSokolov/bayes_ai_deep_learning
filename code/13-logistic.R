# Code of chapter: Logistic Regression and Generalized Linear Models
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/13-logistic.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Data: data/NBAspread.csv, data/df_hkjc_with_factors.csv, data/tennis.csv
# Packages: BayesLogit, dplyr, scatterplot3d, tidyverse

source("code/common.R")

# ---- Model Fitting ---------------------------------------------------------

set.seed(92) # Kuzy
x <- seq(-3, 3, length.out = 100)
y <- pnorm(x + rnorm(100)) > 0.5
probitModel <- glm(y ~ x, family = binomial(link = "probit"))
mc <- as.double(coef(probitModel))
# we want to predict outcome for x = -1
xnew <- -1
(yt <- mc[1] + mc[2] * xnew)
(pnorm(yt))
(pred <- predict(probitModel, list(x = c(xnew)), type = "response"))

u <- seq(-4, 4, length.out = 100)
nd <- dnorm(u)
plot(u, nd, type = "l", col = "red", xlab = "linear predictor", ylab = "density")
polygon(c(-4, u[u < yt], yt, yt), c(0, nd[u < yt], dnorm(yt), 0), col = "blue")

logitModel <- glm(y ~ x, family = binomial(link = "logit"))
pred_logit <- predict(logitModel, list(x = x), type = "response")
pred_probit <- predict(probitModel, list(x = x), type = "response")
plot(x, pred_probit, pch = 1, col = "red", cex = 0.9, ylab = "y")
lines(x, pred_logit, type = "p", pch = 20, cex = 0.5, col = "blue")
lines(x, y, type = "p", pch = 21, cex = 0.5, bg = "lightblue")
legend("bottomright", pch = c(20, 1), legend = c("Logit", "Probit"), col = c("blue", "red"), y.intersp = 2, bty = "n")

# ---- Example: NBA Point Spread ---------------------------------------------

NBA <- read.csv("data/NBAspread.csv")
n <- nrow(NBA)
head(NBA)

hist(NBA$spread[NBA$favwin == 1], breaks = seq(0, 40, 2), col = 5, main = "", xlab = "spread")
hist(NBA$spread[NBA$favwin == 0], breaks = seq(0, 40, 2), add = TRUE, col = 6)
legend("topright", legend = c("Favorite wins", "Favorite loses"), fill = c(5, 6), bty = "n", cex = 0.7)
boxplot(NBA$spread ~ NBA$favwin, names = c("No", "Yes"), col = c(6, 5), horizontal = TRUE, ylab = "Favorite wins", xlab = "spread")

nbareg <- glm(favwin ~ spread - 1, family = binomial, data = NBA)
nbareg %>%
  tidy() %>%
  kable()

s <- seq(0, 30, length = 100)
fit <- exp(s * nbareg$coef[1]) / (1 + exp(s * nbareg$coef[1]))
plot(s, fit, typ = "l", col = 4, lwd = 2, ylim = c(0.5, 1), xlab = "spread", ylab = "Probability favorite wins")

predict(nbareg, newdata = data.frame(spread = c(8, 4)), type = "response")

exp(0.156 * 8) / (1 + exp(0.156 * 8))
exp(0.156 * 4) / (1 + exp(0.156 * 4))

table(NBA$favwin, as.integer(predict(nbareg, type = "response") > 0.5), dnn = c("Actual", "Predicted"))

# ---- Logistic Regression for Tennis Classification -------------------------

set.seed(11) # Messier
d <- read.csv("data/tennis.csv")
d[sample(1:943, size = 5), c("Player1", "Player2", "Round", "Result", "gender", "surf")]

set.seed(10) # Lafleur
n <- dim(d)[1]
plot(d$BPW.1 + rnorm(n), d$BPW.2 + rnorm(n),
  pch = ifelse(d$Result == 1, 21, 24), col = d$Result + 2, cex = 0.6, bg = "yellow", lwd = 0.8,
  xlab = "BPW by Player 1", ylab = "BPW by Player 2"
)
legend("bottomright", c("P1 won", "P2 won"), col = c(3, 2), pch = c(21, 24), pt.bg = "yellow", bty = "n")

which(is.na(d$BPW.1)) # there is one row with NA value for the BPW.1 value and we remove it
d <- d[-171, ]
n <- dim(d)[1]
m <- glm(Result ~ BPW.1 + BPW.2 - 1, data = d, family = "binomial")
m %>%
  tidy() %>%
  kable()

table(d$Result, as.integer(m$fitted.values > 0.5), dnn = c("Actual", "Predicted"))

set.seed(91) # Tavares
plot(d$BPW.1 + rnorm(n), d$BPW.2 + rnorm(n),
  pch = ifelse(d$Result == 1, 21, 24), col = d$Result + 2, cex = 0.6, bg = "yellow", lwd = 0.8,
  xlab = "BPW by Player 1", ylab = "BPW by Player 2"
)
legend("bottomright", c("P1 won", "P2 won"), col = c(3, 2), pch = c(21, 24), pt.bg = "yellow", bty = "n")

x <- seq(0, 30, length.out = 200)
y <- -m$coefficients[1] * x / m$coefficients[2]
lines(x, y, lwd = 2, col = "red")

exp(0.4019)

predict.glm(m, newdata = data.frame(BPW.1 = c(0), BPW.2 = c(0)), type = "response")
predict.glm(m, newdata = data.frame(BPW.1 = c(1), BPW.2 = c(0)), type = "response")

predict.glm(m, newdata = data.frame(BPW.1 = c(0), BPW.2 = c(0)), type = "response")
predict.glm(m, newdata = data.frame(BPW.1 = c(3), BPW.2 = c(0)), type = "response")

d$upset <- (fitted(m) > 0.5) != (d$Result == 1)
tab <- table(Gender = d$gender, Upset = d$upset)
tab

pt <- prop.test(tab[, "TRUE"], rowSums(tab))
pt

# ---- Horse Race Betting ----------------------------------------------------

# [load-hkjc]
library(tidyverse)

# Load HKJC race data
df <- read_csv("data/df_hkjc_with_factors.csv",
  show_col_types = FALSE
)

# Identify favorite in each race and create race-level dataset
race_df <- df |>
  group_by(race_id) |>
  mutate(is_favorite = rank(-public_prob, ties.method = "first") == 1) |>
  filter(is_favorite) |>
  ungroup() |>
  dplyr::select(
    race_id, venue, field_size, date, public_prob, win, win_odds,
    jockey_win_rate, trainer_win_rate, draw_normalized, rating_diff
  )

cat(sprintf(
  "Dataset: %d races from %s to %s\n",
  nrow(race_df), min(race_df$date), max(race_df$date)
))
cat(sprintf("Favorite win rate: %.1f%%\n", mean(race_df$win) * 100))

# [betting-model]
glm.fit <- glm(win ~ public_prob, data = race_df, family = binomial)
glm.fit %>%
  tidy() %>%
  kable()

# [betting-prob-plot]
x <- seq(0.15, 0.45, length.out = 100)
y <- predict(glm.fit, newdata = data.frame(public_prob = x), type = "response")
plot(x, y,
  type = "l", col = "red", lwd = 2,
  xlab = "Public Implied Probability", ylab = "P(Favorite Wins)"
)
abline(a = 0, b = 1, lty = 2, col = "gray50") # Perfect calibration line
legend("topleft",
  legend = c("Model prediction", "Perfect calibration"),
  col = c("red", "gray50"), lty = c(1, 2), bty = "n"
)

# [betting-confusion]
pred <- predict(glm.fit, type = "response")
confusion_matrix <- table(
  Actual = factor(race_df$win, levels = c(0, 1)),
  Predicted = factor(as.integer(pred > 0.3), levels = c(0, 1))
)
# Convert to rates
cm_rates <- prop.table(confusion_matrix, margin = 1)
cm_rates %>% kable(digits = 3)

# [betting-roc-fn]
roc <- function(p, y, ...) {
  y <- factor(y, levels = c(0, 1))
  n <- length(p)
  p <- as.vector(p)
  alpha <- seq(0, 1, length.out = 100)
  Q <- p > matrix(rep(alpha, n), ncol = 100, byrow = TRUE)
  # Calculate specificity and sensitivity, handling missing classes
  if (sum(y == 0) > 0) {
    specificity <- colMeans(!Q[y == 0, , drop = FALSE])
  } else {
    specificity <- rep(1, 100)
  }
  if (sum(y == 1) > 0) {
    sensitivity <- colMeans(Q[y == 1, , drop = FALSE])
  } else {
    sensitivity <- rep(0, 100)
  }
  return(list(specificity = specificity, sensitivity = sensitivity, alpha = alpha))
}

# [betting-roc-plot]
res <- roc(p = pred, y = race_df$win)
plot(1 - res$specificity, res$sensitivity,
  type = "l", bty = "n",
  xlab = "1 - Specificity", ylab = "Sensitivity",
  main = "ROC: Predicting Favorite Wins", lwd = 3
)
abline(a = 0, b = 1, lty = 2, col = 8)

# Mark specific thresholds
points(
  x = 1 - mean((pred < 0.3)[race_df$win == 0]),
  y = mean((pred > 0.3)[race_df$win == 1]),
  cex = 1.5, pch = 24, col = "red", bg = "white", lwd = 2
)
points(
  x = 1 - mean((pred < 0.5)[race_df$win == 0]),
  y = mean((pred > 0.5)[race_df$win == 1]),
  cex = 1.5, pch = 22, col = "blue", bg = "white", lwd = 2
)
legend("bottomright",
  pch = c(24, 22), col = c("red", "blue"), pt.bg = "white", pt.lwd = 2,
  legend = c("alpha=0.3", "alpha=0.5"), bty = "n", title = "cutoff"
)

# [betting-multi]
race_df$venue_ST <- as.integer(race_df$venue == "ST")

glm.fit2 <- glm(win ~ public_prob + field_size + venue_ST,
  data = race_df, family = binomial
)
glm.fit2 %>%
  tidy() %>%
  kable()

# [betting-confounding]
boxplot(field_size ~ factor(venue, levels = c("HV", "ST"), labels = c("Happy Valley", "Sha Tin")),
  data = race_df,
  xlab = "Venue", ylab = "Field Size", col = c(2, 3)
)
glm.venue <- glm(win ~ public_prob + venue_ST, data = race_df, family = binomial)
fs_mean <- tapply(race_df$field_size, race_df$venue, mean)

# [betting-adjusted]
# Predictions for 10-horse races at each venue
x_hv <- data.frame(
  public_prob = seq(0.2, 0.4, length.out = 50),
  field_size = 10, venue_ST = 0
)
x_st <- data.frame(
  public_prob = seq(0.2, 0.4, length.out = 50),
  field_size = 10, venue_ST = 1
)
y_hv <- predict(glm.fit2, newdata = x_hv, type = "response")
y_st <- predict(glm.fit2, newdata = x_st, type = "response")

plot(x_hv$public_prob, y_hv,
  type = "l", col = "red", lwd = 2,
  xlab = "Public Implied Probability", ylab = "P(Favorite Wins)",
  ylim = c(0.2, 0.5)
)
lines(x_st$public_prob, y_st, col = "blue", lwd = 2, lty = 2)
legend("topleft",
  legend = c("Happy Valley", "Sha Tin"),
  col = c("red", "blue"), lwd = 2, lty = c(1, 2), bty = "n"
)

# [betting-payoff]
# Recalculate predictions using our betting model from the earlier example
pred_bet <- predict(glm.fit2, type = "response")
res_bet <- roc(p = pred_bet, y = race_df$win)
alpha <- res_bet$alpha
specificity <- res_bet$specificity # correctly identify non-winners
sensitivity <- res_bet$sensitivity # correctly identify winners

# Payoffs: win gives +1.5, lose gives -1, no bet gives 0
# sensitivity = P(predict win | actual win), (1-specificity) = P(predict win | actual lose)
# Expected profit = P(win) * sensitivity * 1.5 - P(lose) * (1-specificity) * 1
base_rate <- mean(race_df$win) # ~30%
profit <- base_rate * sensitivity * 1.5 - (1 - base_rate) * (1 - specificity) * 1
par(mar = c(2.5, 3, 0.7, 0.5))
plot(alpha, profit,
  type = "l", xlab = expression("Threshold " * alpha), ylab = "", yaxt = "n",
  lwd = 3, col = "red", cex.lab = 0.8
)
axis(2, at = seq(-0.25, 0, by = 0.05), las = 1, mgp = c(1.5, 0.6, 0))
title(ylab = "Expected Profit ($)", line = 2, cex.lab = 0.8)
abline(h = 0, lty = 2)

# [betting-optimal-threshold]
real_return <- mean((race_df$win * race_df$win_odds - 1)[pred_bet > alpha[which.max(profit)]])
if (any(profit > 0)) {
  cat(sprintf(
    "Profitable threshold range: %.2f to %.2f\n",
    min(alpha[profit > 0]), max(alpha[profit > 0])
  ))
  cat(sprintf("Optimal threshold: %.2f\n", alpha[which.max(profit)]))
  cat(sprintf("Maximum expected profit: $%.3f per race\n", max(profit)))
} else {
  cat("No threshold produces positive expected profit at these odds\n")
}

# ---- Kernel Trick ----------------------------------------------------------

gencircledata <- function(numSamples, radius, noise) {
  d <- matrix(0, ncol = 3, nrow = numSamples) # matrix to store our generated data
  # Generate positive points inside the circle.
  for (i in 1:(numSamples / 2)) {
    r <- runif(1, 0, radius * 0.4)
    angle <- runif(1, 0, 2 * pi)
    x <- r * sin(angle)
    y <- r * cos(angle)
    noiseX <- runif(1, -radius, radius) * noise
    noiseY <- runif(1, -radius, radius) * noise
    d[i, ] <- c(0, x + noiseX, y + noiseY)
  }

  # Generate negative points outside the circle.
  for (i in (numSamples / 2 + 1):numSamples) {
    r <- runif(1, radius * 0.8, radius)
    angle <- runif(1, 0, 2 * pi)
    x <- r * sin(angle)
    y <- r * cos(angle)
    noiseX <- runif(1, -radius, radius) * noise
    noiseY <- runif(1, -radius, radius) * noise
    d[i, ] <- c(1, x + noiseX, y + noiseY)
  }
  colnames(d) <- c("label", "x1", "x2")
  return(d)
}

# [fig-circle-data]
set.seed(13) # Sundin
d <- gencircledata(numSamples = 200, radius = 1, noise = 0.001)
plot(d[, 2], d[, 3], col = d[, 1] + 1, pch = 19, xlab = expression(x[1]), ylab = expression(x[2]), asp = 1)

phi <- function(x1, x2) {
  z1 <- x1^2
  z2 <- sqrt(2) * x1 * x2
  z3 <- x2^2
  return(cbind(z1, z2, z3))
}

# [scatterplot3d]
library("scatterplot3d")

# Generate sample 2D data (you can replace this with your actual data)
# Apply the transformation
transformed_data <- phi(d[, 2], d[, 3])
par(xpd = TRUE)
scatterplot3d(transformed_data,
  color = ifelse(d[, 1] == 0, "red", "blue"), pch = ifelse(d[, 1] == 0, 19, 17), cex.symbols = 0.5,
  xlab = expression(z[1] == x[1]^2), ylab = expression(z[2] == sqrt(2) * x[1] * x[2]), zlab = expression(z[3] == x[2]^2),
  main = "3D Scatter Plot of Transformed Data", angle = 40, scale.y = 0.8, mar = c(3, 2.6, 1.5, 2), cex.axis = 0.5,
  grid = FALSE, box = FALSE
)
par(xpd = FALSE)

# ---- The Data-Augmentation Strategy ----------------------------------------

bayesian_logit_pg <- function(y, X, n_iter = 5000, burn_in = 1000) {
  n <- length(y)
  p <- ncol(X)
  # Prior specification (weakly informative)
  beta_prior_mean <- rep(0, p)
  beta_prior_prec <- diag(0.01, p) # Precision matrix

  # Storage for samples
  beta_samples <- matrix(0, n_iter, p)
  omega_samples <- matrix(0, n_iter, n)

  # Initialize
  beta <- rep(0, p)

  for (iter in 1:n_iter) {
    # Step 1: Sample omega (auxiliary variables)
    psi <- X %*% beta
    omega <- rpg(n, h = 1, z = psi)

    # Step 2: Sample beta (regression coefficients)
    # Posterior covariance and mean
    V_omega <- solve(t(X) %*% diag(omega) %*% X + beta_prior_prec)
    kappa <- y - 0.5
    m_omega <- V_omega %*% (t(X) %*% kappa + beta_prior_prec %*% beta_prior_mean)

    # Sample from multivariate normal
    beta <- mvrnorm(1, m_omega, V_omega)

    # Store samples
    beta_samples[iter, ] <- beta
    omega_samples[iter, ] <- omega
  }

  # Return samples after burn-in
  list(
    beta = beta_samples[(burn_in + 1):n_iter, ],
    omega = omega_samples[(burn_in + 1):n_iter, ],
    n_samples = n_iter - burn_in
  )
}

# [bayesian-logit-implementation]
library("BayesLogit")

# Bayesian Logistic Regression with Polya-Gamma Data Augmentation
# Example usage with simulated data
set.seed(123)
n <- 100
X <- cbind(1, matrix(rnorm(n * 2), n, 2)) # Intercept + 2 predictors
beta_true <- c(-0.5, 1.2, -0.8)
logits <- X %*% beta_true
probs <- 1 / (1 + exp(-logits))
y <- rbinom(n, 1, probs)

# Fit model
results <- bayesian_logit_pg(y, X, n_iter = 3000, burn_in = 500)

# Posterior summaries
posterior_means <- colMeans(results$beta)
posterior_sds <- apply(results$beta, 2, sd)
# Visualize posterior distributions
par(mfrow = c(1, 3))
for (j in 1:3) {
  hist(results$beta[, j],
    breaks = 30, main = "", xlab = bquote(beta[.(j - 1)]),
    col = "lightblue", border = "white", cex.axis = 0.75, cex.lab = 1.05
  )
  abline(v = beta_true[j], col = "red", lwd = 2, lty = 2)
  abline(v = posterior_means[j], col = "blue", lwd = 2)
}
par(mfrow = c(1, 1))
