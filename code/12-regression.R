# Code of chapter: Linear Regression
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/12-regression.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Data: data/SaratogaHouses.csv, data/keynes.csv, data/mammals.csv, data/newfood.csv, data/oj.csv, data/pga-2000.csv, data/pga-2018.csv
# Packages: dplyr, knitr, quantmod

source("code/common.R")

# ---- Housing Price Prediction ----------------------------------------------

# [plothouses]
d <- read.csv("data/SaratogaHouses.csv")
d$price <- d$price / 1000
d$livingArea <- d$livingArea / 1000

# [lm-houses]
l <- lm(price ~ livingArea, data = d)

coef(l)

plot(d$livingArea, d$price, "p", pch = 21, bg = "lightblue", xlab = "Living Area", ylab = "Price", cex = 0.6)
abline(l, col = "red", lwd = 3)
# Draw a line between the two points
x <- 2.2
yhat <- x * coef(l)[2] + coef(l)[1]
lines(c(x, x), c(0, yhat), col = "black", lwd = 3, lty = 2)
lines(c(0, x), c(yhat, yhat), col = "black", lwd = 3, lty = 2)
text(x + 2.3, yhat - 150, expression(hat(y) == "262.3"), cex = 1.5)
arrows(x + 1.7, yhat - 120, x + 0.08, yhat - 15, length = 0.08, lwd = 1.5)

y <- d$price
Psi <- cbind(1, d$livingArea)
lhs <- t(Psi) %*% Psi
rhs <- t(Psi) %*% y
beta <- solve(lhs, rhs)
beta[, 1]

# ---- Keynes Investment Performance -----------------------------------------

# [keynes]
keynes <- read.csv("data/keynes.csv", header = T)
knitr::kable(head(keynes))
attach(keynes)
# Plot the data
plot(Year, Keynes, pch = 20, col = 34, cex = 3, type = "l", lwd = 3)
mean(Keynes)

# [fig-keynes-plot]
plot(Market, Keynes, xlab = "Market Return", ylab = "Keynes Excess Return", col = 20, bg = "lightblue", pch = 21, cex = 0.8)
model <- lm(Keynes ~ Market)
abline(model, lwd = 3)

coef(model)
model %>%
  tidy() %>%
  knitr::kable(digits = 2)

Keynes <- Keynes - Rate
Market <- Market - Rate
modelnew <- lm(Keynes ~ Market)
modelnew %>%
  tidy() %>%
  knitr::kable(digits = 2)

# ---- House Prices ----------------------------------------------------------

d <- read.csv("data/SaratogaHouses.csv")
d$price <- d$price / 1000
d$livingArea <- d$livingArea / 1000
l <- lm(price ~ livingArea, data = d)
l %>%
  tidy() %>%
  kable()

# [fig-simbeta]
set.seed(92) # Kuzy
d <- read.csv("data/SaratogaHouses.csv")
d$price <- d$price / 1000
d$livingArea <- d$livingArea / 1000
plot(d$livingArea, d$price,
  col = "lightblue", xlab = "Living Area",
  ylab = "Price", bg = "lightblue", pch = 21, cex = 0.6
)
for (i in 1:10) {
  # Sample with replacement
  dnew <- d[sample(1:nrow(d), replace = T), ]
  # Fit a linear model
  l <- lm(price ~ livingArea, data = dnew, subset = sample(1:nrow(d), 100))
  abline(l, col = "green", lwd = 3)
}

set.seed(92) # Kuzy
# Read housing data
d <- read.csv("data/SaratogaHouses.csv")
d$price <- d$price / 1000
d$livingArea <- d$livingArea / 1000
# Simulate 1000 samples
n <- 1000
# Create a matrix to store the results
beta <- matrix(0, nrow = n, ncol = 2)
for (i in 1:n) {
  # Sample with replacement
  dnew <- d[sample(1:nrow(d), replace = T), ]
  # Fit a linear model
  l <- lm(price ~ livingArea, data = dnew)
  # Store the coefficients
  beta[i, ] <- coef(l)
}

ind <- 2
# Plot the results
plot(beta[, 1], beta[, 2], col = "blue", xlab = "Intercept", ylab = "Slope", bg = "lightblue", cex = 0.8)
abline(h = coef(l)[2], lwd = 3, col = "red")
abline(v = coef(l)[1], lwd = 3, col = "red")
X <- cbind(1, d$livingArea)
# Calculate the variance of the coefficients
var <- sigma(l)^2 * solve(t(X) %*% X)
varb <- var[ind, ind] / 0.63
hist(beta[, ind], col = "lightblue", xlab = "Slope", main = "", freq = F)
bt <- seq(80, 140, 0.1)

