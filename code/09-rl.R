# Code of chapter: Reinforcement Learning
# Every R chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.
# Run from the book folder: Rscript code/09-rl.R. Data are read from the data folder. Figures go to the graphics device (Rplots.pdf under Rscript).
# Data: data/secretary.csv, data/student-mdp.tab, data/student-reward.tab
# Packages: knitr, laGP

source("code/common.R")

# ---- When to End Experiments -----------------------------------------------

bandit <- function(x, n, alpha = 1, beta = 1, ndraws = 5000) {
  K <- length(x) # number of bandits
  prob <- matrix(nrow = ndraws, ncol = K)
  no <- n - x
  for (a in 1:K) { # posterior draws for each arm
    prob[, a] <- rbeta(ndraws, x[a] + alpha, no[a] + beta)
  }
  prob
}

# [bandit-example]
x <- c(12, 20, 30)
n <- c(20, 30, 40)
set.seed(17) # Kharlamov
prob <- bandit(x, n, ndraws = 6)
rownames(prob) <- c("1", "2", "3", "4", "5", "6")
knitr::kable(prob, digits = 2, col.name = c("$\\theta_1$", "$\\theta_2$", "$\\theta_3$"), row.names = T)

wat <- table(factor(max.col(prob), levels = 1:3)) / 6
knitr::kable(t(wat), digits = 2)

regret <- (apply(prob, 1, max) - prob[, 3]) / prob[, 3]
knitr::kable(t(regret), digits = 2)

set.seed(17)
prob <- bandit(x, n, ndraws = 10000)
regret <- (apply(prob, 1, max) - prob[, 3]) / prob[, 3]
hist(regret, breaks = 10, xlab = "Regret", main = "")
abline(v = quantile(regret, 0.95), col = "red")
wat <- table(factor(max.col(prob), levels = 1:3)) / 10000
knitr::kable(t(wat), digits = 2)

quantile(regret, 0.95)

# ---- Secretary Problem -----------------------------------------------------

# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# set.seed(17) # Kharlamov
# nmc <- 1000
# n <- 1000
# sz <- 300
# rules <- round(n * seq(0.002, 0.8, length.out = sz))
# rules <- unique(rules[rules > 0])
# sz <- length(rules)
# cnt <- rep(0, sz)
# quality <- rep(0, sz)
# for (i in 1:sz)
# {
#   for (j in 1:nmc) {
#     x <- sample(1:n, n)
#     screen <- x[1:(rules[i] - 1)]
#     best_screen <- max(screen)
#     xchoice <- x[(rules[i]):n]
#     better_candidates <- which(xchoice > best_screen)
#     if (length(better_candidates) == 0) {
#       choice <- x[n]
#     } else {
#       choice <- xchoice[min(better_candidates)]
#     }
#     cnt[i] <- cnt[i] + (choice == max(x))
#     quality[i] <- quality[i] + choice
#   }
# }
# d <- data.frame(cnt = cnt, quality = quality, nmc = nmc, rules = rules)

# (the book does not run this chunk when it builds; it has no output in the book, and it is commented out here: remove the comment marks to run it)
# d <- data.frame(cnt = cnt, quality = quality, nmc = nmc, rules = rules)
# write.csv(d, "data/secretary.csv", row.names = FALSE)

d <- read.csv("data/secretary.csv")
# rules[i] is the index of the first candidate that can be chosen,
# so the number screened (rejected) is rules - 1.
par(mar = c(2.5, 3.2, 0.7, 0.5))
plot(d$rules - 1, d$cnt / d$nmc,
  type = "l", col = 3, lwd = 3, xlab = "Number of Candidates Screened",
  ylab = "Probability of\nPicking the Best"
)
plot(d$rules - 1, d$quality / 1000,
  type = "l", col = 3, lwd = 3, xlab = "Number of Candidates Screened",
  ylab = "Average Quality\nof Candidate"
)

# ---- Student Example -------------------------------------------------------

# Reward function
R <- read.csv("data/student-reward.tab", header = T, sep = "\t", row.names = 1)
t(R) %>% knitr::kable()
getR <- function(s) R[s, ]

# Read transition probability matrix
p <- read.csv("data/student-mdp.tab",
  header = T, sep = "\t", row.names = 1, check.names = FALSE
)
# Blank the exact zeros only. Do not gsub("0"), which would also eat the
# digit inside 0.9, 0.1 and 0.8 and leave ".9", ".1", ".8" in the table.
disp <- as.data.frame(lapply(p, function(x) ifelse(x == 0, "", as.character(x))),
  check.names = FALSE, row.names = rownames(p)
)
knitr::kable(disp, align = "r")

p <- as.matrix(p)
rowSums(p) %>%
  t() %>%
  knitr::kable()

