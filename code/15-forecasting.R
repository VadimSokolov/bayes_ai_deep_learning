# Code of chapter: Forecasting
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/15-forecasting.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Data: data/AAPL.csv, data/GSPC.csv, data/timeseries/model12-sp500.RData, data/timeseries/model123.RData, data/timeseries/rec_data_20160613.csv, data/timeseries/tsmodel-nber.RData
# Packages: bsts, fma, fpp2, ggplot2, gridExtra, knitr, xts

source("code/common.R")

# ---- Structural Time Series Models -----------------------------------------

# [fig-randomwalk]
library(xts)
AAPL <- read.csv("data/AAPL.csv")
AAPL <- xts(AAPL, order.by = as.Date(rownames(AAPL), "%Y-%m-%d"))
set.seed(17) # Kharlamov
p <- as.numeric(AAPL$AAPL.Adjusted)
mu <- mean(diff(p), na.rm = T)
s <- 0.1 * sd(diff(p), na.rm = T)
n <- length(p)
rw <- rep(p[1], n)
for (i in 2:n) {
  rw[i] <- max(min(p), rw[i - 1] + rnorm(1, mu, s))
}
plot(p, xlab = "Trading day", ylab = "AAPL Price", type = "l", lwd = 2, col = "blue")
plot(rw, type = "l", xlab = "Trading day", ylab = "AAPL Price", lwd = 2, col = "red")

# ---- Nowcasting ------------------------------------------------------------

# [fig-bsts]
library(bsts) # load the bsts package
data(iclaims) # bring the initial.claims data into scope
plot(initial.claims$iclaimsNSA, lwd = 2, xlab = "Year", ylab = "Initial claims (standardized)", col = "blue")

# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# ss <- AddLocalLinearTrend(list(), initial.claims$iclaimsNSA)
# ss <- AddSeasonal(ss, initial.claims$iclaimsNSA, nseasons = 52)
# model1 <- bsts(initial.claims$iclaimsNSA, state.specification = ss, niter = 1000)

load("data/timeseries/model123.RData")

names(model1)

# [fig-claims]
par(mar = c(4, 4, 2, 0))
model1$state.specification[[1]]$name <- dimnames(model1$state.contributions)[[2]][1] <- "Trend"
model1$state.specification[[2]]$name <- dimnames(model1$state.contributions)[[2]][2] <- "Seasonal"
plot(model1, ylab = "Claims (standardized)")
plot(model1, "components", ylab = "Contribution")

# [predict1]
par(mar = c(4, 4, 0.5, 0))
pred1 <- predict(model1, horizon = 12)
plot(pred1, plot.original = 156, ylab = "Claims (standardized)", xlab = "Year")

# ---- Regression with Spike and Slab Priors ---------------------------------

# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# # Fit a bsts model with expected model size 1, the default.
# model2 <- bsts(iclaimsNSA ~ ., state.specification = ss, niter = 1000, data = initial.claims)
# # Fit a bsts model with expected model size 5, to include more coefficients.
# model3 <- bsts(iclaimsNSA ~ ., state.specification = ss, niter = 1000, data = initial.claims, expected.model.size = 5) # Passed to SpikeSlabPrior.

# [plotmodel2]
par(mar = c(4, 4, 3, 0), cex.axis = 0.75, cex.lab = 1.05, cex.main = 0.75)
model2$state.specification[[1]]$name <- dimnames(model2$state.contributions)[[2]][1] <- "Trend"
model2$state.specification[[2]]$name <- dimnames(model2$state.contributions)[[2]][2] <- "Seasonal"
plot(model2, "comp", ylab = "Contribution")

# [fig-model23]
op <- par(ps = 4, cex.axis = 1.5, cex.lab = 2.1, mar = c(2.5, 0, 0.3, 0.5)) # bsts sets the left margin from the width of the names at this font size
plot(model2, "coef")
plot(model3, "coef")
par(op)

# [fig-bstshist]
# unemployment.office
hist(model3$coefficients[-(1:SuggestBurn(0.1, model3)), 10], breaks = 25, main = "", xlab = expression(beta * ", unemployment office"), col = "lightblue")
# idaho.unemployment
hist(model3$coefficients[-(1:SuggestBurn(0.1, model3)), 3], breaks = 25, main = "", xlab = expression(beta * ", Idaho unemployment"), col = "lightblue")
hist(model2$coefficients[-(1:SuggestBurn(0.1, model2)), 3], breaks = 25, main = "", xlab = expression(beta * ", Idaho unemployment"), col = "lightblue")

# ---- Model Diagnostics: Did the Google Data Help? --------------------------

