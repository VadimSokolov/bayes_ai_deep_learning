# Code of chapter: Neural Networks
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/18-nn.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Packages: scatterplot3d

source("code/common.R")

# ---- Classification with Neural Networks -----------------------------------

# [circle-data]
set.seed(43) # Tom Wilson
numSamples <- 200 # total number of observations
radius <- 10 # radius of the outer circle
noise <- 0.0001 # amount of noise to be added to the data
d <- matrix(0, ncol = 3, nrow = numSamples)
# matrix to store our generated data

# Generate positive points inside the circle.
for (i in 1:(numSamples / 2)) {
  r <- runif(1, 0, radius * 0.4)
  angle <- runif(1, 0, 2 * pi)
  x <- r * sin(angle)
  y <- r * cos(angle)
  noiseX <- runif(1, -radius, radius) * noise
  noiseY <- runif(1, -radius, radius) * noise
  d[i, ] <- c(0, x, y)
}

# Generate negative points outside the circle.
for (i in (numSamples / 2 + 1):numSamples) {
  r <- runif(1, radius * 0.8, radius)
  angle <- runif(1, 0, 2 * pi)
  x <- r * sin(angle)
  y <- r * cos(angle)
  noiseX <- runif(1, -radius, radius) * noise
  noiseY <- runif(1, -radius, radius) * noise
  d[i, ] <- c(1, x, y)
}
colnames(d) <- c("label", "x1", "x2")
# Plot the training dataset
# plot(d[,2],d[,3], col=d[,1]+2, pch=16, xlab="x1", ylab="x2")
# utils$save_pdf("~/papers/twocultures/fig/","nn-circle-2")
x1 <- seq(-11, 11, length.out = 100)

# [circle-lr]
# Fit a logistic regression model
fit <- glm(label ~ x1 + x2, data = as.data.frame(d), family = binomial(link = "logit"))
# Plot the training dataset
plot(d[, 2], d[, 3], col = d[, 1] + 2, pch = 16 + d[, 1], xlab = expression(x[1]), ylab = expression(x[2]), asp = 1)
th <- fit$coefficients
# Plot the decision boundary
abline(-th[1] / th[3], -th[2] / th[3], col = 2)

# [sep-lines]
plot(d[, 2], d[, 3], col = d[, 1] + 2, pch = 16 + d[, 1], xlab = expression(x[1]), ylab = expression(x[2]), asp = 1)
# Plot lines that separate once class (red) from another (green)
lines(x1, -x1 - 6)
text(-4.6, -3.6, 1)
lines(x1, -x1 + 6)
text(4.6, 3.6, 2)
lines(x1, x1 - 6)
text(4.6, -3.6, 3)
lines(x1, x1 + 6)
text(-3.6, 4.6, 4)

# [circle-logistic]
# Define sigmoid function
sigmoid <- function(z) exp(z) / (1 + exp(z))

# Define hidden layer of our neural network
features <- function(x1, x2) {
  z1 <- 6 + x1 + x2
  a1 <- sigmoid(z1) # The bias 6 shifts the decision boundaries
  z2 <- 6 - x1 - x2
  a2 <- sigmoid(z2)
  z3 <- 6 - x1 + x2
  a3 <- sigmoid(z3)
  z4 <- 6 + x1 - x2
  a4 <- sigmoid(z4)
  return(c(a1, a2, a3, a4))
}

# [circle-nn]
# Calculate prediction (classification) using our neural network
predict_prob <- function(x) {
  x1 <- x[1]
  x2 <- x[2]
  z <- features(x1, x2)
  mu <- sum(z) - 3.1
  sigmoid(mu)
}

# [circle-pred]
# Predict the probability of the positive class for a given point
predict_prob(c(0, 0))
predict_prob(c(0, 10))

# [circle-boundary]
x1 <- seq(-11, 11, length.out = 100)
x2 <- seq(-11, 11, length.out = 100)
# Generate all combinations of (x1,x2) values
gr <- as.matrix(expand.grid(x1, x2))
dim(gr)
# Calculate prediction for each point in the grid
yhat <- apply(gr, 1, predict_prob)
length(yhat)
# Plot everything together
image(x1, x2, matrix(yhat, ncol = 100), col = gray.colors(20, start = 0.6, end = 1), asp = 1, xlab = expression(x[1]), ylab = expression(x[2]))
lines(d[, 2], d[, 3], pch = c(21, 24)[d[, 1] + 1], bg = "white", xlab = "x1", ylab = "x2", type = "p")
lines(x1, -x1 - 6)
text(-4.6, -3.6, 1)
lines(x1, -x1 + 6)
text(4.6, 3.6, 2)
lines(x1, x1 - 6)
text(4.6, -3.6, 3)
lines(x1, x1 + 6)
text(-3.6, 4.6, 4)

# [regression]
relu <- function(x) max(0, x)
nn <- function(W, f = relu) {
  b0 <- W[1]
  w0 <- W[2:4]
  b1 <- W[5]
  w1 <- W[6:8]
  z0 <- apply(b0 + outer(x, w0, "*"), 1:2, f)
  yhat <- b1 + z0 %*% w1
  return(list(yhat = yhat[, 1], z0 = z0))
}