set.seed(17)
# Sample column s' using probabilities in row s
jump <- function(s) sample(rownames(p), 1, prob = p[s, ])
# Function to generate a trajectory
tr <- function(s, m) {
  traj <- c(s)
  for (i in 1:m) {
    traj <- c(traj, jump(traj[i]))
  }
  return(traj)
}

traj <- t(replicate(6, tr("Pub", 5)))
knitr::kable(traj)

trajR <- apply(traj, 1:2, getR)
disc <- 0.5^(0:5)
trajR %*% disc %>%
  t() %>%
  knitr::kable()

# Value function of a trajectory
value <- function(s, m, gamma = 0.5) {
  traj <- tr(s, m)
  disc <- gamma^(0:m)
  return(sum(sapply(traj, getR) * disc))
}
vpub <- replicate(1000, value("Pub", 6))
hist(vpub, main = "", xlab = "Discounted reward")
mean(vpub)

gamma <- 0.5
V <- solve(diag(nrow(p)) - gamma * p, R[rownames(p), ])
names(V) <- rownames(p)
knitr::kable(t(V), digits = 2)

# ---- MDP for Forest Management ---------------------------------------------

fire <- 0.01
P_forest <- array(0, c(4, 4, 2))
P_forest[cbind(1:4, c(2, 3, 4, 4), 1)] <- 1 - fire  # Wait: the forest grows a year older
P_forest[, 1, 1] <- P_forest[, 1, 1] + fire         # a fire sends it back to state 1
P_forest[, 1, 2] <- 1
R_forest <- cbind(Wait = c(0, 0, 0, 10), Cut = c(0, 1, 1, 1))

value_iteration <- function(P, R, gamma, tol = 1e-10) {
  V <- rep(0, nrow(R))
  repeat {
    Q <- sapply(1:ncol(R), function(a) R[, a] + gamma * P[, , a] %*% V)
    V_new <- apply(Q, 1, max)
    if (max(abs(V_new - V)) < tol) break
    V <- V_new
  }
  list(V = V_new, policy = max.col(Q, ties.method = "first"))
}
vi <- value_iteration(P_forest, R_forest, gamma = 0.9)
cat("Optimal policy:", vi$policy, "\nValues:", sprintf("%.1f", vi$V), "\n")

# ---- Bayesian Optimization -------------------------------------------------

# p must be the predGP output on the grid the caller will index into.
acq <- function(p, fstar) {
  d <- fstar - p$mean
  s <- sqrt(diag(p$Sigma))
  return(s * dnorm(d / s) + d * pnorm(d / s))
}

# ---- Taxi Fleet Optimisation -----------------------------------------------

# [plotgp]
plotgp <- function(x, y, XX, p) {
  q1 <- qnorm(0.05, mean = p$mean, sd = sqrt(diag(p$Sigma)))
  q2 <- qnorm(0.95, mean = p$mean, sd = sqrt(diag(p$Sigma)))
  q3 <- qnorm(0.5, mean = p$mean, sd = sqrt(diag(p$Sigma)))
  ggplot() +
    geom_line(aes(x = XX, y = q3), col = 2, lwd = 2) +
    geom_ribbon(aes(x = XX, ymin = q1, ymax = q2), fill = "blue", alpha = 0.2) +
    geom_point(aes(x = x, y = y), shape = 21, fill = "white", size = 2.5) +
    labs(x = "Number of taxis", y = "Negative profit")
}

# [fig-inittaxi]
library(laGP)
x <- matrix(c(10, 90, 30), ncol = 1)
xx <- seq(1, 100, length = 500)
XX <- matrix(xx, ncol = ncol(x))
profit <- -c(3.1, 3.6, 6.6)
gp <- newGP(x, profit, 1000, 1e-6, dK = TRUE)
p <- predGP(gp, XX)
plotgp(x, profit, XX, p)

nextsample <- function() {
  ei <- acq(p, min(profit))
  plot(xx, ei, type = "l", col = 2, lwd = 2, xlab = "Number of taxis", ylab = "Expected improvement")
  xnext <- as.integer(xx[which.max(ei)])
  return(xnext)
}
updgp <- function(xnext, f) {
  profit <<- c(profit, f)
  x <<- rbind(x, xnext)
  gp <<- newGP(x, profit, 1000, 1e-6, dK = TRUE)
  p <<- predGP(gp, XX)
  plotgp(x, profit, XX, p) + theme_gray(base_size = 8)
}
invisible(nextsample()) # suggests 48; simulator was run at 44
updgp(44, -8.4)
invisible(nextsample()) # suggests 58; simulator was run at 57
updgp(57, -7.1)
invisible(nextsample()) # suggests 45
updgp(45, -8.5)
invisible(nextsample()) # suggests 100
updgp(100, -3.3)

# [fig-stopbayes]
nextsample()