# [compareRUE]
# bsts::CompareBstsModels with shorter axis titles, a gap between the two panels and an unboxed legend in the lower right
CompareBstsModels <- function(model.list, colors, lwd = 2, xlab = "Time") {
  burn <- SuggestBurn(0.1, model.list[[1]])
  cum <- sapply(model.list, function(m) cumsum(abs(colMeans(bsts.prediction.errors(m, burn = burn)$in.sample))))
  idx <- model.list[[1]]$timestamp.info$timestamps
  op <- par(mfrow = c(2, 1), mar = c(0.5, 2.5, 0.5, 0.5))
  plot(zoo(cum[, 1], idx), ylim = range(cum), ylab = "Cumulative abs. error", xaxt = "n", lwd = lwd, col = colors[1])
  axis(2)
  for (i in 2:ncol(cum)) lines(zoo(cum[, i], idx), lty = i, col = colors[i], lwd = lwd)
  grid(nx = NA)
  legend("bottomright", names(model.list), lty = 1:ncol(cum), col = colors, lwd = lwd, bg = "white", box.col = "white", cex = 0.7)
  par(mar = c(2.5, 2.5, 0.5, 0.5))
  plot(model.list[[1]]$original.series, main = "", ylab = "Claims (standardized)", xlab = xlab)
  grid(nx = NA)
  par(op)
  invisible(cum)
}
CompareBstsModels(
  list(
    "Model 1" = model1,
    "Model 2" = model2,
    "Model 3" = model3
  ),
  colors = c("black", "red", "blue")
)

# ---- Long-term Forecasting -------------------------------------------------

# [sp500]
GSPC <- read.csv("data/GSPC.csv")
GSPC <- xts(GSPC, order.by = as.Date(rownames(GSPC), "%Y-%m-%d"))
knitr::kable(head(GSPC))
plot(GSPC$GSPC.Adjusted, main = "")

# [spmodel]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# sp500 <- GSPC$GSPC.Adjusted
# ss1 <- AddLocalLinearTrend(list(), sp500)
# model1 <- bsts(sp500, state.specification = ss1, niter = 1000)
# ss2 <- AddSemilocalLinearTrend(list(), sp500)
# model2 <- bsts(sp500, state.specification = ss2, niter = 1000)

# [fig-sp500]
load("data/timeseries/model12-sp500.RData")
pred1 <- predict(model1, horizon = 360)
pred2 <- predict(model2, horizon = 360)
plot(pred2, plot.original = 360, ylim = range(pred1), ylab = "S&P 500 closing value", xlab = "Year")
plot(pred1, plot.original = 360, ylim = range(pred1), ylab = "S&P 500 closing value", xlab = "Year")

# ---- Recession Modeling Using Non-Gaussian Data ----------------------------

# [nber]
dat <- read.csv("data/timeseries/rec_data_20160613.csv")
rec <- ts(dat$nber, start = c(1973, 1), end = c(2016, 5), frequency = 12)
plot(rec, type = "l", col = "blue", ylab = "Recession")

# [shift-nber]
h <- 0
# predict h months ahead
y.h <- dat$nber[-(1:h)]
hh <- length(dat$nber) - h
dat.h <- dat[1:hh, -1]
# h=0 is a special case
if (h == 0) y.h <- dat$nber
if (h == 0) dat.h <- dat[, -1]

# [gdp-model]
# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# # Because 'y' is 0/1 and the state is on the logit scale the default prior
# # assumed by AddLocalLevel won't work here, so we need to explicitly set the
# # priors for the variance of the state innovation errors and the initial value
# # of the state at time 0.  The 'SdPrior' and 'NormalPrior' functions used to
# # define these priors are part of the Boom package.  See R help for
# # documentation.  Note the truncated support for the standard deviation of the
# # random walk increments in the local level model.
# ss <- AddLocalLevel(list(), y.h,
#   sigma.prior = SdPrior(
#     sigma.guess = .1,
#     sample.size = 1,
#     upper.limit = 1
#   ),
#   initial.state.prior = NormalPrior(0, 5)
# )
# # Tell bsts that the observation equation should be a logistic regression by
# # passing the 'family = "logit"' argument.
# ts.model <- bsts(y.h ~ ., ss, data = dat.h, niter = 20000, family = "logit", expected.model.size = 10)

# [load-nber-model]
load("data/timeseries/tsmodel-nber.RData")

