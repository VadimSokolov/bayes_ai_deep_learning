# Code of chapter: Gaussian Processes
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/08-gp.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Packages: MASS, laGP

source("code/common.R")

# ---- Gaussian Processes ----------------------------------------------------

x = seq(0,10, length.out = 100)

mean = rep(0, length(x))
sqexpcov = function(x, x1, l=1, sigma=1) {
  exp(-0.5 * (x - x1)^2 / l^2) * sigma^2
}

cov_mat = outer(x, x, sqexpcov)

# [fig-gp-sample]
library(MASS)
set.seed(17)
Y = mvrnorm(1, mean, cov_mat)
plot(x, Y, type="l", xlab="x", ylab="y", ylim=c(-1.5,2), lwd=2, col="blue")

# [fig-gp-samples]
set.seed(68) # Jagr
Ys = mvrnorm(3, mean, cov_mat)
matplot(x, t(Ys), type="l", ylab="Y", lwd=5)

# ---- Gaussian Process for $\sin$ Function ----------------------------------

n = 8; eps=1e-6
X = matrix(seq(0, 2*pi, length=n), ncol=1)
Y = sin(X)
K = outer(X[,1], X[,1], sqexpcov) + diag(eps, n)

q = 100
XX = matrix(seq(-0.5, 2*pi + 0.5, length=q), ncol=1)
KX = outer(X[,1], XX[,1],sqexpcov)
KXX = outer(XX[,1],XX[,1], sqexpcov) + diag(eps, q)

Si = solve(K)
mup = t(KX) %*% Si %*% Y # we assume mu is 0
Sigmap = KXX - t(KX) %*% Si %*% KX

set.seed(9) # Gordie Howe
YY = mvrnorm(100, mup, Sigmap)

plot_gp = function(mup, Sigmap, X, Y, XX, YY, ...){
  q1 = mup + qnorm(0.05, 0, sqrt(diag(Sigmap)))
  q2 = mup + qnorm(0.95, 0, sqrt(diag(Sigmap)))
  matplot(XX, t(YY), type="l", col="gray", lty=1, xlab="x", ylab="y", ...)
  points(X, Y, pch=20, cex=if (par("din")[1] < 4) 1 else 2)
  lines(XX, sin(XX), col="blue")
  lines(XX, mup, lwd=2)
  lines(XX, q1, lwd=2, lty=2, col=2)
  lines(XX, q2, lwd=2, lty=2, col=2)
}

# [fig-gp-sin]
plot_gp(mup, Sigmap, X, Y, XX, YY)

# ---- Gaussian Process for Simulated Data Using MLE -------------------------

# [gpmle]
loglik = function(par, X, Y) {
  sigma = par[1]
  l = par[2]
  K = outer(X[,1],X[,1], sqexpcov,l,sigma) + diag(eps, n)
  Si = solve(K)
  return(-(-0.5 * log(det(K)) - 0.5 * t(Y) %*% Si %*% Y - (n/2)* log(2*pi)))
}
par = optim(c(1,1), loglik, X=X, Y=Y)$par
print(par)

set.seed(4) # Bobby Orr
l = par[2]; sigma = par[1]
predplot = function(X, Y, XX, YY, l, sigma, ...) {
  K = outer(X[,1],X[,1], sqexpcov,l,sigma) + diag(eps, n)
  KX = outer(X[,1], XX[,1],sqexpcov,l,sigma)
  KXX = outer(XX[,1],XX[,1], sqexpcov,l,sigma) + diag(eps, q)
  Si = solve(K)
  mup = t(KX) %*% Si %*% Y # we assume mu is 0
  Sigmap = KXX - t(KX) %*% Si %*% KX
  YY = mvrnorm(100, mup, Sigmap)
  plot_gp(mup, Sigmap, X, Y, XX, YY, ...)
}
predplot(X, Y, XX, YY, l, sigma)

# ---- Mathematical Details: Gradient Derivation -----------------------------

# [code-gp-deriv]
# Derivative of the negative log-likelihood function with respect to sigma
dloglik_sigma = function(par, X, Y) {
  sigma = par[1]; l = par[2]
  K = outer(X[,1],X[,1], sqexpcov,l,sigma) + diag(eps, n)
  Si = solve(K)
  dK = 2*K/sigma
  tr = sum(diag(Si %*% dK))
  return(-(-0.5 * tr + 0.5 * t(Y) %*% Si %*% dK %*% Si %*% Y))
}
# Derivative of the negative log-likelihood function with respect to l
dloglik_l = function(par, X, Y) {
  sigma = par[1]; l = par[2]
  K = outer(X[,1],X[,1], sqexpcov ,l,sigma) + diag(eps, n)
  Si = solve(K)
  dK =   outer(X[,1],X[,1], function(x, x1) (x - x1)^2)/l^3 * K
  tr = sum(diag(Si %*% dK))
  return(-(-0.5 * tr + 0.5 * t(Y) %*% Si %*% dK %*% Si %*% Y))
}
# Gradient function that returns a vector of derivatives
gnlg = function(par,X,Y) {
  return(c(dloglik_sigma(par, X, Y), dloglik_l(par, X, Y)))
}

par1 = optim(c(1,1), fn=loglik, gr=gnlg ,X=X, Y=Y,method="BFGS")$par
l = par1[2]; sigma = par1[1]
print(par1)

# [laGP]
library(laGP)
gp = newGP(X, Y, 1, 0, dK = TRUE)
res = mleGP(gp, tmax=20)
l.laGP = sqrt(res$d/2)
print(l.laGP)

# [fig-gp-sin-mle]
predplot(X, Y, XX, YY, l, sigma)
predplot(X, Y, XX, YY, l.laGP, 1)

XX1 = matrix(seq(-4*pi, 6*pi + 0.5, length=q), ncol=1)
predplot(X, Y, XX1, YY, l, sigma, ylim = c(-6, 6))
predplot(X, Y, XX1, YY, l.laGP, 1, ylim = c(-6, 6))

# ---- Gaussian Process for Motorcycle Accident Data -------------------------

library(MASS)
X = mcycle$times
Y = mcycle$accel
gp = newGP(matrix(X), Y, 2, 1e-6, dK = TRUE)
mleGP(gp, tmax=10)

XX = matrix(seq(2.4, 55, length = 499), ncol=1)
p = predGP(gp, XX)

N = 499
q1 = qnorm(0.05, mean = p$mean, sd = sqrt(diag(p$Sigma)))
q2 = qnorm(0.95, mean = p$mean, sd = sqrt(diag(p$Sigma)))
q3 = qnorm(0.5, mean = p$mean, sd = sqrt(diag(p$Sigma)))
ggplot() + 
  geom_point(aes(x=X,y=Y)) + 
  geom_line(aes(x=XX,y=q3)) + 
  geom_ribbon(aes(x=XX,ymin=q1, ymax=q2), alpha=0.2) +
  labs(x = "Time (ms)", y = "Acceleration (g)")

hist(X, main = "", xlab = "Time (ms)")