# ---- Google vs S&P 500 -----------------------------------------------------

getSymbols(Symbols = c("GOOG", "SPY"), from = "2017-01-03", to = "2023-12-29")
gret <- as.numeric(dailyReturn(GOOG))
spyret <- as.numeric(dailyReturn(SPY))
l <- lm(gret ~ spyret)
tidy(l) %>% knitr::kable(digits = 4)

plot(spyret, gret, bg = "lightblue", xlab = "SPY Return", ylab = "Google Return")
abline(l, lwd = 3, col = "red")

alpha <- coef(l)[1]
beta <- coef(l)[2]
# Calculate the expected return
alpha + beta * 0.1

# [tbl-googspy]
getSymbols(Symbols = c("GOOG", "SPY"), from = "2005-01-03", to = "2016-12-29")
gret <- as.numeric(dailyReturn(GOOG))
spyret <- as.numeric(dailyReturn(SPY))
l <- lm(gret ~ spyret)
tidy(l) %>% knitr::kable(digits = 4)

# [fig-googspy]
plot(spyret, gret, col = "blue", ylab = "Google Return", xlab = "SPY Return", bg = "lightblue", cex = 0.8)
abline(l, lwd = 3, col = "red")

# ---- Logarithmic and Power Transformations ---------------------------------

# [fig-aapl]
library(quantmod)
getSymbols(Symbols = "AAPL", from = "2000-01-01", to = "2023-12-31", auto.assign = TRUE) |> invisible()
plot(AAPL$AAPL.Adjusted, type = "l", col = "blue", xlab = "", ylab = "Price", grid.col = NA, main = "")

# [fig-compound]
T <- 1:100
r <- 1
plot(T, (1 + r / T)^T, type = "l", col = "blue", ylab = "Future Value")
abline(h = exp(r), col = "red", lwd = 3)

# ---- World's Smartest Mammal -----------------------------------------------

mammals <- read.csv("data/mammals.csv")
knitr::kable(head(mammals))

# [mammals]
attach(mammals)
model <- lm(Brain ~ Body)
plot(Body, Brain, pch = 21, bg = "lightblue")
abline(model, col = "red", lwd = 3)

# [fig-mammals]
plot(model$fitted.values, model$residuals, pch = 21, bg = "lightblue", xlab = "Fitted y", ylab = "Residuals", lab = c(5, 3, 7))
abline(h = 0, col = "red", lwd = 3)
plot(Brain, model$fitted.values, pch = 21, bg = "lightblue", xlab = "True y", ylab = "Fitted y")
abline(a = 0, b = 1, col = "red", lwd = 3)

# [mammals2]
model <- lm(log(mammals$Brain) ~ log(mammals$Body))
model %>%
  tidy() %>%
  knitr::kable(digits = 2)

# [fig-mammalslog]
plot(model$fitted.values, model$residuals, pch = 21, bg = "lightblue", xlab = "Fitted log y", ylab = "Residuals")
abline(h = 0, col = "red", lwd = 3)
plot(log(Brain), model$fitted.values, pch = 21, bg = "lightblue", xlab = "True log y", ylab = "Fitted log y")
abline(a = 0, b = 1, col = "red", lwd = 3)

# [mammals4]
# res = rstudent(model)
res <- model$residuals / sd(model$residuals)
outliers <- order(res, decreasing = T)[1:10]
cbind(mammals[outliers, ],
  Std.Res = res[outliers], Residual = model$residuals[outliers],
  Fit = exp(model$fitted.values[outliers])
) %>% knitr::kable(digits = 2)

abs(model$fitted.values[11] - log(6.4)) / sd(model$residuals)

# ---- Newfood ---------------------------------------------------------------

# [newfood]
newfood <- read.csv("data/newfood.csv")
attach(newfood)
names(newfood)
# knitr::kable()
head(newfood)
# correlation matrix
cm <- cor(cbind(sales, price, adv, locat, income, svol))
cm[upper.tri(cm, diag = TRUE)] <- NA
# knitr::kable(as.table(round(cm, 3)))
as.table(round(cm, 3)) %>% knitr::kable()

# [abtable]
as.table(round(cm[2:4, 1:3], 3)) %>% knitr::kable()