# [nber-plot]
op <- par(ps = 6, cex.axis = 1, cex.lab = 1.4, mar = c(2.5, 2.5, 0.5, 1))
plot(ts.model, "coef")
plot(ts.model, ylab = expression(logit(p[t])), xlab = "Month")
r <- rle(y.h == 1)
e <- cumsum(r$lengths)
for (i in which(r$values)) rect(e[i] - r$lengths[i] + 1, par("usr")[3], e[i], par("usr")[4], col = adjustcolor("blue", 0.2), border = NA)
par(op)

# [ts.model]
incl <- colMeans(ts.model$coefficients[-(1:SuggestBurn(0.1, ts.model)), ] != 0)
incl <- sort(incl[incl > 0.1], decreasing = TRUE)
plot(ts.model, "predictors", show.legend = FALSE, ylim = c(-4.8, 13.5))
legend("top", c("recession", paste(round(incl, 2), names(incl))), lty = c(1, seq_along(incl)), lwd = c(3, rep(1, length(incl))), col = c("blue", gray(1 - incl)), ncol = 3, bty = "n", cex = 0.7)
title(xlab = "Month")

# ---- Modern Era Forecasting ------------------------------------------------

# [whitenoise]
set.seed(97) # McDavid
yt <- rnorm(100)
plot(yt, type = "l", xlab = "Time", ylab = expression(y[t]))

# [fig-stationary]
library(fma)
library(fpp2)
library(gridExtra)
pl <- list()
pl[[1]] <- autoplot(dj, main = "(a)", xlab = "Day", ylab = "Dow Jones index") + theme_bw() + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank())
pl[[2]] <- autoplot(diff(dj), main = "(b)", xlab = "Day", ylab = "Daily change") + theme_bw() + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank())
pl[[3]] <- autoplot(strikes, main = "(c)", xlab = "Year", ylab = "Strikes") + theme_bw() + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank())
pl[[4]] <- autoplot(fma::hsales, main = "(d)", xlab = "Year", ylab = "House sales") + theme_bw() + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank())
pl[[5]] <- autoplot(eggs, main = "(e)", xlab = "Year", ylab = "Egg price") + theme_bw() + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank())
pl[[6]] <- autoplot(pigs, main = "(f)", xlab = "Year", ylab = "Pigs slaughtered") + theme_bw() + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank())
pl[[7]] <- autoplot(lynx, main = "(g)", xlab = "Year", ylab = "Lynx trapped") + theme_bw() + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank())
pl[[8]] <- autoplot(beer, main = "(h)", xlab = "Year", ylab = "Beer production") + theme_bw() + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank())
pl[[9]] <- autoplot(elec, main = "(i)", xlab = "Year", ylab = "Electricity") + theme_bw() + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank())
gridExtra::marrangeGrob(pl, nrow = 3, ncol = 3, top = "")

# ---- Kalman Filter for Robot Localization ----------------------------------

# [kf-prior]
xhat <- c(0.2, -0.2)
Sigma <- matrix(c(
  0.4, 0.3,
  0.3, 0.45
), ncol = 2)
x1 <- seq(-2, 4, length = 151)
x2 <- seq(-4, 2, length = 151)
f <- function(x1, x2, mean = xhat, varcov = Sigma) {
  # density of the bivariate normal N(mean, varcov)
  d <- cbind(x1 - mean[1], x2 - mean[2])
  exp(-rowSums(d %*% solve(varcov) * d) / 2) / (2 * pi * sqrt(det(varcov)))
}
z <- outer(x1, x2, f)
mycols <- topo.colors(100, 0.5)
image(x1, x2, z,
  col = mycols, main = "Prior density",
  xlab = expression("x"[1]), ylab = expression("x"[2]), asp = 1
)
contour(x1, x2, z, add = TRUE, drawlabels = FALSE)
points(0.2, -0.2, pch = 19)
text(-0.65, 0.65, labels = expression(hat(x)), cex = 0.8)

# [kf-measure]
R <- 0.5 * Sigma
z2 <- outer(x1, x2, f, mean = c(2.4, -1.9), varcov = R)
image(x1, x2, z2,
  col = mycols, main = "Sensor density",
  xlab = expression("x"[1]), ylab = expression("x"[2]), asp = 1
)
contour(x1, x2, z2, add = TRUE, drawlabels = FALSE)
points(2.4, -1.9, pch = 19)
text(3.1, -2.6, labels = "y", cex = 0.8)
contour(x1, x2, z, add = TRUE, drawlabels = FALSE)
points(0.2, -0.2, pch = 19)
text(-0.65, 0.65, labels = expression(hat(x)), cex = 0.8)

