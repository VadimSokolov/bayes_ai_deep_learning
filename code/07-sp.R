# Code of chapter: Stochastic Processes
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/07-sp.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Data: data/sea_bubble.csv

source("code/common.R")

# ---- Brownian Motion -------------------------------------------------------

# [fig-brownian]
# Brownian Motion
set.seed(92)
t <- seq(0, 1, 0.001)
bm <- function() c(0, cumsum(rnorm(1000, 0, sqrt(0.001))))
plot(t, bm(),
  type = "l", xlab = "t",
  ylab = expression(B[t]), lwd = 2, ylim = c(-1.4, 2.1)
)
lines(t, bm(), lwd = 2, col = 2)
lines(t, bm(), lwd = 2, col = 3)

# ---- Poisson Process -------------------------------------------------------

# Poisson Process with rate lambda = 5
set.seed(92)
lambda <- 5
T_max <- 1

# Event times: cumulative sums of exponential waiting times, kept up to T_max
simulate_poisson <- function(lambda, T_max) {
  times <- cumsum(rexp(100, rate = lambda))
  times[times <= T_max]
}

# [fig-poisson]
paths <- lapply(1:3, function(i) simulate_poisson(lambda, T_max))
plot(NULL, xlim = c(0, T_max), ylim = c(0, max(lengths(paths)) + 1),
  xlab = "t", ylab = expression(N[t]))
for (i in 1:3) {
  x <- paths[[i]]
  lines(c(0, x, T_max), c(0, seq_along(x), length(x)), type = "s", lwd = 2, col = i)
}

# ---- Newton and the South Sea Bubble ---------------------------------------

# [fig-south-sea-prices]
d <- read.csv("data/sea_bubble.csv", header = TRUE)
d$date <- as.Date(d$Gregorian.Date, format = "%d-%m-%Y")
# head(d)
par(mar = c(5, 4, 1, 1), bty = "n")
plot(d$date, d[, 5], type = "l", xlab = "Date", ylab = "Prices", main = "", col = 2, lty = 1, lwd = 2, ylim = c(0, 1000))
lines(d$date, d[, 2], col = 3, lty = 2, lwd = 2)
lines(d$date, d[, 3], col = 4, lty = 3, lwd = 2)
lines(d$date, d[, 4], col = 5, lty = 4, lwd = 2)
legend("topleft", legend = c("South Sea Company", "Bank of England", "Royal African Company", "Old East India Company"), col = c(2, 3, 4, 5), lty = 1:4, lwd = 2, bty = "n")