# [newfood-lm1]
model <- lm(sales ~ price + adv + locat)
model %>%
  tidy() %>%
  knitr::kable(digits = 2)

# [newfood-lm]
model <- lm(log(sales) ~ log(price) + adv + locat +
  log(income) + log(svol))
model %>%
  tidy() %>%
  knitr::kable(digits = 2)

# [oj-lm-log]
modelnew <- lm(log(sales) ~ log(price) + adv + log(income) + log(svol))
modelnew %>%
  tidy() %>%
  knitr::kable(digits = 2)
newdata <- data.frame(price = 30, adv = 1, income = 8, svol = 34)
predict.lm(modelnew, newdata, interval = "confidence", level = 0.99)

# ---- Interactions ----------------------------------------------------------

# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# model <- lm(y ~ x1 * x2)

# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# model <- lm(y ~ x1:x2)

# ---- Orange Juice ----------------------------------------------------------

# [oj-lm]
oj <- read.csv("data/oj.csv")
knitr::kable(oj[1:5, c(1:7, 10)], digits = 2)
model <- lm(logmove ~ log(price) * feat, data = oj)
model %>%
  tidy() %>%
  knitr::kable(digits = 2)
model <- lm(log(price) ~ brand - 1, data = oj)
model %>%
  tidy() %>%
  knitr::kable(digits = 2)

# [oj-lm-plot]
brandcol <- c("green", "red", "gold")
oj$brand <- factor(oj$brand)
boxplot(log(price) ~ brand,
  data = oj, col = brandcol, xlab = "Brand", ylab = "Log price",
  names = c("Dominick's", "Minute Maid", "Tropicana")
)
plot(logmove ~ log(price), data = oj, col = brandcol[oj$brand], pch = 20, xlab = "Log price", ylab = "Log units sold")

# [plot-oj-lm]
plot(exp(logmove) ~ price, data = oj, col = brandcol[oj$brand], pch = 16, cex = 0.5, xlab = "Price", ylab = "Units sold")
legend("topright", c("Dominick's", "Minute Maid", "Tropicana"), col = brandcol, pch = 16, bty = "n", cex = 0.7)

# [lines-smoothed1]
par(mar = c(2.5, 2.5, 0.5, 1), bty = "n")
l1 <- loess(logmove ~ price, data = oj, span = 2)
smoothed1 <- predict(l1)
ind <- order(oj$price)
plot(logmove ~ price, data = oj, col = brandcol[oj$brand], pch = 16, cex = 0.5, xlab = "Price", ylab = "Log units sold")
lines(smoothed1[ind], x = oj$price[ind], col = "blue", lwd = 2)

# [lines-smoothed2]
par(mar = c(2.5, 2.5, 0.5, 1), bty = "n")
plot(logmove ~ log(price), data = oj, col = brandcol[oj$brand], pch = 16, cex = 0.5, xlab = "Log price", ylab = "Log units sold")
for (i in 1:3) {
  brand_data <- oj[oj$brand == levels(oj$brand)[i], ]
  l2 <- lm(logmove ~ log(price), data = brand_data)
  smoothed2 <- predict(l2)
  ind <- order(brand_data$price)
  lines(smoothed2[ind], x = log(brand_data$price[ind]), col = "blue", lwd = 2)
}

# [lm-logmove]
lm(logmove ~ log(price), data = oj) %>%
  tidy() %>%
  knitr::kable(digits = 2)

# [lm-logmove1]
lm(logmove ~ log(price) + feat + brand, data = oj) %>%
  tidy() %>%
  knitr::kable(digits = 2)

# [lm-logmove2]
ojreg <- lm(logmove ~ log(price) * feat, data = oj)
ojreg %>%
  tidy() %>%
  knitr::kable(digits = 2)

# [oj-box]
doj <- oj %>% filter(brand == "dominicks")
boxplot(price ~ feat,
  data = oj[oj$brand == "dominicks", ], col = c(2, 3),
  main = "Dominick's", xlab = "Featured", ylab = "Price ($)", names = c("No", "Yes")
)
boxplot(price ~ feat,
  data = oj[oj$brand == "minute.maid", ], col = c(2, 3),
  main = "Minute Maid", xlab = "Featured", ylab = "Price ($)", names = c("No", "Yes")
)
boxplot(price ~ feat,
  data = oj[oj$brand == "tropicana", ], col = c(2, 3),
  main = "Tropicana", xlab = "Featured", ylab = "Price ($)", names = c("No", "Yes")
)