G <- diag(2)
y <- c(2.4, -1.9)
xhatf <- xhat + Sigma %*% t(G) %*% solve(G %*% Sigma %*% t(G) + R) %*% (y - G %*% xhat)
Sigmaf <- Sigma - Sigma %*% t(G) %*% solve(G %*% Sigma %*% t(G) + R) %*% G %*% Sigma

# [kf-post]
z3 <- outer(x1, x2, f, mean = c(xhatf), varcov = Sigmaf)
image(x1, x2, z3,
  col = mycols,
  xlab = expression("x"[1]), ylab = expression("x"[2]),
  main = "Filtered density", asp = 1
)
contour(x1, x2, z3, add = TRUE, drawlabels = FALSE)
points(xhatf[1], xhatf[2], pch = 19)
text(0.97, -2.55, labels = expression(hat(x)[f]), cex = 0.8)
lb <- adjustcolor("black", alpha = 0.5)
contour(x1, x2, z, add = TRUE, col = lb, drawlabels = FALSE)
points(0.2, -0.2, pch = 19, col = lb)
text(-0.65, 0.65, labels = expression(hat(x)), col = lb, cex = 0.8)
contour(x1, x2, z2, add = TRUE, col = lb, drawlabels = FALSE)
points(2.4, -1.9, pch = 19, col = lb)
text(3.1, -2.6, labels = "y", col = lb, cex = 0.8)

A <- matrix(c(
  1.2, 0,
  0, -0.2
), ncol = 2)
Q <- 0.3 * Sigma
K <- A %*% Sigma %*% t(G) %*% solve(G %*% Sigma %*% t(G) + R)
xhatnew <- A %*% xhat + K %*% (y - G %*% xhat)
Sigmanew <- A %*% Sigma %*% t(A) - K %*% G %*% Sigma %*% t(A) + Q

# [kf-predict]
z4 <- outer(x1, x2, f, mean = c(xhatnew), varcov = Sigmanew)
image(x1, x2, z4,
  col = mycols,
  xlab = expression("x"[1]), ylab = expression("x"[2]),
  main = "Predictive density", asp = 1
)
contour(x1, x2, z4, add = TRUE)
points(xhatnew[1], xhatnew[2], pch = 19)
text(2, 1.57, labels = expression(hat(x)[new]), cex = 0.8)
contour(x1, x2, z3, add = TRUE, col = lb, drawlabels = FALSE)
points(xhatf[1], xhatf[2], pch = 19, col = lb)
text(0.97, -2.55, labels = expression(hat(x)[f]), col = lb, cex = 0.8)
contour(x1, x2, z, add = TRUE, col = lb, drawlabels = FALSE)
points(0.2, -0.2, pch = 19, col = lb)
text(-0.65, 0.65, labels = expression(hat(x)), col = lb, cex = 0.8)
contour(x1, x2, z2, add = TRUE, col = lb, drawlabels = FALSE)
points(2.4, -1.9, pch = 19, col = lb)
text(3.1, -2.6, labels = "y", col = lb, cex = 0.8)

# ---- Particle Learning for Poisson Mixture Models --------------------------

set.seed(8) # Ovi
# Simulate data (500 observations)
n_obs <- 500
true_z <- sample(1:2, n_obs, replace = TRUE, prob = c(0.7, 0.3))
y <- ifelse(true_z == 1, rpois(n_obs, 2), rpois(n_obs, 10))

# Relative frequencies of the counts in each mixture component and in the mixture
k <- 0:23
freq <- function(v) tabulate(v + 1, nbins = length(k)) / length(v)
plot(k, freq(y[true_z == 1]), type = "b", pch = 16, xlab = "y", ylab = "Relative frequency", col = "blue", lwd = 2, ylim = c(0, 0.4))
lines(k, freq(y[true_z == 2]), type = "b", pch = 17, col = "red", lwd = 2, lty = 2)
lines(k, freq(y), type = "b", pch = 15, col = "purple", lwd = 2, lty = 3)
legend("topright", legend = expression("Component 1 (" * lambda == 2 * ")", "Component 2 (" * lambda == 10 * ")", "Mixture"), col = c("blue", "red", "purple"), pch = c(16, 17, 15), lwd = 2, lty = 1:3, bty = "n", cex = 0.7)

# [pl-mixture-code]
# (the book does not run this chunk when it builds; its output is kept in results/15-forecasting/fig-pl-mixture-*)
# Model parameters
m <- 2 # Number of components
alpha <- c(1, 1) # Gamma prior shape parameters
beta <- c(1, 1) # Gamma prior rate parameters
gamma <- c(1, 1) # Dirichlet prior parameters
n_particles <- 1000 # Number of particles