set.seed(99) # gretzky
params <- c(0, rnorm(3), 0, rnorm(3))
x <- seq(-1, 1, 0.02)
y <- 0.5 + 0.3 * x^2 + rnorm(length(x), 0, 0.02)
loss <- function(W) sum((nn(W)$yhat - y)^2)
# BFGS is a quasi-Newton optimization method
res <- optim(params, loss, method = "BFGS")
res$par

# [fig-relu]
o <- nn(res$par)
plot(x, y)
lines(x, o$yhat, lwd = 2)
lines(x, 0.5 + o$z0[, 1], col = 2, lwd = 2, lty = 2)
lines(x, 0.5 + o$z0[, 2], col = 3, lwd = 2, lty = 2)
lines(x, 0.5 + o$z0[, 3], col = 4, lwd = 2, lty = 2)

set.seed(8) # gretzky
params <- c(0, rnorm(3), 0, rnorm(3))
loss <- function(W) mean((nn(W, f = tanh)$yhat - y)^2)
res <- optim(params, loss, method = "BFGS")
o <- nn(res$par, f = tanh)
plot(x, y, ylim = c(0.4, 0.95))
lines(x, o$yhat, lwd = 2)
lines(x, 0.5 * o$z0[, 1] + 0.9, lwd = 2, lty = 2, col = 2)
lines(x, 0.5 * o$z0[, 2] + 0.9, lwd = 2, lty = 2, col = 3)
lines(x, 0.5 * o$z0[, 3] + 0.9, lwd = 2, lty = 2, col = 4)

set.seed(99) # ovi
x1 <- runif(200, -1, 1)
x2 <- runif(200, -1, 1)
y <- 0.5 + 0.1 * x1 + 0.2 * x2 + 0.5 * x1 * x2 + rnorm(length(x1), 0, 0.02)
library("scatterplot3d")
s3d <- scatterplot3d(x1, x2, y, pch = 16, cex.axis = 0.5, xlab = expression(x[1]), ylab = expression(x[2]), zlab = "y")
x <- cbind(x1, x2)
nn <- function(W, f = relu) {
  b0 <- W[1]
  w0 <- W[2:5]
  b1 <- W[6]
  w1 <- W[7:8]
  w0 <- matrix(w0, nrow = 2)
  z0 <- apply(b0 + x %*% w0, 1:2, f)
  yhat <- b1 + z0 %*% w1
  return(list(yhat = yhat[, 1], z0 = z0))
}
W <- c(0, rnorm(4), 0, rnorm(2))
loss <- function(W) sum((nn(W, f = tanh)$yhat - y)^2)
res <- optim(W, fn = loss, method = "BFGS")
o <- nn(res$par, f = tanh)
s3d$points3d(x1, x2, o$yhat, col = 2, pch = 1)
s3d$points3d(x1, x2, 0.5 * o$z0[, 1] + 0.9, col = 3, pch = 2, cex = 0.5)
s3d$points3d(x1, x2, 0.5 * o$z0[, 2] + 0.9, col = 4, pch = 3, cex = 0.5)
legend("top", c("data", "network output", "hidden unit 1 (rescaled)", "hidden unit 2 (rescaled)"), pch = c(16, 1, 2, 3), col = c(1, 2, 3, 4), bty = "n", cex = 0.6, ncol = 2, xpd = NA, inset = c(0, -0.16))

# ---- Activation Functions --------------------------------------------------

x <- seq(-2.5, 2.5, 0.05)
ytanh <- tanh(x)
yhardtanh <- pmax(-1, pmin(1, x))
ysoftplus <- log(1 + exp(x))
yrelu <- pmax(0, x)
yleakyrelu <- pmax(0.1 * x, x)
ysigmoid <- 1 / (1 + exp(-x))
plot(x, ytanh, type = "l", col = 2, lwd = 2, ylim = c(-1, 1), xlab = "", ylab = "")
abline(h = 0, lty = 2)
abline(v = 0, lty = 2)
plot(x, yhardtanh, type = "l", col = 2, lwd = 2, ylim = c(-1, 1), xlab = "", ylab = "")
abline(h = 0, lty = 2)
abline(v = 0, lty = 2)
plot(x, ysoftplus, type = "l", col = 2, lwd = 2, ylim = range(0, ysoftplus), xlab = "", ylab = "")
abline(h = 0, lty = 2)
abline(v = 0, lty = 2)
plot(x, yrelu, type = "l", col = 2, lwd = 2, ylim = range(yrelu), xlab = "", ylab = "")
abline(h = 0, lty = 2)
abline(v = 0, lty = 2)
plot(x, yleakyrelu, type = "l", col = 2, lwd = 2, ylim = range(yleakyrelu), xlab = "", ylab = "")
abline(h = 0, lty = 2)
abline(v = 0, lty = 2)
plot(x, ysigmoid, type = "l", col = 2, lwd = 2, ylim = c(0, 1), xlab = "", ylab = "")
abline(h = 0, lty = 2)
abline(v = 0, lty = 2)