# ---- Categorical Variables and Dummy Encoding ------------------------------

lm(logmove ~ log(price) + brand, data = oj) %>%
  tidy() %>%
  knitr::kable(digits = 2)

# ---- Golf Performance Data -------------------------------------------------

# [load-pga-data]
d00 <- read_csv("data/pga-2000.csv")
d18 <- read_csv("data/pga-2018.csv")

# [pga-lm]
model00 <- lm(money ~ nevents + drivedist + gir + avgputts, data = d00)
model00 %>%
  tidy() %>%
  knitr::kable(digits = 2)

# [pga-lm-plot]
hist(rstandard(model00),
  breaks = 20, col = "lightblue",
  xlab = "Standardized Residual", main = ""
)
arrows(x0 = 7.5, y0 = 22 - strheight("Tiger Woods"), x1 = 8.5, y1 = 2, length = 0.1)
text(x = 7, y = 22, labels = "Tiger Woods", cex = 1)

# [pga-lm-log-1]
model00log <- lm(log(money) ~ nevents + drivedist + gir + avgputts, data = d00)
model00log %>%
  tidy() %>%
  knitr::kable(digits = 2)
hist(rstandard(model00log),
  breaks = 20, col = "lightblue",
  xlab = "Standardized Residual", main = ""
)
arrows(x0 = 3, y0 = 20, x1 = 3.2, y1 = 2, length = 0.1)
text(x = 2.6, y = 22, labels = "Notah Begay III", cex = 1)

# [pga-lm-final]
m1 <- lm(formula = log(money) ~ drivedist + gir + avgputts, data = d00)
m1 %>%
  tidy() %>%
  knitr::kable(digits = 3)

# [Over-Performers]
ind <- which(rstandard(m1) > 2)
tb <- data.frame(Name = d00$name[ind], Money = d00$money[ind], Predicted = exp(m1$fitted.values[ind]))
tb$Ratio <- tb$Money / tb$Predicted
knitr::kable(tb, caption = "Over-Performers", align = "c", digits = c(0, 0, 0, 2), format.args = list(big.mark = ","), row.names = FALSE)

# [Under-Performers]
ind <- which(rstandard(m1) < -2)
tb <- data.frame(Name = d00$name[ind], Money = d00$money[ind], Predicted = exp(m1$fitted.values[ind]))
tb$Ratio <- tb$Money / tb$Predicted
knitr::kable(tb, caption = "Under-Performers", align = "c", digits = c(0, 0, 0, 2), format.args = list(big.mark = ","), row.names = FALSE)

# [Highest]
tb <- d18 %>%
  arrange(desc(money)) %>%
  dplyr::select(-ROUNDS) %>%
  as.data.frame() %>%
  head()
knitr::kable(tb, caption = "Highest earners 2018", align = "c")

m18 <- lm(log(money) ~ drivedist + gir + avgputts, data = d18)
ind <- which(rstandard(m18) > 2)
tb <- data.frame(Name = d18$name[ind], Money = d18$money[ind], Predicted = exp(m18$fitted.values[ind]))
tb$Ratio <- tb$Money / tb$Predicted
knitr::kable(tb, caption = "Overperformers 2018", align = "c", digits = c(0, 0, 0, 2), format.args = list(big.mark = ","), row.names = FALSE)

ind <- which(rstandard(m18) < -2)
tb <- data.frame(Name = d18$name[ind], Money = d18$money[ind], Predicted = exp(m18$fitted.values[ind]))
tb$Ratio <- tb$Money / tb$Predicted
knitr::kable(tb, caption = "Underperformers 2018", align = "c", digits = c(0, 0, 0, 2), format.args = list(big.mark = ","), row.names = FALSE)

# ---- Posterior Distribution for Simple Linear Regression -------------------

# [fig-bayes-lm]
set.seed(1)
n <- 10
x <- runif(n, -1, 1)
y <- 0.4 + 0.8 * x + rnorm(n)
X <- cbind(1, x)
A <- crossprod(X) + diag(2)
bbar <- solve(A, crossprod(X, y))
prior <- mvrnorm(20, c(0, 0), diag(2))
post <- mvrnorm(20, bbar, solve(A))
for (b in list(prior, post)) {
  plot(NULL, xlim = c(-1, 1), ylim = c(-3, 3), xlab = "x", ylab = "y")
  for (i in 1:20) abline(b[i, 1], b[i, 2], col = "gray60")
  if (identical(b, post)) points(x, y, pch = 16)
}
