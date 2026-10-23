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

# Function to simulate one Poisson process trajectory
simulate_poisson <- function(lambda, T_max) {
  # Generate inter-arrival times (exponential with rate lambda)
  event_times <- c(0)
  current_time <- 0

  while (current_time < T_max) {
    inter_arrival <- rexp(1, rate = lambda)
    current_time <- current_time + inter_arrival
    if (current_time <= T_max) {
      event_times <- c(event_times, current_time)
    }
  }

  # Create step function, carrying the last count to T_max
  n_events <- length(event_times)
  counts <- 0:(n_events - 1)

  return(list(times = c(event_times, T_max), counts = c(counts, n_events - 1)))
}

# [fig-poisson]
# Simulate three trajectories
traj1 <- simulate_poisson(lambda, T_max)
traj2 <- simulate_poisson(lambda, T_max)
traj3 <- simulate_poisson(lambda, T_max)

# Plot
plot(traj1$times, traj1$counts,
  type = "s", xlab = "t", ylab = expression(N[t]),
  lwd = 2, ylim = c(0, max(c(traj1$counts, traj2$counts, traj3$counts)) + 1),
  xlim = c(0, T_max), col = 1
)
lines(traj2$times, traj2$counts, type = "s", lwd = 2, col = 2)
lines(traj3$times, traj3$counts, type = "s", lwd = 2, col = 3)

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
