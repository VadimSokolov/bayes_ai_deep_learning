# Code of chapter: Probability and Uncertainty
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/01-prob.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Data: data/dc_travel_time.csv
# Packages: knitr, quantmod

source("code/common.R")

# ---- Probability and Uncertainty -------------------------------------------

set.seed(89)
N <- 30
y <- rbinom(N, 1, 0.5)
plot(cumsum(y) / seq_along(y), type = "l",
     xlab = "Number of Trials", ylab = "Proportion of Heads", ylim = c(0, 1))
abline(h = 0.5, col = "red")

# ---- NFL: New England Patriots Coin Toss -----------------------------------

factorial(25) / (factorial(19) * factorial(25 - 19))

p <- 177100 * 0.5^25
(1 - p) / p

# ---- Discrete CDF ----------------------------------------------------------

plot(ecdf(1:6), main = "", ylab = expression(F(x)))

# ---- Continuous CDF for Uniform Distribution -------------------------------

set.seed(33) # Patrick Roy
plot(ecdf(runif(500)), main = "", ylab = expression(F[n](x)), col = "lightblue", pch = 21, bg = "grey")
plot(ecdf(rnorm(500)), main = "", ylab = expression(F[n](x)), col = "lightblue", pch = 21, bg = "grey")

# ---- Uber ------------------------------------------------------------------

d <- read.csv("data/dc_travel_time.csv")
# use evening travel times (column 18) and convert from seconds to minutes
evening_tt <- d[, 18] / 60
day_tt <- d[, 15] / 60
evening_tt <- evening_tt[!is.na(evening_tt)] # remove missing observations
hist(evening_tt, freq = F, main = "", xlab = "Travel Time [min]", nclass = 20, col = "lightblue")

# [ex-travel]
bins <- hist(evening_tt, breaks = 3, plot = F)
knitr::kable(data.frame("tt" = bins$mids, "Probability" = bins$counts / length(evening_tt)), col.names = c("Travel Time", "Probability"), digits = c(1, 2), format.args = list(digits = 3))

0.05 * 17.5 + 0.77 * 22.5 + 0.18 * 27.5

# ---- Coin Toss -------------------------------------------------------------

barplot(dbinom(0:20, size = 20, prob = 0.3),
  names.arg = 0:20, col = "lightblue", ylim = c(0, 0.2),
  xlab = "Number of Heads", ylab = "Probability"
)

# ---- Poisson Distribution --------------------------------------------------

# Create x values
x <- 0:20

# Plot the first distribution
plot(x, dpois(x, lambda = 1),
  type = "b", col = "blue", lwd = 2, lty = 1, pch = 16,
  xlab = "Number of Events", ylab = "Probability",
  main = "Poisson Distribution for Different Lambda Values",
  ylim = c(0, 0.4)
)

# Add the other distributions
lines(x, dpois(x, lambda = 5), col = "red", lwd = 2, lty = 2, pch = 17, type = "b")
lines(x, dpois(x, lambda = 10), col = "darkgreen", lwd = 2, lty = 3, pch = 15, type = "b")

# Add legend
legend("topright",
  legend = expression(lambda == 1, lambda == 5, lambda == 10),
  col = c("blue", "red", "darkgreen"), lwd = 2, lty = 1:3, pch = c(16, 17, 15), bty = "n", cex = 0.8
)

# ---- Heights of Adults -----------------------------------------------------

# [fig-normal-height]
# Define parameters
mu <- 70
sigma <- 3

# Create x values for the curve
x <- seq(mu - 4 * sigma, mu + 4 * sigma, length.out = 1000)
y <- dnorm(x, mean = mu, sd = sigma)

# Plot the normal curve
plot(x, y,
  type = "l", lwd = 2, col = "blue", ylim = c(0, 0.16),
  xlab = "Height (inches)", ylab = "Density", main = ""
)

# Add vertical lines at 67 and 73, ending at the curve
segments(c(67, 73), 0, c(67, 73), dnorm(c(67, 73), mean = mu, sd = sigma), col = "red", lty = 2, lwd = 2)

# Highlight the area between 67 and 73
x_area <- seq(67, 73, length.out = 100)
y_area <- dnorm(x_area, mean = mu, sd = sigma)
polygon(c(67, x_area, 73), c(0, y_area, 0),
  col = rgb(0, 0, 1, alpha = 0.3), border = NA
)

# Add labels
text(66, 0.01, "67", col = "red", cex = 1.2)
text(74, 0.01, "73", col = "red", cex = 1.2)
text(70, 0.15, "P(67 < X < 73)", cex = 1.2, col = "darkblue")

prob_between <- pnorm(73, mean = 70, sd = 3) - pnorm(67, mean = 70, sd = 3)
cat("P(67 < X < 73) =", sprintf("%.4f", prob_between), "\n")

x <- qnorm(0.95, mean = 70, sd = 3)
cat("Height corresponding to the 95th percentile:", sprintf("%.3f", x), "inches\n")

# ---- The 1987 Stock Market Crash -------------------------------------------

z_score <- (-0.2176 - 0.012) / 0.043
pnorm(z_score)

# ---- Salary-Happiness ------------------------------------------------------

survey <- matrix(c(0.03, 0.12, 0.07, 0.02, 0.13, 0.11, 0.01, 0.13, 0.14, 0.01, 0.09, 0.14), ncol = 3)
rownames(survey) <- c("Y = low (0)", "Y = medium (1)", "Y = high (2)", "Y = very high (3)")
colnames(survey) <- c("X = 0 (low)", "X = 1 (medium)", "X = 2 (high)")

knitr::kable(survey, caption = "Joint distribution of salary ($Y$, rows) and happiness ($X$, columns) in a hypothetical survey.", align = "c")

0.07 + 0.01 + 0.09

# ---- Marginal --------------------------------------------------------------

d = data.frame(farm = c(0.018,0.002,0.001,0.001,0.001),operatives=c(0.035,0.112,0.066,0.018,0.029),craftsman=c(0.031,0.064,0.094,0.019,0.032),sales=c(0.008,0.032,0.032,0.010,0.043),professional=c(0.018,0.069,0.084,0.051,0.130), row.names = c("farm","operative","craftsman","sales","professional"))
d %>% knitr::kable()

# ---- Portfolio Means, Standard Deviations and Correlation ------------------

# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# library(quantmod)
# getSymbols(c("VUG","VTV"), from = "2015-01-01", to = "2024-01-01")
# VUG = VUG$VUG.Adjusted
# VTV = VTV$VTV.Adjusted
