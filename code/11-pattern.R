# Code of chapter: Pattern Matching
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/11-pattern.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Packages: mgcv, nnet

source("code/common.R")

# ---- Composition versus Addition: Why Depth Captures Interactions ----------

library(mgcv)
library(nnet)

set.seed(11)
n <- 400
x1 <- runif(n, -1, 1)
x2 <- runif(n, -1, 1)
y  <- 4 * x1 * x2 + rnorm(n, 0, 0.3)
dat <- data.frame(y, x1, x2)

# neither predictor is correlated with y on its own
cat(sprintf("cor(y, x1) = %.3f   cor(y, x2) = %.3f   var(y) = %.3f\n",
            cor(y, x1), cor(y, x2), var(y)))

# 70/30 train/test split
tr <- sample(n, 0.7 * n)
train <- dat[tr, ]; test <- dat[-tr, ]

# baselines and the two competing structures
mse_mean <- mean((test$y - mean(train$y))^2)                 # mean rule
gam_fit  <- gam(y ~ s(x1) + s(x2), data = train)             # addition
mse_gam  <- mean((test$y - predict(gam_fit, test))^2)
net      <- nnet(y ~ x1 + x2, data = train, size = 8,        # composition
                 linout = TRUE, decay = 0.001, trace = FALSE)
mse_net  <- mean((test$y - predict(net, test))^2)

cat(sprintf("mean rule    test MSE = %.3f\n", mse_mean))
cat(sprintf("additive GAM test MSE = %.3f\n", mse_gam))
cat(sprintf("1-layer net  test MSE = %.3f  (%.1fx smaller, R^2 = %.2f)\n",
            mse_net, mse_gam / mse_net, 1 - mse_net / mse_mean))

# the GAM smooths detect nothing: edf ~ 1, both non-significant
sg <- summary(gam_fit)
cat(sprintf("GAM smooths: edf = %.2f, %.2f   p = %.3f, %.3f\n",
            sg$edf[1], sg$edf[2], sg$s.pv[1], sg$s.pv[2]))

# ---- Why $R^2$ Should Be Avoided: Two Regimes ------------------------------

set.seed(11)
n <- 300

# (a) correctly specified linear model, high noise
x_a <- rnorm(n, 0, 1)
y_a <- 2 + 3 * x_a + rnorm(n, 0, 50)
fit_a <- lm(y_a ~ x_a)
cat(sprintf("R^2 (correct model, high noise): %.4f | slope: %.3f (true = 3)\n",
            summary(fit_a)$r.squared, coef(fit_a)[2]))

# (b) misspecified nonlinear, heteroskedastic relationship
x_b <- runif(n, 1, 10)
y_b <- 5 + 10 * sqrt(x_b) + rnorm(n, 0, 0.4 * x_b)
fit_b <- lm(y_b ~ x_b)
cat(sprintf("R^2 (wrong model, nonlinear + heteroskedastic): %.4f\n", summary(fit_b)$r.squared))

# (c) heteroskedasticity the high R^2 conceals
cat(sprintf("cor(|resid|, x): %.3f\n", cor(abs(residuals(fit_b)), x_b)))

# ---- Comparing the Mean Rule, k-NN, and Linear Regression ------------------

set.seed(11)
data(mtcars)
x <- mtcars$wt; y <- mtcars$mpg; n <- length(y)

knn_predict <- function(x_tr, y_tr, x_te, k) {
  sapply(x_te, function(x0) mean(y_tr[order(abs(x_tr - x0))[1:k]]))
}

folds <- sample(rep(1:5, length.out = n))
mse_mean <- mse_knn <- mse_lm <- numeric(5)

for (f in 1:5) {
  tr <- which(folds != f); te <- which(folds == f)
  mse_mean[f] <- mean((y[te] - mean(y[tr]))^2)
  pred_knn    <- knn_predict(x[tr], y[tr], x[te], k = 3)
  mse_knn[f]  <- mean((y[te] - pred_knn)^2)
  fit         <- lm(y[tr] ~ x[tr])
  pred_lm     <- coef(fit)[1] + coef(fit)[2] * x[te]
  mse_lm[f]   <- mean((y[te] - pred_lm)^2)
}

cat(sprintf("Mean rule  CV-MSE: %.2f\n", mean(mse_mean)))
cat(sprintf("k-NN (k=3) CV-MSE: %.2f\n", mean(mse_knn)))
cat(sprintf("Linear reg CV-MSE: %.2f\n\n", mean(mse_lm)))

for (kk in c(1, 3, 5, 10, 26)) {
  mse_k <- sapply(1:5, function(f) {
    tr <- which(folds != f); te <- which(folds == f)
    pred <- knn_predict(x[tr], y[tr], x[te], k = min(kk, length(tr)))
    mean((y[te] - pred)^2)
  })
  cat(sprintf("k = %d  CV-MSE = %.2f\n", kk, mean(mse_k)))
}
