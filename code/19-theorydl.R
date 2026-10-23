# Code of chapter: Theory of Deep Learning
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/19-theorydl.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Packages: MASS

source("code/common.R")

# ---- Reproducing Double Descent with Polynomial Regression -----------------

set.seed(42)
n <- 20; sigma <- 0.3
x <- seq(-1, 1, length.out = n)
ftrue <- function(x) sin(5 * x)
y <- ftrue(x) + rnorm(n, sd = sigma)
xdense <- seq(-1, 1, length.out = 200)

legvander <- function(x, d) {
  # columns are Legendre polynomials P_0(x), ..., P_d(x), via the standard recurrence
  X <- matrix(0, length(x), d + 1); X[, 1] <- 1
  if (d >= 1) X[, 2] <- x
  if (d >= 2) for (k in 2:d) X[, k+1] <- ((2*k-1)*x*X[, k] - (k-1)*X[, k-1]) / k
  X
}
rmse <- function(a, b) sqrt(mean((a - b)^2))

degrees <- 1:45
train_err <- test_err <- numeric(length(degrees))
for (i in seq_along(degrees)) {
  Xd <- legvander(x, degrees[i])
  beta <- MASS::ginv(Xd) %*% y            # minimum-norm solution, valid for d+1 > n too
  train_err[i] <- rmse(Xd %*% beta, y)
  test_err[i]  <- rmse(legvander(xdense, degrees[i]) %*% beta, ftrue(xdense))
}

plot(degrees, log10(test_err), type = "l", col = "blue", lwd = 2,
     xlab = "polynomial degree (model complexity)", ylab = "log10(RMSE)",
     ylim = range(log10(c(test_err, train_err))))
lines(degrees, log10(train_err), col = "red", lwd = 2)
abline(v = n, lty = 2)
legend("topright", legend = c("test", "train"), col = c("blue", "red"), lwd = 2, bty = "n")

cat("classical-regime minimum test RMSE: degree", degrees[which.min(test_err[degrees < n])],
    ", value", round(min(test_err[degrees < n]), 3), "\n")
cat("peak test RMSE: degree", degrees[which.max(test_err)], ", value", round(max(test_err), 2), "\n")
cat("test RMSE at degree 45:", round(test_err[degrees == 45], 3), "\n")

cat("train RMSE at degree 18:", round(train_err[degrees == 18], 4),
    ", degree 19:", round(train_err[degrees == 19], 4),
    ", degree 20:", round(train_err[degrees == 20], 4), "\n")

# ---- Nadaraya-Watson Kernel Smoothing on Toy Data --------------------------

set.seed(1)
n <- 15
x <- seq(0, 1, length.out = n)
y <- sin(2*pi*x) + rnorm(n, sd = 0.2)

nw_fit <- function(x0, x, y, h) {
  wts <- exp(-(x0 - x)^2 / (2*h^2))
  sum(wts * y) / sum(wts)
}

xg <- seq(0, 1, length.out = 200)
fit_narrow <- sapply(xg, nw_fit, x = x, y = y, h = 0.03)
fit_wide   <- sapply(xg, nw_fit, x = x, y = y, h = 0.3)

plot(x, y, pch = 19, ylim = c(-1.5, 1.5), xlab = "x", ylab = "y")
lines(xg, sin(2*pi*xg), col = "gray50")
lines(xg, fit_narrow, col = "red", lwd = 2)
lines(xg, fit_wide, col = "blue", lwd = 2)
legend("topright", legend = c("truth", "h = 0.03", "h = 0.3"),
       col = c("gray50", "red", "blue"), lwd = 2, bty = "n", cex = 0.8)

rmse <- function(a, b) sqrt(mean((a - b)^2))
cat("RMSE vs truth, h=0.03:", round(rmse(fit_narrow, sin(2*pi*xg)), 3), "\n")
cat("RMSE vs truth, h=0.3 :", round(rmse(fit_wide, sin(2*pi*xg)), 3), "\n")