# Initialize particles
particles <- lapply(1:n_particles, function(i) {
  list(
    s = c(0, 0), # Sufficient statistics (sum of y in each component)
    n = c(0, 0)
  ) # Counts per component
})

# Store posterior samples
posterior_lambda <- matrix(0, nrow = n_obs, ncol = m)
posterior_weights <- matrix(0, nrow = n_obs, ncol = m)

# Particle Learning algorithm
for (t in 1:n_obs) {
  y_t <- y[t]
  log_weights <- numeric(n_particles)

  # 1. Compute weights using posterior predictive
  for (i in 1:n_particles) {
    total_obs <- sum(particles[[i]]$n)
    weight_components <- (particles[[i]]$n + gamma) / (total_obs + sum(gamma))

    # Predictive for each component (Poisson-Gamma: negative binomial)
    pred_prob <- sapply(1:m, function(j) {
      shape_post <- alpha[j] + particles[[i]]$s[j]
      rate_post <- beta[j] + particles[[i]]$n[j]
      dnbinom(y_t, size = shape_post, prob = rate_post / (rate_post + 1))
    })

    log_weights[i] <- log(sum(weight_components * pred_prob))
  }

  # Normalize weights
  max_logw <- max(log_weights)
  weights <- exp(log_weights - max_logw)
  weights <- weights / sum(weights)

  # 2. Resample particles
  idx <- sample(1:n_particles, size = n_particles, replace = TRUE, prob = weights)
  particles <- particles[idx]

  # 3. Propagate state
  for (i in 1:n_particles) {
    # Compute allocation probabilities
    alloc_probs <- sapply(1:m, function(j) {
      shape_post <- alpha[j] + particles[[i]]$s[j]
      rate_post <- beta[j] + particles[[i]]$n[j]
      log_prior <- log(particles[[i]]$n[j] + gamma[j]) - log(sum(particles[[i]]$n) + sum(gamma))
      log_lik <- dnbinom(y_t, size = shape_post, prob = rate_post / (rate_post + 1), log = TRUE)
      exp(log_prior + log_lik)
    })
    alloc_probs <- alloc_probs / sum(alloc_probs)

    # Sample component allocation
    k <- sample(1:m, size = 1, prob = alloc_probs)

    # Update sufficient statistics
    particles[[i]]$s[k] <- particles[[i]]$s[k] + y_t
    particles[[i]]$n[k] <- particles[[i]]$n[k] + 1
  }

  # 4. Learn parameters (store posterior means)
  lambda_samples <- t(sapply(particles, function(p) {
    (alpha + p$s) / (beta + p$n)
  }))
  weight_samples <- t(sapply(particles, function(p) {
    (gamma + p$n) / sum(gamma + p$n)
  }))

  posterior_lambda[t, ] <- colMeans(lambda_samples)
  posterior_weights[t, ] <- colMeans(weight_samples)
}

# Plot the results
library(ggplot2)
# Convert posterior estimates to data frames for ggplot
posterior_df <- data.frame(
  Observation = 1:n_obs,
  Lambda1 = posterior_lambda[, 1],
  Lambda2 = posterior_lambda[, 2],
  Weight1 = posterior_weights[, 1],
  Weight2 = posterior_weights[, 2]
)
# Plot Lambda parameters
ggplot(posterior_df, aes(x = Observation)) +
  geom_hline(yintercept = c(2, 10), colour = "grey70", linewidth = 0.4) +
  geom_line(aes(y = Lambda1, colour = "Component 1", linetype = "Component 1"), linewidth = 0.8) +
  geom_line(aes(y = Lambda2, colour = "Component 2", linetype = "Component 2"), linewidth = 0.8) +
  scale_colour_manual(values = c("black", "grey50")) +
  scale_linetype_manual(values = c("solid", "dashed")) +
  labs(x = "Observation", y = expression(lambda), colour = NULL, linetype = NULL) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom")

# Plot Weights
ggplot(posterior_df, aes(x = Observation)) +
  geom_hline(yintercept = c(0.3, 0.7), colour = "grey70", linewidth = 0.4) +
  geom_line(aes(y = Weight1, colour = "Component 1", linetype = "Component 1"), linewidth = 0.8) +
  geom_line(aes(y = Weight2, colour = "Component 2", linetype = "Component 2"), linewidth = 0.8) +
  scale_colour_manual(values = c("black", "grey50")) +
  scale_linetype_manual(values = c("solid", "dashed")) +
  labs(x = "Observation", y = "Weight", colour = NULL, linetype = NULL) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom")
